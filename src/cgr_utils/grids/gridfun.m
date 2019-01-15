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
    multifun=iscell(infun);
    
    assert(isa(selcrit,'EventSelectionParameters'));
    
    nSkippedDueToInsufficientEvents = 0;
    % check input data
    
    if isempty(requiredNumEvents)
        requiredNumEvents = 1;
    end
    
    check_provided_functions(multifun);
    
    if ~isa(catalog, 'ZmapCatalog')
        error('CATALOG should be a ZmapCatalog');
    end
    if ~isa(zgrid, 'ZmapGrid')
        error('Grid should be ZmapGrid, is a %s',class(zgrid));
    end
    
    if ~exist('answidth', 'var')
        answidth=1;
    end
    
    values = initialize_from_grid(answidth);
    resultsize = [size(values,1),1];
    
    nEvents = zeros(resultsize);
    maxDist = nan(resultsize);
    maxMag = nan(resultsize);
    
    wasEvaluated = false(length(zgrid),1);
    
    drawnow nocallbacks
    
    % start parallel pool if necessary, but warn user!
    ZG = ZmapGlobal.Data;
    
    
    UseParallelProcessing = ZG.ParallelProcessingOpts.Enable && ...
        (length(zgrid) >= ZG.ParallelProcessingOpts.Threshhold || ~isempty(gcp('nocreate'))); % get parallel pool details
    
    try
        if UseParallelProcessing
            start_the_parallel_pool();
        end
    catch ME
        warning(ME.message);
    end
    
    mytic = tic;    
    
    gridmsg = sprintf('Computing values across grid.            %d Total points', length(zgrid));
    if ~iscell(infun)
        gridttl = sprintf('Zmap: %s', func2str(infun));
    else
        gridttl = sprintf('Zmap: [%d functions]', numel(infun));
    end
    
    h=msgbox_nobutton({ 'Please wait.' , gridmsg },gridttl);
        
    if QUICKDISTANCES
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
    if multifun
        error('Unimplemented. Cannot yet do Multifun');
        %doMultifun(infun)
    elseif UseParallelProcessing
        doParSinglefun(infun);
    else 
        doSinglefun(infun);
    end
    toc(mytic)
    h.ButtonVisible=true;
    h.String={'Calculation Complete.',...
        sprintf('skipped %d grid points due to insuffient events\n', nSkippedDueToInsufficientEvents)};
    
    % close the window after a while. this is probably a kludge.
    %h.delay_for_close(seconds(2));
    
    if answidth==1 && ~isempty(varargin) && ~any(varargin == "noreshape")
        reshaper=@(x) reshape(x, size(zgrid.X));
        values=reshaper(values);
    end
 
    function doSinglefun(myfun)
        if UseParallelProcessing
            error('disabled parallel processing')
        end
            
        gridpoints = zgrid.GridVector;
        gridpoints=gridpoints(zgrid.ActivePoints,:);
        
        % where to put the value back into the matrix
        activeidx = find(zgrid.ActivePoints);
        doZ=~isempty(zgrid.Z);
        
        yEgrid=yEgrid(activeidx);
        xNgrid=xNgrid(activeidx);
        if doZ
            zDgrid=zDgrid(activeidx);
        end
        
        assert(isa(selcrit,'EventSelectionParameters'));
        for i=1:numel(activeidx)
            fun=myfun; % local copy of function
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
                %isWithinRadius = dd <= MaxSampleRadius .^ 2;
                mask = selcrit.SelectionFromDistances(dd, catalog.RefEllipsoid.LengthUnit);
                minicat = catalog.subset(mask);
                maxd = max(dd(mask));
                
            else
                if doZ
                    [minicat, maxd] = catalog.selectCircle(selcrit, x,y,gridpoints(i,3));
                else

                    [minicat, maxd] = catalog.selectCircle(selcrit, x,y,[]);
                end
            end
            
            nEvents(write_idx)=minicat.Count;
            if ~isempty(minicat)
                maxMag(write_idx)=max(minicat.Magnitude);
                maxDist(write_idx)=maxd;
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

    
    function doParSinglefun(myfun)
            
        gridpoints = zgrid.GridVector;
        gridpoints=gridpoints(zgrid.ActivePoints,:);
        
        % where to put the value back into the matrix
        activeidx = find(zgrid.ActivePoints);
        size(activeidx)
        x=gridpoints(:,1);
        y=gridpoints(:,2);
        doZ=~isempty(zgrid.Z);
        if doZ
            z=gridpoints(:,3);
            zDgrid=zDgrid(activeidx);
        else
            z=nan(size(x));
        end
        yEgrid=yEgrid(activeidx);
        xNgrid=xNgrid(activeidx);
        nTotal = numel(x);
        nEvaluated=0;
        D = parallel.pool.DataQueue;
        D.afterEach(@updateWaitBar)
        p=gcp('nocreate'); % get parallel pool details
        parfor i=1:nTotal
            fun=myfun; % local copy of function;
            if QUICKDISTANCES
                if doZ
                    dd = sqrt((xNcat-xNgrid(i)).^2 + (yEcat-yEgrid(i)).^2 + (zDcat - zDgrid(i)).^2);
                else
                    dd = sqrt((xNcat-xNgrid(i)).^2 + (yEcat-yEgrid(i)).^2);
                end
                %isWithinRadius = dd <= MaxSampleRadius .^ 2;
                mask = selcrit.SelectionFromDistances(dd, catalog.RefEllipsoid.LengthUnit);
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
        
            
            nEvents(i)=minicat.Count; %%
            maxDist(i)=maxd; %%
            if ~isempty(minicat)
                maxMag(i)=max(minicat.Magnitude); %%
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
            if ~mod(nEvaluated,ceil(length(zgrid)/50))
                h.String={"Parallel Computation: " + p.NumWorkers + " workers",sprintf('Computing grid values: %5d / %d Total points', nEvaluated, nTotal)};
                drawnow limitrate nocallbacks
            end
        end
    end

    
    % helper functions
    function check_provided_functions(multifun)
        
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
    
    function values = initialize_from_grid(answidth)
            values=nan(length(zgrid),answidth);
    end
    
    function start_the_parallel_pool()
        p=gcp('nocreate');
        if isempty(p)
            msgbox_nobutton('Parallel pool starting up for first time...this might take a moment','Starting Parpool');
            parpool();
        end
    end
end

