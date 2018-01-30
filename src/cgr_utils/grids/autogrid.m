function [zgrid, gpc] = autogrid(catalog, dohist, plotOnMap)
    % AUTOGRID automatically define grid parameters based on catalog
    % returns a ZmapGrid, 
    %
    % zgrid = AUTOGRID(catalog) calculate a ZmapGrid from a ZmapCatalog
    %
    % [zgrid, gpc] = AUTOGRID(...) additionally, provide a GridParameterChoice
    % styled struct.
    %
    % [zgrid, gpc] = AUTOGRID(catalog, dohist, plotOnMap) show a 2-d histogram of
    % events if dohist is true, and plot the grid dots on the main map if plotOnMap
    % is true.
    %
    % output:
    %    zgrid : ZmapGrid
    %    gpc : GridParameterChoice styled struct
    %
    % see also autoradius, ZmapGrid, GridParameterChoice
    
    % assert(isa(catalog,'ZmapCatalog'), 'catalog must be a zmap catalog')
   
    % use 2-d histogram to automatically determine an appropriate grid coverage
    % for the catalog
        [N,XEDGES,YEDGES] = histcounts2(...
            catalog.Longitude,...
            catalog.Latitude,...
            'BinMethod','fd'); % using freedman-Diaconis rule to determine bins
        
        MAGICX=50;
        MAGICY=50;
        DOAGAIN=median(max(N,[],1))>MAGICX || median(max(N,[],2))>MAGICY;
        prevNx=numel(XEDGES);
        prevNy=numel(YEDGES);
        while DOAGAIN
            DOAGAIN=false;
            medmaxNx=median(max(N,[],1));
            medmaxNy=median(max(N,[],2));
            if medmaxNx>MAGICX || medmaxNy>MAGICY
                prevNx=numel(XEDGES);
                nxEDGES=ceil(prevNx*1.5);
                XEDGES=linspace(XEDGES(1),XEDGES(end),nxEDGES);
                prevNy=numel(YEDGES);
                nyEDGES=ceil(prevNy*1.5);
                YEDGES=linspace(YEDGES(1),YEDGES(end),nyEDGES);
                DOAGAIN=true;
            end
            if ~DOAGAIN
                break
            end
            [N,XEDGES,YEDGES] = histcounts2(...
                catalog.Longitude,...
                catalog.Latitude,...
                XEDGES,YEDGES); % using freedman-Diaconis rule to determine bins
        end
        XEDGES=linspace(XEDGES(1),XEDGES(end),prevNx);
        YEDGES=linspace(YEDGES(1),YEDGES(end),prevNy);
        % create a grid (on bin centers!)
        %zgrid=ZmapGrid.FromVectors('autogrid',XEDGES(2:end)-diff(XEDGES(1:2))/2,...
        %    YEDGES(2:end)-diff(YEDGES(1:2))/2,'deg');
        
        
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
    
    zgrid=ZmapGrid('autogrid',gpc);
    
    if exist('dohist','var') && dohist
        figure('Name','Automatic Grid');
        histogram2(catalog.Longitude,catalog.Latitude,XEDGES,YEDGES);
        title('Event distribution')
        xlabel('Longitude')
        ylabel('Latitude')
        zlabel('# events')
    end
    if exist('plotOnMap','var') && plotOnMap
        zgrid.plot(mainmap('axes'));
    end
end