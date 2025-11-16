clear all;
close all;
clc;


w = linspace(0.1, 10, 500);  % vecteur de fréquences (rad/s)
Hs = 2;  % hauteur significative (m)
w0 = 1.4; %pulsation dominante 
T0 = 2*pi/w0;    % période de pic (s)

figure 
S = wavespec(3, [Hs, T0], w, 1);
plot(w, S)
title('MPM centré sur w0', 'FontSize', 14, 'FontWeight', 'bold')
xlabel('w(rad/s)', 'FontSize', 12)
ylabel('S(w)', 'FontSize', 12)


% Paramètres du spectre
Hs = 2;          % hauteur significative (m)
lambda =0.26;    % coefficient d’amortissement spectral recommandé par le livre pour wo=1.4
sigma=sqrt(max(S)) ;     % intensité du spectre 
Kw = 2*lambda*w0*sigma;  % gain du filtre



%fonction de transfert pour le modèle de la houle 

num = [Kw 0];                 % numérateur : Kw*s
den = [1 2*lambda*w0 w0^2];  % dénominateur : s²+2λω0s+ω₀²
H = tf(num, den)


% Matrices d'état (Fossen eq. 8.120–8.123)
A = [0       1;
    -w0^2  -2*lambda*w0];
B = [0; Kw];
C = [0 1];
D = 0;

% Création du modèle 
sys_wave = ss(A,B,C,D);
