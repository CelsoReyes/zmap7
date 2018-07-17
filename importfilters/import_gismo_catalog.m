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
    %   [uOutput] = import_gismo_catalog(1, catalog)
    
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
        uOutput=nan(numel(catalog.lon),10);
        
        uOutput(:,1) = catalog.lon;
        uOutput(:,2) = catalog.lat;
        uOutput(:,3)= decyear(catalog.otime);% decimal year.
        
        [~, uOutput(:,4),...
            uOutput(:,5),...
            uOutput(:,8),...
            uOutput(:,9),...
            uOutput(:,10)] = datevec(catalog.otime);
        
        uOutput(:,6) = catalog.mag;
        uOutput(:,7) = catalog.depth;
    else
        uOutput = 'unable to import Catalog';
    end
end
