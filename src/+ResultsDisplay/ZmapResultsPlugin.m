classdef (Abstract) ZmapResultsPlugin
    % base class for displaying results
    properties
       Parent
    end
    
    properties(Dependent)
        Data
        PlotTag
    end
    
    properties(Abstract)
    end
    
    methods(Abstract)
    end
    
    methods
        function r = get.Data(obj)
            r = obj.Parent.Result.values;
        end
        function r = get.PlotTag(obj)
            r = obj.Parent.PlotTag;
        end
    end
end