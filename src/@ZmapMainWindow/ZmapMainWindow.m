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
        xsections;
        xscats;
        xs_tabs;
        prev_states=Stack(10);
        undohandle;
        Features;
    end
    
    properties(Constant)
        WinPos=position_in_current_monitor(1200,750)% [50 50 1200 750]; % position of main window
        URPos=[800 380 390 360]; %
        LRPos=[800 10 390 360];
        MapPos_S=[70 270 680 450];
        MapPos_L=[70 50 680 450+220]; %260
        XSPos=[15 10 760 215];
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
            obj.fig=figure('Position',obj.WinPos,'Name','Catalog Name and Date','Units',...
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
            obj.xsections=containers.Map();
            obj.xscats=containers.Map();
            
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
            uitabgroup('Units','pixels','Position',obj.URPos,'TabLocation',TabLocation,'Tag','UR plots');
            uitabgroup('Units','pixels','Position',obj.LRPos,'TabLocation',TabLocation,'Tag','LR plots');
            
            obj.xsgroup=uitabgroup('Units','pixels','Position',obj.XSPos,...
                'TabLocation',TabLocation,'Tag','xsections','Visible','off');
          
            obj.replot_all()
        end
        
        replot_all(obj)
        plot_base_events(obj)
        plotmainmap(obj)
        
        plothist(obj, name, values, tabgrouptag)
        fmdplot(obj, tabgrouptag)
        
        cummomentplot(obj,tabgrouptag)
        time_vs_something_plot(obj, name, whichplotter, tabgrouptag)
        cumplot(obj, tabgrouptag)
        
        function myTab = findOrCreateTab(obj, parent, title)
            % FINDORCREATETAB if tab doesn't exist yet, create it
            %    parent :
            myTab=findobj(obj.fig,'Title',title,'-and','Type','uitab');
            if isempty(myTab)
                p = findobj(obj.fig,'Tag',parent);
                myTab=uitab(p, 'Title',title);
            end
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
            obj.replot_all();
        end
        
        function cb_endhere(obj,ax)
            [x,~]=click_to_datetime(ax);
            obj.pushState();
            obj.daterange(2)=x;
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
            xsec = XSection.initialize_with_dialog(axm,20);
            % zans = plot_cross_section(obj.catalog);
            mytitle=[xsec.startlabel ' - ' xsec.endlabel];
            obj.xsections(mytitle)=xsec;
            
            xsTabGroup = findobj(obj.fig,'Tag','xsections','-and','Type','uitabgroup');
            % mytab=findOrCreateTab(obj.fig, xsTabGroup.Tag, mytitle);
            
            mytab=findobj(obj.fig,'Title',mytitle,'-and','Type','uitab');
            if ~isempty(mytab)
                delete(mytab);
            end
            
            p = findobj(obj.fig,'Tag',xsTabGroup.Tag);
            
            obj.xsgroup.Visible = 'on';
            set(findobj(obj.fig,'Tag','mainmap_ax'),'Position',obj.MapPos_S);
            mytab=uitab(p, 'Title',mytitle,'ForegroundColor',xsec.color,'DeleteFcn',xsec.DeleteFcn);
            delete(findobj(obj.fig,'Tag',['xsTabContext' mytitle]))
            c=uicontextmenu(obj.fig,'Tag',['xsTabContext' mytitle]);
            uimenu(c,'Label','Info','Callback',@(~,~) msgbox(xsec.project(obj.catalog).info(),mytitle));
            uimenu(c,'Label','Change Width','Callback',@(~,~)cb_chwidth);
            uimenu(c,'Label','Change Color','Callback',@(~,~)cb_chcolor);
            uimenu(c,'Label','Examine This Area','Callback',@(~,~)cb_cropToXS);
            uimenu(c,'Separator','on',...
                'Label','Delete',...
                'Callback',@deltab);
            
            mytab.UIContextMenu=c;
            
            ax=axes(mytab,'Units','pixels','Position',[40 35 680 125],'YDir','reverse');
            xsec.plot_events_along_strike(ax,obj.catalog);
            ax.Title=[];
            
            % make this the active tab
            mytab.Parent.SelectedTab=mytab;
            obj.replot_all();
            
            function cb_chwidth()
                % change width of a cross-section
                prompt={'Enter the New Width:'};
                name='Cross Section Width';
                numlines=1;
                defaultanswer={num2str(xsec.width_km)};
                answer=inputdlg(prompt,name,numlines,defaultanswer);
                if ~isempty(answer)
                    xsec=xsec.change_width(str2double(answer),axm);
                    obj.xsections(mytitle)=xsec;
                end
                xsec.plot_events_along_strike(ax,obj.catalog);
                ax.Title=[];
                obj.replot_all();
            end
            function cb_chcolor()
                color=uisetcolor(xsec.color,['Color for ' xsec.startlabel '-' xsec.endlabel]);
                xsec=xsec.change_color(color,axm);
                mytab.ForegroundColor = xsec.color;
                obj.xsections(mytitle)=xsec;
                obj.replot_all();
            end
            function cb_cropToXS()
                oldshape=copy(obj.shape)
                obj.shape=ShapePolygon('polygon',[xsec.polylons(:), xsec.polylats(:)]);
                obj.shapeChangedFcn(oldshape, obj.shape);
                obj.replot_all();
            end
            function deltab(s,v)
                xsec.DeleteFcn();
                xsec.DeleteFcn='';
                delete(mytab);
                obj.xsections.remove(mytitle);
                obj.xscats.remove(mytitle);
                obj.replot_all();
            end
        end
        
        %% METHODS DEFINED IN DIRECTORY
        
        % push and pop state
        pushState(obj)
        popState(obj)
        
        [c,m]=filtered_catalog(obj)

    end % METHODS
end % CLASSDEF