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
        cua; % plot axes
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
    end
    
    methods
        function obj = bdiff2(catalog, interactive, ax)
            % obj = bdiff2(catalog, interactive)
            % if unspecified, catalog defaults to ZG.newt2
            
            report_this_filefun();
            
            ZG=ZmapGlobal.Data;
            
            if ~exist('catalog','var') || isempty(catalog)
                catalog = ZG.newt2;
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
                zdlg.AddBasicPopup('mc_method','Max. likelihood Estimation',calc_Mc(),1,'Choose Magnitude of completion calculation method');
                zdlg.AddBasicEdit('fMccorr','Mc Correction',fMccorr,'Correction term for Magnitude of Completeness');
                zdlg.AddBasicCheckbox('doBootstrap','Uncertainty by bootstrapping',false,{'nBstSample'},'tooltip');
                zdlg.AddBasicEdit('nBstSample','Bootstraps',nBstSample,'Number of bootstraps used to estimate error');
                zdlg.AddBasicCheckbox('doLinearityCheck','Perform Nonlinearity check on B-values',false,[],'tooltip');
                [obj.dlg_res, pressedOk] = zdlg.Create('Mc Input Parameter');
                if ~pressedOk
                    return
                end
            else
                dlg_res.mc_method = 1;
                dlg_res.fMccorr = fMccorr;
                dlg_res.doBootstrap = false;
                dlg_res.nBstSample = nBstSample;
                dlg_res.doLinearityCheck = false;
                obj.dlg_res = dlg_res;
            end
            
            obj=obj.calculate(catalog);
            if exist('ax','var') && strcmp(ax,'noplot')
                % do not plot
                obj.write_globals();
                return;
            end
            if ~exist('ax','var')||isempty(ax)|| ~isvalid(ax)
                [ax]=obj.setup_figure(catalog);
            end
            
            % add context menu equivelent to ztools menu
            f=ancestor(ax,'figure');
            delete(findobj(f,'Tag','bdiff context','-and','Type','uicontextmenu'));
            c = uicontextmenu(f,'Tag','bdiff context');
            obj.create_my_menu(c,catalog);
            ax.UIContextMenu=c;
            uimenu(ax.UIContextMenu,'Label','Open as new figure',Futures.MenuSelectedFcn,@(~,~)obj.plot(catalog,obj.setup_figure(catalog)));
                
            obj.plot(catalog,ax);
            obj.write_globals();
        end
        
        function obj = calculate(obj, catalog)
            % global magsteps_desc bvalsum3  bval
            global gBdiff % contains b1, n1, b2, n2
            
            ZG = ZmapGlobal.Data;
            
            % reassign variables
            ZG.inb2 = obj.dlg_res.mc_method;
            fMccorr = obj.dlg_res.fMccorr;
            nBstSample = obj.dlg_res.nBstSample;
            method = obj.dlg_res.mc_method;
            doBootstrap = obj.dlg_res.doBootstrap;
            doLinearityCheck = obj.dlg_res.doLinearityCheck;
            
            % check to see if figure exists
            % if does -- draw over
            % if it does not, create the window
            
            
            maxmag = ceil(10*max(catalog.Magnitude))/10;
            mima = min(catalog.Magnitude);
            if mima > 0 ; mima = 0 ; end
            
            
            %%
            %
            % bval contains the number of events in each bin
            % bvalsum is the cum. sum in each bin
            % bval2 is number events in each bin, in reverse order
            % bvalsum3 is reverse order cum. sum.
            % magsteps_desc is the step in magnitude for the bins == .1
            %
            %%
            
            [obj.bval,~] = hist(catalog.Magnitude,(mima:0.1:maxmag));
            % bvalsum = cumsum(obj.bval); % N for M <=
            obj.bval2 = obj.bval(end:-1:1);
            obj.bvalsum3 = cumsum(obj.bval(end:-1:1));    % N for M >= (counted backwards)
            obj.magsteps_desc = (maxmag:-0.1:mima);
            
            
            
            %%
            % Estimate the b value
            %
            % calculates max likelihood b value(bvml) && WLS(bvls)
            %
            %%
            
            %% SET DEFAULTS TO BE ADDED INTERACTIVELY LATER
            Nmin = 10;
            
            %% enough events??
            [fMc, obj.fStd_Mc, fBValue, fStd_B, fAValue, fStd_A] = deal(NaN);
            if catalog.Count >= Nmin
                % Added to obtain goodness-of-fit to powerlaw value
                [Mc, Mc90, Mc95, obj.magco, prf]=mcperc_ca3(catalog.Magnitude);
                
                fMc = calc_Mc(catalog, method, obj.fBinning, fMccorr);
                l = catalog.Magnitude >= fMc-(obj.fBinning/2);
                if sum(l) >= Nmin
                    [ fBValue, fStd_B, fAValue] =  calc_bmemag(catalog.subset(l), obj.fBinning);
                else
                    fMc = NaN;
                end
                
                % Bootstrap uncertainties
                if doBootstrap
                    % Check Mc from original catalog
                    l = catalog.Magnitude >= fMc-(obj.fBinning/2);
                    if sum(l) >= Nmin
                        [fMc, obj.fStd_Mc, fBValue, fStd_B, fAValue, fStd_A, vMc, mBvalue] = calc_McBboot(catalog, obj.fBinning, nBstSample, method, Nmin, fMccorr);
                    end
                end
            end% of if length(catalog) >= Nmin
            
            %% calculate limits of line to plot for b value line
            
            % For ZMAP
            obj.magco = fMc;
            obj.index_low=find(obj.magsteps_desc < obj.magco+.05 & obj.magsteps_desc > obj.magco-.05);
            
            mag_hi = obj.magsteps_desc(1);
            % index_hi = 1;
            mz = obj.magsteps_desc <= mag_hi & obj.magsteps_desc >= obj.magco-.0001;
            obj.mag_zone=obj.magsteps_desc(mz);
            
            
            
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
                obj.pr = calc_probabliity(obj,gBdiff, M1b);
            end
            
            if doLinearityCheck
                obj.nonlin_keepmc(catalog);
            end
            
            
        end
      
        function [ax] = setup_figure(obj,catalog)
            ZG=ZmapGlobal.Data;
            bfig=findobj('Type','Figure','-and','Name','Frequency-magnitude distribution');
            if isempty(bfig)
                bfig=figure_w_normalized_uicontrolunits(...
                    'Units','normalized','NumberTitle','off',...
                    'Name','Frequency-magnitude distribution',...
                    ...'visible','off',...
                    'pos',[ 0.300  0.3 0.4 0.6]);
                
                ZG.hold_state=false;
                
                add_menu_divider();
                c = uimenu('Label','ZTools');
                obj.create_my_menu(c,catalog);
            else
                bfig.Visible='on';
                figure(bfig)
            end
            
            ax = findobj(bfig,'Tag','main_bval_axes');
            
            if ~isempty(ax) && isvalid(ax) && ZG.hold_state
                axes(bfig,ax)
                hold on
            else
                delete(findobj(bfig,'Type','axes'));
                rect = [0.22,  0.3, 0.65, 0.6];           % plot Freq-Mag curves
                ax=axes(bfig,'position',rect,'Tag','main_bval_axes');
                
            end
        end
       
        function plot(obj,catalog, ax)
            % extracted from inside the calculation routine
            
            global gBdiff % contains b1, n1, b2, n2
            ZG = ZmapGlobal.Data;
            
            bfig=findobj('Type','Figure','-and','Name','Frequency-magnitude distribution');
            is_standalone = ~isempty(bfig) && ax==findobj(bfig,'Tag','main_bval_axes');
            if is_standalone
                fw='normal'; % fw='bold';
                fs=ZG.fontsz.m;
            else
                fw='normal';
                fs=get(ax,'FontSize');
            end
            % plot the cum. sum in each bin
            ax.YScale='log';
            
            pl =line(ax,obj.magsteps_desc, obj.bvalsum3,'Marker','s',...
                'LineWidth',1.0,'MarkerSize',6,'LineStyle','none',...
                ...'MarkerFaceColor','w',...
                'MarkerEdgeColor','k',...
                'Tag','total events at or above magnitude',...
                'DisplayName','Tot events > M(x)');
            
            % plot discrete values
            line(ax,obj.magsteps_desc,obj.bval2,'LineStyle','none','Marker','^',...
                'LineWidth',1.0,'MarkerSize',4,...
                'MarkerFaceColor',[0.7 0.7 .7],'MarkerEdgeColor','k',...
                'Tag','DiscreteValuePlot','DisplayName','Discrete');
            
            % CALCULATE the diff in cum sum from the previous bin
            
            
            xlabel('Magnitude','FontWeight',fw,'FontSize',fs)
            ylabel('Cumulative Number','FontWeight',fw,'FontSize',fs)
            set(ax,'visible','on','FontSize',fs,'FontWeight','normal',...
                'FontWeight',fw,'LineWidth',1.0,'TickDir','out','Ticklength',[0.02 0.02],...
                'Box','on','Tag','cufi','color','w')
            
            obj.cua = ax;
            
            % Marks the point of Mc
            line(ax, obj.magsteps_desc(obj.index_low),...
                obj.bvalsum3(obj.index_low)*1.5,...
                'Marker','v','MarkerFaceColor','b',...
                'LineWidth',1.0,'MarkerSize',7,...
                'Tag','magnitude of Completeness',...
                'DisplayName',sprintf('%s: %0.1f','Mc',obj.magco));
            text(obj.magsteps_desc(obj.index_low)+0.2,obj.bvalsum3(obj.index_low)*1.5,'Mc','FontWeight','bold','FontSize',ZG.fontsz.s,'Color','b')
            
            % plot line corresponding to B value
            bvdispname = sprintf('b-val: %.3f +/- %0.3f\na-val: %.3f\na-val_{annual}: %.3f',...
                obj.bw, obj.std_backg, obj.aw, obj.a0);
            line(ax, obj.mag_zone,obj.f,'Color','r','LineWidth',1 ,...
                'Tag', 'linear fit',...
                'DisplayName',bvdispname);   % plot linear fit to backg
            % a value
            %line(ax, obj.aw,1,'color','m','Marker','o','MarkerSize',6,'linestyle','none','DisplayName',sprintf('a-val: %.2f',obj.aw));
            %pdf_calc;
            set(ax,'XLim',obj.myXLim);
            set(ax,'YLim',obj.myYLim);
            
            tx = obj.descriptive_text(gBdiff);
            
            if is_standalone % unique figure, go ahead,
                rect=[0 0 1 1];
                h2=axes('position',rect);
                set(h2,'visible','off');
                
                text(ax,.16,.14,tx);
            end
            
            set(bfig,'visible','on');
            legend(ax,'show')
            % created here too, for when figure is created from inset figure
            if isempty(ax.UIContextMenu)
                delete(findobj(bfig,'Tag','bdiff_from_inset context'))
                c = uicontextmenu('Tag','bdiff_from_inset context');
                obj.create_my_menu(c,catalog);
                ax.UIContextMenu=c;
            end
                uimenu(ax.UIContextMenu,'Separator','on','Label','info',Futures.MenuSelectedFcn,@(~,~)msgbox(tx,'b-Value results','modal'));
        end
        
        function tx=descriptive_text(obj,gBdiff)
            ZG=ZmapGlobal.Data;
            if ZG.hold_state
                ba_text = sprintf('b-value (w LS, M  >= %f ): %.2f +/- %.2f ,a-value = %.3f',M1b(1) ,obj.bw, obj.std_backg, obj.aw );
                
                p_text = ['p=  ', num2str(obj.pr,2)];
                nbs_text = sprintf( 'n1: %g, n2: %g, b1: %g, b2: %g', gBdiff.n1, gBdiff.n2, gBdiff.b1, gBdiff.b2);
                tx = sprintf('%s\n%s\n%s',ba_text, p_text, nbs_text');
            else
                fmt = 'b-value = %.2f +/- %.2f,  a-value = %.3f,  a-value (annual) = %.3f';
                if ~obj.dlg_res.doBootstrap
                    ba_text = sprintf(fmt, obj.bw, obj.std_backg, obj.aw, obj.a0);
                    sol_type = 'Maximum Likelihood Solution';
                    mag_text = sprintf('Magnitude of Completeness = %.2f',obj.magco);
                else
                    ba_text = sprintf(fmt, obj.bw, obj.ew,obj.aw, obj.a0);
                    sol_type = 'Maximum Likelihood Estimate, Uncertainties by bootstrapping';
                    mag_text = sprintf('Magnitude of Completeness = %.2f +/- %.2f',obj.magco, obj.fStd_Mc);
                end
                tx = sprintf('%s\n%s\n%s',sol_type,ba_text,mag_text);
            end % ZmapGlobal.Data.hold_state
            
        end
        %% ui functions
        function create_my_menu(obj,c,catalog)
            uimenu(c,'Label','Estimate recurrence time/probability',Futures.MenuSelectedFcn,@callbackfun_recurrence);
            uimenu(c,'Label','Plot time series',Futures.MenuSelectedFcn,@callbackfun_ts);
            uimenu(c,'Label','Examine Nonlinearity (optimize  Mc)',Futures.MenuSelectedFcn,{@cb_nonlin_optimize,catalog});
            uimenu(c,'Label','Examine Nonlinearity (Keep Mc)',Futures.MenuSelectedFcn,{@cb_nonlin_keepmc,catalog});
            uimenu(c,'Label','Show discrete curve',Futures.MenuSelectedFcn,@callbackfun_nodiscrete,'Checked','on');
            uimenu(c,'Label','Save values to file',Futures.MenuSelectedFcn,{@calSave9,obj.magsteps_desc, obj.bvalsum3});
            addAboutMenuItem();
            
            function callbackfun_recurrence(~,~)
                global onesigma
                plorem(onesigma, obj.aw, obj.bw);
            end
            
            function callbackfun_ts(~,~)
                ZG=ZmapGlobal.Data;
                ZG.newcat = catalog;
                timeplot();
            end
            
            function callbackfun_nodiscrete(mysrc,~)
                % toggles discrete curve
                isChecked = strcmp(mysrc.Checked,'on');
                mysrc.Checked = tf2onoff(~isChecked);
                set(findobj(gcf,'Tag','DiscreteValuePlot'),'Visible',mysrc.Checked);
            end
            
            function cb_nonlin_optimize(~, ~,catalog)
                [Results.bestmc,Results.bestb,Results.result_flag] = nonlinearity_index(catalog, obj.magco, 'OptimizeMc');
                Results.functioncall = sprintf('nonlinearity_index(catalog,%.1f,''OptimizeMc'')',obj.magco);
                assignin('base','Results_NonlinearityAnalysis',Results);
            end
            function cb_nonlin_keepmc(~, ~,catalog)
                obj.nonlin_keepmc(catalog);
                % DUPLICATED ast obj.nonlin_keepmc
                %[Results.bestmc,Results.bestb,Results.result_flag]=nonlinearity_index(catalog, obj.magco, 'PreDefinedMc');
                %Results.functioncall = sprintf('nonlinearity_index(catalog,%.1f,''PreDefinedMc'')',obj.magco);
                %assignin('base','Results_NonlinearityAnalysis',Results);
            end
        
        end
        
        function write_globals(obj)
            global cua aw bw ew
            global inpr1
            global magsteps_desc bvalsum3  bval
            global magco
            cua=obj.cua;
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
        function pr = calc_probabliity(obj,gBdiff, M1b)
            
                % calculate percentages.
                gBdiff.b2 = round(obj.bw,3);
                gBdiff.n2 = M1b(2);
                n = gBdiff.n1+gBdiff.n2;
                da = -2*n*log(n) + 2*gBdiff.n1*log(gBdiff.n1+gBdiff.n2*gBdiff.b1/gBdiff.b2) + 2*gBdiff.n2*log(gBdiff.n1*gBdiff.b2/gBdiff.b1+gBdiff.n2) -2;
                pr = exp(-da/2-2);
        end
    end
end
