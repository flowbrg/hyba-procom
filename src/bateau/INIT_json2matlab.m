addpath('./JSON_MODEL/');

%% Importation modèle d'Hélice
fname = 'propellers.json';
fid = fopen(fname); 
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
PROP = jsondecode(str);


%% Importation modèle de coque
fname = 'hulls.json';
fid = fopen(fname); 
raw = fread(fid,inf); 
str = char( ...
    raw'); 
fclose(fid); 
HULL = jsondecode(str);

 % Resistance (N)
 %HULL.Naoned_hull.u = [0:0.1:3];
 
 %HULL.Naoned_hull.Rt = HULL.Naoned_hull.corr * polyval(HULL.Naoned_hull.p, HULL.Naoned_hull.u)
 %Avoid negative values
 % HULL.Naoned_hull.Rt = max(0.0,self.Rt)
        
 % Acceleration (m/s^2)
 % HULL.Naoned_hull.u_dot = (HULL.Naoned_hull.Th - HULL.Naoned_hull.Rt - HULL.Naoned_hull.Tc) / (HULL.Naoned_hull.m + HULL.Naoned_hull.mA)
   
%% Importation cartographie moteur thermique 
fname = 'thermal_engines.json';
fid = fopen(fname); 
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
MTH = jsondecode(str);

%mesh(MTH.Mitsubishi_S6R2.speed,MTH.Mitsubishi_S6R2.torque,MTH.Mitsubishi_S6R2.eff_map);

%% Importation cartographie moteur électrique
fname = 'electrical_engines.json';
fid = fopen(fname); 
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
MELEC = jsondecode(str);

%mesh(MELEC.Bosch_EMP1_13H20_EDS1_L0600.speed,MELEC.Bosch_EMP1_13H20_EDS1_L0600.torque,MELEC.Bosch_EMP1_13H20_EDS1_L0600.eff_map)

%% Importation Batterie
fname = 'batteries.json';
fid = fopen(fname); 
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
BAT = jsondecode(str);

%% Importation réducteurs
fname = 'gearboxes_el.json';
fid = fopen(fname); 
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
GEAR_EL = jsondecode(str);

fname = 'gearboxes_th.json';
fid = fopen(fname); 
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
GEAR_TH = jsondecode(str);

%% Importation générateurs
fname = 'generators.json';
fid = fopen(fname); 
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
GENE = jsondecode(str);

%% Importation réservoir
fname = 'tanks.json';
fid = fopen(fname); 
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
TANK = jsondecode(str);

%% Importation Chalut
fname = 'gears.json';
fid = fopen(fname); 
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
GEAR = jsondecode(str);

%% Importation du régulateur de vitesse
fname = 'controllers.json';
fid = fopen(fname); 
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
CONTR = jsondecode(str);

%% Importation des scènes
fname = 'scenes.json';
fid = fopen(fname); 
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
SCENES = jsondecode(str);

fname = 'scenes_pelagic_hake.json';
fid = fopen(fname); 
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
SCENES_PEL = jsondecode(str);

% Construction des vecteurs de données
% Définition du profil de vitesse et d'activation du chalut
SC9kn=SCENES.nav_9_knots_10_min;
t_9kn_10m = [1:SC9kn.driver_dt:SC9kn.driver_duration];
u_9kn_10m = [0 SC9kn.speed_pilot_du/4 SC9kn.speed_pilot_du/2 SC9kn.speed_pilot_du*3/4 SC9kn.speed_pilot_du*ones(1,length(t_9kn_10m)-4)];
g_9kn_10m = [SC9kn.gear_active*ones(1,length(t_9kn_10m))];
%plot(t_9kn_10m,u_9kn_10m)

SC7kn=SCENES.nav_7_knots_10_min;
t_7kn_10m = [t_9kn_10m(end)+1:SC7kn.driver_dt:SC9kn.driver_duration+SC7kn.driver_duration];
u_7kn_10m = [SC9kn.speed_pilot_du*4/5 SC7kn.speed_pilot_du*ones(1,length(t_7kn_10m)-1)];
g_7kn_10m = [SC7kn.gear_active*ones(1,length(t_7kn_10m))];
%hold on
%plot(t_7kn_10m,u_7kn_10m,'r--')

SC35fkn=SCENES.fishing_3_5_knots_10_min;
t_35kn_10m = [t_7kn_10m(end)+1:SC35fkn.driver_dt:SC9kn.driver_duration+SC7kn.driver_duration+SC35fkn.driver_duration];
u_35kn_10m = [SC7kn.speed_pilot_du*3/4 SC35fkn.speed_pilot_du*ones(1,length(t_35kn_10m)-1)];
g_35kn_10m = [SC35fkn.gear_active*ones(1,length(t_35kn_10m))];

% Construction du scénario
%t_sc = [t_9kn_10m t_7kn_10m t_35kn_10m];
%u_sc = [u_9kn_10m u_7kn_10m u_35kn_10m];
%g_sc = [g_9kn_10m g_7kn_10m g_35kn_10m];
%t_sc = [t_9kn_10m t_7kn_10m];
%u_sc = [u_9kn_10m u_7kn_10m];
%g_sc = [g_9kn_10m g_7kn_10m];
t_sc = [t_9kn_10m ];
u_sc = [u_9kn_10m ];
g_sc = [g_9kn_10m ];
% plot(t_sc,u_sc,'k',t_sc,g_sc,'r--');