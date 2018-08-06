classdef AnalysisWindow < handle
    % AnalysisWindow 
    %
    %   add_series    : 
    %   remove_series :
    %   prepare_axes  : 
    %   calculate     : 
    
    properties
        ax               % handle for the axis
        prepared = false % axis has been prepared (labeled, titled, scaled, etc.) 
        nMarkers = 3;    % number of markers in the plot
    end

    methods
        function obj = AnalysisWindow(ax)
            obj.ax=ax;
        end
        
        function h=add_series(obj, catalog, tagID, varargin)
            % obj.ADD_SERIES(catalog, tagID, [[Name, Value],...])
            p = inputParser();
            p.addRequired('catalog',    @(x)isa(x,'ZmapCatalog'));
            p.addRequired('tagID',      @(x)ischar(tagID)|| isstring(tagID));
            
            p.addParameter('UseCalculation', @obj.calculate, ...
                @(x)isa(x,'function_handle') && ... % must be a function that
                nargout(x)==2 ...                   % must return [x,y]
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
        prepare_axes(obj)
        [x,y]=calculate(obj,catalog)
    end
    
    methods(Access=protected)
        function add_big_series(obj, catalog, minbigmag)
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
            % [v,found,strippedC] = GETPROPERTY(C,name,defaultval)
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

