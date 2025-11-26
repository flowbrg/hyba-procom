classdef Hulldyn < handle
    % Un modèle dynamique de coque
    %
    % HYBA project
    % Traduit de Python vers MATLAB
    % Basé sur le travai original de Sylvain lanneau
    % 2025 janvier 14
    
    properties
        % Constantes d'entrée
        p = [0;0;0;0];      % Coefficients polynomiaux de la résistance de coque
        corr = 1.0;         % Coefficient de correction pour la résistance de coque
        corr_mass = 0.0;    % Coefficient de correction pour la résistance de coque, multiplie la masse totale du navire
        mA = 0.0;           % Masse ajoutée
        
        % Variables d'entrée
        Th = 0.0;           % Poussée de l'hélice (N)
        Tc = 0.0;           % Résistance de l'engrenage (N)
        u = 0.0;            % Vitesse relative du navire (m/s)
        m = 0.0;            % Masse du navire (kg)
        
        % Sorties
        u_dot = 0.0;        % Accélération relative du navire (m/s^2)
        Rt = 0.0;           % Résistance de la coque (N)
        wh = 0.0;           % Facteur de sillage
        th = 0.0;           % Facteur de déduction de poussée
    end
    
    methods
        function obj = Hulldyn(varargin)
            % Constructeur avec paramètres optionnels
            % Utilise une structure de paires nom-valeur
            
            % Traitement des arguments optionnels
            for i = 1:2:length(varargin)
                if isprop(obj, varargin{i})
                    obj.(varargin{i}) = varargin{i+1};
                end
            end
        end
        
        function compute(obj)
            % Calcule les variables de sortie
            
            % Résistance (N)
            obj.Rt = obj.corr * polyval(obj.p, obj.u);
            % Note: Dans l'original il y a un commentaire pour éviter les valeurs négatives
            % obj.Rt = max(0.0, obj.Rt);
            
            % Accélération (m/s^2)
            obj.u_dot = (obj.Th - obj.Rt - obj.Tc) / (obj.m + obj.mA);
            
            % Décommenter pour déboguer
            %{
            disp('-Hull speaking-');
            disp(['p: ', mat2str(obj.p)]);
            disp(['corr: ', num2str(obj.corr)]);
            disp(['u_dot: ', num2str(obj.u_dot)]);
            disp(['u: ', num2str(obj.u)]);
            disp(['Rt: ', num2str(obj.Rt)]);
            disp(['Th: ', num2str(obj.Th)]);
            disp(['Tc: ', num2str(obj.Tc)]);
            disp(['th: ', num2str(obj.th)]);
            disp(['wh: ', num2str(obj.wh)]);
            disp(['m: ', num2str(obj.m)]);
            disp('---------------');
            %}
        end
    end
end