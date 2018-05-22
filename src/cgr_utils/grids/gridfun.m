function [ values, nEvents, maxDist, maxMag, wasEvaluated ] = gridfun( infun, catalog, zgrid, selcrit, answidth )
    %GRIDFUN Applies a function to each grid point using events determined by selection criteria
    %
    %
    %  VALUES = GRIDFUN( FUN, CATALOG, GRID, SELCRIT) will apply the function FUN to each point
    %  in GRID, by choosing appropriate events from CATALOG using the selection criteria SELCRIT.
    %  FUN is a function handle that takes a ZmapCatalog as input, and returns a number.
    %  GRID is a ZmapGrid.
    %  SELCRIT is a structure containing one or more of the following set of fields:
    %    * numNearbyEvents (by itself) : runs function against this many closest events.
    %          < incompatable with radius_km, unless useNumNearbyEvents 
    %            and useEventsInRadius are also defined >
    %
    %    * radius_km  (by itself) : runs function against all events in this radius
    %          < incompatable with numNearbyEvents, unless useNumNearbyEvents 
    %            and useEventsInRadius are also defined >
    %
    %    * useNumNearbyEvents, useEventsInRadius, numNearbyEvents, radius_km (ALL of the above): 
    %           uses the useNumNearbyEvents and useEventsInRadius to determine its behavior.  Only
    %           one of these fields may be true.
    %
    %    * maxRadiusKm - defines a cutoff, used when local events are too sparce for numNearbyEvents 
    %
    %    * requiredNumEvents - calculations are only performed for selections (catalogs) that
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
    multifun=iscell(infun);
    countEvents=nargout>1;
    getMaxDist=nargout>2;
    
    MIN_POINTS_FOR_PARALLEL = 1000000;
    nSkippedDueToInsufficientEvents = 0;
    % check input data
    
    check_provided_functions(multifun);
    check_catalog();
    check_grid();
    check_selection(); % may modify selcrit
    
    
    if ~exist('answidth','var')
        answidth=1;
    end
    
    values = initialize_from_grid(answidth);
    
    nEvents=zeros(size(values,1),1);
    
    maxDist=nan(size(values,1),1);
    
    maxMag=nan(size(values,1),1);
    
    wasEvaluated=false(length(zgrid),1);
    
    drawnow nocallbacks
    
    % start parallel pool if necessary, but warn user!
    ZG = ZmapGlobal.Data;
    try
        start_the_parallel_pool();
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
        
    if multifun
        error('Unimplemented. Cannot yet do Multifun');
        %doMultifun(infun)
    else
        doSinglefun(infun);
    end
    toc(mytic)
    h.ButtonVisible=true;
    h.String={'Calculation Complete.',...
        sprintf('skipped %d grid points due to insuffient events\n', nSkippedDueToInsufficientEvents)};
    
    % close the window after a while. this is probably a kludge.
    %h.delay_for_close(seconds(2));
    if answidth==1
        reshaper=@(x) reshape(x, size(zgrid.X));
        values=reshaper(values);
    end
 
    function doSinglefun(myfun)
        if length(zgrid)<MIN_POINTS_FOR_PARALLEL || ~ZG.useParallel
            
            gridpoints = zgrid.GridVector;
            gridpoints=gridpoints(zgrid.ActivePoints,:);
            
            % where to put the value back into the matrix
            activeidx = find(zgrid.ActivePoints);
            doZ=~isempty(zgrid.Z);
            
            for i=1:numel(activeidx)
                fun=myfun; % local copy of function
                % is this point of interest?
                write_idx = activeidx(i);
                x=gridpoints(i,1);
                y=gridpoints(i,2);
                if doZ
                    [minicat, maxd] = catalog.selectCircle(selcrit, x,y,gridpoints(i,3));
                else
                    
                    [minicat, maxd] = catalog.selectCircle(selcrit, x,y,[]);
                end
                
                nEvents(write_idx)=minicat.Count;
                maxDist(write_idx)=maxd;
                if ~isempty(minicat)
                    maxMag(write_idx)=max(minicat.Magnitude);
                end
                % are there enough events to do the calculation?
                if minicat.Count < selcrit.requiredNumEvents
                    nSkippedDueToInsufficientEvents = nSkippedDueToInsufficientEvents + 1;
                    continue
                end
                
                returned_vals = fun(minicat);
                values(write_idx,:)=returned_vals;
                
                wasEvaluated(write_idx)=true;
                if ~mod(i,ceil(length(zgrid)/50))
                    h.String=sprintf('Computing values across grid.   %5d / %d Total points', i,length(zgrid));
                    drawnow limitrate nocallbacks
                end
            end
        else
            error('disabled parallel processing')
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
    
    function check_catalog()
        assert(isa(catalog,'ZmapCatalog'),'CATALOG should be a ZmapCatalog');
    end
    
    function check_grid()
        assert(isa(zgrid,'ZmapGrid'),'Grid should be ZmapGrid');
    end
    
    function check_selection()
        assert(isstruct(selcrit),'selcrit should be a struct');
        assert(isfield(selcrit,'numNearbyEvents') || isfield(selcrit,'radius_km'),...
            'selcrit should at least have one field named either "numNearbyEvents" or "radius_km"');
        if ~isfield(selcrit,'requiredNumEvents')
            selcrit.requiredNumEvents=1;
        end
    end
    
    function values = initialize_from_grid(answidth)
            values=nan(length(zgrid),answidth);
    end
    
    function start_the_parallel_pool()
        p=gcp('nocreate');
        if isempty(p) &&  ZG.useParallel
            msgbox_nobutton('Parallel pool starting up for first time...this might take a moment','Starting Parpool');
            parpool();
        end
    end
end

