classdef bdiff2 < ZmapFunction
    % bdiff2 estimates the b-value of a curve automatically
    % The b-value curve is differenciated and the point
    % of the magnitude of completeness is marked. The b-value will be calculated
    % using this point and the point half way toward the high
    % magnitude end of the b-value curve.
    %
    %
    % Formerly : function  bdiff(newcat)
    % Stefan Wiemer 1/95
    % upadated: J.Woessner, 27.08.04
    
    % Changes record:
    % 02.06.03: Added choice of EMR-method to calculate Mc
    % 06.10.03: Added choice of MBS-method to calculate Mc (fixed at 5)
    %           Added bootstrap choice
    % 28.07.04: Many changes: Now able to do computatios with all functions
    %           available in calc_Mc
    properties
        fBinning = 0.1; % magnitude binning
        %index_low;
        myXLim
        myYLim
        fitted
        %a_value_annual
        %a_value % a-value
        %b_value % b-value
        %b_value_std % error for b-value
        binnedEvents_reverse;% number of  events in each bin, in reverse order
        cum_b_values % reverse order cum. sum.
        
        fStd_Mc;
        magsteps_desc % the step in magnitude for the bins == .1
        % mag_zone
        % magco % magnitude of completion
        pr % probability
        %maxCurveMag
        %maxCurveBval
        
        % controlled by dialog 
        mc_method           McMethods       = ZmapGlobal.Data.McCalcMethod
        mc_auto             McAutoEstimate  = ZmapGlobal.Data.UseAutoEstimate
        fMccorr                             = 0       % magnitude of completeness correction factor
        useBootstrapping    logical         = false   % estimate errors with bootstrapping
        nBstSample                          = 100     % number of bootstraps used to estimate error
        doLinearityCheck    logical         = false   % perform nonlinearity check on B-values
        
        showDiscrete        matlab.lang.OnOffSwitchState  = 'on'    %show discrete events curve
        Nmin                                = 10;  % minimum number of events
    end
    
    properties(Constant)
        PlotTag = 'FMDplot';
        ParameterableProperties = ["mc_method", "mc_auto", "nBstSample", "useBootstrapping",...
            "doLinearityCheck", "fBinning", "showDiscrete", "ax"]
        
        tags = struct(...% itemdesc, tag
            'cumevents',    'total events at or above magnitude',...
            'discrete',     'DiscreteValuePlot',...
            'mc',           'magnitude of Completeness',...
            'mctext',       'mctext',...
            'linearfit',    'linear fit',...
            'bdinscontext', 'bdiff_from_inset context',...
            'bdcontext',    'bdiff context',...
            'mainbvalax',   'main_bval_axes'...
            )
        figName = "Frequency-magnitude distribution"
        figPos = [0.3 0.3 0.4 0.6] % normalized position for base figure
        axRect = [0.22,  0.3, 0.65, 0.6] % normalized position for axes within figure
    end
            
    
    methods
        function obj = bdiff2(catalogFcn, varargin)
            % obj = bdiff2(catalog, interactive, ax)
            % catalog used to default to ZG.newt2
            
            report_this_filefun();
            
            obj@ZmapFunction(catalogFcn);
            
            report_this_filefun();
            obj.parseParameters(varargin);
            obj.StartProcess();
        return
        
            ZG=ZmapGlobal.Data;
            
            if ~exist('catalogFcn','var') || isempty(catalogFcn)
                catalogFcn = @()ZG.newt2;
            end
            if ~exist('interactive','var') || isempty(interactive)
                interactive=true;
            end
              
            obj=obj.calculate(catalogFcn());
            if exist('ax','var') && ax == "noplot"
                % do not plot
                obj.write_globals();
                return;
            end
            if ~exist('ax','var')||isempty(ax)|| ~isvalid(ax)
                [ax]=obj.setup_figure(catalogFcn());
            end
            
            % add context menu equivalent to ztools menu
            f=ancestor(ax,'figure');
            delete(findobj(f,'Tag',obj.tags.bdcontext,'-and','Type','uicontextmenu'));
            c = uicontextmenu(f,'Tag',obj.tags.bdcontext);
            obj.create_my_menu(c,catalogFcn);
            ax.UIContextMenu=c;
            uimenu(ax.UIContextMenu,...
                'Label','Open as new figure',...
                MenuSelectedField(),@open_as_new_figure_cb);
                
            obj.write_globals();
            
            obj.plot(catalogFcn(),ax);
            
            function open_as_new_figure_cb(src, ev)
                otherobj = bdiff2(catalogFcn, 'InteractiveMode',false);
                f        = otherobj.setup_figure(catalogFcn);
                otherobj.plot(catalogFcn(),f);
            end
        end
        
        function InteractiveSetup(obj)
            zdlg = ZmapDialog(obj);
            zdlg.AddHeader('Magnitude of Completness parameters');
            
            zdlg.AddMcMethodDropdown('mc_method',     obj.mc_method);
            zdlg.AddMcAutoEstimateCheckbox('mc_auto', obj.mc_auto);
            
            zdlg.AddEdit('fMccorr',        'Mc Correction',                obj.fMccorr,...
                'Correction term for Magnitude of Completeness');
            zdlg.AddEdit('fBinning',     'Magnitude bin width',                   obj.fBinning,...
                'size of each magnitude bin');
            zdlg.AddEdit('Nmin',     'min # of events',                   obj.Nmin,...
                'Minimum number of events required to calculate b-values');
            zdlg.AddCheckbox('useBootstrapping','Uncertainty by bootstrapping', obj.useBootstrapping,{'nBstSample'},...
                'tooltip');
            zdlg.AddEdit('nBstSample',     'Bootstraps',                   obj.nBstSample,...
                'Number of bootstraps used to estimate error');
            zdlg.AddCheckbox('doLinearityCheck','Perform Nonlinearity check on B-values',obj.doLinearityCheck,[],...
                'tooltip');
            [res, pressedOk] = zdlg.Create('Mc Input Parameter');
            
            if ~okPressed
                return
            end
            %obj.SetValuesFromDialog(res)
            obj.doIt()
        end
        
        function obj = Calculate(obj)
            % global magsteps_desc cum_b_values  bval
            global gBdiff % contains b1, n1, b2, n2
            catalog = obj.RawCatalog;
          
            dMag = obj.fBinning;
            
            maxmag = max(catalog.Magnitude);
            maxmag = ceil(10 * maxmag) /10;
            
            mima = min([0; catalog.Magnitude]);
            mima = round(mima,1);
            
            obj.magsteps_desc = (maxmag : -dMag : mima);
            binEdges = (mima-(dMag/2) : dMag : maxmag+(dMag/2));
            
            
            %%
            %
            % bvalsum is the cum. sum in each bin
            %
            %%
            
            binnedEvents = histcounts(catalog.Magnitude, binEdges);
            obj.binnedEvents_reverse = binnedEvents(end : -1 : 1);
            obj.cum_b_values = cumsum(binnedEvents(end : -1 : 1));    % N for M >= (counted backwards)
            
            
            %%
            % Estimate the b value
            %
            % calculates max likelihood b value(bvml) && WLS(bvls)
            %
            
            [obj.magco, obj.fStd_Mc, b_value, b_value_std, a_value] = deal(NaN);
            
            if catalog.Count >= obj.Nmin
                % Added to obtain goodness-of-fit to powerlaw value
                magco = calc_Mc(catalog, obj.mc_method, obj.fBinning, obj.fMccorr);
                l = catalog.Magnitude >= obj.magco - (obj.fBinning/2);
                if sum(l) >= obj.Nmin
                    [b_value, b_value_std, a_value] = calc_bmemag(catalog.Magnitude(l), obj.fBinning);
                else
                    magco = NaN;
                end
                
                % Bootstrap uncertainties
                if obj.useBootstrapping
                    % Check Mc from original catalog
                    l = catalog.Magnitude >= magco-(obj.fBinning/2);
                    if sum(l) >= obj.Nmin
                        % note: this will replace the magnitude of completion with the mean magnitude of completion from bootstrapping
                        [magco, obj.fStd_Mc, b_value, b_value_std, a_value] = ...
                            calc_McBboot(catalog, obj.fBinning, obj.nBstSample, obj.mc_method, obj.Nmin, obj.fMccorr);
                    end
                end
            end% of if length(catalog) >= Nmin
            
            %% calculate limits of line to plot for b value line
            
            % For ZMAP
            halfstep = obj.fBinning / 2;
            obj.Result.index_low = find(obj.magsteps_desc < (magco + halfstep) & obj.magsteps_desc > (magco - halfstep));
            
            mag_hi = obj.magsteps_desc(1);
            % index_hi = 1;
            mz = obj.magsteps_desc <= mag_hi & obj.magsteps_desc >= magco-.0001;
            mag_zone=obj.magsteps_desc(mz);
            
            
            bdiffs = diff(obj.cum_b_values);
            maxCurveIdx = find(bdiffs == max(bdiffs),1,'last')+1;
            
            
            
            
            %% create and draw a line corresponding to the b value
            
            p = [ -1*b_value , a_value];
            obj.fitted = polyval(p, mag_zone);
            obj.fitted = 10 .^ obj.fitted;
            
            %% Error Bar Calculation -- call to pdf_calc.m
            obj.myXLim = [min(catalog.Magnitude)-0.5  max(catalog.Magnitude)+0.5];
            obj.myYLim = [0.9 length(catalog.Date+30)*2.5];
            
            
            %p=-p(1,1);
            %p=fix(100*p)/100;
            
            obj.Result.magco        = magco;
            obj.Result.b_value      = b_value;%bvml;
            obj.Result.a_value      = a_value; %avml;
            obj.Result.b_value_std  = b_value_std; %stanml;    % standard deviation of fit
            obj.Result.a_value_annual = a_value-log10(years(max(catalog.Date)-min(catalog.Date)));
            
            obj.Result.maxCurveMag  = obj.magsteps_desc(maxCurveIdx);
            obj.Result.maxCurveBval = obj.cum_b_values(maxCurveIdx);
            obj.Result.mag_zone     = mag_zone;
            
            
            
            
            if ZmapGlobal.Data.hold_state
                [obj.Result.pr, gBdiff] = calc_probability(obj,gBdiff);
            end
            
            if obj.doLinearityCheck
                obj.nonlin_keepmc(catalog);
            end
            
            
        end
      
        function ax = setup_figure(obj,catalogFcn)
            
            bfig=findobj(get(groot,'Children'),'flat','Type','Figure','-and','Name', obj.figName);
            if isempty(bfig)
                bfig=figure('Units','normalized','pos',obj.figPos,'NumberTitle','off','Name',obj.figName);
                
                
                add_menu_divider();
                c = uimenu('Label','ZTools');
                obj.create_my_menu(c,catalogFcn);
            else
                bfig.Visible='on';
                figure(bfig)
            end
            
            ax = findobj(bfig,'Tag',obj.tags.mainbvalax);
            if isempty(ax)
                ax=axes(bfig,'position',obj.axRect,'Tag',obj.tags.mainbvalax);
            end
            bfig.CurrentAxes=ax;
            
        end
       
        function plot(obj,catalog, ax)
            % extracted from inside the calculation routine
            
            global gBdiff % contains b1, n1, b2, n2
            ZG = ZmapGlobal.Data;
            
            bfig=ancestor(ax,'figure');
            is_standalone = bfig.Name==obj.figName && ax.Tag==string(obj.tags.mainbvalax);
            
            if is_standalone
                fs=ZG.fontsz.m;
            else
                fs=get(ax,'FontSize');
            end
            fontProps = {'FontWeight','normal','FontSize',fs};
            
            ax.YScale='log';
            ax.NextPlot='add';
            obj.updatePlottedCumSum(ax);
            
            obj.updatePlottedDiscreteValues(ax);
            % CALCULATE the diff in cum sum from the previous bin
           
            obj.updatePlottedMc(ax);
            obj.updatePlottedBvalLine(ax);
            
            ax.XLim=obj.myXLim;
            ax.YLim=obj.myYLim;
            
            tx = obj.descriptive_text(gBdiff);
            
            if is_standalone % unique figure, go ahead,
                rect=[0 0 1 1];
                h2=axes('position',rect);
                h2.Visible='off';
                text(ax,.16,.14,tx,'Tag','bvaltext');
            else
                txh=text(ax,'Units','Normalized',...
                    'HorizontalAlignment','right',...
                    'Position',[.995 .75],...
                    'String',tx,'Tag','bvaltext');
                txh.String(end)=[];
            end
            
            bfig.Visible = 'on';
            ax.NextPlot='replace';
            
            % make axis pretty
            grid(ax,'on');
            xlabel('Magnitude',fontProps{:});
            ylabel('Cumulative Number',fontProps{:});
            set(ax,'visible','on',fontProps{:},...
                'LineWidth',1.0,'TickDir','out','Ticklength',[0.02 0.02],...
                'Box','on','Tag','cufi','color','w')
            
            legend(ax,'show');
            ax.Legend.String(~(startsWith(ax.Legend.String,'Cum') | startsWith(ax.Legend.String,'Discrete')))=[];
            
            % created here too, for when figure is created from inset figure
            if isempty(ax.UIContextMenu)
                delete(findobj(bfig,'Tag',obj.tags.bdinscontext))
                c = uicontextmenu('Tag',obj.tags.bdinscontext);
                obj.create_my_menu(c,catalog);
                ax.UIContextMenu=c;
            end
            uimenu(ax.UIContextMenu,'Separator','on',...
                'Label','info',MenuSelectedField(),@(~,~)msgbox(tx,'b-Value results','modal'));
        end
        
        function updatePlottedCumSum(obj,ax)
            % plot the cum. sum in each bin
            h = findobj(ax,'Tag',obj.tags.cumevents);
            if isempty(h)
                scatter(ax,obj.magsteps_desc, obj.cum_b_values,...
                    'Marker','s',...
                    'LineWidth',1.0,...
                    'MarkerEdgeColor','k',...
                    'Tag',obj.tags.cumevents,...
                    'DisplayName','Cum events > M(x)');
            else
                h.XData=obj.magsteps_desc;
                h.YData=obj.cum_b_values;
            end
        end
        function updatePlottedDiscreteValues(obj,ax)
            % plot discrete values
            hdv = findobj(ax,'Tag',obj.tags.discrete);
            if isempty(hdv)
            scatter(ax,obj.magsteps_desc,obj.binnedEvents_reverse,'Marker','^',...
                'LineWidth',1.0,...
                'MarkerFaceColor',[0.7 0.7 .7],'MarkerEdgeColor','k',...
                'Tag',obj.tags.discrete, 'DisplayName','Discrete');
            else
                hdv.XData=obj.magsteps_desc;
                hdv.YData=obj.binnedEvents_reverse;
            end
        end  
            
        function updatePlottedMc(obj, ax)
            
            % Marks the point of Mc
            mcText = sprintf('%s: %0.1f','Mc',obj.Results.magco);
            
            mcline=findobj(ax,'Tag',obj.tags.mc);
            if isempty(mcline)
                line(ax, obj.magsteps_desc(obj.index_low),...
                    obj.cum_b_values(obj.index_low)*1.5,...
                    'Marker','v','MarkerFaceColor','b',...
                    'LineWidth',1.0,'LineStyle','none','MarkerSize',7,...
                    'Tag',obj.tags.mc,...
                    'DisplayName',mcText);
            else
                mcline.XData=obj.magsteps_desc(obj.index_low);
                mcline.YData=obj.cum_b_values(obj.index_low)*1.5;
                mcline.DisplayName=mcText;
            end
            hmctext=findobj(ax,'Tag',obj.tags.mctext);
            if isempty(hmctext)
                ZG=ZmapGlobal.Data;
                
                text(ax,obj.magsteps_desc(obj.index_low)+0.2,obj.cum_b_values(obj.index_low)*1.5,...
                    mcText,'FontWeight','bold','FontSize',ZG.fontsz.s,'Color','b','Tag',obj.tags.mctext)
            else
                hmctext.Position([1 2])=[obj.magsteps_desc(obj.index_low)+0.2, obj.cum_b_values(obj.index_low)*1.5];
                hmctext.String=mcText;
            end
            
                
        end
        
        function  updatePlottedBvalLine(obj,ax)
            % plot line corresponding to B value
            %bvdispname = sprintf('b-val: %.3f +/- %0.3f\na-val: %.3f\na-val_{annual}: %.3f',obj.b_value, obj.b_value_std, obj.a_value, obj.a_value_annual);
            bvl = findobj(ax,'Tag',obj.tags.linearfit);
            if isempty(bvl)
                line(ax, obj.mag_zone,obj.fitted,'Color','r','LineWidth',1 ,...
                    'Tag', obj.tags.linearfit...,'DisplayName',bvdispname
                    );   % plot linear fit to backg
            else
                bvl.XData=obj.Result.mag_zone;
                bvl.YData=obj.fitted;
                % bvl.DisplayName=bvdispname;
            end
            txh = findobj(ax,'Tag','bvaltext');
            set(txh,'String', obj.descriptive_text());
        end
        
        
        function tx=descriptive_text(obj,gBdiff)
            ZG=ZmapGlobal.Data;
            res = obj.Result;
            if ZG.hold_state
                ba_text = sprintf('b-value (w LS, M >= %f): %.2f +/-%.2f \na-value = %.3f',...
                    res.MaxCurveMag ,res.b_value, res.b_value_std, res.a_value );
                
                p_text = sprintf('p=  %.2g', obj.pr);
                if exist('gBdiff','var')
                nbs_text = sprintf('n1: %g, n2: %g, b1: %g, b2: %g', gBdiff.n1, gBdiff.n2, gBdiff.b1, gBdiff.b2);
                else
                    nbs_text = 'n1:? n2:? b1:? b2:?';
                end
                tx = sprintf('%s\n%s\n%s', ba_text, p_text, nbs_text');
            else
                fmt = 'b-value = %.2f +/-%.2f\na-value=%.3f, (annual)=%.3f';
                if ~obj.useBootstrapping
                    ba_text = sprintf(fmt, res.b_value, res.b_value_std, res.a_value, res.a_value_annual);
                    sol_type = 'Max Likelihood Solution';
                    mag_text = sprintf('Magnitude of Completeness=%.2f',obj.magco);
                else
                    ba_text = sprintf(fmt, res.b_value, res.b_value_std, res.a_value, res.a_value_annual);
                    sol_type = 'Max Likelihood Est., Uncertainties by bootstrapping';
                    mag_text = sprintf('Magnitude of Completeness=%.2f +/-%.2f',obj.magco, obj.fStd_Mc);
                end
                tx = sprintf('%s\n%s\n%s', sol_type, ba_text ,mag_text);
            end % ZmapGlobal.Data.hold_state
            
        end
        %% ui functions
        function create_my_menu(obj,c,catalogFcn)
            uimenu(c,'Label','Estimate recurrence time/probability',MenuSelectedField(),@callbackfun_recurrence);
            uimenu(c,'Label','Plot time series',MenuSelectedField(),{@callbackfun_ts,catalogFcn});
            uimenu(c,'Label','Examine Nonlinearity (optimize  Mc)',MenuSelectedField(),{@cb_nonlin_optimize,catalogFcn});
            uimenu(c,'Label','Examine Nonlinearity (Keep Mc)',MenuSelectedField(),{@cb_nonlin_keepmc,catalogFcn});
            uimenu(c,'Label','Show discrete curve',MenuSelectedField(),@cb_toggleDiscrete,'Checked',char(obj.ShowDiscrete));
            uimenu(c,'Label','Save values to file',MenuSelectedField(),{@calSave9,obj.magsteps_desc, obj.Resultcum_b_values});
            addAboutMenuItem();
            
            function callbackfun_recurrence(~,~)
                global onesigma
                plorem(onesigma, obj.Result.a_value, obj.Result.b_value);
            end
            
            function callbackfun_ts(~,~,catalogFcn)
                ZG=ZmapGlobal.Data;
                ZG.newcat = catalogFcn();
                ctp=CumTimePlot(catalogFcn());
                ctp.plot();
            end
            
            function cb_toggleDiscrete(mysrc,~)
                % toggles discrete curve
                obj.showDiscrete = ~logical(obj.showDiscrete);
                mysrc.Checked = obj.showDiscrete;
                set(findobj(gcf,'Tag',obj.tags.discrete),'Visible', mysrc.Checked);
            end
            
            function cb_nonlin_optimize(~, ~,catalogFcn)
                [Results.bestmc,Results.bestb,Results.result_flag] = nonlinearity_index(catalogFcn(), obj.magco, 'OptimizeMc');
                Results.functioncall = sprintf('nonlinearity_index(catalog,%.1f,''OptimizeMc'')',obj.magco);
                assignin('base', 'Results_NonlinearityAnalysis',Results);
            end
            function cb_nonlin_keepmc(~, ~,catalogFcn)
                obj.nonlin_keepmc(catalogFcn());
                % DUPLICATED ast obj.nonlin_keepmc
                %[Results.bestmc,Results.bestb,Results.result_flag]=nonlinearity_index(catalog, obj.magco, 'PreDefinedMc');
                %Results.functioncall = sprintf('nonlinearity_index(catalog,%.1f,''PreDefinedMc'')',obj.magco);
                %assignin('base','Results_NonlinearityAnalysis',Results);
            end
        
        end
        
        function write_globals(obj)
            global a_value b_value b_value_std
            global inpr1
            global magsteps_desc
            global magco
            a_value = obj.a_value;
            b_value = obj.b_value;
            b_value_std = obj.b_value_std;
            inpr1 = obj.dlg_res.mc_method;
            magsteps_desc = obj.magsteps_desc;
            cum_b_values = obj.cum_b_values;
            magco = obj.magco;
            
        end
        
        function nonlin_keepmc(obj,catalog)
            [Results.bestmc,Results.bestb,Results.result_flag]=nonlinearity_index(catalog, obj.magco, 'PreDefinedMc');
            Results.functioncall = sprintf('nonlinearity_index(catalog,%.1f,''PreDefinedMc'')',obj.magco);
            assignin('base','Results_NonlinearityAnalysis',Results);
        end
            
    end
    methods(Access=private)
        function [pr, gBdiff] = calc_probability(obj,gBdiff)
                % calculate percentages.
                gBdiff.b2 = round(obj.b_value,3);
                gBdiff.n2 = obj.maxCurveBval;
                n = gBdiff.n1+gBdiff.n2;
                da = -2*n*log(n) + 2*gBdiff.n1*log(gBdiff.n1+gBdiff.n2*gBdiff.b1/gBdiff.b2) + 2*gBdiff.n2*log(gBdiff.n1*gBdiff.b2/gBdiff.b1+gBdiff.n2) -2;
                pr = exp(-da/2-2);
        end
    end
    
    methods(Static)
        
        function h=AddMenuItem(parent,catalogFcn)
            % create a menu item
            label='FMD plot';
            h=uimenu(parent,'Label',label,MenuSelectedField(), @(~,~)bdiff2(catalogFcn()));
        end
    end
end
