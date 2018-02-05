classdef ZmapMainWindow < handle
    % ZMAPMAINWINDOW
    
    properties
        catalog % event catalog
        rawcatalog;
        shape % used to subset catalog by selected area
        views % used to subset the catalog with date/latlon/depth/mag ranges
        Grid % grid that covers entire catalog area
        gridopts % used to define the grid
        fig % figure handle
        xsgroup;
        xs_tabs;
        prev_states=Stack(5);
        undohandle;
    end
    
    methods
        function obj=ZmapMainWindow(fig,catalog)
            %TOFIX filtering of Dates are not preserved when "REDRAW" is clicked
            %TOFIX shape lags behind
            if exist('fig','var')
                delete(fig);
            end
            obj.fig=figure('Position',[50 50 1200 750],'Name','Catalog Name and Date','Units',...
                'pixels','Tag','Zmap Main Window','NumberTitle','off');
            
            % plot all events from catalog as dots before it gets filtered by shapes, etc.
            axm=findobj(obj.fig,'Tag','mainmap_ax');
            if isempty(axm)
                axm=axes('Units','pixels','Position',[70 270 680 450]);
            end
            if exist('catalog','var')
                obj.rawcatalog=catalog;
            else
                ZG=ZmapGlobal.Data;
                obj.rawcatalog=ZG.primeCatalog;
            end
            alleq=plot(axm, obj.rawcatalog.Longitude, obj.rawcatalog.Latitude,'.','color',[.76 .75 .8],'Tag','all events');
            alleq.ZData=obj.rawcatalog.Depth;
            
            axm.Tag = 'mainmap_ax';
            axm.TickDir='out';
            axm.Box='on';
            axm.ZDir='reverse';
            xlabel(axm,'Longitude')
            ylabel(axm,'Latitude');
            
            
            % initialize from the existing globals
            ZG=ZmapGlobal.Data;
            
            
            obj.shape=ZG.selection_shape;
            obj.catalog=obj.filtered_catalog();
            obj.Grid=ZG.Grid;
            obj.gridopts= ZG.gridopt;
            
            obj.prev_states=Stack(5); % remember last 5 catalogs
            obj.pushState();
            add_menu_divider()
            emm = uimenu(obj.fig,'label','Edit!');
            obj.undohandle=uimenu(emm,'label','Undo','Callback',@(s,v)obj.cb_undo(s,v),'Enable','off');
            uimenu(emm,'label','Redraw','Callback',@(s,v)obj.cb_redraw(s,v));
            % TODO: undo could also stash grid options & grids
            
            
            TabLocation = 'top'; % 'top','bottom','left','right'
            uitabgroup('Units','pixels','Position',[800 380 390 360],'TabLocation',TabLocation,'Tag','UR plots');
            uitabgroup('Units','pixels','Position',[800 10 390 360],'TabLocation',TabLocation,'Tag','LR plots');
            
            obj.xsgroup=uitabgroup('Units','pixels','Position',[15 10 760 215],'TabLocation',TabLocation,'Tag','xsections');
            obj.xs_tabs=uitab(obj.xsgroup,'title','A - A'''); % tabs for cross-sections created as cross-sections are defined.
            a=axes(obj.xs_tabs(1),'Units','pixels','Position',[40 35 680 125],'YDir','reverse');
            xlabel(a,'Distance along profile [km]'); ylabel(a,'Depth')
            
            obj.replot_all()
        end
        
        function replot_all(obj)
            figure(obj.fig)
            obj.plotmainmap();
            % Each tab group will have a "SelectionChanghedFcn", "CreateFcn", "DeleteFcn", "UIContextMenu"
            
            obj.plothist('Magnitude',obj.catalog.Magnitude,'UR plots');
            obj.plothist('Depth',obj.catalog.Depth,'UR plots');
            obj.plothist('Date',obj.catalog.Date,'UR plots');
            obj.plothist('Hour',hours(obj.catalog.Date.Hour),'UR plots');
            
            obj.fmdplot('UR plots');
           
            obj.cumplot('LR plots');
            obj.time_vs_something_plot('Time-Mag',TimeMagnitudePlotter,'LR plots');
            obj.time_vs_something_plot('Time-Depth',TimeDepthPlotter, 'LR plots');
        end
        
        function plotmainmap(obj)
             % set up main map window
            axm=findobj(obj.fig,'Tag','mainmap_ax');
            eq=findobj(axm,'Tag','active quakes');
            
            if isempty(eq)
                hold(axm,'on');
                eq=scatter(axm, obj.catalog.Longitude, obj.catalog.Latitude, ...
                    mag2dotsize(obj.catalog.Magnitude),datenum(obj.catalog.Date),...
                    'Tag','active quakes');
                eq.ZData=obj.catalog.Depth;
                eq.Marker='s';
                hold(axm,'off');
            else
                eq.XData=obj.catalog.Longitude;
                eq.YData=obj.catalog.Latitude;
                eq.ZData=obj.catalog.Depth;
                eq.SizeData=mag2dotsize(obj.catalog.Magnitude);
                eq.CData=datenum(obj.catalog.Date);
            end
            
            hold(axm,'on');
            if ~isempty(obj.shape)
                obj.shape.plot(axm)
            end
            hold(axm,'off');
        end
        
        function myTab = findOrCreateTab(obj, parent, title)
            % FINDORCREATETAB if tab doesn't exist yet, create it
            myTab=findobj(obj.fig,'Title',title,'-and','Type','uitab');
            if isempty(myTab)
                myTab=uitab(findobj(obj.fig,'Tag',parent), 'Title',title);
            end
        end
        
        function plothist(obj, name, values, tabgrouptag)
            % PLOTHIST plot a histogram in the Upper Right plot area
            
            myTab = obj.findOrCreateTab(tabgrouptag, name);
            
            %if axes doesn't exist, create it and plot
            ax=findobj(myTab,'Type','axes');
            if isempty(ax)
                ax=axes(myTab);
                hisgra(obj.catalog,name,ax)
            else
                ax.Children.Data=values; %TODO move into hisgra
            end
            
        end
        
        function fmdplot(obj, tabgrouptag)
            
            myTab = obj.findOrCreateTab(tabgrouptag, 'FMD');
            
            delete(myTab.Children);
            ax=axes(myTab);
            ylabel(ax,'Cum # events');
            xlabel(ax,'Magnitude');
            
            %mainax=findobj(obj.fig,'Tag','mainmap_ax');
            bdiff2(obj.catalog,false,ax);
            
            %mainax2=findobj(obj.fig,'Tag','mainmap_ax');
            %assert(mainax==mainax2);
        end
        
        function cumplot(obj, tabgrouptag)
            % Cumulative Event Plot
            
            
            myTab = obj.findOrCreateTab(tabgrouptag, 'cumplot');
            
            delete(myTab.Children);
            ax=axes(myTab);
            ax.TickDir='out';
            p=plot(ax,obj.catalog.Date,1:obj.catalog.Count,'r','linewidth',2);
            ylabel(ax,'Cummulative Number of events');xlabel(ax,'Time');
            c=uicontextmenu('tag','CumPlot line contextmenu');
            uimenu(c,'Label','start here','Callback',@(~,~)cb_starthere(ax));
            uimenu(c,'Label','end here','Callback',@(~,~)cb_endhere(ax));
            uimenu(c, 'Label', 'trim to largest event','Callback',@cb_trim_to_largest);
            p.UIContextMenu=c;
            
            uimenu(p.UIContextMenu,'Label','Open in new window','Callback',@(~,~)timeplot());
            c=uicontextmenu('tag','CumPlot bg contextmenu');
            ax.UIContextMenu=c;
            uimenu(c,'Label','Open in new window','Callback',@(~,~)timeplot());
            
            function cb_starthere(ax)
                [x,~]=click_to_datetime(ax);
                obj.pushState();
                obj.catalog=obj.catalog.subset(obj.catalog.Date>=x);
                obj.replot_all();
            end
            
            function cb_endhere(ax)
                [x,~]=click_to_datetime(ax);
                obj.pushState();
                obj.catalog=obj.catalog.subset(obj.catalog.Date<=x);
                obj.replot_all();
            end
            
            function cb_trim_to_largest(~,~)
                biggests = obj.catalog.Magnitude == max(obj.catalog.Magnitude);
                idx=find(biggests,1,'first');
                obj.pushState();
                obj.catalog = obj.catalog.subset(obj.catalog.Date>=obj.catalog.Date(idx));
                obj.replot_all()
            end
        end
        
        function time_vs_something_plot(obj, name, whichplotter, tabgrouptag)
            % TIME_VS_SOMETHING_PLOT
            % whchplotter can be an instance of either TimeMagnitudePLottter or TimeDepthPlotter
            % if tab doesn't exist yet, create it
            
            myTab = obj.findOrCreateTab(tabgrouptag, name);
            
            delete(myTab.Children);
            ax=axes(myTab);
            whichplotter.plot(obj.catalog,ax);
            ax.Title=[];
            c=uicontextmenu('tag',[name ' contextmenu']);
            uimenu(c,'Label','Open in new window','Callback',@(~,~)whichplotter.plot(obj.catalog));
            ax.UIContextMenu=c;
        end
        
        function cb_undo(obj,s,~)
            obj.popState()
            obj.replot_all();
        end
        
        function cb_redraw(obj,~,~)
            % REDRAW if things have changed, then also push the new state
            watchon
            item=obj.prev_states.peek();
            do_stash=true;
            if ~isempty(item)
                do_stash = ~strcmp(item{1}.summary('stats'),obj.catalog.summary('stats')) ||...
                    ~isequal(obj.shape,item{2});
            end
            if do_stash
                disp('pushing')
                obj.pushState();
            end
            obj.catalog=obj.filtered_catalog();
            obj.replot_all();
            watchoff
        end
        
        %% push and pop state
        function pushState(obj)
            obj.prev_states.push({obj.catalog, copy(obj.shape)});
            obj.undohandle.Enable='on';
        end
        
        function popState(obj)
            obj.fig.Pointer='watch';
            pause(0.01);
            items = obj.prev_states.pop();
            obj.shape=copy(items{2});
            if ~isempty(obj.shape)
                obj.shape.plot(findobj(obj.fig,'Tag','mainmap_ax'))
            end
            obj.catalog = items{1};
            if isempty(obj.prev_states)
                obj.undohandle.Enable='off';
            end
            obj.fig.Pointer='arrow';
            pause(0.01);
        end
        
        function c=filtered_catalog(obj)
            c=obj.rawcatalog;
            if ~isempty(obj.shape)
                c=c.subset(obj.shape.isInside(c.Longitude,c.Latitude));
            end
        end
    end % METHODS
end % CLASSDEF

