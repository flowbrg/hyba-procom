INIT_json2matlab

% Variables modèle coque 
m = 250000; % Masse navire
ma = 123434; % Masse ajoutée


% Variables modèle hélice
rho = 1025; % Masse volumique de l'eau

prop = PROP.Ka3_65_19A_D_2_07;
hull = HULL.Naoned_hull;

x = prop.x;
y = prop.y;
Cxy = prop.Cxy;
Axy = prop.Axy;
wh = hull.wh;
th = hull.th;
D = prop.D;



% Modèle moteur thermique avec temps de réponse désiré de 4s
nmt_nom = 750; % Vitesse rotation nominale du moteur

R = 1/2.953; % Rapport de réduction du moteur diesel seul

tau_mt = 0.4;

%Rt = 1.8; % Résistance moteur thermique %pas utilisé avec nouveau modèle
Jmt = 2.22; % Résistance moteur thermique (kg.m2)

% Modèle moteur thermique avec temps de réponse désiré de 0.4s
% Re = 1.5; % Résistance moteur électrique %pas utilisé avec nouveau modèle
% Je = 0.6; % Résistance moteur electrique %pas utilisé dans la v1



% Modele Transmission
Rmt = 4.6680;
Rme = 6.6080;
eta_mt = 0.4; % Rendement maximal moteur thermique

Jprop = Jmt/R^2;

Pe = 5; %Puissance alternateurs
Py = 60; % valeur en filage car ligne droite
eta_p = 0.5;
eta_r = 0.96;


%Coefficients PID du speed pilot 
kp = 3500;
ki = 700;


%Modèle chalut
Tc = 5.8e3; % poussée du chalut


%Servent à quelque chose ?

eta_b = 1;
