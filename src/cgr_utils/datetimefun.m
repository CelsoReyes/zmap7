function [ values, nEvents, dateSpread, maxMag, wasEvaluated ] = datetimefun( infun, catalog, starttimes, endtimes, mineventcount, answidth )
    %DATETIMEFUN Applies a function to a catalog, divided by time periods
    %
    %
    %  VALUES = DATETIMEFUN( FUN, CATALOG, STARTTIMES, ENDTIMES, MINEVENTCOUNT, ANSWIDTH) will apply
    %  the function FUN to each timewindow defined by STARTTIMES and ENDTIMES by choosing 
    %  appropriate events from CATALOG
    %  FUN is a function handle that takes a ZmapCatalog as input, and returns a number.
    %  START_TIMES and  ENDTIMES must be vectors of the same length (Nx1)
    %
    %  VALUES will be an Nx1 or NxANSWIDTH vector of values determined by the FUN.
    %
    %  VALUES = DATETIMEFUN(...,varargin); passes varargin as additional parameters to the function.
    %  (MAY NOT BE IMPLEMENTED)
    %
    %  [VALUES, NEVENTS] = DATETIMEFUN(...) will also return the number of events used for each point.
    %  Not-evaluated points would have a value of zero.
    %
    %  [VALUES, NEVENTS, DATESPREAD, MAXMAG, WASEVALUATED ] = datetimefun(...)
    %
    %
    %  FUN can also be a cell of {funHandle, fieldname;...} in which case each function in the cell
    %  will be run against the selection of events, with the results returned as a single struct. 
    %  Each field of the struct will be an array.
    %
    %  NOTE: if the function would normally take multiple parameters which are NOT time dependent
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
    
    % set flags for how to treat this data
    multifun=iscell(infun);
    assert(numel(starttimes)==numel(endtimes));
    nSkippedDueToInsufficientEvents = 0;
    % check input data
    
    check_provided_functions(multifun);
    
    assert(isa(catalog,'ZmapCatalog'), 'CATALOG should be a ZmapCatalog');
    
    if ~exist('answidth','var')
        answidth=1;
    end
    
    values = nan(numel(starttimes), answidth );
    
    resultsize = [size(values,1),1];
    
    nEvents = zeros(resultsize);
    dateSpread = days(nan(resultsize));
    maxMag = nan(resultsize);
    
    wasEvaluated = false(numel(starttimes),1);
    
    drawnow nocallbacks
    
    % start parallel pool if necessary, but warn user!
    ZG = ZmapGlobal.Data;
    
    
    UseParallelProcessing = ZG.ParallelProcessingOpts.Enable && ...
        length(starttimes) >= ZG.ParallelProcessingOpts.Threshhold;
    
    try
        if UseParallelProcessing
            start_the_parallel_pool();
        end
    catch ME
        warning(ME.message);
    end
    
    mytic = tic;    
    
    gridmsg = sprintf('Computing values across time.            %d Total points', length(starttimes));
    if ~iscell(infun)
        gridttl = sprintf('Zmap: %s', func2str(infun));
    else
        gridttl = sprintf('Zmap: [%d functions]', numel(infun));
    end
    
    h=msgbox_nobutton({ 'Please wait.' , gridmsg },gridttl);
        
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
        sprintf('skipped %d time windows due to insuffient events\n', nSkippedDueToInsufficientEvents)};
    
    % close the window after a while. this is probably a kludge.
    %h.delay_for_close(seconds(2));
    if answidth==1
        reshaper=@(x) reshape(x, size(starttimes));
        values=reshaper(values);
    end
 
    function doSinglefun(myfun)
        allTimes = catalog.Date;
        for i=1:numel(starttimes)
            fun=myfun; % local copy of function
            % is this point of interest?
            in_range = allTimes >=starttimes(i) & allTimes < endtimes(i);
            nEvents = sum(in_range);
            if nEvents < mineventcount
                nSkippedDueToInsufficientEvents = nSkippedDueToInsufficientEvents + 1;
                continue
            end
            
            minicat = catalog.subset(in_range);
            if ~isempty(minicat)
                dateSpread(i) = max(minicat.Date) - min(minicat.Date);
                maxMag(i)=max(minicat.Magnitude);
            end
           
            returned_vals = fun(minicat);
            values(i,:)=returned_vals;
            
            wasEvaluated(i)=true;
            if ~mod(i,ceil(length(starttimes)/50))
                h.String=sprintf('Computing values across time.   %5d / %d Total points', i, length(starttimes));
                drawnow limitrate nocallbacks
            end
        end
    end

    
    function doParSinglefun(myfun)
            
        allTimes = catalog.Date;
        
        parfor i=1:numel(starttimes)
            fun=myfun; % local copy of function
            % is this point of interest?
            in_range = allTimes >=starttimes(i) & allTimes < endtimes(i);
            nEvents = sum(in_range);
            if nEvents < mineventcount
                nSkippedDueToInsufficientEvents = nSkippedDueToInsufficientEvents + 1;
                continue
            end
            
            minicat = catalog.subset(in_range);
            if ~isempty(minicat)
                dateSpread(i) = max(minicat.Date) - min(minicat.Date);
                maxMag(i)=max(minicat.Magnitude);
            end
           
            returned_vals = fun(minicat);
            values(i,:)=returned_vals;
            wasEvaluated(i)=true;
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
     
    function start_the_parallel_pool()
        p=gcp('nocreate');
        if isempty(p)
            msgbox_nobutton('Parallel pool starting up for first time...this might take a moment','Starting Parpool');
            parpool();
        end
    end
end

