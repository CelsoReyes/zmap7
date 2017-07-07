classdef ZmapCatalog < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name
        Date        % datetime
        % Nanosecond  % additional precision, if needed
        Longitude
        Latitude
        Depth       % km
        Magnitude
        MagnitudeType
        Filter
    end
    
    properties(Dependent)
        DecimalYear
        DayOfYear
        Count
    end
    
    methods
        function propval = get.Count(obj)
            % number of events
            propval = numel(obj.Longitude);
        end
        
        function propval = get.DecimalYear(obj)
            propval = decyear(obj.Date);
        end
        
        function propval = get.DayOfYear(obj)
            propval = fix(datenum(obj)) - datenum(obj.Date.Year - 1, 12 , 31);
        end
        
        function obj = ZmapCatalog(varargin)
            % ZmapCatalog create a ZmapCatalog object
            obj.Name = '';
            if nargin==0
                %donothing
                return
            end
            if isnumeric(varargin{1})
                % import Catalog from Array
                obj.Longitude = varargin{1}(:,1);
                obj.Latitude = varargin{1}(:,2);
                if all(varargin{1}(:,3) < 100)
                    varargin{1}(:,3) = varargin{1}(:,3)+1900;
                    errdisp =  'The catalog dates appear to have 2 digits years. Action taken: added 1900 for Y2K compliance';
                    warndlg(errdisp)
                end
                obj.Date = datetime([floor(varargin{1}(:,3)), varargin{1}(:,[4,5,8,9,10])]);
                obj.Depth = varargin{1}(:,7);
                obj.Magnitude = varargin{1}(:,6);
                
                obj.MagnitudeType = cell(size(obj.Magnitude));
                
                for i=1:numel(obj.MagnitudeType)
                    if isempty(obj.MagnitudeType{i})
                        obj.MagnitudeType(i)={''};
                    end
                end
                
                
                if nargin==2 && ischar(varargin{2})
                    obj.Name = varargin{2};
                end
       
            elseif (nargin==0)
                obj = ZmapCatalog;
            elseif isa(varargin{1},'ZmapCatalog')
                obj = varargin{1};
            end
            
        end
        
        function outval = ZmapArray(obj)
            % create a zmap array from this catalog
            outval = [obj.Longitude, obj.Latitude, obj.DecimalYear, obj.Date.Month, obj.Date.Day,...
                obj.Depth, obj.Magnitude, obj.Date.Hour, obj.Date.Minute, obj.Date.Second];
            % rake = a(:,12)
        end
        
        function s =  summary(obj, verbosity)
            % return a summary of this catalog
            % valid verbosity values: 'simple', 'stats'
            
            % add additional ways to look at catalog if it makes sense
            if ~exist('verbosity','var')
                verbosity='';
            end
            
            if obj.Count==0
                s = sprintf('Empty Catalog, named "%s"',obj.Name);
                return
            end
            
            switch verbosity
                case 'simple'
                    minti = min( obj.Date );
                    maxti  = max( obj.Date );
                    minma = min(obj.Magnitude);
                    maxma = max(obj.Magnitude);
                    mindep = min(obj.Depth);
                    maxdep = max(obj.Depth);
                    
                    fmtstr = [...
                        'Catalog "%s" with %d events\n',...
                        'Start Date: %s\n',...
                        'End Date:   %s\n',...
                        'Depths:     %4.2f km ≤ Z ≤ %4.2f km\n',...
                        'Magnitudes: %2.1f ≤ M ≤ %2.1f'];
                    
                    s = sprintf(fmtstr, obj.Name, obj.Count, ...
                        char(minti,'uuuu-MM-dd HH:mm:ss'),...
                        char(maxti,'uuuu-MM-dd HH:mm:ss'),...
                        mindep, maxdep,...
                        minma, maxma);
                case 'stats'
                    minti = min( obj.Date );
                    maxti  = max( obj.Date );
                    minma = min(obj.Magnitude);
                    maxma = max(obj.Magnitude);
                    mindep = min(obj.Depth);
                    maxdep = max(obj.Depth);
                    
                    fmtstr = [...
                        'Catalog "%s"\nNumber of events: %d\n',...
                        'Start Date: %s\n',...
                        'End Date:   %s\n',...
                        '  %s\n',...
                        'Depths:     %4.2f km ≤ Z ≤ %4.2f km\n',...
                        '  %s\n',...
                        'Magnitudes: %2.1f ≤ M ≤ %2.1f\n',...
                        '  %s'];
                    
                    mean_int = mean(diff(obj.Date));
                    median_int = median(diff(obj.Date));
                    std_int = std(diff(obj.Date));
                    mean_int.Format = 'd';
                    median_int.Format = 'd';
                    std_int.Format = 'd';
                    if std_int < 10
                        std_int.Format = 'hh:mm:ss';
                    end
                    if mean_int < 10
                        mean_int.Format = 'hh:mm:ss';
                    end
                    if median_int < 10
                        median_int.Format = 'hh:mm:ss';
                    end
                    s = sprintf(fmtstr, obj.Name, obj.Count, ...
                        char(minti,'uuuu-MM-dd HH:mm:ss'),...
                        char(maxti,'uuuu-MM-dd HH:mm:ss'),...
                        sprintf('mean interval: %s ±std %s , median int: %s',mean_int, std_int, median_int),... 
                        mindep, maxdep,...
                        sprintf('mean: %.3f ±std %.3f , median: %.3f',mean(obj.Depth), std(obj.Depth), median(obj.Depth)),... 
                        minma, maxma,...
                        sprintf('mean: %.2f ±std %.2f , median: %.2f',mean(obj.Magnitude), std(obj.Magnitude), median(obj.Magnitude)));
                    
                otherwise
                    s = sprintf('Catalog "%s", containing %d events', obj.Name, obj.Count);
            end
        end
        
        function clearFilter(obj)
            % clearFilter sets all items in filter to true
            obj.Filter = true(size(obj.Longitude));
        end
        
        function invertFilter(obj)
            % invertFilter flips all true to false and vice-versa
            obj.Filter = ~obj.Filter;
        end
        
        function setFilterToAxesLimits(obj, ax)
            if ~isvalid(ax)
                return
            end
            obj.addFilter('Longitude','>=',min(ax.XLim));
            obj.addFilter('Latitude','>=',min(ax.YLim));
            obj.addFilter('Longitude','<=',max(ax.XLim));
            obj.addFilter('Latitude','<=',max(ax.YLim));
        end
        
        function cropToFilter(obj)
            % applies the filter to this ZmapCatalog
            % 
            % see also addFilter, clearFilter
            
            if isempty(obj.Filter)
                return
            end
            
            obj.Date = obj.Date(obj.Filter);       % datetime
            % Nanosecond  % additional precision, if needed
            obj.Longitude = obj.Longitude(obj.Filter) ;
            obj.Latitude = obj.Latitude(obj.Filter);
            obj.Depth =  obj.Depth(obj.Filter) ;      % km
            obj.Magnitude = obj.Magnitude(obj.Filter) ;
            obj.MagnitudeType = obj.MagnitudeType(obj.Filter) ;
            obj.Filter = obj.Filter(obj.Filter) ;
        end
        
        function obj = getCropped(existobj)
            % get a new, cropped ZmapCatalog from this one
            % reasoning: requires less memory
            
            if isempty(existobj.Filter)
                obj = existobj;
                return
            end
            % get a subset of an existing catalog
            obj = ZmapCatalog();
            obj.Longitude = existobj.Longitude(existobj.Filter);
            obj.Latitude = existobj.Latitude(existobj.Filter);
            obj.Date = existobj.Date(existobj.Filter);
            obj.Depth = existobj.Depth(existobj.Filter);
            obj.Magnitude = existobj.Magnitude(existobj.Filter);
            obj.MagnitudeType = existobj.MagnitudeType(existobj.Filter);
            obj.Filter = existobj.Filter(existobj.Filter); 
        end
        
        function addFilter(obj, field, operation, value, varargin)
            % addFilter allows subsets of data to be specified
            %
            % addFilter(mask) AND's the mask with the existing filter
            %     where mask is a logical array of same length as ZmapCatalog.Count
            %
            % 
            % addFilter(field, operation, value) compares the data from the field to the value using
            %     the specified operation.
            %     FIELD is a string containing the name of a valid ZmapCatalog field
            %     OPERATION is either a function handle or one of the following:
            %          '<','>','<=','≤','≥','>=','==','~='
            %     VALUE is what the field will be compared against.
            % 
            % Example 1
            %     obj.addFilter('Depth','>=',3) % sets Filter to true wherever depth >= 3
            %     obj.addFilter('Depth','<', 23) % now Filter is true only where depth >=3 AND depth < 23
            %
            % Example 2
            %     odd_dates = @(x,~) mod(datenum(x),2) == 1;
            %     obj.addFilter('Date',@odd_dates,[]); %true where datenum is odd
            %        
            %
            % see also clearFilter
            % 
            if ~exist('operation','var') && islogical(field) && all(size(field)==size(obj.Longitude))
                obj.Filter = field;
                return
            end
                
            if ischar(operation)
                switch operation
                    case '<'
                        operation=@lt;
                    case '>'
                        operation=@gt;
                    case {'<=','≤'}
                        operation = @le;
                    case {'>=','≥'}
                        operation = @ge;
                    case '=='
                        operation = @eq;
                    case '~='
                        operation = @ne;
                    otherwise
                        operation = str2func(operation);
                end
            end
            if ~isprop(obj, field)
                error('%s is not a valid property of a ZmapCatalog',field);
            end
            if isa(operation,'function_handle')
                if isempty(obj.Filter)
                    obj.clearFilter();
                end
                obj.Filter = obj.Filter & operation(obj.(field), value);
                if ~isempty(varargin)
                    obj.addFilter(varargin{:});
                end
                
            else
                error('don''t know how to handle a %s',class(operation));
            end
            %
        end
        
        function sort(obj, field, direction)
            % sort this object by the field specified
            % obj.sort(field), where field is a valid ZmapCatalog property
            % 
            % obj.sort(field, direction), where direction is 'ascend' or 'descend'
            % ex.
            % obj.sort('Date')
            % sortBy (fieldname)
            if ~isprop(obj, field)
                error('%s is not a valid property of a ZmapCatalog',field);
            end
            if ~exist('direction','var')
                direction = 'ascend';
            end
            [~,idx] = sort(obj.(field),direction);
            
            obj.Date = obj.Date(idx);       % datetime
            obj.Longitude = obj.Longitude(idx) ;
            obj.Latitude = obj.Latitude(idx);
            obj.Depth =  obj.Depth(idx) ;      % km
            obj.Magnitude = obj.Magnitude(idx) ;
            obj.MagnitudeType = obj.MagnitudeType(idx) ;
            if isempty(obj.Filter)
                obj.clearFilter();
            end
            obj.Filter = obj.Filter(idx) ;
        end
         
        function obj = subset(existobj, range)
            % subset get a subset of this object
            % newobj = obj.subset(mask) where mask is a t/f array matching obj.Count
            %    will keep all "true" events
            % newobj = obj.subset(range), where range evaluates to an integer array
            %    will retrieve the specified events.
            %    this option can be used to change the order of the catalog too
        
            obj = ZmapCatalog();
            obj.Date = existobj.Date(range);       % datetime
            obj.Longitude = existobj.Longitude(range) ;
            obj.Latitude = existobj.Latitude(range);
            obj.Depth =  existobj.Depth(range) ;      % km
            obj.Magnitude = existobj.Magnitude(range) ;
            obj.MagnitudeType = existobj.MagnitudeType(range) ;
            obj.Filter = existobj.Filter(range) ;
        end   
        
        function obj = cat(objA, objB)
            % cat combines two catalogs
            % duplicates are not looked for
            obj = objA;
            objA.Date = [objA.Date; objB.Date];
            objA.Longitude = [objA.Longitude; objB.Longitude];
            objA.Latitude = [objA.Latitude; objB.Latitude];
            objA.Depth = [objA.Depth; objB.Depth];
            objA.Magnitude = [objA.Magnitude; objB.Magnitude];
            objA.MagnitudeType = [objA.MagnitudeType; objB.MagnitudeType];
            objA.clearFilter();
        end
        
        function obj = removeDuplicates(obj, tolLat, tolLon, tolDepth_m, tolTime_sec, tolMag)
            % removeDuplicates removes events from catalog that are similar within tolerances
            % catalog = catalog.removeDuplicates(tolLat, tolLon, tolDepth_m, tolTime_sec, tolMag)

            obj.sort('Date');
            orig_size = obj.Count;
            if ~exist('tolLat','var') || isempty(tolLat), tolLat = 0.0001; end
            if ~exist('tolLon','var') || isempty(tolLon), tolLon = 0.0001; end
            if ~exist('tolDepth_m','var') || isempty(tolDepth_m), tolDepth_m = 0.5; end
            if ~exist('tolTime_sec','var') || isempty(tolTime_sec), tolTime_sec = 0.01; end
            if ~exist('tolMag','var') || isempty(tolMag), tolMag = 0.001; end
            fprintf('Removing duplicates with the following tolerances:\n');
            fprintf('  Time (s): %.2f\nLat: %f\nLon: %f\nDepth (m): %f\nMag:%.3f\n',...
                tolTime_sec, tolLat, tolLon, tolDepth_m, tolMag);
            
            isSame = abs(diff(obj.Date)) <= seconds(tolTime_sec) & ...
                abs(diff(obj.Latitude)) <= tolLat & ...
                abs(diff(obj.Longitude)) <= tolLon & ...
                abs(diff(obj.Depth)) <= (tolDepth_m / 1000) & ...
                abs(diff(obj.Magnitude)) <= tolMag;
            sameidx = [false; isSame];
            obj = obj.subset(~sameidx);
            fprintf('Removed %d duplicates\n', orig_size - obj.Count);
        end
            
    end
    
end

