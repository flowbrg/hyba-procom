clc; clear; 

Rm = 1/2.9; % Rapport de réduction du moteur thermique
eta_m = 0.4; % Rendement maximal moteur thermique
eta_r = 0.96; % Rendement de la chaine de transmission

Jm = 2.2; % Inertie du moteur thermique (kg.m2)
Jprop = Jm/Rm^2; % Inertie du moteur après réduction
B = 1/eta_m; % frottement visqueux Qf = Bw

tau_f = 0.2; % temps caractéristique de l'actionneur (s)

Kpm = 8.7; % Coefficient proportionnel du régulateur du moteur thermique
Kim = 4.4; % Coefficient intégral du régulateur du moteur thermique