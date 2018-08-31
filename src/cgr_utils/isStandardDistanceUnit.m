function tf=isStandardDistanceUnit(unit)
    % standardize the distance units
    %
    % see also sandardizeDistanceUnits
    try
        standardizeDistanceUnits(unit); %will error if incorrect
        tf = true;
    catch
        tf = false;
    end
end