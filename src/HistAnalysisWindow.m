classdef HistAnalysisWindow < AnalysisWindow
    % analysis window for histograms, overwrites some ploting basics
    properties(SetObservable)
        BinBy  (1,:)   char    {HistAnalysisWindow.mustBeCatalogProperty} = 'Magnitude'
        UseLogYScale   logical     = false
        BinWidth
    end
    properties
        BinState       containers.Map
    end
    
    properties(Constant)
        HistogrammableCatalogProperties = {...
            'Date', 'Depth', 'Latitude', 'Longitude',...
            'Magnitude', 'MagnitudeType',...
            'Dip', 'DipDirection', 'Rake'};
        ValidHistogramFields        = HistAnalysisWindow.fillValidHistogramFields;
    end
    % note also: morebins, fewerbins functions
    
    methods
        function obj=HistAnalysisWindow(ax, BinBy, BinByListener)
            obj@AnalysisWindow(ax);
            
            if exist('BinBy','var')
                obj.BinBy = BinBy;
            end
            if exist('BinByListener','var') && ~isempty(BinByListener)
                obj.addlistener('BinBy','PostSet',BinByListener);
            end
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
            %   PARAMETERIZED:  as name,value. for example.. obj.add_series(cat,tag, 'FontSize',23)
            %
            %     Additional Parameterized properties will be interpreted as histogram properties,
            %          Such as BinLimits, BinWidth, BinEdges, BinCenters, NumBins, DisplayStyle,...
            %          BinMethod, LineWidth, etc...
            
            p = inputParser();
            p.addRequired('catalog',    @(x)isa(x,'ZmapCatalog'));
            p.addRequired('tagID',      @(x)ischar(tagID) || isstring(tagID));
            
            p.KeepUnmatched = true;
           p.parse(catalog, tagID, varargin{:});
            
            props = p.Unmatched;
            
            props = HistAnalysisWindow.adapt_colors(props);
            
            if ~obj.prepared
                obj.prepare_axes();
                obj.prepared = true;
            end
            
            h = findobj(obj.ax,'Tag', tagID);
            
            props.Tag = tagID;
            %props.DisplayName = catalog.Name;
            
            % do not assume that properties that are valid today will be valid tommorrow.
            % anyhists = findobj(obj.ax,'Type','histogram');
            first_in_series = isempty(findobj(obj.ax,'Type','histogram'));
            
            histProps = HistAnalysisWindow.KeepValidHistogramProperties(props);
            
            if isempty(h)
                % add new series
                obj.ax.NextPlot = 'add';
                h = histogram(obj.ax, catalog.(obj.BinBy), 'Tag', tagID);
                set(h, histProps);
                obj.ax.NextPlot ='replace';
                h.UserData = catalog;
            else
                h.Data=catalog.(obj.BinBy);
                set(h, histProps);
                % replace data in existing series
            end
            
            if first_in_series || (~isempty(histProps) && ismember('BinWidth', fieldnames(histProps)))
                obj.BinWidth = h.BinWidth;
            else
                h.BinWidth = obj.BinWidth;
            end
        end
        
        
        function prepare_axes(obj)
            % shrink axes, and add a control that allows the user to change what property will be counted.
            
            % start with fresh axes
            cla(obj.ax);
            
            % do not take for granted this is a simple figure. make every item relative to container
            c=obj.ax.Parent; % get container
            c.Units='pixels';
            obj.ax.Units='pixels';
            p=obj.ax.OuterPosition;
            obj.ax.OuterPosition([2 4]) = p([2 4]) + [30 , -30];
            popupLeft =min([p(3)/2+p(1), p(4)-155]);
            
            % label for popup menu
            lb = uicontrol(c,'Style','text','String','Histogram of : ','HorizontalAlignment','right',...
                'Units','pixels','Position',[popupLeft-150, p(2)+5,150,25]);
            
            % create the popup menu
            dd = uicontrol(c,'Style','popupmenu',...
                'Value',find(string(obj.BinBy)==HistAnalysisWindow.HistogrammableCatalogProperties),...
                'String',HistAnalysisWindow.HistogrammableCatalogProperties,...
                'Units','pixels','Position',[popupLeft, p(2)+5, 150, 25],...
                'Callback',@obj.changedfield);
            % put units back so that items scale properly when size changes
            obj.ax.Units='normalized';
            c.Units = 'normalized';
            lb.Units = 'normalized';
            dd.Units = 'normalized';
            
            
        end
        
        function [x,y]=calculate(obj,catalog)
            x=nan;
            y=nan;
        end
        
        
        function changedfield(obj, src, ev)
            assert(obj.ax.Tag=="histograms")
            % oldTag = obj.ax.Tag;
            old = obj.BinBy;
            obj.BinBy = src.String(src.Value);
            h_s=[findobj(obj.ax.Children,'flat','Type','histogram'),
                findobj(obj.ax.Children,'flat','Type','categoricalhistogram'),];
            h=h_s(1);
            toCopy={'NumBins','BinEdges','Normalization','DisplayStyle','Orientation'};
            
            obj.ax.NextPlot = 'replaceChildren';
            switch class(h.UserData.(obj.BinBy))
                case 'categorical'
                    if ~isa(obj.ax.XAxis,'matlab.graphics.axis.decorator.CategoricalRuler')
                        obj.ax.XAxis = matlab.graphics.axis.decorator.CategoricalRuler;
                        obj.ax.NextPlot = 'replace';
                    end
                case 'datetime'
                    if ~isa(obj.ax.XAxis,'matlab.graphics.axis.decorator.DatetimeRuler')
                        obj.ax.XAxis = matlab.graphics.axis.decorator.DatetimeRuler;
                        obj.ax.NextPlot = 'replace';
                    end
                case 'duration'
                    if ~isa(obj.ax.XAxis,'matlab.graphics.axis.decorator.DurationRuler')
                        obj.ax.XAxis = matlab.graphics.axis.decorator.DurationRuler;
                        obj.ax.NextPlot = 'replace';
                    end
                otherwise
                    if ~isa(obj.ax.XAxis,'matlab.graphics.axis.decorator.NumericRuler')
                        obj.ax.XAxis = matlab.graphics.axis.decorator.NumericRuler;
                        obj.ax.NextPlot = 'replace';
                    end
            end
           % if replace_histograms_entirely
                % stash the important details. well, some of them, anyway.
                stash = struct([]);
                for i=1:numel(h_s)
                    % order matters! If the DisplayStyle is changed AFTER the colors, then all is reset
                    stash(i).DisplayStyle = h_s(i).DisplayStyle;
                    stash(i).Tag = h_s(i).Tag;
                    stash(i).UserData = h_s(i).UserData;
                    stash(i).LineWidth = h_s(i).LineWidth;
                    stash(i).LineStyle = h_s(i).LineStyle;
                    stash(i).FaceColor = h_s(i).FaceColor;
                    stash(i).EdgeColor = h_s(i).EdgeColor;
                    stash(i).Visible = h_s(i).Visible;
                end
                
                axStash=struct();
                if obj.ax.NextPlot=="replace" 
                    % our axes is about to go bye-bye. save what we can.
                    allFields = fieldnames(set(obj.ax));
                    thingsToStash=[allFields(contains(allFields,'Grid'));...
                        {'Tag';'UserData'};...
                        allFields(contains(allFields,'Font'))];
                    
                    for i=1:numel(thingsToStash)
                        axStash.(thingsToStash{i}) = obj.ax.(thingsToStash{i});
                    end
                end
                
                delete(h_s);
                for i=numel(stash): -1: 1
                    % for some reason, histogram is destroying the axes!
                    h=histogram(obj.ax,stash(i).UserData.(obj.BinBy));
                    
                    set(h,stash(i));
                    obj.ax.NextPlot = 'add';
                end
                if ~isempty(axStash)
                        set(obj.ax,  axStash);
                end
                assert(obj.ax.Tag=="histograms")
                obj.ax.NextPlot = 'replace';
                % set(h,stash(i));
                set(ancestor(obj.ax,'figure'),'CurrentAxes',obj.ax);
                axis auto
                %ned
        end
    end
    
    methods(Access=protected)
        function add_big_series(obj, catalog, minbigmag)
            % big series have no affect on the histograms
            do_nothing()
        end
        
    end
    
    methods(Access=protected, Hidden)
        
        
    end
    
    
    methods(Static) % to be hidden
        function mustBeCatalogProperty(x)
            assert(ismember(x,properties('ZmapCatalog')));
        end
        
        function s = fillValidHistogramFields()
            f = figure('Visible','off');
            ax=axes(f);
            h = histogram(ax);
            s = fieldnames(set(h));
            delete(f)
        end
        
        function s = KeepValidHistogramProperties(s)
            if isempty(s)
                return
            end
            fn = fieldnames(s);
            invalidProps = fn(~ismember(fn, HistAnalysisWindow.ValidHistogramFields));
            if ~isempty(invalidProps)
                s = rmfield(s,invalidProps);
            end
        end
        function props = adapt_colors(props)
            % sometimes just a "Color" property is provided, translate this into Edge and Face Colors.
            
            if isfield(props,'Color')
                if isfield(props,'DisplayStyle')
                    switch props.DisplayStyle
                        case 'stairs'
                            if ~isfield(props,'EdgeColor')
                                props.EdgeColor = props.Color;
                            end
                        otherwise
                            if ~isfield(props,'FaceColor')
                                props.FaceColor = props.Color;
                            end
                    end
                                
                else
                    if ~isfield(props,'EdgeColor')
                        props.EdgeColor = props.Color;
                    end
                    
                    if ~isfield(props,'FaceColor')
                        props.FaceColor = props.Color;
                    end
                end
            end
        end
        
    end
end
