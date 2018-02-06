classdef ZmapMainWindow < handle
    % ZMAPMAINWINDOW
    
    properties
        catalog % event catalog
        rawcatalog;
        shape % used to subset catalog by selected area
        daterange % used to subset the catalog with date ranges
        Grid % grid that covers entire catalog area
        gridopts % used to define the grid
        fig % figure handle
        xsgroup;
        xs_tabs;
        prev_states=Stack(5);
        undohandle;
        Features;
    end
    methods (Static)
        function feat=features()
            persistent feats
            ZG=ZmapGlobal.Data;
            if isempty(feats)
                feats=ZG.features;
                MapFeature.foreach_waitbar(feats,'load');
            end
            feat=feats;
        end
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

            add_menu_divider()
            if exist('catalog','var')
                obj.rawcatalog=catalog;
            else
                ZG=ZmapGlobal.Data;
                obj.rawcatalog=ZG.primeCatalog;
            end
            obj.daterange=[min(obj.rawcatalog.Date) max(obj.rawcatalog.Date)];
            % initialize from the existing globals
            ZG=ZmapGlobal.Data;
            obj.Features=ZG.features;
            
            obj.shape=ZG.selection_shape;
            obj.catalog=obj.filtered_catalog();
            obj.Grid=ZG.Grid;
            obj.gridopts= ZG.gridopt;
            
            obj.fig.Name=sprintf('%s [%s - %s]',obj.catalog.Name ,char(min(obj.catalog.Date)),...
                char(max(obj.catalog.Date)));
            
            obj.Features=ZmapMainWindow.features();
            %MapFeature.foreach_waitbar(obj.Features,'load');
            
            obj.plot_base_events();
            
            obj.prev_states=Stack(5); % remember last 5 catalogs
            obj.pushState();
            
            emm = uimenu(obj.fig,'label','Edit!');
            obj.undohandle=uimenu(emm,'label','Undo','Callback',@(s,v)obj.cb_undo(s,v),'Enable','off');
            uimenu(emm,'label','Redraw','Callback',@(s,v)obj.cb_redraw(s,v));
            uimenu(emm,'label','xsection','Callback',@(s,v)obj.cb_xsection);
            % TODO: undo could also stash grid options & grids
            
            
            TabLocation = 'top'; % 'top','bottom','left','right'
            uitabgroup('Units','pixels','Position',[800 380 390 360],'TabLocation',TabLocation,'Tag','UR plots');
            uitabgroup('Units','pixels','Position',[800 10 390 360],'TabLocation',TabLocation,'Tag','LR plots');
            
            obj.xsgroup=uitabgroup('Units','pixels','Position',[15 10 760 215],'TabLocation',TabLocation,'Tag','xsections');
            %obj.xs_tabs=uitab(obj.xsgroup,'title','A - A'''); % tabs for cross-sections created as cross-sections are defined.
            %a=axes(obj.xs_tabs(1),'Units','pixels','Position',[40 35 680 125],'YDir','reverse');
            %xlabel(a,'Distance along profile [km]'); ylabel(a,'Depth')
            
            obj.replot_all()
        end
        
        function replot_all(obj)
            obj.undohandle.Enable=tf2onoff(~isempty(obj.prev_states));
            obj.catalog=obj.filtered_catalog();
            obj.fig.Name=sprintf('%s [%s - %s]',obj.catalog.Name ,char(min(obj.catalog.Date)),...
                char(max(obj.catalog.Date)));
            figure(obj.fig)
            obj.plotmainmap();
            % Each tab group will have a "SelectionChanghedFcn", "CreateFcn", "DeleteFcn", "UIContextMenu"
            
            obj.plothist('Magnitude',obj.catalog.Magnitude,'UR plots');
            obj.plothist('Depth',obj.catalog.Depth,'UR plots');
            obj.plothist('Date',obj.catalog.Date,'UR plots');
            obj.plothist('Hour',hours(obj.catalog.Date.Hour),'UR plots');
            
            obj.fmdplot('UR plots');
           
            obj.cumplot('LR plots');
            obj.cummomentplot('LR plots');
            obj.time_vs_something_plot('Time-Mag',TimeMagnitudePlotter,'LR plots');
            obj.time_vs_something_plot('Time-Depth',TimeDepthPlotter, 'LR plots');
        end
        
        function plot_base_events(obj)
            % plot all events from catalog as dots before it gets filtered by shapes, etc.
            % call once at beginning
            axm=findobj(obj.fig,'Tag','mainmap_ax');
            if isempty(axm)
                axm=axes('Units','pixels','Position',[70 270 680 450]);
            end
            
            alleq = findobj(obj.fig,'Tag','all events');
            if isempty(alleq)
                alleq=plot(axm, obj.rawcatalog.Longitude, obj.rawcatalog.Latitude,'.','color',[.76 .75 .8],'Tag','all events');
                alleq.ZData=obj.rawcatalog.Depth;
            end
            
            axm.Tag = 'mainmap_ax';
            axm.TickDir='out';
            axm.Box='on';
            axm.ZDir='reverse';
            xlabel(axm,'Longitude')
            ylabel(axm,'Latitude');
            
            MapFeature.foreach(obj.Features,'plot',axm);
            c=uicontextmenu(obj.fig,'Tag','mainmap context');
            % options for choosing a shape
            ShapePolygon.AddPolyMenu(c,obj.shape);
            ShapeCircle.AddCircleMenu(c, obj.shape);
            for j=1:numel(c.Children)
                if startsWith(c.Children(j).Tag,{'circle','poly'})
                    c.Children(j).Callback={@updatewrapper,c.Children(j).Callback};
                end
            end
            uimenu(c,'Label','Clear Shape','Callback',{@updatewrapper,@(~,~)cb_shapeclear});
            uimenu(c,'Label','Define X-section','Separator','on','Callback',@(s,v)obj.cb_xsection);
            axm.UIContextMenu=c;
            
            mapoptionmenu=uimenu(obj.fig,'Label','Map Options','Tag','mainmap_menu_overlay');
            uimenu(mapoptionmenu,'Label','Set aspect ratio by latitude',...
                'callback',@toggle_aspectratio,...
                'checked',ZmapGlobal.Data.lock_aspect);
            if strcmp(ZmapGlobal.Data.lock_aspect,'on')
                daspect(axm, [1 cosd(mean(axm.YLim)) 10]);
            end
            
            uimenu(mapoptionmenu,'Label','Toggle Lat/Lon Grid',...
                'callback',@toggle_grid,...
                'checked',ZmapGlobal.Data.mainmap_grid);
            if strcmp(ZmapGlobal.Data.mainmap_grid,'on')
                grid(axm,'on');
            end
            
            function updatewrapper(s,v,f)
                f(s,v);
                obj.shape=copy(ZmapGlobal.Data.selection_shape);
                obj.cb_redraw();
            end
            
            function cb_shapeclear
                ZG=ZmapGlobal.Data;
                ZG.selection_shape=ShapeGeneral('unassigned');
                ZG.selection_shape.clearplot();
            end
            
            function toggle_aspectratio(src, ~)
                src.Checked=toggleOnOff(src.Checked);
                switch src.Checked
                    case 'on'
                        daspect(axm, [1 cosd(mean(axm.YLim)) 10]);
                    case 'off'
                        daspect(axm,'auto');
                end
                ZG = ZmapGlobal.Data;
                ZG.lock_aspect = src.Checked;
                %align_supplimentary_legends();
            end
            
            function toggle_grid(src, ~)
                src.Checked=toggleOnOff(src.Checked);
                grid(axm,src.Checked);
                %ZG = ZmapGlobal.Data;
                %ZG.lock_aspect = src.Checked;
                %align_supplimentary_legends();
                drawnow
            end
        end
        
        function plotmainmap(obj)
             % set up main map window
             
            axm=findobj(obj.fig,'Tag','mainmap_ax');
            
            
            
            % initialize from the existing globals
            %ZG=ZmapGlobal.Data;
            %obj.Features=ZG.features;
            %MapFeature.foreach_waitbar(obj.Features,'load');
           % MapFeature.foreach(obj.Features,'plot',axm);
            
            
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
                obj.shape.plot(axm,@obj.shapeChangedFcn)
            end
            hold(axm,'off');
        end
        
        function myTab = findOrCreateTab(obj, parent, title)
            % FINDORCREATETAB if tab doesn't exist yet, create it
            %    parent : 
            myTab=findobj(obj.fig,'Title',title,'-and','Type','uitab');
            if isempty(myTab)
                p = findobj(obj.fig,'Tag',parent);
                myTab=uitab(p, 'Title',title);
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
            uimenu(c,'Label','start here','Callback',@(~,~)obj.cb_starthere(ax));
            uimenu(c,'Label','end here','Callback',@(~,~)obj.cb_endhere(ax));
            uimenu(c, 'Label', 'trim to largest event','Callback',@obj.cb_trim_to_largest);
            p.UIContextMenu=c;
            
            uimenu(p.UIContextMenu,'Label','Open in new window','Callback',@(~,~)obj.cb_timeplot());
            c=uicontextmenu('tag','CumPlot bg contextmenu');
            ax.UIContextMenu=c;
            uimenu(c,'Label','Open in new window','Callback',@(~,~)obj.cb_timeplot());
            
        end
        function cb_timeplot(obj)
            ZG=ZmapGlobal.Data;
            ZG.newt2=obj.catalog;
            timeplot();
        end
        
            function cb_starthere(obj,ax)
                disp(ax)
                [x,~]=click_to_datetime(ax);
                obj.pushState();
                obj.daterange(1)=x;
                %obj.catalog=obj.catalog.subset(obj.catalog.Date>=x);
                obj.replot_all();
            end
            
            function cb_endhere(obj,ax)
                [x,~]=click_to_datetime(ax);
                obj.pushState();
                obj.daterange(2)=x;
                %obj.catalog=obj.catalog.subset(obj.catalog.Date<=x);
                obj.replot_all();
            end
            
            function cb_trim_to_largest(obj,~,~)
                biggests = obj.catalog.Magnitude == max(obj.catalog.Magnitude);
                idx=find(biggests,1,'first');
                obj.pushState();
                obj.daterange(1)=obj.catalog.Date(idx);
                %obj.catalog = obj.catalog.subset(obj.catalog.Date>=obj.catalog.Date(idx));
                obj.replot_all()
            end
            
        function cummomentplot(obj,tabgrouptag)
            myTab = obj.findOrCreateTab(tabgrouptag, 'Moment');
            delete(myTab.Children);
            ax=axes(myTab);
            [fCumMoment, vCumMoment, vMoment] = calc_moment(obj.catalog);
            p=plot(ax,obj.catalog.Date,vCumMoment,'b','linewidth',2);
            ylabel(ax,'Cummulative Moment');
            xlabel(ax,'Time');
            c=uicontextmenu('tag','CumMom line contextmenu');
            uimenu(c,'Label','start here','Callback',@(~,~)obj.cb_starthere(ax));
            uimenu(c,'Label','end here','Callback',@(~,~)obj.cb_endhere(ax));
            uimenu(c, 'Label', 'trim to largest event','Callback',@obj.cb_trim_to_largest);
            p.UIContextMenu=c;
            
            uimenu(p.UIContextMenu,'Label','Open in new window','Callback',@(~,~)timeplot());
            c=uicontextmenu('tag','CumMom bg contextmenu');
            ax.UIContextMenu=c;
            uimenu(c,'Label','Open in new window','Callback',@(~,~)timeplot());
            
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
        
        function shapeChangedFcn(obj,oldshapecopy,newshapecopy)
            obj.prev_states.push({obj.catalog, oldshapecopy, obj.daterange});
            obj.replot_all();
        end
        function cb_undo(obj,~,~)
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
        
        function cb_xsection(obj)
            % main map axes, where the cross section outline will be plotted
            axm=findobj(obj.fig,'Tag','mainmap_ax');
            axes(axm);
            
            [c2, zans] = plot_cross_section(obj.catalog);
            mytitle=[zans.startlabel ' - ' zans.endlabel];
            
            xsTabGroup = findobj(obj.fig,'Tag','xsections','-and','Type','uitabgroup');
            % mytab=obj.findOrCreateTab(xsTabGroup.Tag, mytitle);
            
            mytab=findobj(obj.fig,'Title',mytitle,'-and','Type','uitab');
            if ~isempty(mytab)
                delete(mytab);
            end
            
            p = findobj(obj.fig,'Tag',xsTabGroup.Tag);
            mytab=uitab(p, 'Title',mytitle,'ForegroundColor',zans.color,'DeleteFcn',zans.DeleteFcn);
            
            c=uicontextmenu(obj.fig);
            uimenu(c,'Label','Info','Callback',@(~,~) msgbox(c2.info(),mytitle));
            uimenu(c,'Separator','on',...
                'Label','Delete',...
                'Callback',@(~,~)delete(mytab));
            
            mytab.UIContextMenu=c;
            
            ax=axes(mytab,'Units','pixels','Position',[40 35 680 125],'YDir','reverse');
            plot_events_along_strike(ax,c2,zans);
            
            function plot_events_along_strike(ax,c2,zans)
                scatter(ax, c2.dist_along_strike_km, c2.Depth,mag2dotsize(c2.Magnitude),years(c2.Date-min(c2.Date)));
                ax.YDir='reverse';
                ax.XLim=[0 c2.curvelength_km];
                ax.XTickLabel{1}=zans.startlabel;
                if ax.XTick(end) ~= c2.curvelength_km
                    ax.XTick(end+1)=c2.curvelength_km;
                    ax.XTickLabel{end+1}=zans.endlabel;
                else
                    ax.XTickLabel{end}=zans.endlabel;
                end
                
                
                grid(ax,'on');
                xlabel('Distance along strike [km]');
                ylabel('Depth');
                %title(sprintf('Profile: %s to %s',zans.startlabel,zans.endlabel));
            end
        end
        %% push and pop state
        function pushState(obj)
            obj.prev_states.push({obj.catalog, copy(obj.shape), obj.daterange});
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
            obj.daterange=items{3};
            obj.fig.Pointer='arrow';
            pause(0.01);
        end
        
        function c=filtered_catalog(obj)
            c=obj.rawcatalog;
            c=c.subset(c.Date>=obj.daterange(1) & c.Date<=obj.daterange(2));
            if ~isempty(obj.shape)
                c=c.subset(obj.shape.isInside(c.Longitude,c.Latitude));
            end
        end
    end % METHODS
end % CLASSDEF

function A = toggleOnOff(A)
    if strcmp(A,'on')
        A='off';
    else
        A='on';
    end
end