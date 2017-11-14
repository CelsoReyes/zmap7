classdef ZmapGrid3 < ZmapGrid
    % UNDER CONSTRUCTION. 
    properties
        Zvector
        Zunits
    end
    properties(Dependent)
        Z
        Zactive
    end
    methods
        function obj = ZmapGrid3(name, x, y, z, xyunits, zunits)
            obj=ZmapGrid(name,x,y,xyunits);
            obj.Zunits=zunits;
            obj.Zvector=z;
        end
        
    end
end