clear all;
close all;
clc;

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