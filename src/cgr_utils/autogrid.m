function [zgrid, gpc] = autogrid(catalog, dohist, plotOnMap)
    % AUTOGRID automatically define grid parameters based on catalog
    % returns a ZmapGrid, 
    %
    % zmg = AUTOGRID(catalog) calculate a ZmapGrid from a ZmapCatalog
    %
    % [zmg, gpc] = AUTOGRID(...) additionally, provide a GridParameterChoice
    % styled struct.
    %
    % [zmg, gpc] = AUTOGRID(catalog, dohist, plotOnMap) show a 2-d histogram of
    % events if dohist is true, and plot the grid dots on the main map if plotOnMap
    % is true.
    %
    % output:
    %    zgrid : ZmapGrid
    %    gpc : GridParameterChoice styled struct
    %
    % see also autoradius, ZmapGrid, GridParameterChoice
    
    assert(isa(catalog,'ZmapCatalog'), 'catalog must be a zmap catalog')
   
    % use 2-d histogram to automatically determine an appropriate grid coverage
    % for the catalog
    [~,XEDGES,YEDGES] = histcounts2(...
        catalog.Longitude,...
        catalog.Latitude,...
        'BinMethod','fd'); % using freedman-Diaconis rule to determine bins
    
    % create a grid (on bin centers!)
    zmg=ZmapGrid('autogrid',XEDGES(1:end-1)-diff(XEDGES(1:2))/2,...
        YEDGES(1:end-1)-diff(YEDGES(1:2))/2,'deg');
    
    % create a structure equivelent to GridParameterChoice.toStruct()
    gpc=struct('dx',diff(XEDGES(1:2))/2,...
        'dy',diff(YEDGES(1:2))/2,...
        'dz',[],...
        'dx_units','deg',...
        'dy_units','deg',...
        'dz_units','km',...
        'GridEntireArea',true,...
        'SaveGrid',false,...
        'LoadGrid',false,...
        'CreateGrid',false); %should be done in conj. with GridParameterChoice
    
    
    if exist('doplot','var') && dohist
        figure('Name','Automatic Grid');
        histogram2(catalog.Longitude,catalog.Latitude,XEDGES,YEDGES);
        title('Event distribution')
        xlabel('Longitude')
        ylabel('Latitude')
        zlabel('# events')
    end
    if exist('plotOnMap','var') && plotOnMap
        zmg.plot(MainInteractiveMap.mainAxes);
    end
end