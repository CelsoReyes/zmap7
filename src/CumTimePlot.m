classdef (Sealed) CumTimePlot < handle
    % CumTimePlot plots selected events as cumulative # over time
    % 
    % catalogview is ZG.Views.timeplot
    % catalog is ZG.newt2
    %
    %
    % CUMTIMEPLOT properties:
    %   catalog
    %   fontsz
    %   hold_state
    %   AxH
    %   FigH
    %   Edges
    %   RelativeEdges
    %
    % CUMTIMEPLOT methods:
    %   reset
    %   Catalog
    %   update
    %   addplot
    %   plot
    %
    % CUMTIMEPLOT protected methods:
    %   create_figure
    %   create_menu
    %   plot_big_events
    %
    % upon creation: a view to newt2 is stored in catalog
    % the view is changed by:
    % 
    
    properties
        catalog ZmapCatalogView %= ZmapCatalogView(@()ZmapGlobal.Data.newt2) % catalog
        fontsz = ZmapGlobal.Data.fontsz;
        hold_state = false;
        AxH % axes handle (may move to dependent)
    end
    properties(Constant)
        FigName='Cumulative Number';
        catname = 'newt2';
        viewname = 'timeplot';
    end
    properties(Dependent)
        FigH % figure handle
        Edges % bin edges (datetime)
        RelativeEdges % bin edges (duration, offset from first event)
    end
    
    methods (Access = private)
        function add_xlabel(obj)
            if (max(obj.catalog.Date)-min(obj.catalog.Date)) >= days(1)
                xlabel(obj.AxH,'Date',...
                    'FontSize',obj.fontsz.s,...
                    'UserData',field_unit.Date)
                
            else
                statime=obj.catalog.Date(1);
                xlabel(obj.AxH,['Time in days relative to ',char(statime)],...
                    'FontSize',obj.fontsz.m,...
                    'UserData',field_unit.Duration(statime));
            end
        end
        function add_ylabel(obj)
            ax.YLabel.String='Cumulative Number ';
            ax.YLabel.FontSize=obj.fontsz.s;
        end
        function add_title(obj)
            obj.AxH.Title.String=sprintf('"%s": Cumulative Earthquakes over time', obj.catalog.Name);
            obj.AxH.Title.Interpreter = 'none';
        end
        function add_legend(obj)
            disp('CumTimePlot.add_legend (unimplemented)')
        end
    end
    methods (Access = protected)        
        function fig = create_figure(obj)
            % acquire_cumtimeplotfigure get handle to figure, otherwise create one and sync the appropriate hold_state
            % Set up the Cumulative Number window
            ZG=ZmapGlobal.Data;
            fig = figure_w_normalized_uicontrolunits( ...
                'Name',obj.FigName,...
                'NumberTitle','off', ...
                'NextPlot','replace', ...
                'backingstore','on',...
                'Tag','cum',...
                'Position',position_in_current_monitor(ZG.map_len(1)-100, ZG.map_len(2)-20));
            
            obj.create_menu();
            obj.hold_state=false;
        end
        function create_menu(obj)
            
            add_menu_divider();
            disp('CumTimePlot.create_menu (unimplemented)');
            mm=uimenu('Label','TimePlot');
            uimenu(mm,'Label','Reset',Futures.MenuSelectedFcn,@(~,~)obj.reset);
            
            % HISTOGRAMS
            op5C = uimenu(mm,'Label','Histograms');
            
            uimenu(op5C,'Label','Magnitude',...
                Futures.MenuSelectedFcn,@(~,~)hisgra(obj.catalog,'Magnitude'));
            uimenu(op5C,'Label','Depth',...
                Futures.MenuSelectedFcn,@(~,~)hisgra(obj.catalog,'Depth'));
            uimenu(op5C,'Label','Time',...
                Futures.MenuSelectedFcn,@(~,~)hisgra(obj.catalog,'Date'));
            uimenu(op5C,'Label','Hr of the day',...
                Futures.MenuSelectedFcn,@(~,~)hisgra(obj.catalog,'Hour'));
            
            add_menu_catalog(obj.catname,obj.viewname,false,gcf);
            add_cumtimeplot_zmenu(obj, mm)
            addAboutMenuItem();
        end
        function plot_big_events(obj)
            % plot big events on curve
            ZG=ZmapGlobal.Data;
            % select "big" events
            bigMask= obj.catalog.Magnitude >= ZG.big_eq_minmag;
            bigCat = obj.catalog.subset( bigMask );
            
            bigIdx = find(bigMask);
            
            if (max(obj.catalog.Date)-min(obj.catalog.Date))>=days(1) && ~isempty(bigCat)
                hold(obj.AxH,'on')
                plot(obj.AxH,bigCat.Date, bigIdx,'hm',...
                    'LineWidth',1.0,'MarkerSize',10,...
                    'MarkerFaceColor','y',...
                    'MarkerEdgeColor','k',...
                    'visible','on',...
                    'Tag','large events',...
                    'UIContextMenu',menu_cumtimeseries());
                stri4 = [];
                for i = 1: bigCat.Count
                    s = sprintf('  M=%3.1f',bigCat.Magnitude(i));
                    stri4 = [stri4 ; s];
                end
                t=text(obj.AxH,bigCat.Date,bigIdx,stri4);
                try
                    t.UIContextMenu=menu_cumtimeseries();
                catch ME
                    warning(ME.message)
                end
                hold(obj.AxH,'off');
            end
        end
    end
    
    methods
        function obj = CumTimePlot(catalog)
            % CUMTIMEPLOT creates a new Cumulative Time Plot figure
            report_this_filefun();
            cf=@()ZmapGlobal.Data.(obj.catname);
            obj.catalog = ZmapCatalogView(cf);
            %obj.BigView = ZmapCatalogView(@()obj.catalog); % major event(s)
            obj.plot()
        end
        
        function fig= get.FigH(obj)
            % FigH is the handle to the one-and-only timeplot figure
            persistent stored_fig
            if numel(stored_fig) ~= 1 || ~isvalid(stored_fig)
                % either this has never been called or something is wrong. start over.
                fig = findall(groot, 'Type','Figure','-and','Name',obj.FigName);
                delete(fig)
                stored_fig = obj.create_figure();
                
            end
            
            fig = stored_fig;
        end
        function reset(obj)
            % reset resets the catalog to the global-version, then replots
            obj.catalog = ZmapCatalogView(@()ZmapGlobal.Data.(obj.catname));
            obj.plot();
        end
        function c = Catalog(obj,n)
            % Catalog get a catalog
            % c = Catalog(obj) returns the main catalog from timeplot
            % c = Catalog(obj,n) returns another catalog (for when multiple have been plotted
            if ~exist('n','var')
                n=1;
            end
            if numel(obj.catalog) <=n && n>0
                c = obj.catalog(n).Catalog;
            end
        end
        function update(obj)
            obj.plot()
        end

        function addplot(obj, othercat, varargin)
            % addplot add another line to the plot
            % tdiff=mycat.DateSpan; % added by CR
            cumu = histcounts(othercat.Date, obj.Edges);
            cumu2 = cumsum(cumu);
            
            hold(obj.AxH,'on');
            axes(obj.AxH)
            tiplot2 = plot(obj.AxH,obj.catalog.Date,(1:obj.catalog.Count),'r','LineWidth',2.0);
            tiplot2.DisplayName=caller(dbstack);
            obj.hold_state=false;
            hold(obj.AxH,'off');
            
            function s=caller(ds)
                % call with dbstack
                if numel(ds)>1
                    s = ['from ' ds(2).name];
                else
                    s = 'from base (?)';
                end
            end
        end
        function plot(obj,varargin)
            myfig = obj.FigH; % will automatically create if it doesn't exist
            try
                figure(myfig);
            catch ME
                disp('failed to get figure!')
            end
            
            if isempty(obj.Catalog)
                ZmapMessageCenter.set_error('No Catalog','timeplot was passed an empty catalog');
                return
            end
            
            if obj.hold_state
                addplot(obj,varargin{:});
                return;
            end
            
            t0b = obj.catalog.DateRange(1);
            teb = obj.catalog.DateRange(2);
            
            delete(findobj(myfig,'Type','Axes'));
            watchon;
            obj.AxH=axes(myfig);
            
            set(obj.AxH,...
                ...'visible','off',...
                'FontSize',ZmapGlobal.Data.fontsz.s,...
                'FontWeight','normal',...
                'LineWidth',1.5,...
                'Tag','cumtimeplot_ax',...
                'SortMethod','childorder')
            grid(obj.AxH,'on')
            % plot time series
            
            nu = (1:obj.Catalog.Count);
            
            hold(obj.AxH,'on')
            plot(obj.AxH, obj.Catalog.Date, nu, 'b',...
                'LineWidth', 2.0,...
                'Tag','cumulative events',...
                'UIContextMenu',menu_cumtimeseries());
            
            % plot marker at end of data
            pl = plot(obj.AxH, teb, obj.Catalog.Count,'rs');
            set(pl,'LineWidth',1.0,'MarkerSize',4,...
                'MarkerFaceColor','w','MarkerEdgeColor','r',...
                'Tag','end marker');
            
            set(obj.AxH,'Ylim',[0 obj.Catalog.Count*1.05]);
            
            obj.plot_big_events();
            
            obj.add_xlabel();
            obj.add_ylabel();
            obj.add_title();
            obj.add_legend();
            
            
            % Make the figure visible
            %
            set(obj.AxH,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,...
                'LineWidth',1.0,'TickDir','out');%,'Ticklength',[0.02 0.02],'Box','on')
            figure(myfig);
            axes(obj.AxH);
            set(myfig,'Visible','on');
            watchoff(myfig);
        end
        function ed = get.Edges(obj)
            ZG=ZmapGlobal.Data;
            % get.Edges get date edges
            ed = min(obj.catalog.Date) : ZG.bin_dur : max(obj.catalog.Date);
        end
        function red = get.RelativeEdges(obj)
            ZG=ZmapGlobal.Data;
            % get.RelativeEdges get duration edges
            red = 0 : ZG.bin_dur : (max(obj.catalog.Date) - min(obj.catalog.Date));
            % (0: ZG.bin_dur :(tdiff + 2*ZG.bin_dur)));
        end
            
    end
end
