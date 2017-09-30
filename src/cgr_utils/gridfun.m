function [ values, nEvents, maxDist ] = gridfun( fun, catalog, zgrid, selcrit, varargin )
    %gridfun Applies a function to each grid point using events determined by selection criteria
    %
    %  VALUES = gridfun( FUN, CATALOG, GRID, SELCRIT) will apply the function FUN to each point
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
    %  VALUES will be an Nx1 vector of values determined by the FUN.
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
    % see also ZmapGrid, EventSelectionChoice, GridParameterChoice
    %
    
    % set flags for how to treat this data
    multifun=iscell(fun);
    countEvents=nargout>1;
    getMaxDist=nargout>2;
    
    nSkippedDueToInsufficientEvents = 0;
    % check input data
    
    check_provided_functions(multifun);
    check_catalog();
    check_grid();
    check_selection(); % may modify selcrit
    
    usemask=any(~zgrid.ActivePoints(:));
    
    values = initialize_from_grid();
    
    if countEvents
        nEvents=zeros(size(values));
    end
    
    if getMaxDist
        maxDist=nan(size(values));
    end
    
    Xs=zgrid.X;
    Ys=zgrid.Y;
    mask=zgrid.ActivePoints;
    
    %{
    hasZ=size(zgrid,2)==3;
    if hasZ
        Zs=zgrid(:,3);
    end
    %}
    
    reshaper=@(x) reshape(x, length(zgrid.Xvector),length(zgrid.Yvector));
    values=reshaper(values);
    
    for i=1:length(zgrid)
        % is this point of interest?
        if usemask && ~mask(i)
            continue
        end
        
        x=Xs(i);
        y=Ys(i);
        
        [minicat, maxd] = catalog.selectCircle(selcrit, x,y,[]);
        
        if countEvents
            nEvents(i)=minicat.Count;
        end
        
        if getMaxDist
            maxDist(i)=maxd;
        end
        
        % are there enough events to do the calculation?
        if minicat.Count < selcrit.requiredNumEvents
            nSkippedDueToInsufficientEvents = nSkippedDueToInsufficientEvents + 1;
            continue 
        end
        
        if ~multifun
            values(i)=fun(minicat);
        else
            % assign to a matrix for now, because of possible parfor issues
            for j=1:size(fun,1)
                tmpval(i,j)=fun{j,1}(minicat);
            end
        end
    end
    
    
    if multifun
        % put tmpval into a struct
        for j=1:size(fun,1)
            values.(fun{j,2})=reshaper(tmpval(:,j));
        end
    end
    
    fprintf('gridfun:skipped %d grid points due to insuffient events\n', nSkippedDueToInsufficientEvents);
    
    
    % helper functions
    function check_provided_functions(multifun)
        
        if multifun
            assert(size(fun,2)==2,...
                'if FUN is a cell, it should be Nx2, like {@fun1, ''field1'';...;@funN, ''fieldN''}');
            for q=1:size(fun,1)
                assert(isa(fun{q,1},'function_handle'),'element %d,1 of FUN isn''t a function handle',q);
                assert(ischar(fun{q,2}),'element %d,2 of FUN isn''t a string',q);
            end
        else
            assert(isa(fun,'function_handle'),...
                'FUN should be a function handle that accepts a catalog and returns a value');
            assert(nargin(fun)==1, 'FUN should take one input: a catalog')
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
    
    function values = initialize_from_grid()
        if usemask
            values=nan(size(zgrid.ActivePoints));
        else
            values=nan(length(zgrid),1);
        end
    end
    
end

