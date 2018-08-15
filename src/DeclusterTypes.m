classdef DeclusterTypes < int32
    %
    % types of clustering, scraped from MonteDeclus
    
    enumeration
        Reasenberg                  (1) %   matlab
        Gardner_Knoppoff            (2)  %   zmap
        Stochastic                  (3)
        Reasenberg_cluster200x      (4) % cluster200x fortran
        Marsan                      (5) % Model-independent stochastic declustering (misd)"
        Gardner_Knopoff_clusterGK   (6) % (From Annemarie's codes)
        Uhrhammer                   (7) % (From Annemarie's codes)
        Utsu                        (8) % (From Annemarie's codes)
    end
    
    methods(Static)
        function s = description(dt)
            switch dt
                case DeclusterTypes.Reasenberg
                    s = "Reasenberg declustering (Matlab-Code)";
                case DeclusterTypes.Gardner_Knoppoff
                    s = "Gardner & Knoppoff  (zmap)";
                case DeclusterTypes.Stochastic
                    s = "Stochastic Declustering";
                case DeclusterTypes.Reasenberg_cluster200x
                    s = "Reasenberg Declustering (cluster200x) [fortran]";
                case DeclusterTypes.Marsan
                    s = "Marsan (Model-independent stochastic declustering (misd)";
                case DeclusterTypes.Gardner_Knopoff_clusterGK
                    s = "Gardner and Knopoff (From Annemarie's codes)";
                case DeclusterTypes.Uhrhammer
                    s = "Uhrhammer (From Annemarie's codes)";
                case DeclusterTypes.Utsu
                    s = "Utsu (From Annemarie's codes)";
            end
        end
    end
end
