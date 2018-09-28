classdef HistAnalysisWindow < AnalysisWindow
    % analysis window for histograms, overwrites some ploting basics
    methods
        function obj=HistAnalysisWindow(ax)
            obj@AnalysisWindow(ax);
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
            
            % set properties unique to a scatter
            props.SizeData = p.Results.SizeFcn(catalog);
            props.CData = p.Results.ColorFcn(catalog);
            
            
            if ~obj.prepared
                obj.prepare_axes();
                obj.prepared = true;
            end
            
            h = findobj(obj.ax,'Tag', tagID);
            
            props.Tag = tagID;
            %props.DisplayName = catalog.Name;
            
            
            if isempty(h)
                obj.ax.NextPlot = 'add';
                h=histogram(obj.ax, x, y);
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
        
        
    end
    
    methods(Access=protected)
        function add_big_series(obj, catalog, minbigmag)
            % big series have no affect on the histograms
            do_nothing()
        end
    end
end