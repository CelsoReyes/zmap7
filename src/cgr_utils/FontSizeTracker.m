classdef FontSizeTracker
    properties
        base_size = 14;
    end
    properties(Dependent=true)
        xs
        s
        m
        l
        xl
    end
    methods
        function x = get.xs(obj)
            x = obj.base_size - 4;
        end
        
        function x = get.s(obj)
            x = obj.base_size - 2;
        end
        
        function x = get.m(obj)
            x = obj.base_size;
        end
        
        function x = get.l(obj)
            x = obj.base_size + 2;
        end
        
        function x = get.xl(obj)
            x = obj.base_size + 4;
        end
        
        function obj = minus(obj, val)
            obj.base_size = obj.base_size - val;
        end
        
        function obj = plus(obj, val)
            obj.base_size = obj.base_size + val;
        end
        
    end
        
end