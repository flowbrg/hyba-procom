function u = pi_contr(Kp, Ki, y_r, y_m, Ts)
    % Régulateur PI simple
    %
    % Entrées:
    %   Kp  - Gain proportionnel
    %   Ki  - Gain intégral
    %   y_r - Signal de référence
    %   y_m - Signal de mesure
    %   Ts  - Pas d'échantillonnage (s)
    %
    % Sortie:
    %   u   - Signal de commande
    %
    % Utilisation:
    %   Cette fonction doit être appelée de manière répétée dans une boucle
    %   La variable persistante 'integral_sum' maintient l'état de l'intégrateur
    %
    % Exemple d'utilisation:
    %   clear pi_controller  % Reset de l'intégrateur au début
    %   for k = 1:N
    %       u(k) = pi_controller(Kp, Ki, reference(k), measurement(k), Ts);
    %   end
    
    % Variable persistante pour stocker la somme intégrale
    persistent integral_sum
    
    % Initialisation de la somme intégrale à la première exécution
    if isempty(integral_sum)
         integral_sum = 0;
     end
     
    % Calcul de l'erreur
    error = y_r - y_m;
    
    % Terme proportionnel
    P_term = Kp * error;
    
    % Mise à jour de la somme intégrale (méthode d'Euler)
    integral_sum = integral_sum + error * Ts;
    
    % Terme intégral
    I_term = Ki * integral_sum;
    
    % Signal de commande PI
    u = P_term + I_term;
    
end