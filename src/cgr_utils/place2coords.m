function [res]=place2coords(city_and_country)
    % ouput is either 'latlon' or 'box'
    % box is returned as [Wlat, Elat, Slon, Nlon]
    % uses openstreetmap to get values

    queryparams = 'format=json';
    % queryparams=[queryparams, '&polygon_geojson=1'];
    if isempty(city_and_country)
        error("need to provide city,country or city,state,country")
    end
    parts = strip(split(city_and_country,','));
    queryparams = [queryparams, '&city=',parts{1}];
    
    if numel(parts)==3
        queryparams=[queryparams,'&state=',parts{2}];
        parts{2}='';
    end
    
    if numel(parts{end})==2
        queryparams=[queryparams,'&countrycode=',parts{end}];
    else
        queryparams=[queryparams,'&country=',parts{end}];
    end
    
    baseUrl = 'https://nominatim.openstreetmap.org/search/query?';
    
    res = webread(['https://nominatim.openstreetmap.org/search/query?',queryparams]);
    for j = 1 : numel(res)
        bb = res(j).boundingbox;
        res(j).boundingbox = struct('minLat',str2double(bb{1}),...
            'maxLat',str2double(bb{2}),...
            'minLon',str2double(bb{3}),...
            'maxLon',str2double(bb{4}));
    end
end
    