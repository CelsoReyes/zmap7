classdef (Sealed) CumTimePlot < handle
    % CumTimePlot plots selected events as cumulative # over time
    
    
    properties
        catalog
        catview         ZmapCatalogView %= ZmapCatalogView(@()ZmapGlobal.Data.newt2) % catalog
        fontsz                          = ZmapGlobal.Data.fontsz
        hold_state                      = false
        AxH % axes handle (may move to dependent)
        Tag                             = 'cum'
    end
    properties(Constant)
        FigName                         = 'Cumulative Number';
        catname                         = 'newt2';
        viewname                        = 'timeplot';
    end
    properties(Dependent)
        FigH % figure handle
        Edges % bin edges (datetime)
        RelativeEdges % bin edges (duration, offset from first event)
    end
    methods
        function obj = CumTimePlot(catalog)
            % CUMTIMEPLOT creates a new Cumulative Time Plot figure
            report_this_filefun();
            if isa(catalog,'function_handle')
                obj.catalog = catalog();
            else
                obj.catalog = catalog;
            end
            obj.catview = ZmapCatalogView(@obj.catfun);
            %obj.plot()
        end
        
        function fig= get.FigH(obj)
            % FigH is the handle to the one-and-only timeplot figure
            persistent stored_fig
            if numel(stored_fig) ~= 1 || ~isgraphics(stored_fig) || ~isvalid(stored_fig)
                % either this has never been called or something is wrong. start over.
                fig = findall(groot, 'Type','Figure','-and','Name',obj.FigName);
                delete(fig)
                stored_fig = obj.create_figure();
                
            end
            
            fig = stored_fig;
        end
        function reset(obj)
            obj.catview = ZmapCatalogView(@obj.catfun);
            obj.plot();
        end
        function c = Catalog(obj,n)
            % Catalog get a catalog
            % c = Catalog(obj) returns the main catalog from timeplot
            % c = Catalog(obj,n) returns another catalog (for when multiple have been plotted
            if ~exist('n','var')
                n=1;
            end
            if numel(obj.catview) <=n && n>0
                c = obj.catview(n).Catalog;
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
            tiplot2 = plot(obj.AxH,obj.catview.Date,(1:obj.catview.Count),'r','LineWidth',2.0);
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
            myfig.UserData = obj; % make this accessible
            
            if isempty(obj.Catalog)
                ZmapMessageCenter.set_error('No Catalog','timeplot was passed an empty catalog');
                return
            end
            
            if obj.hold_state
                addplot(obj,varargin{:});
                return;
            end
            
            t0b = obj.catview.DateRange(1);
            teb = obj.catview.DateRange(2);
            
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
                'UIContextMenu',obj.menu_cumtimeseries());
            
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
            ed = min(obj.catview.Date) : ZG.bin_dur : max(obj.catview.Date);
        end
        
        function red = get.RelativeEdges(obj)
            ZG=ZmapGlobal.Data;
            % get.RelativeEdges get duration edges
            red = 0 : ZG.bin_dur : (max(obj.catview.Date) - min(obj.catview.Date));
            % (0: ZG.bin_dur :(tdiff + 2*ZG.bin_dur)));
        end
        
    end
    methods(Hidden)
        function c=catfun(obj)
            % for use with the ZmapCatalogView
            c = obj.catalog;
        end
    end
    methods (Access = protected)
        
        function fig = create_figure(obj)
            % acquire_cumtimeplotfigure get handle to figure, otherwise create one and sync the appropriate hold_state
            % Set up the Cumulative Number window
            ZG=ZmapGlobal.Data;
            fig = figure('Name',obj.FigName,'Tag',obj.Tag);
            fig.NumberTitle = 'off';
            fig.NextPlot = 'replace';
            fig.Position = position_in_current_monitor(ZG.map_len(1)-100, ZG.map_len(2)-20);
            obj.create_menu(fig);
            fig.UserData=obj;
            obj.hold_state=false;
        end
        
        function create_menu(obj,fig)
            add_menu_divider(fig);
            mm=uimenu(fig, 'Label', 'TimePlot');
            uimenu(mm, 'Label', 'Reset', MenuSelectedField(), @(~,~)obj.reset);
            
            % HISTOGRAMS
            op5C = uimenu(mm,'Label','Histograms');
            
            uimenu(op5C,'Label','Magnitude',...
                MenuSelectedField(),@(~,~)hisgra(obj.catview,'Magnitude'));
            uimenu(op5C,'Label','Depth',...
                MenuSelectedField(),@(~,~)hisgra(obj.catview,'Depth'));
            uimenu(op5C,'Label','Time',...
                MenuSelectedField(),@(~,~)hisgra(obj.catview,'Date'));
            uimenu(op5C,'Label','Hr of the day',...
                MenuSelectedField(),@(~,~)hisgra(obj.catview,'Hour'));
            
            add_cumtimeplot_zmenu(obj, mm)
            addAboutMenuItem(fig);
        end
        
        function plot_big_events(obj)
            % plot big events on curve
            ZG=ZmapGlobal.Data;
            % select "big" events
            bigMask= obj.catview.Magnitude >= ZG.CatalogOpts.BigEvents.MinMag;
            bigCat = obj.catview.subset( bigMask );
            
            bigIdx = find(bigMask);
            
            if (max(obj.catview.Date)-min(obj.catview.Date))>=days(1) && ~isempty(bigCat)
                hold(obj.AxH,'on')
                plot(obj.AxH,bigCat.Date, bigIdx,'hm',...
                    'LineWidth',1.0,'MarkerSize',10,...
                    'MarkerFaceColor','y',...
                    'MarkerEdgeColor','k',...
                    'visible','on',...
                    'Tag','large events',...
                    'UIContextMenu',obj.menu_cumtimeseries());
                stri4 = [];
                for i = 1: bigCat.Count
                    s = sprintf('  M=%3.1f',bigCat.Magnitude(i));
                    stri4 = [stri4 ; s];
                end
                t=text(obj.AxH,bigCat.Date,bigIdx,stri4);
                try
                    [t.UIContextMenu] = deal(obj.menu_cumtimeseries());
                catch ME
                    warning(ME.message)
                end
                hold(obj.AxH,'off');
            end
        end
    end
    
    methods (Access = private)
        function add_xlabel(obj)
            if (max(obj.catview.Date)-min(obj.catview.Date)) >= days(1)
                obj.AxH.XLabel.String = 'Date';
                obj.AxH.XLabel.FontSize = obj.fontsz.s;
                obj.AxH.XLabel.UserData = field_unit.Date;
                
            else
                statime=obj.catview.Date(1);
                obj.AxH.XLabel.String = ['Time in days relative to ',char(statime)];
                obj.AxH.XLabel.FontSize = obj.fontsz.m;
                obj.AxH.XLabel.UserData = field_unit.Duration(statime);
            end
        end
        function add_ylabel(obj)
            obj.AxH.YLabel.String='Cumulative Number ';
            obj.AxH.YLabel.FontSize=obj.fontsz.s;
        end
        function add_title(obj)
            obj.AxH.Title.String=sprintf('"%s": Cumulative Earthquakes over time', obj.catview.Name);
            obj.AxH.Title.Interpreter = 'none';
        end
        function add_legend(obj)
            % under_construction()
        end
        
        function c=menu_cumtimeseries(obj, c)
            % menu_cumtimeseries add a context menu to the cumulative timeseries
            % plot(x,x,....,'UIContextMenu',menu_cumtimeseries);
            
            if ~exist('c','var')
                c=uicontextmenu('Tag','CumTimeSeriesContext');
            end
            
            uimenu(c, 'Label', 'filter',...
                'Enable','off',...
                MenuSelectedField(),@unimplemented_error);
            uimenu(c, 'Label', 'also plot main catalog',...
                'Enable','off',...
                MenuSelectedField(),@unimplemented_error);
            uimenu(c, 'separator','on','Label', 'start here',MenuSelectedField(),@start_here);
            uimenu(c, 'Label', 'end here',MenuSelectedField(),@end_here);
            uimenu(c, 'Label', 'trim to largest event',MenuSelectedField(),@trim_to_largest);
            uimenu(c, 'Label', 'show in map (keeping all)',MenuSelectedField(),@show_in_map,'Enable','off');
            uimenu(c, 'separator','on','Label', '- * t b a * -',...
                'Enable','off',...
                MenuSelectedField(),@unimplemented_error);
            
            function trim_to_largest(~,~)
                disp('trim to largest')
                obj=CumTimePlot.getInstance;
                biggests = obj.catalog.Magnitude == max(obj.catalog.Magnitude);
                idx=find(biggests,1,'first');
                obj.catalog.DateRange(1)=obj.catalog.Date(idx);
                obj.plot()
            end
            
            function start_here(src,ev)
                [x,~]=click_to_datetime(obj.AxH);
                zdlg = ZmapDialog();
                zdlg.AddEdit('startdate','Keep events AFTER ', x,'');
                zdlg.AddCheckbox('inclusive','inclusive',true,[],'keep events that occur at exactly this time?');
                [res,ok] = zdlg.Create('Name', 'Cut catalog');
                if ok
                    if res.inclusive
                        obj.catalog = obj.catalog.subset(obj.catalog.Date > res.startdate);
                    else
                        obj.catalog = obj.catalog.subset(obj.catalog.Date >= res.startdate);
                    end
                    obj.plot();
                else
                    beep;
                end
            end
            
            function end_here(src,ev)
                [x,~]=click_to_datetime(obj.AxH);
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
            
            function show_in_map()
                ZmapMessageCenter.set_info('Unimplemented. now there would be some green marks on the main map, too');
            end
            
        end
        
        function add_cumtimeplot_zmenu(obj, parent)
            % add the cumulative time plot menu
            ZG = ZmapGlobal.Data;
            
            analyzemenu=parent;%uimenu(parent,'Label','analyze');
            ztoolsmenu=uimenu(parent,'Label','ztools');
            
            
            % uimenu(ztoolsmenu,'Label','Date Ticks in different format',MenuSelectedField(),@(~,~)newtimetick,'Enable','off');
            
            uimenu(ztoolsmenu,'Label','Overlay another curve (hold)',...
                'Checked',tf2onoff(ZG.hold_state2),...
                MenuSelectedField(),@cb_hold)
            % uimenu(ztoolsmenu,'Label','Compare two rates (fit)',MenuSelectedField(),@cb_comparerates_fit); %DELETE ME
            uimenu(ztoolsmenu,'Label','Compare two rates (no fit)',MenuSelectedField(),@cb_comparerates_nofit);
            %uimenu(ztoolsmenu,'Label','Day/Night split ',MenuSelectedField(),@cb_006)
            
            uimenu(ztoolsmenu,'Separator','on','Label','Time-depth plot ',...
                MenuSelectedField(),{@cb_timeSomethingPlot,TimeDepthPlotter()});
            uimenu(ztoolsmenu,'Label','Time-magnitude plot ',...
                MenuSelectedField(),{@cb_timeSomethingPlot, TimeMagnitudePlotter()});
            
            
            
            
            op4B = uimenu(analyzemenu,'Label','Rate changes (beta and z-values) ');
            
            uimenu(op4B, 'Label', 'beta values: LTA(t) function', MenuSelectedField(),{@cb_z_beta_ratechanges,'bet'});
            uimenu(op4B, 'Label', 'beta values: "Triangle" Plot', MenuSelectedField(), {@cb_betaTriangle}); % wasnewcat
            uimenu(op4B,'Label','z-values: AS(t)function', MenuSelectedField(),{@cb_z_beta_ratechanges,'ast'});
            uimenu(op4B,'Label','z-values: Rubberband function', MenuSelectedField(),{@cb_z_beta_ratechanges,'rub'});
            uimenu(op4B,'Label','z-values: LTA(t) function ',  MenuSelectedField(),{@cb_z_beta_ratechanges,'lta'});
            
            
            op4 = uimenu(analyzemenu,'Label','Mc and b-value estimation');
            uimenu(op4,'Label','automatic',MenuSelectedField(),@cb_auto_mc_b_estimation)
            uimenu(op4,'label','Mc with time ',MenuSelectedField(),{@plotwithtime,'mc'});
            uimenu(op4,'Label','b with depth',MenuSelectedField(),@(~,~)bwithde2(obj.catview.Catalog()));
            uimenu(op4,'label','b with magnitude',MenuSelectedField(),@(~,~)bwithmag(obj.catview.Catalog()));
            uimenu(op4,'label','b with time',MenuSelectedField(),{@plotwithtime,'b'});
            
            op5 = uimenu(analyzemenu,'Label','p-value estimation');
            
            %The following instruction calls a program for the computation of the parameters in Omori formula, for the catalog of which the cumulative number graph" is
            %displayed (the catalog mycat).
            uimenu(op5,'Label','Completeness in days after mainshock',MenuSelectedField(),@(~,~)mcwtidays(obj.catalog))
            uimenu(op5,'Label','Define mainshock',...
                'Enable','off', MenuSelectedField(),@cb_016);
            uimenu(op5,'Label','Estimate p',MenuSelectedField(),@cb_pestimate);
            
            uimenu(op5,'Label','p as a function of time and magnitude',MenuSelectedField(),@(~,~)MyPvalClass.pvalcat2(obj.catalog))
            uimenu(op5,'Label','Cut catalog at mainshock time',...
                MenuSelectedField(),@cb_cut_mainshock)
            
            op6 = uimenu(analyzemenu,'Label','Fractal dimension estimation');
            uimenu(op6,'Label','Compute the fractal dimension D',MenuSelectedField(),{@cb_computefractal,2});
            uimenu(op6,'Label','Compute D for random catalog',MenuSelectedField(),{@cb_computefractal,5});
            uimenu(op6,'Label','Compute D with time',MenuSelectedField(),{@cb_computefractal,6});
            uimenu(op6,'Label',' Help/Info on  fractal dimension',MenuSelectedField(),@(~,~)showweb('fractal'))
            
            uimenu(ztoolsmenu,'Label','Cumulative Moment Release ',MenuSelectedField(),@(~,~)morel(obj.catalog))
            
            op7 = uimenu(analyzemenu,'Label','Stress Tensor Inversion Tools');
            uimenu(op7,'Label','Invert for stress-tensor - Michael''s Method ',MenuSelectedField(),@(~,~)doinverse_michael())
            uimenu(op7,'Label','Invert for stress-tensor - Gephart''s Method ',MenuSelectedField(),@(~,~)doinversgep_pc())
            uimenu(op7,'Label','Stress tensor with time',MenuSelectedField(),@(~,~)stresswtime())
            uimenu(op7,'Label','Stress tensor with depth',MenuSelectedField(),@(~,~)stresswdepth())
            uimenu(op7,'Label',' Help/Info on  stress tensor inversions',MenuSelectedField(),@(~,~)showweb('stress'))
            
            
            
            %uimenu(ztoolsmenu,'Label','Save cumulative number curve',...
            %    'Separator','on',...
            %    MenuSelectedField(),@unimplemented_error);
            
            %uimenu(ztoolsmenu,'Label','Save cum #  and z value',...
            %    MenuSelectedField(),@unimplemented_error);
            
            function plotwithtime(mysrc,myevt,sPar)
                %sPar tells what to plot.  'mc', 'b'
                callback_tracker(mysrc,myevt,mfilename('fullpath'));
                plot_McBwtime(obj.catview.Catalog(), sPar);
            end
            
            function cb_hold(mysrc,myevt)
                callback_tracker(mysrc,myevt,mfilename('fullpath'));
                obj.hold_state = ~obj.hold_state;
                mysrc.Checked=(tf2onoff(obj.hold_state));
            end
            
            function cb_comparerates_nofit(mysrc,myevt)
                callback_tracker(mysrc,myevt,mfilename('fullpath'));
                ic=0;
                dispma3;
            end
            
            function cb_z_beta_ratechanges(mysrc,myevt,sta)
                % beta values:
                %   'bet' : LTA(t) function
                %   'ast' : AS(t) function
                %   'rub' : Rubberband function
                callback_tracker(mysrc,myevt,mfilename('fullpath'));
                set(gcf,'Pointer','watch');
                newsta(sta, obj.catalog);
            end
            
            function cb_betaTriangle(~, ~)
                betatriangle(obj.catalog);
            end
            
            function cb_auto_mc_b_estimation(mysrc,myevt)
                callback_tracker(mysrc,myevt,mfilename('fullpath'));
                obj.hold_state=false;
                bdiff2(obj.catalog);
            end
            
            function cb_cut_mainshock(mysrc,myevt)
                callback_tracker(mysrc,myevt,mfilename('fullpath'));
                l = min(find( obj.catalog.Magnitude == max(obj.catalog.Magnitude) ));
                obj.catalog = obj.catalog.subset(l:obj.catalog.Count);
                ctp=CumTimePlot(obj.catalog);
                ctp.plot();
            end
            
            function cb_pestimate(mysrc,myevt)
                callback_tracker(mysrc,myevt,mfilename('fullpath'));
                ZG.hold_state=false;
                MyPvalClass.pvalcat(obj.catalog);
            end
            
            function cb_computefractal(mysrc,myevt, org)
                callback_tracker(mysrc,myevt,mfilename('fullpath'));
                if org==2
                    E = obj.catalog;
                end % FIXME this is probably unneccessary, but would need to be traced in startfd before deleted
                startfd(org);
            end
            
            function cb_timeSomethingPlot(~,~,plotter)
                plotter.plot([], obj.catalog);
            end
            
            
        end

    end
    
    
    
end
