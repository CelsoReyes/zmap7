function [ values, nEvents, maxDist, maxMag, wasEvaluated ] = gridfun( infun, catalog, zgrid, selcrit, requiredNumEvents, answidth,varargin )
    %GRIDFUN Applies a function to each grid point using events determined by selection criteria
    %
    %
    %  VALUES = GRIDFUN( FUN, CATALOG, GRID, SELCRIT, requiredNumEvents) will apply the function FUN to each point
    %  in GRID, by choosing appropriate events from CATALOG using the selection criteria SELCRIT.
    %  FUN is a function handle that takes a ZmapCatalog as input, and returns a number.
    %  GRID is a ZmapGrid.
    %  SELCRIT is an EventSelectionParameters object
    %
    %  requiredNumEvents - calculations are only performed for selections (catalogs) that
    %           contain at least this many events.
    %
    %  VALUES will be an Nx1 or NxANSWIDTH vector of values determined by the FUN.
    %
    %  if the ZmapGrid has the active points, then this will will only evaluate the active grid 
    %  points. inactive values will be set to NaN.
    %
    %  VALUES = gridfun(...,varargin); passes varargin as additional parameters to the function.
    %  (MAY NOT BE IMPLEMENTED)
    %
    %  [VALUES, NEVENTS] = gridfun(...) will also return the number of events used for each point.
    %  Not-evaluated points would have a value of zero.
    %
    %  [VALUES, NEVENTS, MAXDIST, MAXMAG, WASEVALUATED ] = gridfun(...)
    %
    %
    %  FUN can also be a cell of {funHandle, fieldname;...} in which case each function in the cell
    %  will be run against the selection of events, with the results returned as a single struct. 
    %  Each field of the struct will be an array.
    %
    %  NOTE: if the function would normally take multiple parameters which are NOT grid dependent
    %        then it can be simplified using an anonymous function. like so:
    %        assume my function is defined as:
    %
    %            function z=func(catalog, value1 value2)  % not usable. must only take catalog
    %       
    %        then, assuming value1 and value2 are the same for all runs 
    % 
    %            minifunc=@(catalog) func(catalog, value1, value2)
    %
    %        this "freezes" value1 and value2 into the function call, so now minifunc can be used
    %        like so:
    %     
    %            z=minifunc(catalog) % value1, value2 are remembered from when function was defined
    %
    %        search the documentation for Anonymous Functions for more details
    %
    %
    %   NOTE: grid evaluations are parallelized
    %
    % see also ZmapGrid, EventSelectionChoice, GridOpts
    %
    
    % set flags for how to treat this data
    QUICKDISTANCES = true; 
    multifun = iscell(infun);
    
    assert(isa(selcrit,'EventSelectionParameters'));
    assert(catalog.CoordinateSystem == zgrid.CoordinateSystem);
    
    nSkippedDueToInsufficientEvents = 0;
    % check input data
    
    if isempty(requiredNumEvents)
        requiredNumEvents = 1;
    end
    
    check_provided_functions(multifun, infun);
    
    if ~isa(catalog, 'ZmapCatalog')
        error('CATALOG should be a ZmapCatalog');
    end
    if ~isa(zgrid, 'ZmapGrid')
        error('Grid should be ZmapGrid, is a %s',class(zgrid));
    end
    
    if ~exist('answidth', 'var')
        answidth=1;
    end
    
    values = nan(length(zgrid),answidth); % initialize from grid
    resultsize = [size(values,1),1];
    
    nEvents = zeros(resultsize);
    maxDist = nan(resultsize);
    maxMag = nan(resultsize);
    
    wasEvaluated = false(length(zgrid),1);
    
    drawnow nocallbacks
    
    
    % start parallel pool if necessary, but warn user!
    UseParallelProcessing = act_upon_parallel_processing_options(length(zgrid));
    
    mytic = tic;    
    
    
    h = show_computation_dlg(infun,length(zgrid));
    
    
    % shortcut only applies if we are dealing with lat/lon
    QUICKDISTANCES = QUICKDISTANCES && catalog.CoordinateSystem == CoordinateSystems.geodetic;
    
    if QUICKDISTANCES
        [xNcat, yEcat, zDcat, xNgrid, yEgrid, zDgrid] = transformGeodetic2ned(catalog, zgrid);
    else
        [xNgrid, yEgrid, zDgrid] = deal([]);
        [xNcat, yEcat, zDcat] = deal([]);
    end
    
    if multifun
        error('Unimplemented. Cannot yet do Multifun');
        
    elseif UseParallelProcessing
        doParSinglefun(infun, selcrit, catalog, zgrid);
    else 
        doSinglefun(infun);
    end
    
    toc(mytic)
    h.ButtonVisible = true;
    h.String = {'Calculation Complete.',...
        sprintf('skipped %d grid points due to insufficient events\n', nSkippedDueToInsufficientEvents)};
    
    % close the window after a while. this is probably a kludge.
    %h.delay_for_close(seconds(2));
    
    if answidth==1 && ~isempty(varargin) && ~any(varargin == "noreshape")
        reshaper = @(x) reshape(x, size(zgrid.X));
        values = reshaper(values);
    end
 
    return
    
    %% calculation functions
    %
    %
    
    function doSinglefun(myfun)
            
        gridpoints = zgrid.GridVector;
        gridpoints = gridpoints(zgrid.ActivePoints,:);
        
        % where to put the value back into the matrix
        activeidx = find(zgrid.ActivePoints);
        doZ = ~isempty(zgrid.Z);
        
        
        if QUICKDISTANCES
            yEgrid = yEgrid(activeidx);
            xNgrid = xNgrid(activeidx);
            if doZ
                zDgrid = zDgrid(activeidx);
            end   
        end
        
        assert(isa(selcrit,'EventSelectionParameters'));
        
        lengthUnit = catalog.RefEllipsoid.LengthUnit;
        
        for i=1:numel(activeidx)
            fun = myfun; % local copy of function
            % is this point of interest?
            write_idx = activeidx(i);
            x=gridpoints(i,1);
            y=gridpoints(i,2);
            if QUICKDISTANCES
                if doZ
                    dd = sqrt((xNcat-xNgrid(i)).^2 + (yEcat-yEgrid(i)).^2 + (zDcat - zDgrid(i)).^2);
                else
                    dd = sqrt((xNcat-xNgrid(i)).^2 + (yEcat-yEgrid(i)).^2);
                end
                mask = selcrit.SelectionFromDistances(dd, lengthUnit);
                minicat = catalog.subset(mask);
                maxd = max(dd(mask));
                
            else
                if doZ
                    [minicat, maxd] = catalog.selectCircle(selcrit, x, y, gridpoints(i,3));
                else
                    [minicat, maxd] = catalog.selectCircle(selcrit, x, y,[]);
                end
            end
            
            nEvents(write_idx)=minicat.Count;
            if ~isempty(minicat)
                maxMag(write_idx) = max(minicat.Magnitude);
                maxDist(write_idx) = maxd;
            end
            % are there enough events to do the calculation?
            if minicat.Count < requiredNumEvents
                nSkippedDueToInsufficientEvents = nSkippedDueToInsufficientEvents + 1;
                continue
            end
            
            returned_vals = fun(minicat);
            values(write_idx,:)=returned_vals;
            
            wasEvaluated(write_idx)=true;
            if ~mod(i,ceil(length(zgrid)/50))
                h.String=sprintf('Computing values across grid.   %5d / %d Total points', i, length(zgrid));
                drawnow limitrate nocallbacks
            end
        end
    end

    
    function doParSinglefun(myfun, selcrit, catalog, zgrid)
            
        gridpoints = zgrid.GridVector;
        gridpoints = gridpoints(zgrid.ActivePoints,:);
        
        % where to put the value back into the matrix
        activeidx = find(zgrid.ActivePoints);
        size(activeidx);
        x=gridpoints(:,1);
        y=gridpoints(:,2);
        doZ=~isempty(zgrid.Z);
        if doZ
            z=gridpoints(:,3);
            if QUICKDISTANCES
                zDgrid=zDgrid(activeidx);
            end
        else
            z=nan(size(x));
        end
        if QUICKDISTANCES
            yEgrid=yEgrid(activeidx);
            xNgrid=xNgrid(activeidx);
        end
        nTotal = numel(x);
        nEvaluated = 0;
        D = parallel.pool.DataQueue;
        updateFreq = ceil(length(zgrid)/50);
        D.afterEach(@updateWaitBar)
        
        
        p = gcp('nocreate'); % get parallel pool details
        refel = catalog.RefEllipsoid.LengthUnit;
        selectFromDistances = @(d) selcrit.SelectionFromDistances(d, refel);
        parfor i=1 : nTotal
            fun = myfun; % local copy of function;
            if QUICKDISTANCES
                if doZ
                    dd = sqrt((xNcat-xNgrid(i)).^2 + (yEcat-yEgrid(i)).^2 + (zDcat - zDgrid(i)).^2);
                else
                    dd = sqrt((xNcat-xNgrid(i)).^2 + (yEcat-yEgrid(i)).^2);
                end
                mask = selectFromDistances(dd); % selcrit.SelectionFromDistances(dd, refel);
                minicat = catalog.subset(mask);
                maxd = max(dd(mask));
                
            else
                if doZ
                    [minicat, maxd] = catalog.selectCircle(selcrit, x(i),y(i),z(i));
                else

                    [minicat, maxd] = catalog.selectCircle(selcrit, x(i),y(i),[]);
                end
            end
            % is this point of interest?
            %write_idx = activeidx(i);
        
            assert(~isempty(minicat.Count));
            
            nEvents(i) = minicat.Count;
            if ~isempty(minicat)
                maxDist(i) = maxd; 
                maxMag(i) = max(minicat.Magnitude);
            end
            % are there enough events to do the calculation?
            if minicat.Count < requiredNumEvents
                nSkippedDueToInsufficientEvents = nSkippedDueToInsufficientEvents + 1;
                continue
            end
            
            returned_vals = fun(minicat);
            values(i,:)=returned_vals; %%
            
            wasEvaluated(i)=true; %%
            D.send(i);
        end
        %% put values into correct place
        nEvents(zgrid.ActivePoints) = nEvents(1:numel(activeidx));
        nEvents(~zgrid.ActivePoints)=0;
        maxDist(zgrid.ActivePoints) = maxDist(1:numel(activeidx));
        maxDist(~zgrid.ActivePoints)=nan;
        maxMag(zgrid.ActivePoints) = maxMag(1:numel(activeidx));
        maxMag(~zgrid.ActivePoints)=nan;
        values(zgrid.ActivePoints,:) = values(1:numel(activeidx),:);
        values(~zgrid.ActivePoints,:)=nan;
        wasEvaluated(zgrid.ActivePoints) = wasEvaluated(1:numel(activeidx));
        wasEvaluated(~zgrid.ActivePoints)=false;
        
        function updateWaitBar(~)
            nEvaluated=nEvaluated+1;
            if ~mod(nEvaluated, updateFreq)
                h.String={"Parallel Computation: " + p.NumWorkers + " workers",sprintf('Computing grid values: %5d / %d Total points', nEvaluated, nTotal)};
                drawnow limitrate nocallbacks
            end
        end
    end

end

function check_provided_functions(multifun, infun)
    
    if multifun
        assert(size(infun,2)==2,...
            'if FUN is a cell, it should be Nx2, like {@fun1, ''field1'';...;@funN, ''fieldN''}');
        for q=1:size(infun,1)
            assert(isa(infun{q,1},'function_handle'),'element %d,1 of FUN isn''t a function handle',q);
            assert(ischar(infun{q,2}),'element %d,2 of FUN isn''t a string',q);
        end
    else
        assert(isa(infun,'function_handle'),...
            'FUN should be a function handle that accepts a catalog and returns a value');
        assert(nargin(infun)==1, 'FUN should take one input: a catalog')
    end
end
    
function UseParallelProcessing = act_upon_parallel_processing_options(gridlength)
    ZG = ZmapGlobal.Data;
    
    % get parallel pool details
    
    UseParallelProcessing = ZG.ParallelProcessingOpts.Enable && ...
        (gridlength >= ZG.ParallelProcessingOpts.Threshhold || ...
        ~isempty(gcp('nocreate'))); 
    
    try
        if UseParallelProcessing
            start_the_parallel_pool();
        end
    catch ME
        warning(ME.message);
    end
end
    
function start_the_parallel_pool()
    p=gcp('nocreate');
    if isempty(p)
        msgbox_nobutton('Parallel pool starting up for first time...this might take a moment','Starting Parpool');
        parpool();
    end
end

function h = show_computation_dlg(infun, nPoints)
    gridmsg = sprintf('Computing values across grid.            %d Total points', nPoints);
    if ~iscell(infun)
        gridttl = sprintf('Zmap: %s', func2str(infun));
    else
        gridttl = sprintf('Zmap: [%d functions]', numel(infun));
    end
    
    h = msgbox_nobutton({ 'Please wait.' , gridmsg },gridttl);
end

function [xNcat, yEcat, zDcat, xNgrid, yEgrid, zDgrid] = transformGeodetic2ned(catalog, zgrid)
    refLat = median(catalog.Latitude);
    refLon = median(catalog.Longitude);
    refDepth = 0;
    % get XYZ positions of cataloged events
    [xNcat, yEcat, zDcat] = geodetic2ned(catalog.Latitude, catalog.Longitude, catalog.Depth,...
        refLat, refLon, refDepth, catalog.RefEllipsoid);
    % getXYZ position of grid points
    if isempty(zgrid.Z)
        inDepth = 0;
    else
        inDepth = zgrid.Z;
    end
    [xNgrid, yEgrid, zDgrid] = geodetic2ned(zgrid.Y, zgrid.X, inDepth,...
        refLat, refLon, refDepth, catalog.RefEllipsoid); %TOFIX should be GRID's RefEllipsoid, but must have same units as catalog's
end
