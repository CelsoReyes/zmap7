function output = exportAsOpenQuakeCatalogueCsv(catalog, filename)
    % export a Catalog to a csv file readable as a Catalogue
    if isa(catalog, 'ZmapCatalog')
        catalog = catalog.table();
    end
    if ~istable(catalog)
        error('expected a ZmapCatalog')
    end
    ymdHMS = datevec(catalog.Date);
    output = table;
    output.year = ymdHMS(:,1);
    output.month = ymdHMS(:,2);
    output.day = ymdHMS(:,3);
    output.hour = ymdHMS(:,4);
    output.minute = ymdHMS(:,5);
    output.second = ymdHMS(:,6);
    output.latitude = catalog.Latitude;
    output.longitude = catalog.Longitude;
    output.depth = catalog.Depth;
    output.magnitude = catalog.Magnitude;
    % output.moment = 10.^(1.5*magnitude + 9.05);
    output.eventID = "id"+string(1:height(output))';
    output.magnitudeType = catalog.MagnitudeType;
    if exist('filename','var') && (~exist(filename,'file') ||...
            questdlg(['File ',filename,' exists, overwrite?'],'export catalog')=="Yes")
        writetable(output,filename);
    end
end