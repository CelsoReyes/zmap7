function webmap_of_catalog(catalog)
    % webmap_of_catalog plot earthquakes in a browser window
    % using the geoweb toolbox
    %
    % see webmap, webmarker
    if catalog.Count >= 1000
        errordlg('Too many events for webmap.  Reduce events to < 1000, and try again');
        return
    end
    dep2color= @(x) [(x - min(x)) /max(x- min(x)), repmat(0,numel(x),1), sqrt(1-(x - min(x)) /max(x- min(x)))];
    scaleit = @(n)(( n + abs(min(n)) + 1 )/4) .^ (1/3);
    %TODO include the MagnitudeType
    desc=splitlines(sprintf('(%8.4f, %8.4f) depth: %4.2f km, mag %3.2f\n',...
        catalog.Latitude, catalog.Longitude, catalog.Depth, catalog.Magnitude)); desc(end)=[];
    tit=cellstr(char(catalog.Date,'uuuu-MM-dd hh:mm:ss'));
    webmap('World Topographic Map');
    wmmarker(catalog.Latitude, catalog.Longitude,...
        'IconScale',scaleit(catalog.Magnitude),...
        'Description',desc,'Color',dep2color(catalog.Depth), 'FeatureName',tit);
end