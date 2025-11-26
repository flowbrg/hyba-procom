clear; close all; clc;
    
%% ----- Paramètres moteur diesel ~800 kW -----
Kth  = 800;          % Gain (puissance nominale en kW)
tau_th = 0.4;      % Constante de temps (s)
Td_th  = 0.02;     % Délai (s)

%% ----- Paramètres moteur électrique ~200 kW -----
Ke  = 200;          % Gain (puissance nominale en kW)
tau_e = 0.01;     % Constante de temps (10 ms)
Td_e  = 0.002;    % Délai (2 ms)

%% ----- Charge -----
J = 10; % Inertie (kg.m²) 10, 100, 1000, 5000

L = tf(1, [J 0]);

%% ----- Retour -----
n_IDL = 600; % Régime nominal (tr/min)
C = 8; % Nombre de cylindres
T = 4; % Nombre de combustions pour une révolution de vilbrequin
tau_ACY = (2*n_IDL*C/T)*(2*pi/60);

alpha = 10; % paramètre de finetuning

inv_L_star = tf([J 0], [alpha*tau_ACY 1]);