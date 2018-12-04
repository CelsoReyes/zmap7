function stdunit = standardizeDistanceUnits(unit)
    % returns a string representation of a standardized unit of measurement
    % eg. 'degrees' for 'deg', and 'kilometer' for 'kilometers' or 'km'
    %
    % see also validateLengthUnit, isStandardDistanceUnit
    
    switch lower(unit)
        case {'deg','degs','degree','degrees'}
            stdunit = 'degrees';
        case {'rad','rads','radian','radians'}
            stdunit = 'radians';
        otherwise
            stdunit = validateLengthUnit(unit); % returns various standard names, such as 'kilometer', 'inch', etc.
    end
    
    if isa(unit,'string')
        stdunit = string(stdunit);
    end
end