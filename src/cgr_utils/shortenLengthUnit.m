function s = shortenLengthUnit(unit)
    % SHORTENLENGTHUNIT get a abbreviated version of a length unit (plus degrees and radians)
    % shortunit = SHORTENLENGTHUNIT(unitname)
    %
    % ex.
    %    su = SHORTENLENGTHUNIT('kilometer') --> 'km'
    %    su = SHORTENLENGTHUNIT('degrees') --> 'deg'
    %
    % see also VALIDATELENGTHUNIT
    
    unit=lower(unit);
    if startsWith(unit,'deg')
        s = 'deg';
    elseif startsWith(unit,'rad')
        s = 'rad';
    else
        unit = validateLengthUnit(unit);
        shortZUnitList = {
            'kilometer','km';
            'meter','m';
            'centimeter','cm';
            'millimeter','mm';
            'micron','nm';
            'mile','mi';
            'foot','ft';
            'inch','in';
            'yard','yd'
            };
        s = shortZUnitList{string(unit)==shortZUnitList(:,1),2};
    end
end