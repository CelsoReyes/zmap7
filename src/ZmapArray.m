function outval = ZmapArray(catalog)
    % ZMAPARRAY create a zmap array from this catalog
    % zmarr = catalog.ZMAPARRAY()
    
    outval = [...
        catalog.Longitude, ...   % 1
        catalog.Latitude, ...    % 2
        catalog.DecimalYear, ... % 3
        catalog.Date.Month, ...  % 4
        catalog.Date.Day,...     % 5
        catalog.Magnitude, ...   % 6
        catalog.Depth ...        % 7
        catalog.Date.Hour,...    % 8
        catalog.Date.Minute, ... % 9
        catalog.Date.Second]; % position 10 of 10
    
    % ZmapArray that had 12 values is like above, except...
    % catalog.Dip % position 10 of 12
    % catalog.DipDirection % position 11 of 12
    % catalog.Rake % position 12 of 12
end