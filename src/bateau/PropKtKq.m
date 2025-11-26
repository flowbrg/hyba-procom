classdef PropKtKq < handle
    % Une classe modélisant un propulseur basée sur le modèle Wageningen Kt-Kq
    % Traduit depuis le code Python HYBA project
    % Original par Sylvain lanneau, 2025 january 14th
    
    properties
        % Entrées constantes
        D = 0.0;    % Diamètre du propulseur
        x = 0.0;    % Puissances P/D
        y = 0.0;    % Puissances J
        Axy = 0.0;  % Coefficients polynomiaux Kt
        Cxy = 0.0;  % Coefficients polynomiaux Kq
        
        % Entrées variables
        u = 0.0;    % Vitesse relative du navire (m/s)
        P = 0.0;    % Pas du propulseur (m)
        nh = 0.0;   % Vitesse de rotation du propulseur (rad/s)
        wh = 0.0;   % Facteur de sillage de la coque
        th = 0.0;   % Facteur de déduction de poussée de la coque
        
        % Sorties
        Th = 0.0;   % Poussée du propulseur (N)
        Qh = 0.0;   % Couple du propulseur (N*m)
        eta = 0.0;  % Rendement du propulseur
    end
    
    methods
        function obj = PropKtKq(varargin)
            % Constructeur avec options de configuration
            % Usage: prop = Propeller('D', 2.0, 'x', x_array, ...)
            
            % Traitement des arguments d'entrée
            if nargin > 0
                for i = 1:2:nargin
                    if isprop(obj, varargin{i})
                        obj.(varargin{i}) = varargin{i+1};
                    else
                        warning('Propriété %s non reconnue', varargin{i});
                    end
                end
            end
        end
        
        function compute(obj)
            % Calcule les variables de sortie à partir des entrées
            
            % Conversion rad/s en tr/s pour les calculs
            Nh = obj.nh/(2*pi);
            
            % Coefficient d'avance et rapport P/D
            J = obj.u*(1-obj.wh)/(obj.D*Nh);
            P_D = obj.P/obj.D;
            
            % Calcul des coefficients Kt et Kq pour ce point de fonctionnement
            Kt = dot(obj.Axy, P_D.^obj.x .* J.^obj.y);
            Kq = dot(obj.Cxy, P_D.^obj.x .* J.^obj.y);
            
            % Les valeurs négatives sont mises à 0 pour éviter des poussées ou couples négatifs
            if Kt < 0.0
                Kt = 0.0;
                obj.eta = 0.0;
            end
            
            if Kq < 0.0
                Kq = 0.0;
                obj.eta = 0.0;
            else
                obj.eta = J*Kt/(Kq*2*pi);
            end
            
            % Calcul de la poussée
            rho = 1025; % masse volumique de l'eau (kg/m^3)
            obj.Th = (1-obj.th)*Kt*rho*obj.D^4*Nh^2;
            obj.Qh = Kq*rho*obj.D^5*Nh^2;
            
            % Décommentez pour afficher les informations de diagnostic
            %{
            disp('-Propeller speaking-');
            disp(['u: ', num2str(obj.u)]);
            disp(['nh: ', num2str(obj.nh)]);
            
            disp(['P: ', num2str(obj.P)]);
            disp(['D: ', num2str(obj.D)]);
            disp(['P/D: ', num2str(P_D)]);
            disp(['J: ', num2str(J)]);
            disp(['Kt: ', num2str(Kt)]);
            
            disp(['Th: ', num2str(obj.Th)]);
            disp(['Qh: ', num2str(obj.Qh)]);
            disp(['th: ', num2str(obj.th)]);
            disp(['wh: ', num2str(obj.wh)]);
            disp('--------------------');
            %}
        end
    end
end