classdef bdiff2
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
        dlg_res;
        fBinning = 0.1; % magnitude binning
        index_low;
        std_backg; % standard deviation of bval
        myXLim;
        myYLim;
        f
        a0
        aw % a-value
        bw % b-value
        ew % error for b-value
        bval % contains the number of events in each bin (possibly unnecessary to store in class)
        bval2;% number of  events in each bin, in reverse order
        bvalsum3 % reverse order cum. sum.
        
        fStd_Mc;
        magsteps_desc % the step in magnitude for the bins == .1
        mag_zone
        magco % magnitude of completion
        pr ; % probability
        maxCurveMag;
        maxCurveBval;
        
        
    end
    properties(Constant)
        tags = struct(...% itemdesc, tag
            'cumevents', 'total events at or above magnitude',...
            'discrete','DiscreteValuePlot',...
            'mc','magnitude of Completeness',...
            'mctext','mctext',...
            'linearfit','linear fit',...
            'bdinscontext','bdiff_from_inset context',...
            'bdcontext','bdiff context',...
            'mainbvalax','main_bval_axes'...
            )
        figName = "Frequency-magnitude distribution"
        figPos = [0.3 0.3 0.4 0.6] % normalized position for base figure
        axRect = [0.22,  0.3, 0.65, 0.6] % normalized position for axes within figure
    end
            
    
    methods
        function obj = bdiff2(catalogFcn, interactive, ax)
            % obj = bdiff2(catalog, interactive, ax)
            % if unspecified, catalog defaults to ZG.newt2
            
            report_this_filefun();
            
            ZG=ZmapGlobal.Data;
            
            if ~exist('catalogFcn','var') || isempty(catalogFcn)
                catalogFcn = @()ZG.newt2;
            end
            if ~exist('interactive','var') || isempty(interactive)
                interactive=true;
            end
                
            
            % Default value
            nBstSample = 100;
            fMccorr = 0;
            
            
            if interactive
                %% new dialog
                zdlg = ZmapDialog();
                zdlg.AddBasicHeader('Magnitude of Completness parameters');
                zdlg.AddBasicPopup('mc_method','Max. likelihood Estimation',McMethods.dropdownList(),double(McMethods.MaxCurvature),'Choose Magnitude of completion calculation method');
                zdlg.AddBasicEdit('fMccorr','Mc Correction',fMccorr,'Correction term for Magnitude of Completeness');
                zdlg.AddBasicCheckbox('doBootstrap','Uncertainty by bootstrapping',false,{'nBstSample'},'tooltip');
                zdlg.AddBasicEdit('nBstSample','Bootstraps',nBstSample,'Number of bootstraps used to estimate error');
                zdlg.AddBasicCheckbox('doLinearityCheck','Perform Nonlinearity check on B-values',false,[],'tooltip');
                [obj.dlg_res, pressedOk] = zdlg.Create('Mc Input Parameter');
                if ~pressedOk
                    return
                end
            else
                dlg_res.mc_method = double(McMethods.MaxCurvature);
                dlg_res.fMccorr = fMccorr;
                dlg_res.doBootstrap = false;
                dlg_res.nBstSample = nBstSample;
                dlg_res.doLinearityCheck = false;
                obj.dlg_res = dlg_res;
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
            
            % add context menu equivelent to ztools menu
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
                otherobj = bdiff2(catalogFcn, false);
                f=otherobj.setup_figure(catalogFcn);
                otherobj.plot(catalogFcn(),f);
            end
        end
        
        function obj = calculate(obj, catalog)
            % global magsteps_desc bvalsum3  bval
            global gBdiff % contains b1, n1, b2, n2
            if isempty(catalog)
                msg.dbdisp('catalog is empty')
                return
            end
            ZG = ZmapGlobal.Data;
            
            % reassign variables
            ZG.inb2 = obj.dlg_res.mc_method;
            fMccorr = obj.dlg_res.fMccorr;
            nBstSample = obj.dlg_res.nBstSample;
            method = obj.dlg_res.mc_method;
            doBootstrap = obj.dlg_res.doBootstrap;
            doLinearityCheck = obj.dlg_res.doLinearityCheck;
            
            dMag = 0.1;
            
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
            
            obj.bval = histcounts(catalog.Magnitude, binEdges);
            obj.bval2 = obj.bval(end : -1 : 1);
            obj.bvalsum3 = cumsum(obj.bval(end : -1 : 1));    % N for M >= (counted backwards)
            
            
            %%
            % Estimate the b value
            %
            % calculates max likelihood b value(bvml) && WLS(bvls)
            %
            %%
            
            %% SET DEFAULTS TO BE ADDED INTERACTIVELY LATER
            Nmin = 10;
            
            %% enough events??
            [obj.magco, obj.fStd_Mc, fBValue, fStd_B, fAValue] = deal(NaN);
            if catalog.Count >= Nmin
                % Added to obtain goodness-of-fit to powerlaw value
                [~, ~, ~, obj.magco, ~]=mcperc_ca3(catalog.Magnitude);
                
                obj.magco = calc_Mc(catalog, method, obj.fBinning, fMccorr);
                l = catalog.Magnitude >= obj.magco-(obj.fBinning/2);
                if sum(l) >= Nmin
                    [ fBValue, fStd_B, fAValue] =  calc_bmemag(catalog.Magnitude(l), obj.fBinning);
                else
                    obj.magco = NaN;
                end
                
                % Bootstrap uncertainties
                if doBootstrap
                    % Check Mc from original catalog
                    l = catalog.Magnitude >= obj.magco-(obj.fBinning/2);
                    if sum(l) >= Nmin
                        [obj.magco, obj.fStd_Mc, fBValue, fStd_B, fAValue] = calc_McBboot(catalog, obj.fBinning, nBstSample, method, Nmin, fMccorr);
                    end
                end
            end% of if length(catalog) >= Nmin
            
            %% calculate limits of line to plot for b value line
            
            % For ZMAP
            obj.index_low=find(obj.magsteps_desc < obj.magco+.05 & obj.magsteps_desc > obj.magco-.05);
            
            mag_hi = obj.magsteps_desc(1);
            % index_hi = 1;
            mz = obj.magsteps_desc <= mag_hi & obj.magsteps_desc >= obj.magco-.0001;
            obj.mag_zone=obj.magsteps_desc(mz);
            
            
            bdiffs = diff(obj.bvalsum3);
            maxCurveIdx = find(bdiffs == max(bdiffs),1,'last')+1;
            
            obj.maxCurveMag = obj.magsteps_desc(maxCurveIdx);
            obj.maxCurveBval = obj.bvalsum3(maxCurveIdx);
            
            obj.bw=fBValue;%bvml;
            obj.aw=fAValue;%avml;
            obj.ew=fStd_B;%stanml;
            
            
            %% create and draw a line corresponding to the b value
            
            p = [ -1*obj.bw obj.aw];
            % backg_ab = log10(obj.bvalsum3);
            % y = backg_ab(mz);
            %[p,S] = polyfit(obj.mag_zone,y,1);
            obj.f = polyval(p,obj.mag_zone);
            obj.f = 10.^obj.f;
            
            obj.std_backg = obj.ew;      % standard deviation of fit
            
            
            %% Error Bar Calculation -- call to pdf_calc.m
            obj.myXLim = [min(catalog.Magnitude)-0.5  max(catalog.Magnitude)+0.5];
            obj.myYLim = [0.9 length(catalog.Date+30)*2.5];
            
            
            %p=-p(1,1);
            %p=fix(100*p)/100;
            
            obj.a0 = obj.aw-log10(years(max(catalog.Date)-min(catalog.Date)));
            
            
            if ZG.hold_state
                [obj.pr, gBdiff] = calc_probability(obj,gBdiff);
            end
            
            if doLinearityCheck
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
                scatter(ax,obj.magsteps_desc, obj.bvalsum3,...
                    'Marker','s',...
                    'LineWidth',1.0,...
                    'MarkerEdgeColor','k',...
                    'Tag',obj.tags.cumevents,...
                    'DisplayName','Cum events > M(x)');
            else
                h.XData=obj.magsteps_desc;
                h.YData=obj.bvalsum3;
            end
        end
        function updatePlottedDiscreteValues(obj,ax)
            % plot discrete values
            hdv = findobj(ax,'Tag',obj.tags.discrete);
            if isempty(hdv)
            scatter(ax,obj.magsteps_desc,obj.bval2,'Marker','^',...
                'LineWidth',1.0,...
                'MarkerFaceColor',[0.7 0.7 .7],'MarkerEdgeColor','k',...
                'Tag',obj.tags.discrete, 'DisplayName','Discrete');
            else
                hdv.XData=obj.magsteps_desc;
                hdv.YData=obj.bval2;
            end
        end  
            
        function updatePlottedMc(obj, ax)
            
            % Marks the point of Mc
            mcText = sprintf('%s: %0.1f','Mc',obj.magco);
            
            mcline=findobj(ax,'Tag',obj.tags.mc);
            if isempty(mcline)
                line(ax, obj.magsteps_desc(obj.index_low),...
                    obj.bvalsum3(obj.index_low)*1.5,...
                    'Marker','v','MarkerFaceColor','b',...
                    'LineWidth',1.0,'LineStyle','none','MarkerSize',7,...
                    'Tag',obj.tags.mc,...
                    'DisplayName',mcText);
            else
                mcline.XData=obj.magsteps_desc(obj.index_low);
                mcline.YData=obj.bvalsum3(obj.index_low)*1.5;
                mcline.DisplayName=mcText;
            end
            hmctext=findobj(ax,'Tag',obj.tags.mctext);
            if isempty(hmctext)
                ZG=ZmapGlobal.Data;
                
                text(ax,obj.magsteps_desc(obj.index_low)+0.2,obj.bvalsum3(obj.index_low)*1.5,...
                    mcText,'FontWeight','bold','FontSize',ZG.fontsz.s,'Color','b','Tag',obj.tags.mctext)
            else
                hmctext.Position([1 2])=[obj.magsteps_desc(obj.index_low)+0.2, obj.bvalsum3(obj.index_low)*1.5];
                hmctext.String=mcText;
            end
            
                
        end
        
        function  updatePlottedBvalLine(obj,ax)
            % plot line corresponding to B value
            %bvdispname = sprintf('b-val: %.3f +/- %0.3f\na-val: %.3f\na-val_{annual}: %.3f',obj.bw, obj.std_backg, obj.aw, obj.a0);
            bvl = findobj(ax,'Tag',obj.tags.linearfit);
            if isempty(bvl)
                line(ax, obj.mag_zone,obj.f,'Color','r','LineWidth',1 ,...
                    'Tag', obj.tags.linearfit...,'DisplayName',bvdispname
                    );   % plot linear fit to backg
            else
                bvl.XData=obj.mag_zone;
                bvl.YData=obj.f;
                % bvl.DisplayName=bvdispname;
            end
            txh = findobj(ax,'Tag','bvaltext');
            set(txh,'String', obj.descriptive_text());
        end
        
        
        function tx=descriptive_text(obj,gBdiff)
            ZG=ZmapGlobal.Data;
            if ZG.hold_state
                ba_text = sprintf('b-value (w LS, M >= %f): %.2f +/-%.2f \na-value = %.3f',...
                    obj.MaxCurveMag ,obj.bw, obj.std_backg, obj.aw );
                
                p_text = sprintf('p=  %.2g', obj.pr);
                if exist('gBdiff','var')
                nbs_text = sprintf('n1: %g, n2: %g, b1: %g, b2: %g', gBdiff.n1, gBdiff.n2, gBdiff.b1, gBdiff.b2);
                else
                    nbs_text = 'n1:? n2:? b1:? b2:?';
                end
                tx = sprintf('%s\n%s\n%s', ba_text, p_text, nbs_text');
            else
                fmt = 'b-value = %.2f +/-%.2f\na-value=%.3f, (annual)=%.3f';
                if ~obj.dlg_res.doBootstrap
                    ba_text = sprintf(fmt, obj.bw, obj.std_backg, obj.aw, obj.a0);
                    sol_type = 'Max Likelihood Solution';
                    mag_text = sprintf('Magnitude of Completeness=%.2f',obj.magco);
                else
                    ba_text = sprintf(fmt, obj.bw, obj.ew, obj.aw, obj.a0);
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
            uimenu(c,'Label','Show discrete curve',MenuSelectedField(),@callbackfun_nodiscrete,'Checked','on');
            uimenu(c,'Label','Save values to file',MenuSelectedField(),{@calSave9,obj.magsteps_desc, obj.bvalsum3});
            addAboutMenuItem();
            
            function callbackfun_recurrence(~,~)
                global onesigma
                plorem(onesigma, obj.aw, obj.bw);
            end
            
            function callbackfun_ts(~,~,catalogFcn)
                ZG=ZmapGlobal.Data;
                ZG.newcat = catalogFcn();
                ctp=CumTimePlot(catalogFcn());
                ctp.plot();
            end
            
            function callbackfun_nodiscrete(mysrc,~)
                % toggles discrete curve
                isChecked = mysrc.Checked == "on";
                mysrc.Checked = tf2onoff(~isChecked);
                set(findobj(gcf,'Tag',obj.tags.discrete),'Visible',mysrc.Checked);
            end
            
            function cb_nonlin_optimize(~, ~,catalogFcn)
                [Results.bestmc,Results.bestb,Results.result_flag] = nonlinearity_index(catalogFcn(), obj.magco, 'OptimizeMc');
                Results.functioncall = sprintf('nonlinearity_index(catalog,%.1f,''OptimizeMc'')',obj.magco);
                assignin('base','Results_NonlinearityAnalysis',Results);
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
            global aw bw ew
            global inpr1
            global magsteps_desc bvalsum3  bval
            global magco
            aw = obj.aw;
            bw = obj.bw;
            ew = obj.ew;
            inpr1 = obj.dlg_res.mc_method;
            magsteps_desc = obj.magsteps_desc;
            bvalsum3 = obj.bvalsum3;
            bval=obj.bval; % may not need to exist in object
            magco = obj.magco;
            
        end
        
        function nonlin_keepmc(obj,catalog)
            [Results.bestmc,Results.bestb,Results.result_flag]=nonlinearity_index(catalog, obj.magco, 'PreDefinedMc');
            Results.functioncall = sprintf('nonlinearity_index(catalog,%.1f,''PreDefinedMc'')',obj.magco);
            assignin('base','Results_NonlinearityAnalysis',Results);
        end
            
        %% callback functions
        
        %{
    % WHY does this reset the hndl2.Value (?)
function callbackfun_003(mysrc,myevt)
        fMccorr=str2double(field2.String);
        field2.String=num2str(fMccorr);
        hndl2.Value=1;
    end
        %}
        
    end
    methods(Access=private)
        function [pr, gBdiff] = calc_probability(obj,gBdiff)
                % calculate percentages.
                gBdiff.b2 = round(obj.bw,3);
                gBdiff.n2 = obj.maxCurveBval;
                n = gBdiff.n1+gBdiff.n2;
                da = -2*n*log(n) + 2*gBdiff.n1*log(gBdiff.n1+gBdiff.n2*gBdiff.b1/gBdiff.b2) + 2*gBdiff.n2*log(gBdiff.n1*gBdiff.b2/gBdiff.b1+gBdiff.n2) -2;
                pr = exp(-da/2-2);
        end
    end
end
