function [uOutput] = import_gismo_catalog(nfunction, catalog)
    % Create a ZMAP-format data matrix from a Catalog object
    % Catalog objects are part of the GISMO suite
    %
    % to get helptext:
    %   [helpstring] = import_gismo_catalog(0)
    %
    % to retrieve Catalog stored in file
    %   [uOutput] = import_gismo_catalog(1, filename)
    %
    % to convert Catalog stored in memory
    %   [uOutput] = import_gismo_catalog(1, catalog) % name will be name of variable
    
    % created by Celso G Reyes, 2017
    
    % ZMAP format is 10 columns: longitude, latitude, decimal year, month, day,
    % magnitude, depth, hour, minute, second
    uOutput = [];
    
    if nfunction==0   % Return info about filter
        uOutput = 'GISMO Catalog - import catalog from the GISMO suite';
        return
    end
    if nfunction ==2
        uOutput = 'gismo.html';
        return
    end
    
    if ~exist('Catalog','class')
        uOutput(['Cannot import catalog, since Catalog class (and probably GISMO) is not installed.',...
            'Last known whereabouts: https://github.com/geoscience-community-codes/GISMO']);
        return
    end
    if ischar(catalog)
        % filename
        if exist(catalog,'file')
            fn = catalog;
            catalog=load(fn);
        end
    end
    
    if exist('catalog','var') && isa(catalog,'Catalog')
        tb=table(datetime(datevec(catalog.otime)),...
            catalog.lat,...
            catalog.lon,...
            catalog.depth,...
            catalog.mag,...
            catalog.magtype,...
            'VariableNames',{'Date','Latitude','Longitude','Depth','Magnitude','MagnitudeType'});
        uOutput=ZmapCatalog(tb);
        
        uOutput.Name=inputname(2);
            

    else
        uOutput = 'unable to import Catalog';
    end
end
