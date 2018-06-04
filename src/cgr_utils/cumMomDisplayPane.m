classdef cumMomDisplayPane < ZmapDisplayPane
    % CUMMOMDISPLAYPANE show cumulative moment in the display pane
    
    methods
        function setup(obj, hContainer)
            obj.ax=axes(myTab);
            obj.ax.TickDir='out';
            obj.ax.YMinorTick='on';
            obj.ax.Box='on';
            
            
            obj.Tags.xs = 'CumMom xs contextmenu';
            obj.Tags.bg = 'CumMom bg contextmenu';
            obj.Tags.line = 'CumMom line contextmenu';
            
            % context for main menu
            cln=findobj(gcf,'Tag',obj.Tags.line);
            if isempty(cln)
                cln=uicontextmenu('tag',obj.Tags.line);
                uimenu(cln,'Label','start here',Futures.MenuSelectedFcn,@(~,~)obj.cb_starthere(ax));
                uimenu(cln,'Label','end here',Futures.MenuSelectedFcn,@(~,~)obj.cb_endhere(ax));
                uimenu(cln, 'Label', 'trim to largest event',Futures.MenuSelectedFcn,@obj.cb_trim_to_largest);
                uimenu(cln,'Label','Open in new window',Futures.MenuSelectedFcn,@(~,~)obj.cb_timeplot());
            end
            
            % context for axes
            cbg=findobj(gcf,'Tag',Tags.bg);
            if isempty(cbg)
                cbg=uicontextmenu('Tag',Tags.bg);
                addLegendToggleContextMenuItem(cbg,'bottom','above');
                uimenu(cbg,'Label','Open in new window',Futures.MenuSelectedFcn,@(~,~)obj.cb_timeplot());
                ax.UIContextMenu=cbg;
            end
            
            
            % context for cross sections
            cxs=findobj(gcf,'Tag',obj.Tags.xs);
            if isempty(cxs)
                cxs=uicontextmenu('tag',obj.Tags.xs);
                uimenu(cxs,'Label','Open in new window',Futures.MenuSelectedFcn,@cb_xstimeplot);
            end
            
            yl=ylabel(obj.ax,'Cumulative Moment');
            yl.UIContextMenu=evt.AffectedObject.sharedContextMenus.LogLinearYScale;
            
            xlabel(ax,'Time');
        end
        
        %% Catalog
        function createCatalog(obj)
            line(obj.ax,nan,nan,'LineWidth',2.5,'Tag','catalog','DisplayName','catalog',...
                'color','k', 'UIContextMenu',findobj(gcf,'Tag',obj.Tags.line));
            grid(obj.ax,'on');
        end
        
        function updateCatalog(obj, prop, evt)
            % plot the main catalog
            catalog = evt.AffectedObject.(prop.Name);
            
            [~, Ys, ~] = calc_moment(catalog);
            p=findobj(obj.ax,'Tag','catalog','-and','Type','line');
            set(p,'XData', catalog.Date, 'YData', Ys);
            
        end
        
        %% Cross Sections
        function createXSection(obj)
        end
        
        function updateXSection(obj, prop, evt)
            % remove any cross-sections that are no longer exist
            xs = evt.AffectedObject.(prop.Name);
            m=findobj(ax,'Type','line','-and','-not','Tag','catalog'); % plotted cross sections
            if ~isempty(m)
                notrep = ~ismember({m.DisplayName},obj.XSectionTitles);
                if any(notrep)
                    delete(m(notrep));
                end
            end
            
            evt.AffectedObject.plot_xsections(@obj.xsplotter, 'Xsection cummomplot');
            
        end
        
        %% Big Events
        function createBigEvents(obj)
            hold(obj.ax,'on');
            scatter(obj.ax, nan, nan, [], 'Marker','h','MarkerEdgeColor','k','MarkerFaceColor','y',...
                'Tag','big events');
            hold(obj.ax,'off');
        end
        
        function updateBigEvents(obj, prop, evt)
            bigcat=ZmapGlobal.Data.maepi;
            idx = ismember(Xs,bigcat.Date) & obj.catalog.Magnitude >= min(bigcat.Magnitude);
            set(gca,'NextPlot','add')
            scatter(ax,Xs(idx), Ys(idx), mag2dotsize(bigcat.Magnitude),...
                'Marker','h','MarkerEdgeColor','k','MarkerFaceColor','y',...
                'Tag','big events');
            set(gca,'NextPlot','replace')
        end
    end
    
    methods(Access=private)
        
        function h = xsplotter(xs, xscat)
            h=findobj(ax,'DisplayName',xs.name,'-and','Type','line');
            if isempty(h)
                [~, vmom, ~] = calc_moment(xscat);
                h=line(ax,xscat.Date, vmom,'LineWidth',1.5,'DisplayName',xs.name,...
                    'Tag',['Xsection cummomplot ' xs.name],'Color',xs.color,...
                    'UIContextMenu',cxs);
            else
                if ~isequal(xscat.Date,h.XData)
                    [~, vmom, ~] = calc_moment(xscat);
                    set(h,'XData',xscat.Date, 'YData', vmom,'LineWidth',1.5,'Color',xs.color);
                else
                    set(h,'Color',xs.color);
                end
            end
        end
        
        function cb_xstimeplot(~,~)
            myName = get(gco,'DisplayName');
            idx=strcmp(obj.XSectionTitles,myName);
            ZG=ZmapGlobal.Data;
            ZG.newt2=obj.catalog.subset(obj.CrossSections(idx).inside(obj.catalog));
            ZG.newt2.Name=sprintf('Events within %g km of %s',myName);
            CumTimePlot(ZG.newt2);
        end
    end
    
end