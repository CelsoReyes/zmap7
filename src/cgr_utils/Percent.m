classdef Percent
    % PERCENT represent numbers as percentages
    properties(Hidden)
        val
    end
    
    methods
        function obj = Percent(p)
            obj.val=p;
        end
        function v = char(obj)
            v = char(cellstr(string(obj(:))));
        end
        function disp(obj)
            disp(char(obj));
        end
        function d=double(obj)
            d=double(obj.val./100);
        end
        function s=string(obj)
            s=string(obj.val);
            s=strcat(s,'%');
        end
    end
end
            
            
        
    