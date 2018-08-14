classdef DeclusterWindowingMethods < int32
    % methods used for declustering a catalog
    % for a complete list
    % >> enumeration('DeclusterWindowingMethods')
    enumeration
        GardinerKnopoff1974     (1) % Gardener & Knopoff, 1974
        GruenthalPersCom        (2) % Gruenthal pers. communication
        Urhammer1986            (3) % Urhammer, 1986
        % Gruenthal1985           (4) % Gruenthal, 1985 (from Figure)
        % ModifiedYoungs1987Max   (5) % Modified Youngs, 1987 Maximum window
        % ModifiedYoungs1987Min   (6) % Modified Youngs, 1987 Minimum window
    end
    
    methods(Static)
        function s = description(val)
            
            switch DeclusterWindowingMethods(val)
                case DeclusterWindowingMethods.GardinerKnopoff1974
                    s = "Gardener & Knopoff, 1974";
                case DeclusterWindowingMethods.GruenthalPersCom
                    s = "Gruenthal pers. communication";
                case DeclusterWindowingMethods.Urhammer1986
                    s = "Urhammer, 1986";
            end
        end
    end
end