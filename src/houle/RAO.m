clear all;
close all;
clc;

% =======================
% PARAMÈTRES DE LA HOULE
% =======================
w = linspace(0.1, 10, 500);  % vecteur de fréquences (rad/s)
Hs = 2;                      % hauteur significative (m)
w0 = 1.4;                    % pulsation dominante (rad/s)
T0 = 2*pi/w0;                % période de pic (s)

figure;
S = wavespec(3, [Hs, T0], w, 1);  % spectre MPM (type=3)
plot(w, S, 'LineWidth', 1.2)
title('Spectre MPM centré sur \omega_0', 'FontSize', 14, 'FontWeight', 'bold')
xlabel('\omega (rad/s)', 'FontSize', 12)
ylabel('S(\omega)', 'FontSize', 12)
grid on

% ============================
% FILTRE DE HOULE (Fossen 8.5)
% ============================
lambda = 0.26;                       % amortissement spectral recommandé
sigma = sqrt(max(S));                % intensité spectrale
Kw = 2*lambda*w0*sigma;              % gain du filtre (cf. eq. 8.116)

% Fonction de transfert de la houle (eq. 8.112)
num = [Kw 0];                        
den = [1 2*lambda*w0 w0^2];         
H_wave = tf(num, den);               % filtre générateur de houle
disp('Filtre de houle H_wave(s):');
H_wave

% Représentation d'état (eq. 8.120–8.123)
A = [0       1;
    -w0^2  -2*lambda*w0];
B = [0; Kw];
C = [0 1];
D = 0;
sys_wave = ss(A,B,C,D);

% Simulation houle (entrée : bruit blanc)
dt = 0.05; 
t = 0:dt:100;                        % horizon de simulation
wn = randn(size(t));                 % bruit blanc d'entrée
eta = lsim(sys_wave, wn, t);         % élévation de houle (m)
figure;
plot(t, eta, 'b');
xlabel('t (s)'); ylabel('\eta (m)');
title('Élévation de la surface libre simulée');
grid on;

% ======================================
% RAO APPROXIMATIF (2e ORDRE)
% ======================================
% Force longitudinale F(ω) normalisée (dimensionless)
Krao = 0.3;      % gain du RAO
wR   = 0.8;      % pulsation de résonance du surge (rad/s)
zeta = 0.25;     % amortissement du RAO

% Fonction de transfert RAO (surge)
numR = [Krao*(wR^2)];                     % gain à la résonance
denR = [1 2*zeta*wR wR^2];                % dénominateur standard
H_RAO = tf(numR, denR);                   % RAO (normalisé)

disp('RAO approximatif F_wave1(s):');
H_RAO
figure
bode(H_RAO)

% ==========================================
% CHAÎNE COMPLÈTE : BRUIT BLANC → HOULE → FORCE
% ==========================================
% Force = ρ g * F_RAO(s) * H_wave(s) * w(t)
rho = 1025; g = 9.81;
H_force = rho * g * series(H_RAO, H_wave);   % composition série

disp('Chaîne complète H_force(s):');
H_force

% Simulation : entrée = bruit blanc (même que précédemment)
tau = lsim(H_force, wn, t);                 % force longitudinale (N)
figure;
plot(t, tau, 'r');
xlabel('t (s)'); ylabel('\tau_{wave,1} (N)');
title('Force longitudinale de houle (approximation 2ᵉ ordre)');
grid on;

% =====================
% ANALYSE RAPIDE
% =====================
figure;
pspectrum(tau, 1/dt);
title('Densité spectrale de la force longitudinale');

% Facultatif : comparer spectres houle/force
figure;
[Sw, f] = pwelch(eta, [], [], [], 1/dt);
[Sf, ~] = pwelch(tau, [], [], [], 1/dt);
plot(2*pi*f, Sw/max(Sw), 'b', 2*pi*f, Sf/max(Sf), 'r');
xlabel('\omega (rad/s)');
ylabel('Spectres normalisés');
legend('\eta(t)', '\tau_{wave,1}(t)');
title('Comparaison spectrale houle / force');
grid on;
