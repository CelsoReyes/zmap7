classdef GridBase
    % Base class for ZMAP Grids
    %
    properties
        Name(1,:)       char 
        X % specific use defined in subclasses
        Y % specific use defined in subclasses
        Z % specific use defined in subclasses
        RefEllipsoid    referenceEllipsoid 
        % [Lat0, Lon0, Z0] grid origin point. Grid is created outward from here
        OriginPoint
        UnitDelta % in the same units as the RefEllipsoid
        GridMarkerOptions struct % contains details used for plotting this grid
    end
    
    properties(Abstract, Constant)
        Type
        DeltaDescription
    end
    
    properties(Hidden)
        UsedPoints logical % t/f mask dictating which points are used 
    end
    
    properties(Dependent)
        Units
        ReferenceName
    end
    
    methods
        %% constructor
        function obj = GridBase(name, unit_delta, ref_ellipsoid, origin)
            obj.Name          = name;
            obj.RefEllipsoid  = ref_ellipsoid;
            obj.UnitDelta     = unit_delta;
            obj.OriginPoint   = origin;
        end
        
        %% dependent properties
        function s = get.Units(obj)
            s = obj.RefEllipsoid.LengthUnit;
        end
        
        function obj = set.Units(obj, new_unit)
            % changes the units and the UnitDelta accordingly
            new_unit = validateLengthUnit(new_unit);
            scale = unitsratio(new_unit,obj.RefEllipsoid.LengthUnit);
            obj.RefEllipsoid.LengthUnit = new_unit;
            obj.UnitDelta = obj.UnitDelta .* scale;
        end
        
        function s = get.ReferenceName(obj)
            s = obj.RefEllipsoid.Name;
        end
        
        %% function overrides
        
        function val = length(obj)
            if obj.isfiltered()
                val = sum(obj.UsedPoints);
            else
                val = size(obj.AllPoints,1);
            end
        end
        
        function tf = isempty(obj)
            tf = isempty(obj.AllPoints) || obj.length()==0;
        end
        
        function disp(obj)
            fprintf('%-12s "%s"\n  Origin: %s\n  (%s): %s , units: %s\n  based on: %s\n',...
                obj.Type, obj.Name, mat2str(obj.OriginPoint),...
                obj.DeltaDescription, mat2str(obj.UnitDelta), obj.Units,...
                obj.ReferenceName); 
        end
        
        %% class functionality
        
        function tf = isfiltered(obj)
            tf = ~all(obj.UsedPoints); % also false when UsedPoints is empty
        end
        
    end
    
    
end
