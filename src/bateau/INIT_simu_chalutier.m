clc; clear; close all;

warning('off', 'MATLAB:interp2:NaNstrip');

%% Charger modèle des organes du navire, et scénario de navigation (vitesse,gear)
    % Chargement des bases de données d'organes
    % les profils de temps, vitesse, et activation chalut sont :
    % t_sc,   u_sc,   g_sc
    INIT_json2matlab;
    Ts = 1;                     % Pas d'échantillonnage de la simulation Ts = 1s
    N = length(t_sc);           % Durée du scénario

    % Choix de chaque organe spécifique
        % Coque
        hull = Hulldyn('p', HULL.Naoned_hull.p, 'corr', HULL.Naoned_hull.corr,'corr_mass', HULL.Naoned_hull.corr_mass, 'wh', HULL.Naoned_hull.wh, 'th', HULL.Naoned_hull.th,'m',HULL.Naoned_hull.m,'mA', HULL.Naoned_hull.mA);

        % Hélice
        prop = PropKtKq('D', PROP.Ka4_55_19A_D_2_07.D, 'x', PROP.Ka4_55_19A_D_2_07.x, 'y', PROP.Ka4_55_19A_D_2_07.y, 'Axy', PROP.Ka4_55_19A_D_2_07.Axy, 'Cxy', PROP.Ka4_55_19A_D_2_07.Cxy);

        % Réducteurs électrique et thermique
        gear_el = GEAR_EL.PTI_6_608;
        gear_th = GEAR_TH.MM_W5700_4_668;
        
        % Rapports de réduction
        R_th = gear_th.R;  % Rapport de réduction pour moteur thermique
        R_el = gear_el.R;  % Rapport de réduction pour moteur électrique

        % Moteur Thermique
        mth = MTH.Mitsubishi_S6R2;
        %Pmth= (mth.speed*2*pi/60)*mth.torque';
        [Speed_grid, Torque_grid] = meshgrid(mth.speed, mth.torque);
        Pmth = (Torque_grid .* Speed_grid) / 9549*1000; % Puissance en W

        %[i, j] = find(isnan(mth.eff_map));
        %masq = not(isnan(mth.eff_map));
        %Pmth = Pmth.*masq;
        Pmax_MTH  = max(max(Pmth));                        
        Pmin_MTH  = 50000;     

        % Moteur électrique
        mel = MELEC.Dana_650V_HP_HV1000;    %MELEC.Bosch_EMS1_16J20_EDS1_L0600;
        %mel = MELEC.Bosch_EMS1_16J20_EDS1_L0600;
        %mel.eff_map = mel.eff_map(1:end-1,:);
        %mel.eff_map(1,:)=mel.eff_map(2,:);          % Retouche de la cartographie car valeur à couple nulle trop faible (abherrant ?).
        mel.eff_map = transpose(mel.eff_map);                         
        %mel.torque  = mel.torque(1:end-1);
        [Speed_grid_mel, Torque_grid_mel] = meshgrid(mel.speed, mel.torque);
        Pmel = (Torque_grid_mel .* Speed_grid_mel) / 9549*1000; % Puissance en W
        MPmel = (mel.speed*2*pi/60).*mel.torque';
        %[i, j] = find(isnan(mel.eff_map));
        masq = not(isnan(mel.eff_map));
        Pmel = Pmel.*masq;
        Pmax_MELEC  = max(max(Pmel));                        
        Pmin_MELEC  = -Pmax_MELEC;  

        % Extension par symétrie pour les couples négatifs
        mel.torque = [-fliplr(mel.torque(2:end)'), mel.torque']';
        mel.eff_map = [fliplr(mel.eff_map(:,2:end)), mel.eff_map]';

        %figure(4);
        %surf(mel.speed, mel.torque, mel.eff_map);
        %xlabel('RPM');
        %ylabel('Torque');
        %zlabel('Efficiency');
        %title('Cartographie moteur/générateur');

        % Générateur
        gene = GENE.standard;

        % Réservoir
        tank = TANK.x30m3;

        % Batterie
        batt = BAT.Lehmann_AN25106;
        batt.Q0 = 1000*1000;

        % Chalut
        gear = GEAR.Pelagic_hake;

        % Pilote (régulateur de vitesse)
        contr = CONTR.PID_speed_pilot;
        contr.ki = 0.002;
        contr.kp = 5;

%% 2. Construction de la demande de propulsion le long du scénario (vitesse,gear)

% En boucle fermée : le pilote (PI) suit le profil de vitesse désirée,
    % et on applique l'équation dynamique de la coque obj.u_dot = (obj.Th - obj.Rt - obj.Tc) / (obj.m + obj.mA);
    % Initialisation de l'état du modèle de coque
    hull.u = 0;
    hull.u_dot = 0;
    hull.Th = 0;

    % Initialisation de l'état de l'hélice
    % Calcul des vitesses de rotation pour chaque instant - imposé par le MTH
    rpm_MTH     = 1300*ones(1,length(t_sc));   % Vitesse de rotation du MTH
    rpm_prop    = rpm_MTH / R_th;              % Vitesse de rotation de l'hélice
    rpm_MELEC   = R_el * rpm_prop;             % Vitesse de rotation du MEL
    prop.nh     = rpm_prop(1)*2*pi/60;

    % Limitation du pas
    P_min = 0;                % Pas minimum
    P_max = prop.D;           % Pas maximum

    % Définition des variables de stockage pour tracer de débuggage
    %Th_des      = zeros(1,length(t_sc));
    acc_hull    = zeros(1,length(t_sc));
    u_hull      = zeros(1,length(t_sc));
    P_hel       = zeros(1,length(t_sc));   % Pas de l'hélice (nouvelle sortie PID)
    Th_des     = zeros(1,length(t_sc));   % Poussée réelle (calculée par l'hélice)
    eta_hel     = zeros(1,length(t_sc));   % Rendement de l'hélice
    Qh_hel      = zeros(1,length(t_sc));   % Couple de l'hélice
    
    for t=1:length(t_sc)
        P_desired = pi_contr(contr.kp,contr.ki,u_sc(t),hull.u,Ts);
        
        % Limitation du pas dans les bornes physiques
        P_current = max(P_min, min(P_max, P_desired));
        P_hel(t)  = P_current;

        % Configuration de l'hélice pour ce pas de temps
        prop.P = P_current;           % Pas de l'hélice
        prop.u = hull.u;              % Vitesse du navire
        prop.wh = hull.wh;            % Facteur de sillage
        prop.th = hull.th;            % Facteur de duction

        % 3. Calcul des performances de l'hélice
        prop.compute();
    
        % 4. Récupération des sorties de l'hélice
        Th_des(t)   = prop.Th;        % Poussée réelle
        eta_hel(t)  = prop.eta;       % Rendement
        Qh_hel(t)   = prop.Qh;        % Couple
    
        % 5. Application de la poussée à la coque
        hull.Th = prop.Th;            % La poussée vient maintenant de l'hélice
    
        % 6. Calcul de la résistance externe (inchangé)
        hull.Tc = 0*10000 * sin(2*pi*0.1*t);
    
        % 7. Calcul de la dynamique de coque
        hull.compute();
    
        % 8. Sauvegarde des résultats
        acc_hull(t) = hull.u_dot;
    
        % 9. Intégration pour le pas suivant
        hull.u = hull.u + hull.u_dot * Ts;
        u_hull(t) = hull.u;   
    end

    % figure(1)
    % subplot(2,1,1)
    % plot(t_sc,u_sc,'k',t_sc,u_hull,'r--')
    % legend('u désiré (m/s)','u mesuré (m/s)')
    % subplot(2,1,2)
    % plot(t_sc,Th_des,'r--')
    % legend('Poussée Th (N)')
    % xlabel('temps (s)');

    % Affichage des résultats
    figure(11)
    subplot(2,3,1)
    plot(t_sc,u_sc,'k',t_sc,u_hull,'r--')
    legend('u désiré (m/s)','u mesuré (m/s)')
    xlabel('Temps (s)')
    ylabel('Vitesse (m/s)')
    title('Vitesse réelle vs consigne')
    grid on

    subplot(2,3,2)
    plot(t_sc, P_hel, 'g-', 'LineWidth', 2)
    xlabel('Temps (s)')
    ylabel('Pas hélice (m)')
    title('Pas helice')
    grid on

    subplot(2,3,3)
    plot(t_sc, Th_des/1000, 'b-', 'LineWidth', 2)
    xlabel('Temps (s)')
    ylabel('Poussée (kN)')
    title('Poussée helice')
    grid on

    subplot(2,3,4)
    plot(t_sc, eta_hel, 'r-', 'LineWidth', 2)
    xlabel('Temps (s)')
    ylabel('Rendement (%)')
    title('Rendement helice')
    grid on

    subplot(2,3,5)
    plot(t_sc, Qh_hel/1000, 'm-', 'LineWidth', 2)
    xlabel('Temps (s)')
    ylabel('Couple (kN.m)')
    title('Couple helice')
    grid on

    subplot(2,3,6)
    plot(t_sc,(Th_des.*u_hull)./1000,'k',t_sc,eta_hel.*Qh_hel.*rpm_prop*2*pi/60./1000,'r--')
    xlabel('Temps (s)')
    ylabel('Puissance (kW)')
    title('Puissances coque et puissance hélice après rendement')
    legend('Puissance coque (kW)','Puissance hélice avec rendement (kW)')
    grid on

    % Construction du flux de puissance de propulsion désirée
    % BETA TEST : ON NE MODELISE PAS L'HELICE !!!
    %P_des             = transpose(Th_des.*u_hull);
    P_des              = transpose(eta_hel.*Qh_hel.*rpm_prop*2*pi/60);
    P_des(P_des < 0)  = 0;    % Pas de frein moteur pour un bateau
    

