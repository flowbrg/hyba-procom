%Variables modèle coque 
m = 250000 %masse navire
Ma = 123434 %masse ajoutée


%Variables modèle hélice
rho = 1025 %Masse volumique de l'eau
x = prop.x;
y = prop.y;
Cxy = prop.Cxy;
Axy = prop.Axy;
wh = hull.wh;
th = hull.th;
D = prop.D;



%Modèle moteur thermique avec temps de réponse désiré de 4s
nmt_nom = 750 %Vitesse rotation nominale du moteur


Rt = 1.8 %résistance moteur thermique
Jt = 2.22 %resistance moteur thermique

%Modèle moteur thermique avec temps de réponse désiré de 0.4s
Re = 1.5 %résistance moteur électrique
Je = 0.6 %resistance moteur electrique



%Modele Transmission
Rmt = 4.6680;
Rme = 6.6080;

eta_m = 0.4 %rendement maximal moteur thermique
R = 1/2.953;
Pyf = 60;
Pyv = 180;
eta_p = 0.5;
eta_r = 0.96;
Pe = 5;

%Coefficients PID du speed pilot 
kp = 3500;
ki = 700;
kd = 0;


eta_b = 1

%Modèle chalut
Tc = 1 % poussée du chalut


