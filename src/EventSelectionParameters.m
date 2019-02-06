classdef EventSelectionParameters
    %holds basic values for specifying samples, either out to a distance, or a specified number
    %
    %CONSTRUCTION OPTIONS
    %  obj = EventSelectionParameters()
    %  obj = EventSelectionParameters('NumClosestEvents', N) 
    %  obj = EventSelectionParameters('AllEventsInRadius', R)
    %  obj = EventSelectionParameters('NumClosestEventsUpToRadius', N, R)
    %  obj = EventSelectionParameters( ... , 'DistanceUnits', unitname)
    %
    %USE CASE
    %
    %  select based on distances, where D is a vector of distances of length N, in unit U.
    %  The unit is flexible, and can be any value accepted by either checkangleunits or ValidateLengthUnits
    %
    %    MASK = obj.SelectionFromDistances(D, U) 
    %
    %  MASK will be a logical vector of length N. It is TRUE where D matches the conditions contained
    %  in obj.  
    %
    %see also EventSelectionParameters/EventSelectionParameters
   
    properties
        % Samples will be collected out to this radius. To ignore radius, set as inf (default)
        MaxSampleRadius         (1,1) double {mustBePositive}    = inf
        % These many samples will be collected. To collect all, set as inf (default)
        NumClosestEvents        (1,1) double {mustBePositive}    = inf
        % Units of distance for the sample radius. Defaults to kilometers.  
        DistanceUnits           (1,1) string {mustBeNonempty}    = standardizeDistanceUnits('km')
    end
    
    properties(Dependent)
        UseNumClosestEvents 
        UseEventsInRadius
    end
    
    properties(Hidden)
        PrevMaxSampleRadius     (1,1) double    = inf;
        PrevNumClosestEvents    (1,1) double    = inf;
    end
    
    properties(Dependent,Hidden)
        % for backwards compatibility
        RadiusKm
    end
    
    methods
        function obj = EventSelectionParameters(style, varargin)
            %EventSelectionParameters constructor
            %obj = EventSelectionParameters()
            %obj = EventSelectionParameters('NumClosestEvents', N) choose the N closest events
            %
            %obj = EventSelectionParameters('AllEventsInRadius', R) choose ALL events within radius R
            % 
            %obj = EventSelectionParameters('NumClosestEventsUpToRadius', N, R) choose the N
            %closest events, limited to radius R.
            %
            % The radius units can be specified as an optional Name,Value pair.
            %
            %obj = EventSelectionParameters( ... , 'DistanceUnits', unitname) where unitname is
            %unit understood by the validateLengthUnits or checkangleunits functions.
            
            
            if ~exist('style','var')
                style = 'none';
            end
            p=inputParser();
            switch style
                case 'AllEventsInRadius'
                    p.addRequired('MaxSampleRadius');
                    p.addParameter('DistanceUnits',obj.DistanceUnits);
                case 'NumClosestEvents'
                    p.addRequired('NumClosestEvents');
                case 'NumClosestEventsUpToRadius'
                    p.addRequired('NumClosestEvents');
                    p.addRequired('MaxSampleRadius');
                    p.addParameter('DistanceUnits',obj.DistanceUnits,@isStandardDistanceUnit);
                case 'none'
            end
            p.parse(varargin{:});
            obj=copyfields(obj, p.Results);
            %{
            fn =fieldnames(p.Results);
            for i=1:numel(fn)
                obj.(fn{i}) = p.Results.(fn{i});
            end
            %}
            
        end
        
        function rk = get.RadiusKm(obj)
            if isinf(obj.MaxSampleRadius)
                rk = obj.MaxSampleRadius;
            elseif obj.DistanceUnits == "kilometer"
                rk = obj.MaxSampleRadius;
            elseif obj.DistanceUnits== "degrees"
                rk = deg2km(obj.MaxSampleRadius);
            elseif obj.DistanceUnits == "radians"
                rk = rad2km(obj.MaxSampleRadius);
            else
                rk = unitsratio('kilometer', obj.DistanceUnits) * obj.MaxSampleRadius;
            end
        end
        function obj = set.RadiusKm(obj,val)
            obj.MaxSampleRadius = val;
            obj.DistanceUnits = 'kilometer';
        end
        
        function tf = get.UseNumClosestEvents(obj)
            tf = obj.NumClosestEvents < inf;
        end
        
        function tf = get.UseEventsInRadius(obj)
            tf = obj.MaxSampleRadius < inf;
        end
        
        function obj = set.UseNumClosestEvents(obj, val)
            if val
                obj.NumClosestEvents = obj.PrevNumClosestEvents;
            else
                if ~isinf(obj.NumClosestEvents)
                    obj.PrevNumClosestEvents = obj.NumClosestEvents;
                end
                obj.NumClosestEvents = inf;
            end
        end
        
        function obj = set.UseEventsInRadius(obj, val)
            if val
                obj.MaxSampleRadius = obj.PrevMaxSampleRadius;
            else
                if ~isinf(obj.MaxSampleRadius)
                    obj.PrevMaxSampleRadius = obj.MaxSampleRadius;
                end
                obj.MaxSampleRadius = inf;
            end
        end
        
        function obj = set.DistanceUnits(obj, units)
            obj.DistanceUnits = standardizeDistanceUnits(units);
        end
        
        function obj = set.MaxSampleRadius(obj, value)
            prev = obj.MaxSampleRadius;
            obj.MaxSampleRadius = value;
            if ~isinf(prev)
                obj.PrevMaxSampleRadius = prev; %#ok<MCSUP>
            end
        end
        function obj = set.NumClosestEvents(obj,value)
            if value==floor(value) || isinf(value)
                prev = obj.NumClosestEvents;
                obj.NumClosestEvents = value;
                if ~isinf(prev)
                    obj.PrevNumClosestEvents = prev; %#ok<MCSUP>
                end
            else
                error('NumClosestEvents must be either a positive integer value, or be inf');
            end
        end
        
        function mask = SelectionFromDistances(obj, distances, distUnits)
            %select values, based on distances
            %
            %MASK = obj.SelectionFromDistances(DISTANCES, UNITS) returns a logical vector of 
            %length N that is TRUE for each value of DISTANCES that matches the conditions 
            %contained in this object. The UNITS specify the units of distances, (eg. 'km', 
            %'radians', 'degrees', etc..) and accepts any value understood by either the 
            %checkangleunits or validateLengthUnit functions.  
            %
            %This object's maximum radius will be compared (with the appropriate conversion)
            %with the provided distance vector.
            %
            % Example of automatic unit conversion
            %  >> esp = EventSelectionParameters('AllEventsInRadius', 1, 'DistanceUnits', 'degrees');
            %  >> esp.SelectionFromDistances([100 110 120], 'km')  % one degree of arc is ~111km
            %     ans =
            %       1×3 logical array
            %        1   1   0
            % 
            %  >> esp.DistanceUnits = 'miles';
            %  >> esp.SelectionFromDistances([2.0, 1.5 1.0],'km'); % comparing against 1 mile
            %     ans =
            %       1×3 logical array
            %        0   1   1
            %  
            %
            %When specifying a number of events and several distances fall across the boundary, it
            %is undefined which values will be selected. For example...
            %
            %  >> D = [ 1 1 1 1 1 1 1 1 ];  % 8 events, all at the same distance
            %  >> esp = EventSelectionParameters('NumClosestEvents',5);
            %  >> esp.SelectionFromDistances(D, 'km')
            %
            %   ans =
            %     1×8 logical array
            %     1   1   1   1   1   0   0   0
            %
            %see also checkangleunits, validateLengthUnit
            
            %% deal with the maximum radius
            
            
            
            if isinf(obj.MaxSampleRadius)                                 % distances do not matter
                mask = true; % scaler because unused later 
            elseif distUnits == obj.DistanceUnits                       % simple case: Units match
                mask = distances <= obj.MaxSampleRadius;
            else
                distUnits = standardizeDistanceUnits(distUnits);
                if distUnits == obj.DistUnits
                    mask = distances <= obj.MaxSampleRadius;
                else
                    mask = []; 
                    % convert Selection Units into provided units, then compare
                    OtherIsAngle = ismember(distUnits,["radians" , "degrees"]);
                    ThisIsAngle  = ismember(obj.DistanceUnits,["radians" , "degrees"]);
                end
            end
            
            
            % remember that UNITSRATIO arguments are (TO , FROM)
            if ~isempty(mask)
                % mask has been calculated already
                
            elseif OtherIsAngle == ThisIsAngle                      % both are length or both are angle 
                maxDist = unitsratio(distUnits, obj.DistanceUnits) * obj.MaxSampleRadius;
                mask = distances < maxDist;
                
            elseif distUnits == "radians"
                maxDist = unitsratio(obj.DistanceUnits,'kilometer') * km2rad(obj.MaxSampleRadius);
                mask = distances < maxDist;
                
            elseif distUnits == "degrees"
                maxDist = unitsratio(obj.DistanceUnits,'kilometer') * km2deg(obj.MaxSampleRadius);
                mask = distances < maxDist;
                
            elseif obj.DistanceUnits == "radians"
                maxDist = unitsratio(distUnits, 'kilometer') * rad2km(obj.MaxSampleRadius);
                mask = distances < maxDist;
                
            elseif obj.DistanceUnits == "degrees"
                maxDist = unitsratio(distUnits, 'kilometer') * deg2km(obj.MaxSampleRadius);
                mask = distances < maxDist;
            end
            
            %% deal with the N closest events
            if ~isinf(obj.NumClosestEvents)
                [~,I]=mink(distances, obj.NumClosestEvents);
                % I'm sure this logic could be simplified...
                II = false(size(distances));
                II(I)=true;
                mask = mask & II;
            end
            
        end
    end
    
    methods(Static)
        function obj = fromStruct(s)
            %Backwards Compatibility with EventSelectionChoice
            if ~isstruct(s)
                error('expected a struct');
            end
            obj = EventSelectionParameters();
            
            if isfield(s,'UseEventsInRadius') && s.UseEventsInRadius
                if isfield(s,'RadiusKm')
                    obj.MaxSampleRadius = s.RadiusKm;
                end
            end
            if isfield(s,'UseNumNearbyEvents') && s.UseNumNearbyEvents
                if isfield(s,'NumClosestEvents')
                    obj.NumClosestEvents = s.NumClosestEvents;
                end
                if isfield(s,'MaxRadiusKm')
                    obj.MaxSampleRadius = s.MaxRadiusKm;
                end
            end
        end
    end
end
    