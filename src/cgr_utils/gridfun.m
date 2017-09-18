function [ values, nEvents, maxDist ] = gridfun( fun, catalog, zgrid, selcrit, varargin )
    %gridfun Applies a function to each grid point using events determined by selection criteria
    %
    %  VALUES = gridfun( FUN, CATALOG, GRID, SELCRIT) will apply the function FUN to each point
    %  in GRID, by choosing appropriate events from CATALOG using the selection criteria SELCRIT.
    %  FUN is a function handle that takes a ZmapCatalog as input, and returns a number.
    %  GRID is a ZmapGrid.
    %  SELCRIT is a structure containing one of the following set of fields:
    %    * numNearbyEvents (by itself) : runs function against this many closest events.
    %    * radius_km  (by itself) : runs function against all events in this radius
    %    * useNumNearbyEvents, useEventsInRadius, numNearbyEvents, radius_km (ALL of the above): 
    %      uses the useNumNearbyEvents and useEventsInRadius to determine its behavior.  If
    %      both of these fields are true, then the closest events are evaluated up to the distance
    %      radius_km.
    %    
    %  Optionally, a the field minNumEvents, if available will cause the function to be evaluated
    %  only if this many events meet the selcrit.
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
    
    % check input data
    multifun=iscell(fun);
    if multifun
        assert(size(fun,2)==2,...
            'if FUN is a cell, it should be Nx2, like {@fun1, ''field1'';...;@funN, ''fieldN''}');
        for i=1:size(fun,1)
            assert(isa(fun{i,1},'function_handle'),'element %d,1 of FUN isn''t a function handle',i);
            assert(ischar(fun{i,2}),'element %d,2 of FUN isn''t a string',i);
        end
    else
        assert(isa(fun,'function_handle'),...
            'FUN should be a function handle that accepts a catalog and returns a value');
        assert(nargin(fun)==1, 'FUN should take one input: a catalog')
    end
    assert(isa(catalog,'ZmapCatalog'),'CATALOG should be a ZmapCatalog');
    assert(isa(zgrid,'ZmapGrid'),'Grid should be ZmapGrid');
    
    usemask=any(~zgrid.ActivePoints);
    if usemask
        values=nan(size(zgrid.ActivePoints));
    else
        values=nan(length(zgrid),1);
    end
    
    countEvents=nargout>1;
    if countEvents
        nEvents=zeros(size(values));
    end
    
    getMaxDist=nargout>2;
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
    
end

