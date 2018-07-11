classdef McMethods < uint32
    % McMethods provides the list of methods usable throughout Zmap
    % for a complete list of valid types, type 
    % >>  enumeration('McMethods')
    
    enumeration
        FixedMc         (2)
        MaxCurvature    (1)
        Mc90            (3)
        Mc95            (4)
        McBestCombo     (5) % Mc90, Mc95, or MaxCurvature
        McEMR           (6)
        McDueB_ShiBolt  (7)
        McDueB_Bootstrap (8)
        McDueB_Cao      (9)
    end
    
    methods(Static)
        function s = describe(val)
            switch val
                case McMethods.FixedMc
                    s="Calculate Mc based on Minimum magnitude in catalog";
                case McMethods.MaxCurvature
                    s="Calculate Mc Based on the point of maximum curvature of the frequency magnitude distribution";
                case McMethods.Mc90
                    s="Calculate Mc Based on 90% probablity";
                case McMethods.Mc95
                    s="Calculate Mc Based on 95% probablity";
                case McMethods.McBestCombo % Mc90, Mc95, or MaxCurvature
                    s="Calculate Mc Best combination, from Mc90, Mc95, and MaxCurvature";
                case McMethods.McEMR
                    s="Calculate Mc using the Entire Magnitude Range (EMR) method";
                case McMethods.McDueB_ShiBolt
                    s="Calculate Mc using the function b-value vs. cut-off-magnitude.  "+...
                        "Decision criterion for b and Mc: b_i-std_Shi(b_i) <= b_ave <= b_i+std_Shi(b_i)";
                case McMethods.McDueB_Bootstrap
                    s="Calculate Mc using the function b-value vs. cut-off-magnitude: Bootstrap approach";
                case McMethods.McDueB_Cao
                    s="Calculate Mc using the function b-value vs. cut-off-magnitude";
                otherwise
                    error('invalid')
            end
        end
        function s = taggeddescription(val)
            switch val
                case McMethods.FixedMc
                    s="<html><b>FixMc</b> : min. magnitude";
                case McMethods.MaxCurvature
                    s="<html><b>MaxCurvature</b> : Max. curvature";
                case McMethods.Mc90
                    s="<html><b>Mc90</b> : (90% probability)";
                case McMethods.Mc95
                    s="<html><b>Mc95</b> : (95% probability)";
                case McMethods.McBestCombo % Mc90, Mc95, or MaxCurvature
                    s="<html><b>McBestCombo</b> : Best combination (Mc95, Mc90, MaxCurvature)";
                case McMethods.McEMR
                    s="<html><b>McEMR</b> : Entire Mag. Range method";
                case McMethods.McDueB_ShiBolt
                    s="<html><b>McDueB</b> : Mc due b using Shi & Bolt uncertainty";
                case McMethods.McDueB_Bootstrap
                    s="<html><b>McDueB_Bootstrap</b></b> : Mc due b using bootstrap uncertainty";
                case McMethods.McDueB_Cao
                    s="<html><b>McDueB_Cao</b></b> : Mc due b using Cao-criterion";
                otherwise
                    error('invalid')
            end
        end
        
        function s = dropdownList()
            methods = enumeration('McMethods');
            s = strjoin(arrayfun(@McMethods.taggeddescription, methods), '|');
            s = char(s);
        end
    end
end
    