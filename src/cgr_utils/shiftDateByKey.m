function d2 = shiftDateByKey(d1,key)
    % shiftDateByKey will shift the day to the start of the nearest time unit
    % depending on the key.
    switch lower(char(key))
        case 'y'
            d2=dateshift(d1,'start','year','nearest');
        case 'm'
            d2=dateshift(d1,'start','month','nearest');
        case 'd'
            d2=dateshift(d1,'start','day','nearest');
        case 'h'
            d2=dateshift(d1,'start','hour','nearest');
        otherwise
            d2=d1;
            % do nothing
    end
end