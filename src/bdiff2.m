classdef bdiff2 < ZmapFunction
    % bdiff2 estimates the b-value of a curve automatically
    % The b-value curve is differenciated and the point
    % of the magnitude of completeness is marked. The b-value will be calculated
    % using this point and the point half way toward the high
    % magnitude end of the b-value curve.
    %
    %
    % note : No longer discarding magco when catalog has enough events, but
    %        number of events > magco
                    
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
        fitted % was f
        binnedEvents_reverse;% number of  events in each bin, in reverse order
        cum_b_values % reverse order cum. sum.
        
        mag_bin_centers % the step in magnitude for the bins == .1
        % mag_zone
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
        
        % properties to apply to the various plots
        plotProps           struct          = struct(   'Mc',struct(),...
                                                        'McText',struct(),...
                                                        'Discrete',struct(),...
                                                        'CumSum',struct(),...
                                                        'BvalFit',struct());
    end
    
    properties(Constant)
        PlotTag = 'FMDplot';
        
         ReturnDetails = cell2table({ ... VariableNames, VariableDescriptions, VariableUnits
            'Mc_value',     'Magnitude of Completion (Mc)', '';... % was magco
            'Mc_std',       'Std. of Magnitude of Completion', '';... % was fStd_Mc
            'b_value',      'b-value', '';...   % was bw
            'b_value_std',  'Std. of b-value', '';...  % was ew
            'a_value',      'a-value', '';...  % was aw
            'a_value_annual',  'Annualized a-value', '';... % was a0
            'power_fit',    'Goodness of fit to power-law', '';...
            'Additional_Runs_b_std',  'Additional runs: Std b-value', '';...
            'Additional_Runs_Mc_std', 'Additional runs: Std of Mc', '';...
            'index_low','','';...
            'pr','probability','';...
            'maxCurveMag','','';...
            'maxCurveBval','','';...
            'fitted','linear fit','';...  % was f
            'cum_b_values','cumulative b-values','';...
            }, 'VariableNames', {'Names','Descriptions','Units'})
        
        ParameterableProperties = ["mc_method", "mc_auto", "nBstSample", "useBootstrapping",...
            "doLinearityCheck", "fBinning", "showDiscrete","ax"]
        
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
        function obj = bdiff2(catalog, varargin)
            % obj = bdiff2(catalog, interactive, ax)
            % catalog used to default to ZG.newt2
            
            obj@ZmapFunction(catalog);
            
            report_this_filefun();
            
            
            % the varous plotProps control how the plots appear
            obj.plotProps.Figure(1).Units = 'normalized';
            obj.plotProps.Figure.pos = obj.figPos;
            obj.plotProps.Figure.NumberTitle = 'off';
            obj.plotProps.Figure.Name = obj.figName;
            
            obj.plotProps.Mc(1).Marker              = 'v';
            obj.plotProps.Mc.MarkerFaceColor        = 'b';
            obj.plotProps.Mc.LineWidth              = 1.0;
            obj.plotProps.Mc.LineStyle              = 'none';
            obj.plotProps.Mc.MarkerSize             = 7;
            obj.plotProps.Mc.Tag                    = obj.tags.mc;
            
            obj.plotProps.McText(1).FontWeight      = 'bold';
            obj.plotProps.McText.FontSize           = obj.ZG.fontsz.s;
            obj.plotProps.McText.Color              = 'b';
            obj.plotProps.McText.Tag                = obj.tags.mctext;
            
            obj.plotProps.Discrete(1).Marker        = '^';
            obj.plotProps.Discrete.LineWidth        = 1.0;
            obj.plotProps.Discrete.MarkerFaceColor  = [0.7 0.7 .7];
            obj.plotProps.Discrete.MarkerEdgeColor  = 'k';
            obj.plotProps.Discrete.Tag              = obj.tags.discrete;
            obj.plotProps.Discrete.DisplayName      = 'Discrete';
            
            obj.plotProps.CumSum(1).Marker          = 's';
            obj.plotProps.CumSum.LineWidth          = 1.0;
            obj.plotProps.CumSum.MarkerEdgeColor    = 'k';
            obj.plotProps.CumSum.Tag                = obj.tags.cumevents;
            obj.plotProps.CumSum.DisplayName        = 'Cum events > M(x)';
            
            obj.plotProps.BvalFit(1).Color          = 'r';
            obj.plotProps.BvalFit.LineWidth         = 1;
            obj.plotProps.BvalFit.Tag               = obj.tags.linearfit;
            
            obj.plotProps.Axes(1).LineWidth     = 1.0;
            obj.plotProps.Axes.Color            = 'w';
            obj.plotProps.Axes.Tag              = 'cufi';
            obj.plotProps.Axes.Box              = 'on';
            obj.plotProps.Axes.TickDir          = 'out';
            obj.plotProps.Axes.TickLength       = [0.02 0.02];
            
            p = obj.parseParameters(varargin);
            if ismember('useBootStrapping', p.UsingDefaults) && ~ismember('nBstSample',p.UsingDefaults)
                % user specified number of bootstraps. This means they want to do bootstrapping (unless this is 0)
                obj.useBootStrapping = obj.nBstSample ~= 0;
            end
            
            obj.StartProcess();
        return
            
            if ~exist('catalog','var') || isempty(catalog)
                catalog = obj.ZG.newt2;
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
            obj.create_my_menu(c);
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
            [res, okPressed] = zdlg.Create('Mc Input Parameter');
            
            if ~okPressed
                return
            end
            %obj.SetValuesFromDialog(res)
            obj.doIt()
        end
        
        function obj = Calculate(obj)
            global gBdiff % contains b1, n1, b2, n2
            obj.Result(1).magco = NaN; % have to assign SOMETHING to the first item of struct when that struct is empty
            
            catalog = obj.RawCatalog;
          
            dMag = obj.fBinning;
            
            maxmag = max(catalog.Magnitude);
            maxmag = ceil(10 * maxmag) /10;
            
            mima = min([0; catalog.Magnitude]);
            mima = round(mima,1);
            
            obj.mag_bin_centers = (maxmag : -dMag : mima);
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
            
            
            if catalog.Count >= obj.Nmin
                % Added to obtain goodness-of-fit to powerlaw value
                
                % calculate an initial magnitude of completion
                magco = calc_Mc(catalog, obj.mc_method, obj.fBinning, obj.fMccorr);
                
                % use it to cut the catalog
                l = catalog.Magnitude >= magco - (obj.fBinning/2);
                
                % if there are still enough events in the cut catalog, then calculate b- and a- values
                if sum(l) >= obj.Nmin
                    if ~obj.useBootstrapping
                        [b_value, b_value_std, a_value] = calc_bmemag(catalog.Magnitude(l), obj.fBinning);
                        fStd_Mc = NaN;
                    else
                        % note: this replaces Mc with the mean Mc from bootstrapping
                        % note also: catalog analyzed is the UNCUT original catalog.
                        [magco, fStd_Mc, b_value, b_value_std, a_value] = ...
                            calc_McBboot(catalog, obj.fBinning, obj.nBstSample, obj.mc_method, obj.Nmin, obj.fMccorr);
                    end
                else
                    [fStd_Mc, b_value, b_value_std, a_value] = NaN;
                end
            else  % catalog doesn't have enough values
                    [magco, fStd_Mc, b_value, b_value_std, a_value] = NaN;
            end 
            
            %% calculate limits of line to plot for b value line
            
            % For ZMAP
            halfstep = obj.fBinning / 2;
            obj.Result.index_low = find(obj.mag_bin_centers < (magco + halfstep) & obj.mag_bin_centers > (magco - halfstep));
            
            mag_hi = obj.mag_bin_centers(1);
            % index_hi = 1;
            mz = obj.mag_bin_centers <= mag_hi & obj.mag_bin_centers >= magco-.0001;
            mag_zone=obj.mag_bin_centers(mz);
            
            
            bdiffs = diff(obj.cum_b_values);
            maxCurveIdx = find(bdiffs == max(bdiffs),1,'last')+1;
            
            
            
            
            %% create and draw a line corresponding to the b value
            
            p = [ -1*b_value , a_value];
            obj.fitted = polyval(p, mag_zone);
            obj.fitted = 10 .^ obj.fitted;
            
            %% Error Bar Calculation -- call to pdf_calc.m
            obj.myXLim = [min(catalog.Magnitude)-0.5  max(catalog.Magnitude)+0.5];
            obj.myYLim = [0.9 length(catalog.Date+30)*2.5];
            
            obj.Result.Mc_value     = magco;
            obj.Result.Mc_std       = fStd_Mc;
            
            obj.Result.b_value      = b_value;
            obj.Result.b_value_std  = b_value_std; % standard deviation of fit
            
            obj.Result.a_value      = a_value;
            obj.Result.a_value_annual = a_value-log10(years(max(catalog.Date)-min(catalog.Date)));
            
            obj.Result.maxCurveMag  = obj.mag_bin_centers(maxCurveIdx);
            obj.Result.maxCurveBval = obj.cum_b_values(maxCurveIdx);
            obj.Result.mag_zone     = mag_zone;
            
            if ZmapGlobal.Data.hold_state
                [obj.Result.pr, gBdiff] = calc_probability(obj,gBdiff);
            end
            
            if obj.doLinearityCheck
                obj.nonlin_keepmc(catalog);
            end
            
            
        end
      
        function ax = setup_figure(obj)
            
            bfig=findobj(get(groot,'Children'),'flat','Type','Figure','-and','Name', obj.figName);
            if isempty(bfig)
                bfig=figure(obj.plotProps.Figure);
                
                
                add_menu_divider();
                c = uimenu('Label','ZTools');
                obj.create_my_menu(c);
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
       
        function plot(obj,ax)
            % extracted from inside the calculation routine
            
            global gBdiff % contains b1, n1, b2, n2
            
            if ~exist('ax','var')
                if isempty(obj.ax)
                    obj.ax = obj.setup_figure();
                end
                ax = obj.ax;
            end
            
            bfig=ancestor(ax,'figure');
            is_standalone = bfig.Name==obj.figName && ax.Tag==string(obj.tags.mainbvalax);
            
            if is_standalone
                fs=obj.ZG.fontsz.m;
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
                    'String',tx,'Tag','bvaltext','Interpreter','none');
                txh.String(end)=[];
            end
            
            bfig.Visible = 'on';
            ax.NextPlot='replace';
            
            % make axis pretty
            grid(ax,'on');
            xlabel('Magnitude',fontProps{:});
            ylabel('Cumulative Number',fontProps{:});
            set(ax,'visible','on',fontProps{:});
            set(ax,obj.plotProps.Axes);
            
            legend(ax,'show');
            ax.Legend.String(~(startsWith(ax.Legend.String,'Cum') | startsWith(ax.Legend.String,'Discrete')))=[];
            
            % created here too, for when figure is created from inset figure
            if isempty(ax.UIContextMenu)
                delete(findobj(bfig,'Tag',obj.tags.bdinscontext))
                c = uicontextmenu('Tag',obj.tags.bdinscontext);
                obj.create_my_menu(c);
                ax.UIContextMenu=c;
            end
            uimenu(ax.UIContextMenu,'Separator','on',...
                'Label','info',MenuSelectedField(),@(~,~)msgbox(tx,'b-Value results','modal'));
        end
        
        function updatePlottedCumSum(obj,ax)
            % plot the cum. sum in each bin
            h = findobj(ax,'Tag',obj.tags.cumevents);
            if isempty(h)
                h = scatter(ax,obj.mag_bin_centers, obj.cum_b_values);
                set(h, obj.plotProps.CumSum);
            else
                h.XData=obj.mag_bin_centers;
                h.YData=obj.cum_b_values;
            end
        end
        
        function updatePlottedDiscreteValues(obj,ax)
            % plot discrete values
            hdv = findobj(ax,'Tag',obj.tags.discrete);
            if isempty(hdv)
                hdv = scatter(ax,obj.mag_bin_centers, obj.binnedEvents_reverse);
                set(hdv, obj.plotProps.Discrete);
            else
                hdv.XData=obj.mag_bin_centers;
                hdv.YData=obj.binnedEvents_reverse;
            end
        end  
            
        function updatePlottedMc(obj, ax)
            
            % Marks the point of Mc
            mcText = sprintf('%s: %0.1f','Mc',obj.Result.Mc_value);
            idx_low = obj.Result.index_low
            markerX = obj.mag_bin_centers(idx_low);
            markerY = obj.cum_b_values(idx_low) * 1.5;
            textX = markerX + 0.2;
            
            hMc=findobj(ax,'Tag',obj.tags.mc);
            if isempty(hMc)
                hMc = line(ax, markerX, markerY,'DisplayName',mcText);
                set(hMc, obj.plotProps.Mc);
            else
                hMc.XData=markerX;
                hMc.YData=markerY;
                hMc.DisplayName=mcText;
            end
            
            hMcText=findobj(ax,'Tag',obj.tags.mctext);
            
            if isempty(hMcText)
                hMcText = text(ax,textX, markerY, mcText);
                set(hMcText, obj.plotProps.McText);
            else
                hMcText.Position([1 2])=[textX, markerY];
                hMcText.String=mcText;
            end
            
                
        end
        
        function  updatePlottedBvalLine(obj,ax)
            % plot line corresponding to B value
            %bvdispname = sprintf('b-val: %.3f +/- %0.3f\na-val: %.3f\na-val_{annual}: %.3f',obj.b_value, obj.b_value_std, obj.a_value, obj.a_value_annual);
            bvl = findobj(ax,'Tag',obj.tags.linearfit);
            if isempty(bvl)
                line(ax, obj.Result.mag_zone, obj.fitted, obj.plotProps.BvalFit);
            else
                bvl.XData = obj.Result.mag_zone;
                bvl.YData = obj.fitted;
                % bvl.DisplayName=bvdispname;
            end
            
            set(findobj(ax,'Tag','bvaltext'), 'String', obj.descriptive_text());
        end
        
        
        function tx=descriptive_text(obj,gBdiff)
            res = obj.Result;
            if obj.ZG.hold_state
                ba_text = sprintf('b-value (w LS, M >= %f): %.2f +/-%.2f \na-value = %.3f',...
                    res.MaxCurveMag ,res.b_value, res.b_value_std, res.a_value );
                
                p_text = sprintf('p=  %.2g', obj.Result.pr);
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
                    sol_type = char(obj.mc_method) + " solution"%'Max Likelihood Solution';
                    mag_text = sprintf('Magnitude of Completeness=%.2f',res.Mc_value);
                else
                    ba_text = sprintf(fmt, res.b_value, res.b_value_std, res.a_value, res.a_value_annual);
                    sol_type = string(obj.mc_method) + "solution, Uncertainties by bootstrapping";
                    mag_text = sprintf('Magnitude of Completeness=%.2f +/-%.2f',res.Mc_value, res.Mc_std);
                end
                tx = sprintf('%s\n%s\n%s', sol_type, ba_text ,mag_text);
            end % ZmapGlobal.Data.hold_state
            
        end
        %% ui functions
        function create_my_menu(obj,c)
            uimenu(c,'Label','Estimate recurrence time/probability',MenuSelectedField(),@callbackfun_recurrence);
            uimenu(c,'Label','Plot time series',MenuSelectedField(),{@callbackfun_ts,catalogFcn});
            uimenu(c,'Label','Examine Nonlinearity (optimize  Mc)',MenuSelectedField(),{@cb_nonlin_optimize,catalogFcn});
            uimenu(c,'Label','Examine Nonlinearity (Keep Mc)',MenuSelectedField(),{@cb_nonlin_keepmc,catalogFcn});
            uimenu(c,'Label','Show discrete curve',MenuSelectedField(),@cb_toggleDiscrete,'Checked',char(obj.showDiscrete));
            uimenu(c,'Label','Save values to file',MenuSelectedField(),@simple_save_cb);
            addAboutMenuItem();
            
            function catalog = catalogFcn()
                catalog = obj.RawCatalog;
            end
            function simple_save_cb(~,~)
                calsave9(obj.mag_bin_centers, obj.Result.cum_b_values)
            end
            
            function callbackfun_recurrence(~,~)
                global onesigma
                plorem(obj.RawCatalog, onesigma, obj.Result.a_value, obj.Result.b_value);
            end
            
            function callbackfun_ts(~,~,catalogFcn)
                obj.ZG.newcat = catalogFcn();
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
                [Results.bestmc,Results.bestb,Results.result_flag] = nonlinearity_index(catalogFcn(), obj.Result.Mc_value, 'OptimizeMc');
                Results.functioncall = sprintf('nonlinearity_index(catalog,%.1f,''OptimizeMc'')',obj.Result.Mc_value);
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
            global a_value b_value b_value_std cumsum3
            global inpr1
            global mag_bin_centers
            global magco
            a_value = obj.Result.a_value;
            b_value = obj.Result.b_value;
            b_value_std = obj.Result.b_value_std;
            inpr1 = obj.dlg_res.mc_method;
            mag_bin_centers = obj.mag_bin_centers;
            cumsum3 = obj.cum_b_values;
            magco = obj.Result.Mc_value;
            
        end
        
        function nonlin_keepmc(obj,catalog)
            [Results.bestmc,Results.bestb,Results.result_flag]=nonlinearity_index(catalog, obj.Result.Mc_value, 'PreDefinedMc');
            Results.functioncall = sprintf('nonlinearity_index(catalog,%.1f,''PreDefinedMc'')',obj.Result.Mc_value);
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
        
        function [allpassed, failMethods] = test(catalog, varargin)
            % [allpassed, failMethods] = test(catalog)
            %  ... = test(...,'fail',true) force errors to be thrown instead of caught & reported
            %  ... = test(...,'interactive',true) allow bvalue popup to be interactive
            
            p=inputParser();
            p.addParameter('fail',false)
            p.addParameter('interactive',false);
            p.parse(varargin{:})
            
            mc_methods = enumeration('McMethods');
            failMethods = McMethods([]);
            nCols = 3;
            nRows = 3;
            f = findobj('Tag','Bvalue test');
            if isempty(f)
                figure('Name','Bvalue test' + string(datetime),'Tag','Bvalue test');
            else
                figure(f);
                clf
            end
            
            for i=1:numel(mc_methods)
                mc_method=mc_methods(i);
                ax = subplot(nCols, nRows, i);
                ttl = char(mc_method);
                title(ax,ttl,'Interpreter','none');
                if p.Results.fail
                    bdiff2(catalog,'ax',ax,'mc_method',mc_method, 'InteractiveMode',p.Results.interactive);
                else
                    try
                        bdiff2(catalog,'ax',ax,'mc_method',mc_method, 'InteractiveMode',p.Results.interactive);
                    catch ME
                        ttl = ttl + ": BROKEN";
                        failMethods = [failMethods; mc_method]; %#ok<AGROW>
                        warning(ME.identifier, "%s\n", ME.message);
                        for j = 1 : min(3, numel(ME.stack))
                            disp(ME.stack(j));
                        end
                    end
                end
                if ~isempty(ax.Legend) && i > 1
                    ax.Legend.Visible = 'off';
                end
                title(ax,ttl,'Interpreter','none');
                drawnow
                
            end
            allpassed = isempty(failMethods);
        end
    end
end
