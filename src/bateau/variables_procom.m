INIT_json2matlab

%% ----- Coque ----- 
m = 250000; % Masse du navire
ma = 123434; % Masse ajoutée


%% ----- Hélice -----
rho = 1025; % Masse volumique de l'eau

prop = PROP.Ka3_65_19A_D_2_07;  % Initialisation du modèle d'hélice
hull = HULL.Naoned_hull;        % Inialisation de la géométrie de la coque

x = prop.x;
y = prop.y;
Cxy = prop.Cxy;
Axy = prop.Axy;
wh = hull.wh;
th = hull.th;
D = prop.D;


%% ----- Moteur thermique (Tm = 4s) -----

% Actionneur
tau_f = 0.2;    % temps caractéristique de l'actionneur (s), temps de
                % variation entre la commande et l'action du couple

% Réducteur
Rm = 1/2.9; % Rapport de réduction du moteur thermique

% Inertie
eta_m = 0.4; % Rendement maximal moteur thermique
Jm = 2.22; % Inertie du moteur thermique (kg.m2)
Jprop = Jm/Rm^2; % Inertie du moteur après réduction
B = 1/eta_m;    % frottement visqueux Qf = Bw, On fait l'hypothèse que les
                % dissipations sont à l'origine du rendement de 0.4

% Coefficients du régulateur du moteur, choisis tels que le temps de
% variation du moteur diesel soit d'environ 4s.
Kpm = 17.7; % Coefficient proportionnel du régulateur du moteur thermique
Kim = 23.2; % Coefficient intégral du régulateur du moteur thermique

%Rt = 1.8; % Résistance moteur thermique %pas utilisé avec nouveau modèle

%% ----- Moteur électrique (Te = 0.4s) -----
% Re = 1.5; % Résistance moteur électrique
% Je = 0.6; % Résistance moteur electrique



%% ----- Powertrain -----
Rmt = 4.6680;
Rme = 6.6080;

Pe = 5; % Puissance des alternateurs
Py = 60; % Puissance hydraulique des pompes de filage
eta_p = 0.5; 
eta_r = 0.96;

%% ----- Speed Pilot -----
kp = 3500;  % Coefficient proportionnel
ki = 700;   % Coefficient intégral

%% ----- Chalut -----
Tc = 5.8e3; % Coefficient de thrust


%Servent à quelque chose ?

eta_b = 1;
