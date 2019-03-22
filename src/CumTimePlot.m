classdef (Sealed) CumTimePlot < handle
    % CumTimePlot plots selected events as cumulative # over time
    
    
    properties
        % catalog
        fontsz                          = ZmapGlobal.Data.fontsz
        hold_state                      = false
        ax                              = gobjects(0)% axes handle (may move to dependent)
        Tag                             = 'cum'
        zmw                             = struct('catalog',ZmapCatalog); % ZmapMainWindow
    end
    properties(Constant)
        FigName                         = 'Cumulative Number';
    end
    properties(Dependent,Access=private)
        catalog
    end
    
    methods
        function obj = CumTimePlot(zmw, ax)
            % CUMTIMEPLOT creates a new Cumulative Time Plot axes
            if isa(zmw,'ZmapMainWindow')
                obj.zmw = zmw;
            elseif isa(zmw,'ZmapCatalog')
                % pretend we have a zmw with a catalog
                obj.zmw.catalog = zmw;
            else
                error('unknown input');
            end
            if exist('ax','var')
                obj.ax = ax;
            end
        end
        
        function c = get.catalog(obj)
            c=obj.zmw.catalog;
        end
        
   
        function reset(obj)
            % obj.catview = ZmapCatalogView(obj.catalog);
            cla(obj.ax)
            obj.plot();
        end
                
        function update(obj)
            obj.plot()
        end
        
        function addplot(obj, othercat, varargin)
            % addplot add another line to the plot
            
            hold(obj.ax,'on');
            axes(obj.ax)
            tiplot2 = plot(obj.ax, othercat.Date, (1:obj.catalog.Count),'LineWidth',2.0);
            tiplot2.DisplayName=caller(dbstack);
            obj.hold_state=false;
            hold(obj.ax,'off');
            
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
            if isempty(obj.ax) || ~isvalid(obj.ax)
                myfig=obj.create_figure();
            else
                myfig=ancestor(obj.ax,'figure');
            end
            
            dispName = obj.catalog.Name;
                
            if isempty(obj.catalog)
                msg.errordisp('CumTimePlot was passed an empty catalog','No Catalog');
                return
            end
            if ~isempty(varargin) && isa(varargin{1},'ZmapCatalog')
                obj.ax.NextPlot = 'add';
            end
            
            if obj.hold_state
                addplot(obj,varargin{:});
                return;
            end
            
            axProps.FontSize    = obj.fontsz.s;
            axProps.FontWeight  = 'normal';
            axProps.LineWidth   = 1.5;
            axProps.Tag         = 'cumtimeplot_ax';
            
            set(obj.ax,axProps);
            grid(obj.ax,'on')
            % plot time series
            
            nu = (1:obj.catalog.Count);
            pl=plot(obj.ax, obj.catalog.Date, nu,...
                'LineWidth', 2.0,...
                'Tag','cumulative events',...
                'DisplayName',strrep(dispName,'_','\_'));
            obj.add_timeseries_contextmenu(pl);
            
            hold(obj.ax,'on')
            % plot marker at end of data
            pl_end = plot(obj.ax, max(obj.catalog.Date), obj.catalog.Count,'rs');
            set(pl_end,'LineWidth',1.0,'MarkerSize',4,...
                'MarkerFaceColor','w','MarkerEdgeColor','r',...
                'Tag','end marker');
            legend(obj.ax,pl,'Location','northwest');
            set(obj.ax,'Ylim',[0 obj.catalog.Count*1.05]);
            hold(obj.ax,'off');
            obj.plot_big_events();
            
            obj.add_xlabel();
            obj.add_ylabel();
            obj.add_title();
            
            
            % Make the figure visible
            %
            set(obj.ax,'visible','on','FontSize',obj.fontsz.s,...
                'LineWidth',1.0,'TickDir','out');%,'Ticklength',[0.02 0.02],'Box','on')
            watchoff(myfig);
        end
    end
    
    methods (Access = protected)
        
        function fig = create_figure(obj)
            % acquire_cumtimeplotfigure get handle to figure, otherwise create one and sync the appropriate hold_state
            % Set up the Cumulative Number window
            ZG=ZmapGlobal.Data;
            fig                 = figure('Name',obj.FigName,'Tag',obj.Tag);
            fig.NumberTitle     = 'off';
            fig.Position        = position_in_current_monitor(ZG.map_len(1)-100, ZG.map_len(2)-20);
            obj.create_menu(fig);
            obj.hold_state      = false;
            obj.ax = axes(fig);
            obj.ax.NextPlot='replace';
        end
        
        function create_menu(obj,fig)
            if ~isempty(findobj(fig,'Label','TimePlot','-and','Type','uimenu'))
                return
            end
            if fig.Type == "figure"
                add_menu_divider(fig);
                mm=uimenu(fig, 'Label', 'TimePlot');
                addAboutMenuItem(fig);
            else
                mm=uimenu(fig, 'Label', 'TimePlot');
            end
            
            uimenu(mm, 'Label', 'Reset', MenuSelectedField(), @(~,~)obj.reset);
            
            % HISTOGRAMS
            op5C = uimenu(mm,'Label','Histograms');
            
            % uimenu(op5C,'Label','Magnitude', MenuSelectedField(), @(~,~)hisgra(obj.catalog,'Magnitude'));
            % uimenu(op5C,'Label','Depth', MenuSelectedField(), @(~,~)hisgra(obj.catalog,'Depth'));
            % uimenu(op5C,'Label','Time', MenuSelectedField(), @(~,~)hisgra(obj.catalog,'Date'));
            uimenu(op5C,'Label','Hr of the day', MenuSelectedField(), @(~,~)hisgra(obj.catalog,'Hour'));
            
            obj.add_cumtimeplot_zmenu(mm)
        end
        
        function plot_big_events(obj)
            % plot big events on curve
            ZG=ZmapGlobal.Data;
            % select "big" events
            bigDisplayName = sprintf('Events %c mag %g',...
               char(8805),... ascii representation of >=
               ZG.CatalogOpts.BigEvents.MinMag); 
            bigMask= obj.catalog.Magnitude >= ZG.CatalogOpts.BigEvents.MinMag;
            bigCat = obj.catalog.subset( bigMask );
            
            bigIdx = find(bigMask);
            
            if (max(obj.catalog.Date)-min(obj.catalog.Date))>=days(1) && ~isempty(bigCat)
                hold(obj.ax,'on')
                pl=plot(obj.ax,bigCat.Date, bigIdx,'hm',...
                    'LineWidth',1.0,'MarkerSize',10,...
                    'MarkerFaceColor','y',...
                    'MarkerEdgeColor','k',...
                    'visible','on',...
                    'Tag','large events',...
                    'DisplayName',bigDisplayName);
                obj.add_timeseries_contextmenu(pl);
                stri4 = [];
                for i = 1: bigCat.Count
                    s = sprintf('  M=%3.1f',bigCat.Magnitude(i));
                    stri4 = [stri4 ; s];
                end
                t=text(obj.ax,bigCat.Date,bigIdx,stri4);
                %try
                %    [t.UIContextMenu] = deal(obj.add_timeseries_contextmenu());
                %catch ME
                %    warning(ME.message)
                %end
                hold(obj.ax,'off');
            end
        end
    end
    
    methods (Access = private)
        function add_xlabel(obj)
            if (max(obj.catalog.Date)-min(obj.catalog.Date)) >= days(1)
                obj.ax.XLabel.String = 'Date';
                obj.ax.XLabel.FontSize = obj.fontsz.s;
                obj.ax.XLabel.UserData = field_unit.Date;
                
            else
                statime=obj.catalog.Date(1);
                obj.ax.XLabel.String = ['Time in days relative to ',char(statime)];
                obj.ax.XLabel.FontSize = obj.fontsz.m;
                obj.ax.XLabel.UserData = field_unit.Duration(statime);
            end
        end
        function add_ylabel(obj)
            obj.ax.YLabel.String='Cumulative Number ';
            obj.ax.YLabel.FontSize=obj.fontsz.s;
        end
        function add_title(obj)
            obj.ax.Title.String=sprintf('"%s": Cumulative Earthquakes over time', obj.catalog.Name);
            obj.ax.Title.Interpreter = 'none';
        end
        
        function trim_to_largest(obj, ~,~)
            disp('trim to largest')
            obj=CumTimePlot.getInstance;
            biggests = obj.catalog.Magnitude == max(obj.catalog.Magnitude);
            idx=find(biggests,1,'first');
            obj.catalog.DateLims(1)=obj.catalog.Date(idx);
            obj.plot()
        end
        
        function start_here(obj, src,ev)
            [x,~]=click_to_datetime(obj.ax);
            zdlg = ZmapDialog();
            zdlg.AddEdit('startdate','Keep events AFTER ', x,'');
            zdlg.AddCheckbox('inclusive','inclusive',true,[],'keep events that occur at exactly this time?');
            [res,ok] = zdlg.Create('Name', 'Cut catalog');
            if ok
                if res.inclusive
                    mycatalog=obj.catalog.subset(obj.catalog.Date > res.startdate);
                else
                    mycatalog=obj.catalog.subset(obj.catalog.Date >= res.startdate);
                end
                mycatalog
                obj.zmw=struct('catalog',mycatalog);
                obj.reset();
            else
                beep;
            end
        end
        
        function end_here(obj, src,ev)
            [x,~]=click_to_datetime(obj.ax);
            zdlg = ZmapDialog();
            zdlg.AddEdit('enddate','Keep events BEFORE ', x,'');
            zdlg.AddCheckbox('inclusive','inclusive',false,[],'keep events that occur at exactly this time?');
            [res,ok] = zdlg.Create('Name', 'Cut catalog');
            if ok
                if res.inclusive
                    obj.catalog = obj.catalog.subset(obj.catalog.Date < res.enddate);
                else
                    obj.catalog = obj.catalog.subset(obj.catalog.Date <= res.enddate);
                end
                obj.plot();
            else
                beep;
            end
        end
        
        function add_timeseries_contextmenu(obj, item)
            % menu_cumtimeseries add a context menu to the cumulative timeseries
            % plot(x,x,....,'UIContextMenu',menu_cumtimeseries);
            
            c=uicontextmenu(ancestor(item,'figure'),'Tag','CumTimeSeriesContext');
            
            uimenu(c, 'Label', 'filter',...
                'Enable','off',...
                MenuSelectedField(),@unimplemented_error);
            uimenu(c, 'Label', 'also plot main catalog',...
                'Enable','off',...
                MenuSelectedField(),@unimplemented_error);
            uimenu(c, 'separator','on','Label', 'start here',MenuSelectedField(),@obj.start_here);
            uimenu(c, 'Label', 'end here',MenuSelectedField(),@obj.end_here);
            uimenu(c, 'Label', 'trim to largest event',MenuSelectedField(),@obj.trim_to_largest);
            item.UIContextMenu = c;
        end
        
        function add_cumtimeplot_zmenu(obj, parent)
            % add the cumulative time plot menu
            ZG = ZmapGlobal.Data;
            
            analyzemenu=parent;%uimenu(parent,'Label','analyze');
            ztoolsmenu=uimenu(parent,'Label','ztools');
            msfield = MenuSelectedField();
            
            % uimenu(ztoolsmenu,'Label','Date Ticks in different format',msfield,@(~,~)newtimetick,'Enable','off');
            
            uimenu(ztoolsmenu,'Label','Overlay another curve (hold)',...
                'Checked',tf2onoff(ZG.hold_state2),...
                msfield,@cb_hold)
            % uimenu(ztoolsmenu,'Label','Compare two rates (fit)',msfield,@cb_comparerates_fit); %DELETE ME
            uimenu(ztoolsmenu,'Label','Compare two rates (no fit)',msfield,@(~,~)dispma3()); % also set ic=0 (?)
            %uimenu(ztoolsmenu,'Label','Day/Night split ',msfield,@cb_006)
            
            uimenu(ztoolsmenu,'Separator','on','Label','Time-depth plot ',...
                msfield,@(~,~)cb_timeSomethingPlot(TimeDepthPlotter()));
            uimenu(ztoolsmenu,'Label','Time-magnitude plot ',...
                msfield,@(~,~)cb_timeSomethingPlot(TimeMagnitudePlotter()));
            
            
            
            
            op4B = uimenu(analyzemenu,'Label','Rate changes (beta and z-values) ');
            
            uimenu(op4B, 'Label', 'beta values: LTA(t) function' , msfield, @(~,~)cb_z_beta_ratechanges('bet'));
            uimenu(op4B, 'Label', 'beta values: "Triangle" Plot' , msfield, @cb_betaTriangle); % wasnewcat
            uimenu(op4B, 'Label', 'z-values: AS(t)function'      , msfield, @(~,~)cb_z_beta_ratechanges('ast'));
            uimenu(op4B, 'Label', 'z-values: Rubberband function', msfield, @(~,~)b_z_beta_ratechanges('rub'));
            uimenu(op4B, 'Label', 'z-values: LTA(t) function '   , msfield, @(~,~)cb_z_beta_ratechanges('lta'));
            
            
            op4 = uimenu(analyzemenu,'Label','Mc and b-value estimation');
            uimenu(op4,'Label','FMD'          , msfield, @cb_auto_mc_b_estimation)
            uimenu(op4,'label','Mc with time '      , msfield, @(~,~)plotwithtime('mc'));
            uimenu(op4,'Label','b with depth'       , msfield, @(~,~)bwithde2(obj.catalog));
            uimenu(op4,'label','b with magnitude'   , msfield, @(~,~)bwithmag(obj.catalog));
            uimenu(op4,'label','b with time'        , msfield, @(~,~)plotwithtime('b'));
            
            op5 = uimenu(analyzemenu,'Label','p-value estimation');
            
            %The following instruction calls a program for the computation of the parameters in Omori formula, for the catalog of which the cumulative number graph" is
            %displayed (the catalog mycat).
            uimenu(op5,'Label','Completeness in days after mainshock', msfield,@(~,~)mcwtidays(obj.catalog))
            uimenu(op5,'Label','Define mainshock',...
                'Enable','off', msfield, @cb_016);
            uimenu(op5,'Label','Estimate p',msfield,@cb_pestimate);
            
            uimenu(op5,'Label','p as a function of time and magnitude',msfield,@(~,~)MyPvalClass.pvalcat2(obj.catalog))
            uimenu(op5,'Label','Cut catalog at mainshock time',...
                msfield,@cb_cut_mainshock)
            
            op6 = uimenu(analyzemenu,'Label','Fractal dimension estimation');
            uimenu(op6,'Label','Compute the fractal dimension D' , msfield, @(~,~)cb_computefractal(2));
            uimenu(op6,'Label','Compute D for random catalog'    , msfield, @(~,~)cb_computefractal(5));
            uimenu(op6,'Label','Compute D with time'             , msfield, @(~,~)cb_computefractal(6));
            uimenu(op6,'Label',' Help/Info on  fractal dimension', msfield, @(~,~)showweb('fractal'))
            
            uimenu(ztoolsmenu,'Label','Cumulative Moment Release ', msfield, @(~,~)morel(obj.catalog))
            
            op7 = uimenu(analyzemenu,'Label','Stress Tensor Inversion Tools');
            uimenu(op7,'Label','Invert for stress-tensor - Michael''s Method ',msfield,@(~,~)doinverse_michael())
            uimenu(op7,'Label','Invert for stress-tensor - Gephart''s Method ',msfield,@(~,~)doinversgep_pc())
            uimenu(op7,'Label','Stress tensor with time',msfield,@(~,~)stresswtime())
            uimenu(op7,'Label','Stress tensor with depth',msfield,@(~,~)stresswdepth())
            uimenu(op7,'Label',' Help/Info on  stress tensor inversions',msfield,@(~,~)showweb('stress'))
                        
            function plotwithtime(sPar)
                %sPar tells what to plot.  'mc', 'b'
                plot_McBwtime(obj.catalog, sPar);
            end
            
            function cb_hold(mysrc,~)
                obj.hold_state = ~obj.hold_state;
                mysrc.Checked=(tf2onoff(obj.hold_state));
            end
                        
            function cb_z_beta_ratechanges(sta)
                % beta values:
                %   'bet' : LTA(t) function
                %   'ast' : AS(t) function
                %   'rub' : Rubberband function
                set(gcf,'Pointer','watch');
                newsta(sta, obj.catalog);
            end
            
            function cb_betaTriangle(~, ~)
                betatriangle(obj.catalog);
            end
            
            function cb_auto_mc_b_estimation(~,~)
                obj.hold_state = false;
                bdiff2(obj.catalog);
            end
            
            function cb_cut_mainshock(~,~)
                biggestEvent = find( obj.catalog.Magnitude == max(obj.catalog.Magnitude) , 1 );
                obj.catalog = obj.catalog.subset(biggestEvent:obj.catalog.Count);
                ctp=CumTimePlot(obj.catalog);
                ctp.plot();
            end
            
            function cb_pestimate(~,~)
                ZG.hold_state=false;
                MyPvalClass.pvalcat(obj.catalog);
            end
            
            function cb_computefractal(org)
                if org==2
                    E = obj.catalog;
                end % FIXME this is probably unneccessary, but would need to be traced in startfd before deleted
                startfd(org);
            end
            
            function cb_timeSomethingPlot(plotter)
                plotter.plot([], obj.catalog);
            end
            
        end

    end
    
    
    
end
