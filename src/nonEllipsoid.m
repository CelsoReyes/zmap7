classdef nonEllipsoid < referenceEllipsoid
    % used when coordinate system is cartesian
    methods
        function obj = nonEllipsoid(varargin)
            obj@referenceEllipsoid();
            p = inputParser;
            p.addOptional('Name','XYZ');
            p.addOptional('LengthUnit','meter');
            p.parse(varargin{:});
            obj.LengthUnit = p.Results.LengthUnit;
            obj.Name = p.Results.Name;
        end
    end
            
end