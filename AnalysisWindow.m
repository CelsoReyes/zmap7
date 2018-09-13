classdef AnalysisWindow < handle
    % AnalysisWindow is a base class to make creating analysis windows of a catalog easier
    %
    %   add_series    : 
    %   remove_series :
    %   prepare_axes  : 
    %   calculate     : 
    
    properties
        ax     {mustBeAxesOrEmpty}          % handle for the axis
        prepared = false % axis has been prepared (labeled, titled, scaled, etc.) 
        nMarkers = 3;    % number of markers in the plot
    end

    methods
        function obj = AnalysisWindow(ax)
            obj.ax = ax;
        end
        
        function h=add_series(obj, catalog, tagID, varargin)
            % add a series of data to this plot. 
            % h = obj.ADD_SERIES(catalog, tagID, [[Name, Value],...])
            %
            % Inputs:
            %   REQUIRED:
            %     catalog : a ZmapCatalog
            %     tagID   : string or char description by which this data series will be accessed
            % 
            %   PARAMETERIZED:  as name,value. for example.. obj.add_series(cat,tag, 'UseCalculation',@mycalcfunction)
            %     'UseCalculation' : handle to a function that accepts a catalog and returns x and y
            %     'SizeFcn' :  handle to a function that accepts a catalog and returns valid sizes 
            %                  (either a single size, or one for each point)
            %     'ColorFcn' : handle to a function that accepts a catalog and returns valid colors
            %                  (either a single RGB value or a vector of RGB for each point)
            %     'MinBigMag' : minimum value for an event to be labeled as a "big" event
            %
            %     Additional Parameterized properties will be interpreted as plotting properties,
            %          such as 'FontSize','LineWidth', etc...
            
            p = inputParser();
            p.addRequired('catalog',    @(x)isa(x,'ZmapCatalog'));
            p.addRequired('tagID',      @(x)ischar(tagID)|| isstring(tagID));
            
            p.addParameter('UseCalculation', @obj.calculate, ...
                @(x)isa(x,'function_handle') && ... 
                (nargout(x)==2 || nargout(x)==-1) ...
            );
        
            % if either SizeFcn or ColorFcn are defined, then this will create a scatter plot.
            % otherwise, it will create a line
            emptyfun=@(x)[];
            p.addParameter('SizeFcn',  emptyfun,  @(x)nargin(x)==1);
            p.addParameter('ColorFcn', emptyfun,  @(x)nargin(x)==1);
            p.addParameter('MinBigMag', inf);
            p.KeepUnmatched = true;
            p.parse(catalog, tagID, varargin{:});
            
            props = p.Unmatched;
            
            
            altcalc = p.Results.UseCalculation;
            
            [x,y] = altcalc(catalog);
            
            if isequal(p.Results.SizeFcn,emptyfun) && isequal(p.Results.ColorFcn,emptyfun)
                plotFcn = @line; 
                % set properties unique to a line
                marker_indices = round(linspace(1, length(y), obj.nMarkers));
                if any(marker_indices==0)
                    marker_indices = [];
                end
                props.MarkerIndices = marker_indices;
            else
                plotFcn = @scatter;
                % set properties unique to a scatter
                props.SizeData = p.Results.SizeFcn(catalog);
                props.CData = p.Results.ColorFcn(catalog);
            end
            
            % allow MarkerIndices to be overridden by incoming parameters
            if isfield(p.Unmatched,'MarkerIndices')
                if ischar(p.Unmatched.MarkerIndices) && p.Unmatched.MarkerIndices == "all"
                    props.MarkerIndices = 1:numel(x);
                else
                    props.MarkerIndices = p.Unmatched.MarkerIndices;
                end
            end
            
            
            if ~obj.prepared
                obj.prepare_axes();
                obj.prepared = true;
            end
            
            h = findobj(obj.ax,'Tag', tagID);
            
            props.Tag = tagID;
            %props.DisplayName = catalog.Name;
            
            
            if isempty(h)
                obj.ax.NextPlot = 'add';
                h=plotFcn(obj.ax, x, y);
                set_valid_properties(h, props);
                obj.ax.NextPlot ='replace';
            else
                h.XData = x;
                h.YData = y;
                set_valid_properties(h, props);
            end
            if ~isinf(p.Results.MinBigMag)
                obj.add_big_series(catalog, ZmapGlobal.Data.CatalogOpts.BigEvents.MinMag);
            end
        end
        
        function remove_series(obj,tagID)
            % remove a data series from this axes. Specify the tag(s) to delete
            
            if isempty(tagID)
                return;
            end
                
            if iscell(tagID) || isstring(tagID)
                for i=1:numel(tagID)
                    myplot=findobj(obj.ax,'Tag',tagID{i});
                    delete(myplot);
                end
            else
               myplot=findobj(obj.ax,'Tag',tagID);
                delete(myplot);
            end
        end
        
        
    end
    
    methods(Abstract)
        % run prior to plotting any data series
        prepare_axes(obj)  
        
         % results of this function are what are graphed
        [x,y]=calculate(obj,catalog)
    end
    
    methods(Access=protected)
        function add_big_series(obj, catalog, minbigmag)
            % controls the plotting of "big" events 
            bigProps = ZmapGlobal.Data.BigEventOpts;
            idx = find(catalog.Magnitude >= minbigmag);
            if bigProps.UseMainEventSizeFunction
                sizeFcn = str2func(ZmapGlobal.Data.MainEventOpts.MarkerSizeFcn);
                bigProps.SizeFcn = @(c) sizeFcn(c.Magnitude);
            end
            bigProps.YData       = idx;
            bigProps.DisplayName = "Events >= " + minbigmag;
            obj.add_series(catalog.subset(idx), 'big events', bigProps);
         
        end
    end
    
    methods(Access=protected, Static)
        
        function [v,found,strippedC] = getProperty(C,name,defaultval)
            % [v, found,strippedC] = GETPROPERTY(C,name,defaultval)
            % looks for property NAME in cell C. if not found, returns DEFAULTVAL
            flds=C(1:2:end);
            strippedC=C;
            is_the_one=strcmpi(flds,name);
            found=any(is_the_one);
            if found
                valIdx=find(is_the_one, 1, 'last') * 2;
                v = C{valIdx};
                strippedC(valIdx-1:valIdx) = [];
            else
                if exist('defaultval','var')
                    v = defaultval;
                else
                    v = [];
                end
            end
        end
    end
end

function mustBeAxesOrEmpty(val)
    if ~( isempty(val) || val.Type=="axes" )
        error("value must be an axes or be empty")
    end
end
