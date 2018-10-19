classdef HistAnalysisWindow < AnalysisWindow
    % analysis window for histograms, overwrites some ploting basics
    properties(SetObservable)
        BinBy  (1,:)   char    {HistAnalysisWindow.mustBeCatalogProperty} = 'Magnitude'
        UseLogYScale   logical     = false
    end
    
    properties
        BinState       containers.Map
        BinWidth       struct
    end
    
    properties(Constant)
        HistogrammableCatalogProperties = cell2table({... 
            'Date'          , years(1/12),'';...
            'Depth'         , 5, 'kilometers';  ...  % km
            'Latitude'      , 0.5, 'degrees'; ... % deg
            'Longitude'     , 0.5, 'degrees'; ... % deg
            'Magnitude'     , 0.1, ''; ...
            'MagnitudeType' , 'category', '';...
            'Dip'           , 5, 'degrees';...  % deg
            'DipDirection'  , 5, 'degrees';...  % deg
            'Rake'          , 5, 'degrees'},... % deg
            'VariableNames', {'field', 'default_bin_width','units'});
        ValidHistogramFields        = HistAnalysisWindow.fillValidHistogramFields;
        
        % DateRules contains the logic table describing bin widths for catalogs of certain date ranges
        DateRules = cell2table(...
            {'year'    , years(1)          , years(10);...
            'month'    , years(1)/12       , years(2);...
            'week'     , days(7)           , years(0.5);...
            'day'      , days(1)           , days(20);...
            'hour'     , hours(1)          , hours(12);... 
            'minute'   , minutes(1)        , minutes(5);...
            'second'   , seconds(1)        , seconds(0)},...
            'VariableNames',{'label','bin_width','min_date_range'});
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
            for j=1: height(obj.HistogrammableCatalogProperties)
                thisField = obj.HistogrammableCatalogProperties.field{j};
                thisWidth = obj.HistogrammableCatalogProperties.default_bin_width{j};
                obj.BinWidth(1).(thisField) = thisWidth;
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
            
            props = HistAnalysisWindow.adapt_colors(props); % Color -> FaceColor and/or EdgeColor
            
            if ~obj.prepared
                obj.prepare_axes();
            end
            
            h = findobj(obj.ax,'Tag', tagID);
            
            props.Tag = tagID;
            %props.DisplayName = catalog.Name;
            
            % do not assume that properties that are valid today will be valid tommorrow.
            % anyhists = findobj(obj.ax,'Type','histogram');
            
            histProps = HistAnalysisWindow.KeepValidHistogramProperties(props);
            
            if isempty(h)
                h = add_new_series();
            else
                replace_series_data(h);
            end
            
            %if isprop(h,'BinWidth')
            %    synchronize_bin_widths(obj,h)
            %end
            
            % % % % % % %
            %
            % End of add_series main function
            %
            %% helper functions for add_series
            
            function h=add_new_series()
                obj.ax.NextPlot = 'add';
                h = histogram(obj.ax, catalog.(obj.BinBy), 'Tag', tagID);
                set(h, histProps);
                obj.ax.NextPlot ='replace';
                h.UserData = catalog;
                if ~iscategorical(catalog.(obj.BinBy))
                    h.BinWidth = obj.BinWidth.(obj.BinBy);
                end
            end
            
            function replace_series_data(h)
                h.Data=catalog.(obj.BinBy);
                set(h, histProps);
                h.UserData = catalog;
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
            
            midPointX = p(3) / 2 + p(1);
            
            obj.ax.OuterPosition(4) = p(4) -30;
            controlBottom =  p(4)-45;
            
            % label for popup menu
            lb = uicontrol(c,'Style','text','String','Histogram','HorizontalAlignment','left',...
                'FontWeight','bold','FontSize', 12,...
                'Units','pixels',...
                'Position',[midPointX, controlBottom,150,25]);
            
            % create the popup menu
            currVal = find(string(obj.BinBy)==HistAnalysisWindow.HistogrammableCatalogProperties.field);
            dd = uicontrol(c,'Style','popupmenu',...
                'Value',currVal,...
                'String',HistAnalysisWindow.HistogrammableCatalogProperties.field,...
                'Units','pixels','Position',[midPointX-150, controlBottom, 150, 25],...
                'Callback',@obj.changedfield);
            % put units back so that items scale properly when size changes
            obj.ax.Units='normalized';
            c.Units = 'normalized';
            lb.Units = 'normalized';
            dd.Units = 'normalized';
            obj.prepared = true;
            obj.label_x();
            
            % add context menus
            c=findobj(ancestor(obj.ax,'figure'),'uicontextmenu','-and','Tag',['histogram ' obj.BinBy]);
            if isempty(c)
                c=uicontextmenu('Tag',['histogram ' obj.BinBy]);
                uimenu(c,'Label','Change Number of Bins...',MenuSelectedField(),@cb_change_nBins);
                uimenu(c,'Enable','of','Label','Change Bin Edges...',MenuSelectedField(),@cb_change_bVector);
                uimenu(c,'Label','Default',MenuSelectedField(),@cb_reset);
                uimenu(c,'Label','Open as new figure',MenuSelectedField(),@open_as_new_fig); %FIXME
                addcontext(obj,c);
                obj.ax.UIContextMenu=c;
            else
                obj.ax.UIContextMenu=c;
            end
        
            uimenu(c,'Label','Use Log Scale',MenuSelectedField(),@(s,~)logtoggle(s,'Y'));
            
            yl = ylabel(obj.ax, '# Events per bin');
            yl.UIContextMenu=c;
            
            
            function cb_change_nBins(src,~)
                h=findobj(obj.ax.Children,'flat','Type','histogram');
                def = num2str(h(1).NumBins);
                binsS = inputdlg('Choose number of bins','Histogram Params',1, {def});
                if isempty(binsS)
                    return
                end
                set(h,'NumBins',str2double(binsS{1}));
                obj.BinWidth.(obj.BinBy)=h(1).BinWidth;
                label_x(obj)
            end
            function cb_reset(~,~)
                h=findobj(obj.ax.Children,'flat','Type','histogram');
                if ~isempty(h)
                    idx = find(string(obj.BinBy)==HistAnalysisWindow.HistogrammableCatalogProperties.field);
                    obj.BinWidth.(obj.BinBy) = HistAnalysisWindow.HistogrammableCatalogProperties.default_bin_width{idx};
                    set(h,'BinWidth',obj.BinWidth.(obj.BinBy));
                end
            end
            function open_as_new_fig(~,~)
                f=figure;
                copyobj(obj.ax,f);
                new_ax = f.CurrentAxes;
                title(new_ax, obj.BinBy + " histogram");
            end
            
        end
        
        function label_x(obj)
            % add a label to the x axes
            idx = obj.HistogrammableCatalogProperties.field == string(obj.BinBy);
            szVal = obj.BinWidth.(obj.BinBy);
            unitVal = obj.HistogrammableCatalogProperties.units{idx};
            if isa(szVal,'duration')
                if szVal==years(1/12)
                szVal = '(1/12) yrs';
                end
            end
                
            xlabel(obj.ax, ...
                sprintf('%s, with bin size  [%s %s]', obj.BinBy, string(szVal), unitVal));
        end
        
        function [x,y]=calculate(~,~)
            % this isn't used for histograms
            x=nan;
            y=nan;
        end
        
        
        function changedfield(obj, src, ~)
            
            h_s=findobj(obj.ax.Children, 'flat', 'Type', 'histogram');
            if isempty(h_s)
             	h_s = findobj(obj.ax.Children, 'flat', 'Type','categoricalhistogram');
            else
                obj.BinWidth(1).(obj.BinBy)=min([h_s.BinWidth]);
            end
            
            obj.BinBy = src.String(src.Value);
            
            stash = stash_histogram_properties(h_s);
            
            ruler_changed = apply_correct_ruler( class(h_s(1).UserData.(obj.BinBy)), obj.ax );
            
            if ruler_changed
                obj.ax.NextPlot = 'replace';
                axStash = stash_axes_properties(obj.ax);
                delete(h_s)
                recreate_histograms(obj,stash);
                reapply_axes_properties(obj.ax, axStash)
            else
                obj.ax.NextPlot = 'replaceChildren';
                delete(h_s)
                recreate_histograms(obj,stash);
            end
            
            obj.ax.NextPlot = 'replace';
            
            set(ancestor(obj.ax,'figure'),'CurrentAxes',obj.ax);
            axis auto
            obj.label_x();
            
        end
    end
    
    methods(Access=protected)
        function add_big_series(~, ~, ~)
            % big series have no affect on the histograms
            do_nothing()
        end
        
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
            % Color -> FaceColor and/or EdgeColor depending on DisplayStyle
            % sometimes just a "Color" property is provided, translate this into Edge and Face Colors.
            
            % This only applies if there is a property called COLOR
            if ~isfield(props,'Color')
                return
            end
            
            
            if isfield(props,'DisplayStyle')
                switch props.DisplayStyle
                    case 'stairs'
                        if ~isfield(props,'EdgeColor')
                            props.EdgeColor = props.Color;
                        end
                    otherwise % 'bar'
                        if ~isfield(props,'FaceColor')
                            props.FaceColor = props.Color;
                        end
                end
                return
            end
            
            % If DisplayStyle is unspecified, change evertyhing.
            
            if ~isfield(props,'EdgeColor')
                props.EdgeColor = props.Color;
            end
            
            if ~isfield(props,'FaceColor')
                props.FaceColor = props.Color;
            end
        end
        
    end
end


%% helper functions
%
%
%
%

function rulerChanged = apply_correct_ruler(dataType, ax)
    rulerChanged=false;
    switch dataType
        case 'categorical'
            if ~isa(ax.XAxis,'matlab.graphics.axis.decorator.CategoricalRuler')
                ax.XAxis = matlab.graphics.axis.decorator.CategoricalRuler;
                rulerChanged=true;
            end
        case 'datetime'
            if ~isa(ax.XAxis,'matlab.graphics.axis.decorator.DatetimeRuler')
                ax.XAxis = matlab.graphics.axis.decorator.DatetimeRuler;
                rulerChanged=true;
            end
        case 'duration'
            if ~isa(ax.XAxis,'matlab.graphics.axis.decorator.DurationRuler')
                ax.XAxis = matlab.graphics.axis.decorator.DurationRuler;
                rulerChanged=true;
            end
        otherwise
            if ~isa(ax.XAxis,'matlab.graphics.axis.decorator.NumericRuler')
                ax.XAxis = matlab.graphics.axis.decorator.NumericRuler;
                rulerChanged=true;
            end
    end
end

function stash = stash_histogram_properties(histHandles)
    % stash the important details. well, some of them, anyway.
    stash = struct([]);
    for ii=1:numel(histHandles)
        % order matters! If the DisplayStyle is changed AFTER the colors, then all is reset
        stash(ii).DisplayStyle = histHandles(ii).DisplayStyle;
        stash(ii).Tag = histHandles(ii).Tag;
        stash(ii).UserData = histHandles(ii).UserData;
        stash(ii).LineWidth = histHandles(ii).LineWidth;
        stash(ii).LineStyle = histHandles(ii).LineStyle;
        stash(ii).FaceColor = histHandles(ii).FaceColor;
        stash(ii).EdgeColor = histHandles(ii).EdgeColor;
        stash(ii).Visible = histHandles(ii).Visible;
    end
end

function recreate_histograms(obj, histStash)
    if obj.BinBy == "Date" && isempty(obj.BinWidth.Date)
        for ii=numel(histStash):-1:1
            thiscat =  histStash(ii).UserData;
            earliests(ii)=min(thiscat.Date);
            latests(ii)=max(thiscat.Date);
        end
        r = range([min(earliests) max(latests)]);
        di=1;
        while obj.DateRules.min_date_range(di) >= r && di < height(obj.DateRules)
            di=di+1;
        end
        theseDateRules = obj.DateRules(di,:);
        obj.BinWidth.Date = theseDateRules.bin_width;
    end
                
    % recreate
    for ii=numel(histStash): -1: 1
        hh=histogram(obj.ax, histStash(ii).UserData.(obj.BinBy));
        if isprop(hh,'BinWidth')
            hh.BinWidth=obj.BinWidth.(obj.BinBy);
        end
        set(hh,histStash(ii));
        if obj.ax.NextPlot ~= "add"
            obj.ax.NextPlot = 'add';
        end
    end
end

function axStash = stash_axes_properties(ax)
    axStash=struct();
    % our axes is about to go bye-bye. save what we can.
    allFields = fieldnames(set(ax));
    thingsToStash=[allFields(contains(allFields,'Grid'));...
        {'Tag';'UserData'};...
        allFields(contains(allFields,'Font'))];
    
    for ii=1:numel(thingsToStash)
        axStash.(thingsToStash{ii}) = ax.(thingsToStash{ii});
    end
end

function reapply_axes_properties(ax, axStash)
    set(ax,  axStash);
end


%% functions from hisgra that need to be hooked up
function addcontext(obj, c)
    h=findobj(obj.ax,'Type','histogram');
    switch obj.BinBy
        case 'Date'
            uimenu(c,'separator','on','Label','Events per Day',MenuSelectedField(),@(~,~)cb_set_to_period(h,'day'));
            uimenu(c,'Label','Events per Week',MenuSelectedField(),@(~,~)cb_set_to_period(h,'week'));
            uimenu(c,'Label','Events per Month',MenuSelectedField(),@(~,~)cb_set_to_period(h,'month'));
            uimenu(c,'Label','Events per Year',MenuSelectedField(),@(~,~)cb_set_to_period(h,'year'));
        otherwise
            do_nothing();
    end
    
    function cb_set_to_period(h,unit)
        mindate=min(h.Data); maxdate = max(h.Data);
        mindate=dateshift(mindate,'start',unit,'previous');
        maxdate=dateshift(maxdate,'start',unit,'next');
        delta=maxdate-mindate;
        switch unit
            case 'day'
                edges = mindate : days(1) : maxdate;
            case 'week'
                edges = mindate : days(7) : maxdate;
            case 'year'
                nyears=ceil(years(delta));
                edges = mindate + calendarDuration(0:nyears,0,0);
            case 'month'
                nmonths=ceil(years(delta) .* 12);
                edges = mindate + calendarDuration(0,0:nmonths,0);
        end
        set(findobj(ax,'Type','histogram'),'BinEdges',edges);
        ax.YLabel.String=['# Events per ' unit];
    end
    
    
end
