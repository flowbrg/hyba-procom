clc; clear;

INIT_json2matlab;

%% ----- Coque ----- 
m = 250000; % Masse du navire
ma = 123434; % Masse ajoutée


%% ----- Hélice -----
rho = 1025; % Masse volumique de l'eau

prop = PROP.Ka4_55_19A_D_2_07;  % Initialisation du modèle d'hélice
hull = HULL.Naoned_hull;        % Inialisation de la géométrie de la coque

x = prop.x;
y = prop.y;
Cxy = prop.Cxy;
Axy = prop.Axy;
wh = hull.wh;
th = hull.th;
D = prop.D;

%% ----- Moteur thermique -----

% Actionneur
tau_f = 0.2;    % temps caractéristique de l'actionneur (s), temps de
                % variation entre la commande et l'action du couple

% Réducteur
Rm = 1/2.9; % Rapport de réduction du moteur thermique

% Inertie
eta_m = 0.4; % Rendement maximal moteur thermique
Jm = 2.22; % Inertie du moteur thermique (kg.m2)
Jprop = Jm/Rm^2; % Inertie du moteur après réduction
B = 0;  % frottement visqueux Qf = Bw, On fait l'hypothèse que les
        % dissipations sont à l'origine du rendement de 0.4

% Coefficients du régulateur du moteur, choisis tels que le temps de
% variation du moteur diesel soit d'environ 4s.
Kpm = 0; % Coefficient proportionnel du régulateur du moteur thermique
Kim = 60; % Coefficient intégral du régulateur du moteur thermique

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
Kp = 3; % 3500;  % Coefficient proportionnel
Ki = 0.1; % 700;   % Coefficient intégral

%% ----- Chalut -----
Tc = 5.8e4; % Coefficient de traction
% polynome dans GEAR.Pelagic_hake.p

%% ----- Houle -----

rho = 1025; g = 9.81;

% Spectre de houle
w = linspace(0.1, 10, 500);  % vecteur de fréquences (rad/s)
Hs = 2;                      % hauteur significative (m)
w0 = 1.4;                    % pulsation dominante (rad/s)
T0 = 2*pi/w0;                % période de pic (s)

S = waveSpectrum(3, [Hs, T0], w, 1);  % spectre MPM (type=3)

lambda = 0.26;                       % amortissement spectral recommandé
sigma = sqrt(max(S));                % intensité spectrale
Kw = 2*lambda*w0*sigma;              % gain du filtre (cf. eq. 8.116)

% RAO
Krao = 1e2;      % gain du RAO
wR   = 0.8;      % pulsation de résonance (rad/s)
zeta = 0.25;     % amortissement du RAO
