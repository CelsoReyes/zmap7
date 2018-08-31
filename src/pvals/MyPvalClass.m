classdef MyPvalClass
    % Calculate Omori Parameters using modified omori law
    % example:
    %    % assume catalog exists with events.
    %    bigEvent = catalog.subset(catalog.Magnitude == max(catalog.Magnitude);
    %    bigEvent = bigEvent.subset(1); %keep only first event
    %
    %   % SETUP
    %    mpvc = MyPvalClass()
    %    mpvc.MinThreshMag = 2
    %    mpvc.setMainEvent(bigEvent);
    %    mpvc.setEvents(catalog);
    %
    %   % DOIT
    %   [P, P_stddev, C, C_stddev, K, K_stddev] = mypvc.mypval2m()
    %
    %    
    properties
        targetCerr              = 0.001 % calculation stops once error in C is below this value
        targetPerr              = 0.001 % calculation stops once error in P is below this value
        
        pstep                   = 0.05  
        min_pstep               = 0.0001
        
        UseConstantC logical    = false;
        cstep                   = 0.05
        min_cstep               = 0.0001
        
        % omori parameters
        KCP_results = [nan nan nan]; %K: productivity, C: time adjustment, P: falloff rate
        pp  % falloff rate
        pc  % time adjusment
        pk  % productivity
        
        % ts % first event time, always zero
        p_initial {mustBeGreaterThanOrEqual(p_initial,0)}   = 1.1 % initialP
        
        MinThreshMag (1,1) double
        c_initial {mustBeGreaterThanOrEqual(c_initial,0)}   = 0.1 % initial C
        
        StepReductionFactor                                 = 0.9 % used in reducing step size
        MaxLoopCount                                        = 500; % magic number. Comes from nowhere
        
        error_c % was err1
        error_p % was err2
        
        mainEventDate  datetime  
        mainEventMag (1,1) double = nan
        
        eventTimes  duration   % time elapsed since mainEvent
        eventMagnitudes double
        catalogSpan duration
    end
    
    methods
        
        function obj = MyPvalClass()
        end
        
        function obj = setMainEvent(obj, varargin)
            % obj = obj.setMainEvent(zcat) provide a zmap catalog with a single mainshock event
            % obj = obj.setMainEvent(date, mag) provide the date (datetime format) and a mag
            if numel(varargin) == 1
                if ~isa(varargin{1},'ZmapCatalog') || varargin{1}.Count ~= 1
                    error('accepts a Zmap Catalog with ONE event');
                end
                obj.mainEventMag = varargin{1}.Magnitude;
                obj.mainEventDate = varargin{1}.Date;
            elseif numel(varargin) == 2
                obj.mainEventDate = varargin{1};
                obj.mainEventMag = varargin{2};
            else
                error('expected either a zmap catalog (of length 1) or a date a magnitude');
            end
        end
        
        function obj = setEvents(obj, catalog)
            % automatically cuts catalog to dates AFTER main event and magnitudes above minimum threshhold
            
            if isnan(obj.mainEventMag)
                error('First use setMainEvent, so that catalog can be put in relative dates');
            end
            validMask = catalog.Date > obj.mainEventDate & catalog.Magnitude >= obj.MinThreshMag;
            obj.eventTimes = catalog.Date(validMask) - obj.mainEventDate;
            obj.eventMagnitudes = catalog.Magnitude(validMask);
            obj.catalogSpan = max(obj.eventTimes); % last event time
        end
        
        function [P, p_std, C, sdc_, K, sdk_, rja, rjb] = mypval2m(obj)
            
            % MYPVAL2M  calculate the parameters of the modified Omori Law
            %
            % [P, PstdDev, C, CstdDev, K, K_stdDev, rja, rjb] = mypval2m(obj, eqDates,eqMags, mainDate, mainMag)
            %
            % this function is a modification of a program by Paul Raesenberg
            % that is based on Programs by Carl Kisslinger and Yoshi Ogata.
            %
            % finds the maximum liklihood estimates of p,c and k, the
            % parameters of the modifies Omori equation
            % it also finds the standard deviations of these parameters
            %
            % Input: Dates from Earthquake Catalog of an Aftershock Sequence
            %        datestyle : 'date' or 'days'
            %           'date' : uses absolute dates
            %           'days' : uses days since big event
            %
            % Output: p c k values of the modified Omori Law with respective
            %         standard deviations
            %
            % datestyle 'days', (goal : maps or cross-sections);
            % datetyle 'date' (goal: determination of parameters in Omori formula for a certain set of data - the
            % one for which the Cumulative Number of earthquakes in time is displayed in the window
            %"Cumulative number").
            %
            %  Bogdan Enescu
            % refactored by Celso Reyes
            
            %set the initial step size
            
            lastwarn('');
            warning('off','MATLAB:illConditionedMatrix');
            
            % % % main calculation % % %
            %
            [nLoops, C, P, K, cStdDev, PstdDev, KstdDev] = obj.ploop_c_and_p_calcs;
            %
            % % %
            warning('on','MATLAB:illConditionedMatrix');
            if ~isempty(lastwarn)
                disp(['warnings were given. ' lastwarn]);
            end
            
            
            if nLoops< obj.MaxLoopCount
                
                P=round(P, 2);
                p_std=round(PstdDev, 2);
                
                C = round(C, 3);
                if ~obj.UseConstantC
                    cStdDev=round(cStdDev, 3);
                else
                    cStdDev = nan;
                end
                
                K=round(K, 2);
                KstdDev= round(KstdDev, 2);
                
                if nargout > 6
                    [rja, rjb] = obj.calc_rj_params(K);
                end
                
            else
                warning('Maximum loops exceeded');
                [P, p_std, C, cStdDev, K, KstdDev, rja, rjb] = deal(nan);
            end
            [sdc_, sdk_] = deal(cStdDev, KstdDev);
        end
        
        function [rja, rjb] = calc_rj_params(obj,K)
            %%
            % added my MCG 7/01 to calculate R&J a & b -- a is not corrected for completeness as in ASPAR
            %
            % compute average magnitude above cutoff - to calc max like b and then a from k (dk) and b
            %%
            
            MagicTopMagnitude   = 6.1;
            log10_from_ln      = @(x)x/log(10);
        
            magInRange = obj.eventMagnitudes >= obj.MinThreshMag & obj.eventMagnitudes <= MagicTopMagnitude; % untrusted because of this magic top magnitude
            magz = obj.eventMagnitudes(magInRange);
            avgMag = sum(magz) / numel(magz);
            
            rjb = log10_from_ln(1) / (avgMag - obj.MinThreshMag + 0.05); % b-value
            rja = log10(K) - rjb * (obj.mainEventMag - min(obj.eventMagnitudes)); % a-value
        end
        
        function [loopcheck, C, P, K, cStdDev, pStdDev, kStdDev] = ploop_c_and_p_calcs(obj)
            % mainloop for calculating c and p values
            % if cstep is empty, then neither cstep or error_c will be calculated
            %
            % modified omori law:
            % n(t) = K /(t+c)^p
            % t : time from mainshock (duration)
            % n(t) : frequency of aftershocks per unit time interval,  (number / time)
            % K : the productivity of the sequence,
            % c : delay before power law is effective (duration)
            % p : how quickly the activity falls off to the constant background intensity. [decay exponent]
            % typically normaized to days
            %
            % ploop parts attributed to A.Allmann and B. Enescu
            % routines deconstructed & merged by C. Reyes 2017
            %
            % Times all relative to mainshock (NOT first aftershock)
            %
            % pp = initial p = 1.1
            % n = length of catalog (# of events)
            % tt = end time (last event)
            % ts = start time (1st event)
            % pc = initial c???
            % t  = time of each event (a vector)
            
            % unchanging parameters.  Normalize everything to the mainshock time
            n         = numel(obj.eventTimes);
            D         = days(obj.catalogSpan); % full sequence duration             % is the new  obj.tt
            evTimes   = days(obj.eventTimes);
            
            kFcn = @(p, c)  (1-p)*n  /  ((D+c)^(1-p) - c ^(1-p) );
            error_c_prev = 0;
            error_p_prev = 0;
            if obj.UseConstantC
                minCerrorReached = @(~) false;
                minCstepReached = @(~) false;
            else
                minCerrorReached =@(err) abs(err) < obj.targetCerr;
                minCstepReached = @(step) step <= obj.min_cstep;
            end
            
            minPerrorReached = @(err) abs(err) <  obj.targetPerr;
            minPstepReached =  @(step) step <= obj.min_pstep;
            
            P=obj.p_initial;
            C=obj.c_initial;
            
            K = kFcn(P,C);
            nwarn = 0;
            for loopcheck = 1 : obj.MaxLoopCount
                if P==1.0
                    nwarn=nwarn+1;
                    P=1.001;
                end
                
                if ~obj.UseConstantC
                    obj.error_c = obj.c_err(D, evTimes, K, P, C);
                end
                
                obj.error_p = obj.p_err(D, evTimes, K,P,C);
                
                ieflag = minCerrorReached(obj.error_c) || minPerrorReached(obj.error_p); 
                isflag = minCstepReached(obj.cstep)    || minPstepReached(obj.pstep);
                
                %stop searching if errors or steps are small enough
                if ieflag || isflag
                    break
                end
                
                take_pstep();     % relies on existing error_p
                
                if ~obj.UseConstantC
                    take_cstep(); % relies on existing error_c
                end
                
            end
            
            obj.KCP_results = [K C P];
            
            if obj.UseConstantC
                [kStdDev, pStdDev]          = kcp_stdevs(2, P, C, K, D);
                cStdDev = nan;
            else
                [kStdDev, pStdDev, cStdDev] = kcp_stdevs(3, P, C, K, D);
            end
            if nwarn > 1
               warning('P was 1.0 changing to 1.001 [%d times]',nwarn);
            end
            
            
            %%

            function take_cstep()
                % if error has changed sign,reduce the step size
                if loopcheck>1 && ~same_sign(error_c_prev, obj.error_c)  &&  obj.cstep >= obj.min_cstep
                	obj.cstep = obj.cstep * obj.StepReductionFactor;
                end
                
                C  = C - obj.cstep * sign(obj.error_c); % move closer to zero
                
                if C <= 0
                    C = obj.cstep;
                end
                error_c_prev    = obj.error_c; 
            end
            
            function take_pstep()
                % calculate the parameters of p-value
                
                % if the error has changed sign,reduce the step size
                if loopcheck>1 && ~same_sign(error_p_prev, obj.error_p) &&  obj.pstep >= obj.min_pstep
                	obj.pstep=obj.pstep * obj.StepReductionFactor;
                end
                
                P = P - obj.pstep * sign(obj.error_p); % move closer to zero
                error_p_prev        = obj.error_p;
            end
            
            
            function [kStdDev, pStdDev, cStdDev] = kcp_stdevs(matSize, p, c, dk, te)
                % calculate standard deviations for k, c, and p values
                %kcp_stdevs.m                          A.Allmann
                %
                % calculate the parameters of p-value
                %calls itself with different parameters for different loops in programm
                
                %te=obj.catalogSpan; % time of last event
                ts = 0; % time elapsed
                %p=obj.pp; % p value (falloff value)
                %c=obj.pc; % c value adjusts for missing earthquakes in the catalog
                %dk=obj.pk; % 
                
                
                
                %case1
                f1=((te+c)^(-p+1))/(-p+1);
                h1=((ts+c)^(-p+1))/(-p+1);
                s(1)=(1/dk)*(f1-h1);
                
                %case2
                f2=((te+c)^(-p));
                h2=((ts+c)^(-p));
                s(2)=f2-h2;
                
                %case3
                
                
                f3=(-(te+c)^(-p+1))*(((log(te+c))/(-p+1))-(1/((-p+1)^2)));
                h3=(-(ts+c)^(-p+1))*(((log(ts+c))/(-p+1))-(1/((-p+1)^2)));
                s(3)=f3-h3;
                
                %case4
                
                s(4)=s(2);
                
                %case5
                
                f5=((te+c)^(-p-1))/(p+1);
                h5=((ts+c)^(-p-1))/(p+1);
                s(5)=(-dk)*(p^2)*(f5-h5);
                
                %case6
                
                
                f6=((te+c)^(-p))*(((log(te+c))/(-p))-(1/(p^2)));
                h6=((ts+c)^(-p))*(((log(ts+c))/(-p))-(1/(p^2)));
                s(6)=(dk*p)*(f6-h6);
                
                %case7
                
                s(7)=s(3);
                
                %case8
                
                s(8)=s(6);
                
                %case9
                
                f10=((te+c)^(-p+1))*((log(te+c))^2)/(-p+1);
                f11=(2*((te+c)^(-p+1)))/((-p+1)^2);
                f12=(log(te+c))-(1/(-p+1));
                f9=f10-(f11*f12);
                
                h10=((ts+c)^(-p+1))*((log(ts+c))^2)/(-p+1);
                h11=(2*((ts+c)^(-p+1)))/((-p+1)^2);
                h12=(log(ts+c))-(1/(-p+1));
                h9=h10-(h11*h12);
                s(9)=(dk)*(f9-h9);
                
                
                %assign the values of s to the matrix A(i,j)
                %invert the matrix to calculate the standard deviation
                %for k,c,p .
                
                if matSize == 3
                    A=[s(1) s(2) s(3); s(4) s(5) s(6); s(7) s(8) s(9)];
                    
                    A=inv(A);
                    
                    kStdDev=sqrt(A(1,1));
                    cStdDev=sqrt(A(2,2));
                    pStdDev=sqrt(A(3,3));
                    
                elseif matSize == 2
                    A=[s(1) s(3); s(3) s(9)];
                    A=inv(A);
                    kStdDev=sqrt(A(1,1));
                    pStdDev=sqrt(A(2,2));
                else
                    error('wrong number of output arguments');
                end
                
            end
        end
        


    end
    methods(Static)
        function pvalcat(catalog)
            %This program is called from timeplot.m and displays the values
            % of p, c and k from Omori law, together with their errors.
            %
            %
            %Modified May: 2001. B. Enescu
            % sets newt2
            
            persistent cua2a % axes associated with this  (should be persistent instead)
            
            report_this_filefun();
            ZG=ZmapGlobal.Data;
            
            nn2 = catalog;
            
            prompt = {'Minimum magnitude',...
                'Min. time after mainshock (in days)',...
                'Enter a negative value if you wish to fix c'};
            title_str = 'You can change the following parameters:';
            lines = 1;
            obj.MinThreshMag = min(catalog.Magnitude);
            minDaysAfterMainshock = days(0); %
            mainshockDate = ZG.maepi.Date(1);
            valeg2 = 0; %  decides if c is fixed or not.
            
            
            if ~ensure_mainshock()
                return
            end
            def = {num2str(obj.MinThreshMag), num2str(minDaysAfterMainshock/days()) , num2str(valeg2)};
            answer = inputdlg(prompt,title_str,lines,def);
            
            obj.MinThreshMag=str2double(answer{1});
            minDaysAfterMainshock = days(str2double(answer{2}));
            valeg2 = str2double(answer{3});
            
            % cut catalog at mainshock time:
            l = catalog.Date > mainshockDate;
            catalog = catalog.subset(l); %keep events AFTER mainshock
            
            % cat at selected magnitude threshold
            l = catalog.Magnitude >= obj.MinThreshMag;
            catalog = catalog.subset(l); %keep big-enough events
            
            ZG.hold_state2=true;
            ctp=CumTimePlot(catalog);
            ctp.plot();
            ZG.hold_state2=false;
            
            CO = 0.01; % c-value (initial?)
            if (valeg2 < 0)
                prompt = {'c-value'}; % time delay before the onset of the power-law aftershock decay rate
                title_str = 'c-value:';
                lines = 1;
                def = {num2str(CO)};
                answer = inputdlg(prompt,title_str,lines,def);
                CO = str2double(answer{1});
            end
            
            eqDates = catalog.Date;
            timeSinceMainshock = eqDates - mainshockDate;
            assert(all(timeSinceMainshock>0));
            
            paramc2 = timeSinceMainshock >= minDaysAfterMainshock;
            eqDates = eqDates(paramc2);
            eqMags = catalog.Magnitude(paramc2);
            
            tmin = min(timeSinceMainshock);
            tmax = max(timeSinceMainshock);
            
            tint = [tmin tmax];
            
            [pv, pstd, cv, cstd, kv, kstd, rja, rjb] = mypval2m(obj, eqDates, eqMags,'date',valeg2,CO);
            
            if ~isnan(pv)
                dispStats(obj, pv, pstd, cv, cstd, kv, kstd, eqDates, tmin,tmax);
            else
                dispGeneral(obj, eqDates, tmin, tmax);
            end
            
            %Find if the figure already exist.
            pgraph=findobj('Tag','p-value graph');
            
            %Make figure
            if isempty(pgraph)
                pgraph = figure_w_normalized_uicontrolunits( ...
                    'Name','p-value graph',...
                    'NumberTitle','off', ...
                    'NextPlot','new', ...
                    'backingstore','on',...
                    'Visible','off', ...
                    ...'Position',position_in_current_monitor(ZG.map_len(1), ZG.map_len(2)),...
                    'Tag','p-value graph');
                %     ...
            end
            
            %If a new graph is overlayed or not
            if ZG.hold_state
                axes(cua2a);
                disp('Hold');
                set(gca,'NextPlot','add')
            else
                set(gca,'NextPlot','add')
                figure(pgraph);
                set(gca,'NextPlot','add')
                delete(gca)
                axis off
            end
            ax=gca;
            
            powers = -12:0.5:12;
            sir2 = 2 .^ (1:numel(powers)); % remarked out because it just didn't make sense if powers wasn't used anywhere else -CGR
            %sir2 = 2 .^ powers;
            sir2(sir2<=tmin | sir2 >=tmax) = 0;
            
            limit1 = (sir2 > 0);
            sir2(~limit1)=[];
            
            lung = length(sir2);
            dursir = diff(sir2);
            tavg = (sir2(2:end).*sir2(1:end-1)).^(0.5);
            numv=[];
            for j = 1 : numel(sir2)-1
                num = sum(sir2(j) < timeSinceMainshock) & (timeSinceMainshock <= sir2(j+1)); % count events between sir2's
                numv = [numv, num];
            end
            
            ratac = numv ./ dursir;
            
            frf = kv ./ ((tavg + cv).^pv);
            frf2 = kv ./ ((days(tint) + cv).^pv);
            
            frfr = [frf2(1) frf frf2(2)];
            tavgr = [tint(1) days(tavg) tint(2)];
            
            %FIXME: this works, but seems to plot incorrectly
            
            llh1=loglog(tavg, ratac, '-k','LineStyle', 'none', 'Marker', '+','MarkerSize',9);
            set(gca,'NextPlot','add')
            loglog(days(tavgr), frfr, '-k','LineWidth',2.0);
            
            if ZG.hold_state
                set(llh1,'Marker','+');
            else
                set(llh1,'Marker','o');
                xlabel(ax,'Time from Mainshock (days)','FontWeight','bold','FontSize',14);
                ylabel(ax,'No. of Earthquakes / Day','FontWeight','bold','FontSize',14);
            end
            
            set(ax,'visible','on','FontSize',12,'FontWeight','normal',...
                'FontWeight','bold','LineWidth',1.0,'TickDir','out',...
                'Box','on','Tag','cufi')
            
            
            cua2a = ax;
            labelPlot(cua2a, pv, pstd, cv, cstd, kv, kstd, valeg2);
            
            function labelPlot(ax, pv, pstd, cv, cstd, kv, kstd, show_cstd)
                textProps.FontWeight    = 'Bold';
                textProps.FontSize      = 12;
                textProps.Units         = 'normalized';
                
                th(1)= text(ax,0.05, 0.2, "p = " + pv  + " +/- " + pstd);
                if show_cstd >= 0
                    th(2) = text(ax,0.05, 0.15, "c = " + cv  + " +/- " + cstd);
                else
                    th(2)= text(ax,0.05, 0.15,"c = " + cv);
                end
                th(3)= text(ax,0.05, 0.1,"k = " + kv + " +/- " + kstd);
                
                [th.FontWeight]    = 'Bold';
                [th.FontSize]      = 12;
                [th.Units]         = 'normalized';
            end
            
            function dispStats(obj, pv, pstd, cv, cstd, kv, kstd)% pv, pstd, cv, cstd, kv, kstd, rja, rjb, eqDates,tmin,tmax,obj.MinThreshMag)
                ZG=ZmapGlobal.Data;
                disp('');
                disp('Parameters :');
                disp("p = "  + pv  + " +/- " + pstd);
                disp("a = " + min(obj.rja) +  " +/- " + pstd);
                disp("b = " + min(obj.rjb) + " +/- " + pstd);
                if valeg2 >= 0
                    disp("c = " + cv  + " +/- " + cstd);
                else
                    disp("c = " + cv);
                end
                disp("k = " + kv + " +/- " + kstd);
                disp("Number of Earthquakes = " + length(eqDates));
                %events_used = sum(catalog.Date(paramc1) > ZG.maepi.Date(1) + days(cv));
                events_used = sum(eqDates > ZG.maepi.Date(1) + days(cv));
                disp("Number of Earthquakes greater than c  = " + events_used);
                disp("tmin = " + char(tmin));
                disp("tmax = " + char(tmax));
                disp("Mmin = " + obj.MinThreshMag);
            end
            
            function dispGeneral(obj, eqDates,tmin,tmax)
                % dispGeneral shows parameters
                disp([]);
                disp('Parameters :');
                disp('No result');
                disp("Number of Earthquakes = "  + length(eqDates));
                disp("tmin = " + char(tmin));
                disp("tmax = " + char(tmax));
                disp("Mmin = " + obj.MinThreshMag);
            end
        end
        function pvalcat2(catalog)
            %PVALCAT2 computes a map of p as function of minimum magnitude and initial time
            %Modified May, 2001 Bogdan Enescu
            % turned into function by Celso G Reyes 2017
            
            %This file is called from timeplot.m and helps for the computation of p-value from Omori formula. for different values of Mcut and Minimum time. The value of p is then displayed as a isoline map.
            
            % FIXME : This doesn't produce answers... why? units on the thresholds?
            
            ZG=ZmapGlobal.Data;
            report_this_filefun();
            
            prompt = {'If you wish a fixed c, please enter a negative value'};
            title_str = 'Input parameter';
            lines = 1;
            valeg2 = 2;
            def = {num2str(valeg2)};
            answer = inputdlg(prompt,title_str,lines,def);
            valeg2=str2double(answer{1});
            
            CO = 0; % c-value (initial?)
            if valeg2 <= 0
                prompt = {'Enter c'};
                title_str = 'Input parameter';
                lines = 1;
                def = {num2str(CO)};
                answer = inputdlg(prompt,title_str,lines,def);
                CO=str2double(answer{1});
            end
            
            pvmat = [];
            prompt = {'Min. threshold. magnitude',...
                'Max. threshold magnitude',...
                'Magnit. step',...
                'Min. threshold time', ...
                'Max. threshold time',...
                'Time step'};
            title_str = 'Input parameters';
            lines = 1;
            obj.MinThreshMag = min(catalog.Magnitude);
            maxThreshMag = obj.MinThreshMag + 2;
            magStep = 0.1;
            minThreshTime = 0;
            maxThreshTime = 0.5;
            timeStep =  0.01 ; % TODO figure out what units this actually is
            def = {num2str(obj.MinThreshMag), num2str(maxThreshMag), num2str(magStep), num2str(minThreshTime), num2str(maxThreshTime), num2str(timeStep)};
            answer = inputdlg(prompt,title_str,lines,def);
            obj.MinThreshMag=str2double(answer{1});
            maxThreshMag = str2num(answer{2});
            magStep=str2num(answer{3});
            minThreshTime = days(str2double(answer{4}));
            maxThreshTime = days(str2num(answer{5}));
            timeStep = days(str2num(answer{6}));
            
            if ~ensure_mainshock()
                return
            end
            % cut catalog at mainshock time:
            l = catalog.Date > ZG.maepi.Date(1);
            catalog = catalog.subset(l);
            
            % cat at selecte magnitude threshold
            l = catalog.Magnitude >= obj.MinThreshMag;
            catalog = catalog.subset(l);
            
            ZG.hold_state2=true;
            ctp=CumTimePlot(catalog);
            ctp.plot();
            drawnow
            ZG.hold_state2=false;
            
            allcount = 0;
            itotal = length(obj.MinThreshMag:magStep:maxThreshMag) * length(minThreshTime:timeStep:maxThreshTime);
            wai = waitbar(0,' Please Wait ...  ');
            set(wai,'NumberTitle','off','Name',' 3D gridding - percent done');
            drawnow
            mainshockDate = ZG.maepi.Date(1);
            timeSinceMainshock = catalog.Date - mainshockDate;
            
            for valm = obj.MinThreshMag:magStep:maxThreshMag
                paramc1 = (catalog.Magnitude >= valm);
                pcat = mainshockDate + timeSinceMainshock(paramc1);
                
                for valtm = minThreshTime:timeStep:maxThreshTime
                    allcount = allcount + 1;
                    
                    paramc2 = pcat >= (mainshockDate+valtm);
                    [pv, pstd, cv, cstd, kv, kstd] = mypval2m(pcat(paramc2),catalog.Magnitude(paramc2),'date',valeg2,CO,obj.MinThreshMag);
                    
                    
                    if isnan(pv)
                        disp('Not a value');
                    end
                    pvmat = [pvmat; valm days(valtm) pv pstd cv cstd kv kstd];
                    waitbar(allcount/itotal)
                    
                end
            end
            
            close(wai)
            pmap=findobj('Type','Figure','-and','Name','p-value map');
            
            
            if isempty(pmap)
                pmap = figure_w_normalized_uicontrolunits( ...
                    'Name','p-value-map',...
                    'NumberTitle','off', ...
                    'NextPlot','new', ...
                    'backingstore','on',...
                    'Visible','off', ...
                    'Position',position_in_current_monitor(ZG.map_len(1), ZG.map_len(2)));
            end
            
            figure(pmap);
            delete(findobj(pmap,'Type','axes'));
            set(gca,'NextPlot','add');
            axis off
            
            
            X1 = [obj.MinThreshMag:magStep:maxThreshMag]; m = length(X1);
            Y1= [minThreshTime:timeStep:maxThreshTime]; n=length(Y1);
            
            [X,Y] = meshgrid(obj.MinThreshMag:magStep:maxThreshMag,minThreshTime:timeStep:maxThreshTime);
            %The following line can be modified to display other maps: c, k or b - for b other few lines have to be added.
            Z = reshape(pvmat(:,3), n, m);
            clear X1; clear Y1;
            pcolor(X,days(Y),Z);
            shading flat
            ylabel(['c in days'])
            xlabel(['Min. Magnitude'])
            shading interp
            set(gca,'box','on',...
                'SortMethod','childorder','TickDir','out',...
                'FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1,'Ticklength',[ 0.02 0.02])
            
            
            % Create a colorbar
            %
            h5 = colorbar('horiz');
            set(h5,'Pos',[0.35 0.08 0.4 0.02],...
                'FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s,'TickDir','out')
            
            rect = [0.00,  0.0, 1 1];
            axes('position',rect)
            axis('off')
            %  Text Object Creation
            txt1 = text(...
                'Units','normalized',...
                'Position',[ 0.33 0.09 0 ],...
                'HorizontalAlignment','right',...
                'FontSize',ZmapGlobal.Data.fontsz.m,....
                'String','p-value');
        end
        
        function cerr = c_err(dur, t, k, p, c)
            %calculate c error
            % dur is duration of sequence
            % t is time since aftershock
            % k, p, c are omori parameters
            
            qsum=k * ((1/(dur+c)^p) - (1/(c)^p));
            psum=sum(1./(t+c));
            cerr=qsum + p * psum;
        end
        function perr = p_err(dur, t, k, p, c)
            %calculate p error
            % dur is duration of sequence
            % t is time since aftershock
            % k, p, c are omori parameters
            
            qp = 1-p;
            sumln=sum(log(t+c));
            qsumln=k / qp^2;
            qsumln=qsumln * ( (dur+c)^qp * (1 - qp*log(dur+c)) - c^qp * (1 - qp*log(c) ));
            esumln=qsumln+sumln;
            perr=esumln;
        end
              
    end
    
end