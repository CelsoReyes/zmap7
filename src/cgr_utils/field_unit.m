classdef field_unit
    % field_unit used to provide context to axes.
    % generally, the x,y,z labels will be have this assigned to their
    % UserData when a new axes that displays catalog data is created
    %
    % They are then used to do filtering by axes
    properties
        fieldn=''
        units='' % ideally a unit, but can be a date, if units would be duration
    end
    
    methods
        function obj = field_unit(fieldn, units)
            obj.fieldn=fieldn;
            obj.units=units;
        end
    end
    
    methods(Static)
        function obj=Longitude()
            % field_unit.Longitude used to assign longitude
            obj = field_unit('Longitude','degrees');
        end
        function obj=Latitude()
            obj = field_unit('Longitude','degrees');
        end
        function obj=Depth()
            obj = field_unit('Depth','kilometers');
        end
        function obj=Elevation()
            obj = field_unit('Elevation','meters');
        end
        function obj=Date()
            obj = field_unit('Date','date');
        end
        function obj=Duration(keydate)
            obj = field_unit('Date',keydate);
        end
            
    end
end