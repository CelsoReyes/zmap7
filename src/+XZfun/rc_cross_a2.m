classdef rc_cross_a2 < ZmapVGridFunction
    % RC_CROSS_A2 Calculates relative rate change map, p-,c-,k- values and standard deviations after model selection by AIC
    % Uses view_rcva_a2 to plot the results
    properties
        bootloops                   = 100 % number of bootstrap loops [bootloops]
        timef       duration        = days(20) % forecast period [forec_period]
        time        duration        = days(47)% learning period  [learn_period]
        addtofig    logical         = false % should this plot in current figure? [oldfig_button]
        Nmin % from eventsel
    end
    properties(Constant)
        PlotTag         = 'rc_cross_a2'
        ReturnDetails   = cell2table({ ... VariableNames, VariableDescriptions, VariableUnits
            'time',     'learning period','days';...                    #1
            'absdiff',  'obs. aftershocks - #events in modeled forecast period','';... #2
            'numreal',  'observed # aftershocks',''; ...                #3
            'nummod',   '#events in modeled forecast period','';...     #4
            ...  p,c,k- values for period before large aftershock or just modified Omori law
            'pval1',    'p-value','';...                                #5 [mPval]
            'pmedStd1', 'p-value standard deviation', '';...            #6 [mPvalstd]
            'cval1',    'c-value','';...                                #7 [mCval]
            'cmedStd1', 'c-value standard deviation','';...             #8 [mCvalstd]
            'kval1',    'k-value','';...                                #9 [mKval]
            'kmedStd1', 'k-value standard deviation','';...             #10 [mKvalstd]
            ... Resolution parameters
            'fStdBst',  '',''; ...                                      #11 [?]
            'nMod',     'Chosen fitting model', '';...                  #12 [mMd]
            'nY',       'Number of events per grid node', '';...        #13 [mNumevents]
            'fMaxDist', 'Radii of chosen events, Resolution', '';...    #14 [vRadiusRes]
            'fRcBst',   'Relative rate change (bootstrap)','';...       #15 [mRelchange]
            ... p,c,k- values for period AFTER large aftershock
            'pval2',    'p-value (after large aftershock)','';...       #16 [mPval2]
            'pmedStd2', 'p-value std dev (after large aftershock)','';... #17 [mPvalstd2]
            'cval2',    'c-value (after large aftershock)','';...        #18 [mCval2]
            'cmedStd2', 'c-value std dev (after large aftershock)','';... #19 [mCvalstd2]
            'kval2',    'k-value (after large aftershock)','';...       #20 [mKval2]
            'kmedStd2', 'k-value std dev (after large aftershock)','';... #21 [mKvalstd2]
            'H',        'KS-Test (H-value) binary rejection criterion at 95% confidence level','';...#22 [mKstestH]
            'KSSTAT',   'KS-Test statistic for goodness of fit','';...  #23 [mKsstat]
            'P',        'KS-Test p-value','';...                        #24 [mKsp]
            'fRMS',     'RMS value for goodness of fit',''...           #25 [mRMS]
            }, 'VariableNames', {'Names','Descriptions','Units'})
        
        CalcFields      = {'time','absdiff','numredal','nummod',...
            'pval1','pmedStd1','cval1','cmedStd1',...
            'kval1','kmedStd1','fStdBst','nMod','nY','fMaxDist','fRcBst',...
            'pval2','pmedStd2','cval2','cmedStd2',...
            'kval2','kmedStd2','H','KSSTAT','P','fRMS'}
        
        ParameterableProperties = ["bootloops", "timef", "time", "addtofig", "Nmin"];
    end
    methods
        function obj=rc_cross_a2(zap,varargin)
            report_this_filefun();
            
            obj@ZmapVGridFunction(zap, 'fRcBst'); % rfRcBst is rate change
            
            obj.parseParameters(varargin);
                
            obj.StartProcess();
        end
        function InteractiveSetup(obj)
            
            zdlg = ZmapDialog();
            
            zdlg.AddMcMethodDropdown('mc_choice');
            
            % add fMaxRadius
            zdlg.AddEventSelector('evsel', obj.EventSelector)
            zdlg.AddEdit('boot_samp','# boot loops', obj.bootloops,' number of bootstraps');
            zdlg.AddEdit('forec_period','forecast period [days]', obj.timef, 'forecast period [days]');
            zdlg.AddEdit('learn_period','learn period [days]', obj.time, 'learning period [days]');
            zdlg.AddCheckbox('addtofig','plot in current figure', obj.addtofig,[],'plot in the current figure');
            % zdlg.AddEdit('Mmin','minMag', nan, 'Minimum magnitude');
            % FIXME min number of events should be the number > Mc
            
            [res, okpressed]=zdlg.Create('relative rate change map');
            if ~okpressed
                return
            end
    
            obj.SetValuesFromDialog(res);
            obj.doIt()
        end
        
        function SetValuesFromDialog(obj,res)
            %% old version
%             UseEventsInRadius=selOpt.UseEventsInRadius;
%             ni=selOpt.ni;
%             ra=selOpt.ra;
%             dx=gridOpt.dx;
%             dy=gridOpt.dy;
            obj.bootloops = res.boot_samp;
            obj.timef = days(res.forec_period);
            obj.time = days(res.learn_period);
            obj.EventSelector=res.evsel;
            
            %oldfig_button=oldfig_button.Value;
        end

        function ModifyGlobals(obj)
            obj.ZG.bvg=obj.Result.values;
        end
        function results = Calculate(obj)
            % ...
                
            % check preconditions
            assert(ensure_mainshock(),'No mainshock was defined')
            
            % cut catalog at mainshock time:
            mainshock=obj.ZG.maepi.subset(1);
            mainshock_time = mainshock.Date;
            learn_to_date = mainshock_time + obj.time;
            forecast_to_date = learn_to_date + obj.timef;
            l = obj.RawCatalog.Date > mainshock_time & obj.RawCatalog.Magnitude > minThreshMag;
            
            assert(any(l),'no events meet the criteria of being after the mainshock ,and greater than threshold magnitude');
            
            obj.RawCatalog=obj.RawCatalog.subset(l);
            ZG.newt2=obj.RawCatalog;
            
            
            obj.gridCalculations(@calculation_function);
            
            if nargout
                results=obj.Result.values;
            end
            %view_rccross_a2(lab1,valueMap)
            
            function [catA, catB] = prep_catalog(catalog)
                
                % Select subcatalog
                % Calculate distance from center point and sort with distance
                l = sqrt(((xsecx' - x)).^2 + ((xsecy + y)).^2) ;
                [s,is] = sort(l);
                b = newa(is(:,1),:) ;       % re-orders matrix to agree row-wise
                
                %         % Choose method of constant radius or constant number
                %         if tgl1 == 0   % take point within r
                %             l3 = l <= ra;
                %             b = newa.subset(l3);      % new data per grid point (b) is sorted in distanc
                %             rd = ra;
                %         else
                %             % take first ni points
                %             b = b(1:ni,:);      % new data per grid point (b) is sorted in distance
                %             rd = s(ni);
                %         end
                % Choose between constant radius or constant number of events with maximum radius
                if tgl1 == 0   % take point within r
                    % Use Radius to determine grid node catalogs
                    l3 = l <= ra;
                    b = catalog.subset(l3);      % new data per grid point (b) is sorted in distance
                    rd = ra;
                    vDist = sort(l(l3));
                    fMaxDist = max(vDist);
                    % Calculate number of events per gridnode in learning period time
                    vSel = b.Date <= learn_to_date;
                    mb_tmp = b(vSel,:);
                else
                    % Determine ni number of events in learning period
                    % Set minimum number to constant number
                    Nmin = ni;
                    % Select events in learning time period
                    vSel = (b.Date <= learn_to_date);
                    b_learn = b(vSel,:);
                    vSel2 = (b.Date > learn_to_date & b.Date <= forecast_to_date);
                    b_forecast = b(vSel2,:);
                    
                    % Distance from grid node for learning period and forecast period
                    vDist = sort(l(vSel));
                    vDist_forecast = sort(l(vSel2));
                    
                    % Select constant number
                    b_learn = b_learn(1:ni,:);
                    % Maximum distance of events in learning period
                    fMaxDist = vDist(ni);
                    
                    if fMaxDist <= fMaxRadius
                        vSel3 = vDist_forecast <= fMaxDist;
                        b_forecast = b_forecast(vSel3,:);
                        b = [b_learn; b_forecast];
                    else
                        vSel4 = (l < fMaxRadius & b.Date <= learn_to_date);
                        b = b(vSel4,:);
                        b_learn = b;
                    end
                    length(b_learn)
                    length(b_forecast)
                    length(b)
                    mb_tmp = b_learn;
                end % End If on tgl1
                
                %Set catalog after selection
                ZG.newt2 = b;
            end
            
            function out=calculation_function(catalog)
                error('hey developer, finish editing the prep_catalog function first')
                % [catA, catB] = prep_catalog(catalog);
                
                % Calculate the relative rate change, p, c, k, resolution
                if length(b) >= obj.Nmin  % enough events?
                    [mRc] = calc_rcloglike_a2(catalog,obj.time,obj.timef,obj.bootloops, mainshock_time);
                    % Relative rate change normalized to sigma of bootstrap
                    if mRc.fStdBst~=0
                        mRc.fRcBst = mRc.absdiff/mRc.fStdBst;
                    else
                        mRc.fRcBst = NaN;
                    end
                    
                    % Final grid
                    mRc.nY = mb_tmp.Count;
                    mRc.fMaxDist = fMaxDist;
                    out = [mRc.time mRc.absdiff mRc.numreal mRc.nummod...
                        mRc.pval1 mRc.pmedStd1 mRc.cval1 mRc.cmedStd1...
                        mRc.kval1 mRc.kmedStd1 mRc.fStdBst mRc.nMod ...
                        mRc.nY mRc.fMaxDist mRc.fRcBst...
                        mRc.pval2 mRc.pmedStd2 mRc.cval2 mRc.cmedStd2...
                        mRc.kval2 mRc.kmedStd2 mRc.H mRc.KSSTAT mRc.P mRc.fRMS];
                else
                    out = nan(1,25);
                end
            end
        end
        
    end
    
    methods(Static)
        function h=AddMenuItem(parent,zapFcn)
            % create a menu item
            label='Rate change, p-,c-,k-value map in aftershock sequence [xsec]';
            h=uimenu(parent,'Label',label,MenuSelectedField(), @(~,~)XZfun.rc_cross_a2(zapFcn()));
        end
    end
end

function orig_rc_cross_a2()
    % Calculate relative rate changes and Omori_parameters on cross section.
    % J. Woessner
    % updated: 31.08.03
    
    
    report_this_filefun();
    ZG=ZmapGlobal.Data;
    catalog = ZG.primeCatalog;
    catalog.sort('Date')

    % Do we have to create the dialogbox?
    % Set the grid parameter
    % initial values
    %
    dd = 1.00; % Depth spacing in km
    dx = 1.00 ; % X-Spacing in km
    ni = 100;   % Number of events
    bv2 = NaN;
    Nmin = 50;  % Minimum number of events
    stan2 = NaN;
    stan = NaN;
    prf = NaN;
    av = NaN;
    nRandomRuns = 1000;
    bGridEntireArea = false;
    time = days(47);
    timef= days(20);
    bootloops = 50;
    ra = 5;
    fMaxRadius = 5;
    
    if ~ensure_mainshock()
        return
    end
    % cut catalog at mainshock time:
    l = catalog.Date > ZG.maepi.Date(1);
    catalog=catalog.subset(l);
    %{
    % Create the dialog box
    figure_w_normalized_uicontrolunits(...
        'Name','Grid Input Parameter',...
        'NumberTitle','off', ...
        'units','points',...
        'Visible','on', ...
        'Menubar','none',...
        'Position',position_in_current_monitor( 550, 300), ...
        'Color', [0.8 0.8 0.8]);
    axis off
    %}
    %     % Dropdown list
    %     labelList2=[' Automatic Mc (max curvature) | Fixed Mc (Mc = Mmin) | Automatic Mc (90% probability) | Automatic Mc (95% probability) | Best combination (Mc95 - Mc90 - max curvature)'];
    %     hndl2=uicontrol(...
    %         'Style','popup',...
    %         'Position',[ 0.2 0.77  0.6  0.08],...
    %         'Units','normalized',...
    %         'String',labelList2,...
    %         'BackgroundColor','w',...
    %         'callback',@callbackfun_001);
    
    %     % Set selection to 'Best combination'
    %     set(hndl2,'value',5);
    
    zdlg = ZmapDialog([]);
    zdlg.AddEventSelector('evsel',ni,ra,Nmin);
    zdlg.AddGridSpacing('gridparam',dx,'km',[],[],dd,'km'); %gridparam.dx->dx %gridparam.dz ->dd
    zdlg.AddEdit('time','learning period (days)',time,'learning period');
    zdlg.AddEdit('timef','forecast period (days)',timef,'forecast period');
    zdlg.AddEdit('bootloops','bootstrap samples',bootloops,'Bootstrap samples');
    
    [res,okPressed]=zdlg.Create('Grid Parameters');
    
    % put response values back into variables expected by program
    ni=res.evsel.NumNearbyEvents;
    ra=res.evsel.RadiusKm;
    tgl1=res.evsel.UseNumNearbyEvents;
    tgl2=~tgl1;
    Nmin=res.evsel.requiredNumEvents;
    if ~isduration(res.time)
        time=days(res.time);
    else
        time=res.time;
    end
    if ~isduration(res.timef)
        timef=days(res.timef);
    else
        timef=res.timef;
    end
    bootloops=res.bootloops;
    
    my_calculate();
    
    % get the grid-size interactively and
    % calculate the b-value in the grid by sorting
    % the seismicity and selecting the ni neighbors
    % to each grid point
    
    function my_calculate()
        %
        % FIXME needs xsecx and xsecy
     
        figure(xsec_fig());
        set(gca,'NextPlot','add')
        
        if bGridEntireArea % Use entire area for grid
            vXLim = get(gca, 'XLim');
            vYLim = get(gca, 'YLim');
            x = [vXLim(1); vXLim(1); vXLim(2); vXLim(2)];
            y = [vYLim(2); vYLim(1); vYLim(1); vYLim(2)];
            x = [x ; x(1)];
            y = [y ; y(1)];     %  closes polygon
            clear vXLim vYLim;
        else
            ax=findobj(gcf,'Tag','mainmap_ax');
            [x,y, mouse_points_overlay] = select_polygon(ax);
        end % of if bGridEntireArea
        
        plos2 = plot(x,y,'b-');        % plot outline
        sum3 = 0.;
        pause(0.3)
        
        %create a rectangular grid
        xvect=[min(x):dx:max(x)];
        yvect=[min(y):dd:max(y)];
        gx = xvect;gy = yvect;
        tmpgri=zeros((length(xvect)*length(yvect)),2);
        n=0;
        for i=1:length(xvect)
            for j=1:length(yvect)
                n=n+1;
                tmpgri(n,:)=[xvect(i) yvect(j)];
            end
        end
        %extract all gridpoints in chosen polygon
        XI=tmpgri(:,1);
        YI=tmpgri(:,2);
        
        ll = polygon_filter(x,y,XI,YI,'inside');
        newgri=tmpgri(ll,:);
        
        % Plot all grid points
        plot(newgri(:,1),newgri(:,2),'+k')
        
        if length(xvect) < 2  ||  length(yvect) < 2
            errordlg('Selection too small! (not a matrix)');
            return
        end
        
        itotal = length(newgri(:,1));
        if length(gx) < 4  ||  length(gy) < 4
            errordlg('Selection too small! ');
            return
        end
        
        %  make grid, calculate start- endtime etc.  ...
        %
        [t0b, teb] = newa.DateRange();
        n = newa.Count;
        tdiff = round(newa.DateSpan/ZG.bin_dur);
        loc = zeros(3, length(gx)*length(gy));
        
        % loop over  all points
        %
        i2 = 0.;
        i1 = 0.;
        mRcCross = []; %NaN(length(newgri),14);
        allcount = 0.;
        wai = waitbar(0,' Please Wait ...  ');
        set(wai,'NumberTitle','off','Name','b-value grid - percent done');
        drawnow
        %
        % loop
        %
        for i= 1:length(newgri(:,1))
            x = newgri(i,1);y = newgri(i,2);
            allcount = allcount + 1.;
            i2 = i2+1;
            
            % Select subcatalog
            % Calculate distance from center point and sort with distance
            l = sqrt(((xsecx' - x)).^2 + ((xsecy + y)).^2) ;
            [s,is] = sort(l);
            b = newa(is(:,1),:) ;       % re-orders matrix to agree row-wise
            
            %         % Choose method of constant radius or constant number
            %         if tgl1 == 0   % take point within r
            %             l3 = l <= ra;
            %             b = newa.subset(l3);      % new data per grid point (b) is sorted in distanc
            %             rd = ra;
            %         else
            %             % take first ni points
            %             b = b(1:ni,:);      % new data per grid point (b) is sorted in distance
            %             rd = s(ni);
            %         end
            % Choose between constant radius or constant number of events with maximum radius
            if tgl1 == 0   % take point within r
                % Use Radius to determine grid node catalogs
                l3 = l <= ra;
                b = catalog.subset(l3);      % new data per grid point (b) is sorted in distance
                rd = ra;
                vDist = sort(l(l3));
                fMaxDist = max(vDist);
                % Calculate number of events per gridnode in learning period time
                vSel = b.Date <= ZG.maepi.Date(1)+days(time);
                mb_tmp = b(vSel,:);
            else
                % Determine ni number of events in learning period
                % Set minimum number to constant number
                Nmin = ni;
                % Select events in learning time period
                vSel = (b.Date <= ZG.maepi.Date(1)+days(time));
                b_learn = b(vSel,:);
                vSel2 = (b.Date > ZG.maepi.Date(1)+days(time) & b.Date <= ZG.maepi.Date(1)+(time+timef)/365);
                b_forecast = b(vSel2,:);
                
                % Distance from grid node for learning period and forecast period
                vDist = sort(l(vSel));
                vDist_forecast = sort(l(vSel2));
                
                % Select constant number
                b_learn = b_learn(1:ni,:);
                % Maximum distance of events in learning period
                fMaxDist = vDist(ni);
                
                if fMaxDist <= fMaxRadius
                    vSel3 = vDist_forecast <= fMaxDist;
                    b_forecast = b_forecast(vSel3,:);
                    b = [b_learn; b_forecast];
                else
                    vSel4 = (l < fMaxRadius & b.Date <= ZG.maepi.Date(1)+days(time));
                    b = b(vSel4,:);
                    b_learn = b;
                end
                length(b_learn)
                length(b_forecast)
                length(b)
                mb_tmp = b_learn;
            end % End If on tgl1
            
            %Set catalog after selection
            ZG.newt2 = b;
            
            % Calculate the relative rate change, p, c, k, resolution
            if length(b) >= Nmin  % enough events?
                [mRc] = calc_rcloglike_a2(b,time,timef,bootloops, ZG.maepi.Date(1));
                % Relative rate change normalized to sigma of bootstrap
                if mRc.fStdBst~=0
                    mRc.fRcBst = mRc.absdiff/mRc.fStdBst;
                else
                    mRc.fRcBst = NaN;
                end
                
                % Number of events per gridnode
                [nY,nX]=size(mb_tmp);
                % Final grid
                mRc.nY = nY;
                mRc.fMaxDist = fMaxDist;
                mRcCross = [mRcCross; mRc.time mRc.absdiff mRc.numreal mRc.nummod mRc.pval1 mRc.pmedStd1 mRc.cval1 mRc.cmedStd1...
                    mRc.kval1 mRc.kmedStd1 mRc.fStdBst mRc.nMod mRc.nY mRc.fMaxDist mRc.fRcBst...
                    mRc.pval2 mRc.pmedStd2 mRc.cval2 mRc.cmedStd2 mRc.kval2 mRc.kmedStd2 mRc.H mRc.KSSTAT mRc.P mRc.fRMS];
            else
                mRcCross = [mRcCross; NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
            end
            waitbar(allcount/itotal)
        end  % for newgr
        
        % save data
        %
        drawnow
        gx = xvect;gy = yvect;
        
        % Save the data to rcval_grid.mat
        
        close(wai)
        watchoff
        
        % plot the results
        %                mRcCross = [mRcCross; mRc.time mRc.absdiff mRc.numreal mRc.nummod mRc.pval1 mRc.pmedStd1 mRc.cval1 mRc.cmedStd1...
        %                     mRc.kval1 mRc.kmedStd1 mRc.fStdBst mRc.nMod mRc.nY mRc.fMaxDist mRc.fRcBst...
        %                     mRc.pval2 mRc.pmedStd2 mRc.cval2 mRc.cmedStd2 mRc.kval2 mRc.kmedStd2 mRc.H mRc.fRMS];
        
        normlap2=NaN(length(tmpgri(:,1)),1);
        % Relative rate change
        normlap2(ll)= mRcCross(:,15);
        mRelchange = reshape(normlap2,length(yvect),length(xvect));
        
        %%% p,c,k- values for period before large aftershock or just modified Omori law
        % p-value
        normlap2(ll)= mRcCross(:,5);
        mPval=reshape(normlap2,length(yvect),length(xvect));
        
        % p-value standard deviation
        normlap2(ll)= mRcCross(:,6);
        mPvalstd = reshape(normlap2,length(yvect),length(xvect));
        
        % c-value
        normlap2(ll)= mRcCross(:,7);
        mCval = reshape(normlap2,length(yvect),length(xvect));
        
        % c-value standard deviation
        normlap2(ll)= mRcCross(:,8);
        mCvalstd = reshape(normlap2,length(yvect),length(xvect));
        
        % k-value
        normlap2(ll)= mRcCross(:,9);
        mKval = reshape(normlap2,length(yvect),length(xvect));
        
        % k-value standard deviation
        normlap2(ll)= mRcCross(:,10);
        mKvalstd = reshape(normlap2,length(yvect),length(xvect));
        
        %%% Resolution parameters
        % Number of events per grid node
        normlap2(ll)= mRcCross(:,13);
        mNumevents = reshape(normlap2,length(yvect),length(xvect));
        
        % Radii of chosen events, Resolution
        normlap2(ll)= mRcCross(:,14);
        vRadiusRes = reshape(normlap2,length(yvect),length(xvect));
        
        % Chosen fitting model
        normlap2(ll)= mRcCross(:,12);
        mMod = reshape(normlap2,length(yvect),length(xvect));
        
        try
            %%% p,c,k- values for period AFTER large aftershock
            % p-value
            normlap2(ll)= mRcCross(:,16);
            mPval2=reshape(normlap2,length(yvect),length(xvect));
            
            % p-value standard deviation
            normlap2(ll)= mRcCross(:,17);
            mPvalstd2 = reshape(normlap2,length(yvect),length(xvect));
            
            % c-value
            normlap2(ll)= mRcCross(:,18);
            mCval2 = reshape(normlap2,length(yvect),length(xvect));
            
            % c-value standard deviation
            normlap2(ll)= mRcCross(:,19);
            mCvalstd2 = reshape(normlap2,length(yvect),length(xvect));
            
            % k-value
            normlap2(ll)= mRcCross(:,20);
            mKval2 = reshape(normlap2,length(yvect),length(xvect));
            
            % k-value standard deviation
            normlap2(ll)= mRcCross(:,21);
            mKvalstd2 = reshape(normlap2,length(yvect),length(xvect));
            
            % KS-Test (H-value) binary rejection criterion at 95% confidence level
            normlap2(ll)= mRcCross(:,22);
            mKstestH = reshape(normlap2,length(yvect),length(xvect));
            
            %  KS-Test statistic for goodness of fit
            normlap2(ll)= mRcCross(:,23);
            mKsstat = reshape(normlap2,length(yvect),length(xvect));
            
            %  KS-Test p-value
            normlap2(ll)= mRcCross(:,24);
            mKsp = reshape(normlap2,length(yvect),length(xvect));
            
            % RMS value for goodness of fit
            normlap2(ll)= mRcCross(:,25);
            mRMS = reshape(normlap2,length(yvect),length(xvect));
        catch
            disp('Values not calculated')
        end
        % Data to plot first map
        valueMap = mRelchange;
        lab1 = 'Rate change';
        
        % View the map
        view_rccross_a2(lab1,valueMap)
        
    end
    
    % Load exist b-grid
    function my_load()
        [file1,path1] = uigetfile(['*.mat'],'b-value gridfile');
        if length(path1) > 1
            
            load([path1 file1])
            
            normlap2=NaN(length(tmpgri(:,1)),1);
            % Relative rate change
            normlap2(ll)= mRcCross(:,15);
            mRelchange = reshape(normlap2,length(yvect),length(xvect));
            
            %%% p,c,k- values for period before large aftershock or just modified Omori law
            % p-value
            normlap2(ll)= mRcCross(:,5);
            mPval=reshape(normlap2,length(yvect),length(xvect));
            
            % p-value standard deviation
            normlap2(ll)= mRcCross(:,6);
            mPvalstd = reshape(normlap2,length(yvect),length(xvect));
            
            % c-value
            normlap2(ll)= mRcCross(:,7);
            mCval = reshape(normlap2,length(yvect),length(xvect));
            
            % c-value standard deviation
            normlap2(ll)= mRcCross(:,8);
            mCvalstd = reshape(normlap2,length(yvect),length(xvect));
            
            % k-value
            normlap2(ll)= mRcCross(:,9);
            mKval = reshape(normlap2,length(yvect),length(xvect));
            
            % k-value standard deviation
            normlap2(ll)= mRcCross(:,10);
            mKvalstd = reshape(normlap2,length(yvect),length(xvect));
            
            %%% Resolution parameters
            % Number of events per grid node
            normlap2(ll)= mRcCross(:,13);
            mNumevents = reshape(normlap2,length(yvect),length(xvect));
            
            % Radii of chosen events, Resolution
            normlap2(ll)= mRcCross(:,14);
            vRadiusRes = reshape(normlap2,length(yvect),length(xvect));
            
            % Chosen fitting model
            normlap2(ll)= mRcCross(:,12);
            mMod = reshape(normlap2,length(yvect),length(xvect));
            
            try
                %%% p,c,k- values for period AFTER large aftershock
                % p-value
                normlap2(ll)= mRcCross(:,16);
                mPval2=reshape(normlap2,length(yvect),length(xvect));
                
                % p-value standard deviation
                normlap2(ll)= mRcCross(:,17);
                mPvalstd2 = reshape(normlap2,length(yvect),length(xvect));
                
                % c-value
                normlap2(ll)= mRcCross(:,18);
                mCval2 = reshape(normlap2,length(yvect),length(xvect));
                
                % c-value standard deviation
                normlap2(ll)= mRcCross(:,19);
                mCvalstd2 = reshape(normlap2,length(yvect),length(xvect));
                
                % k-value
                normlap2(ll)= mRcCross(:,20);
                mKval2 = reshape(normlap2,length(yvect),length(xvect));
                
                % k-value standard deviation
                normlap2(ll)= mRcCross(:,21);
                mKvalstd2 = reshape(normlap2,length(yvect),length(xvect));
                
                % KS-Test (H-value) binary rejection criterion at 95% confidence level
                normlap2(ll)= mRcCross(:,22);
                mKstestH = reshape(normlap2,length(yvect),length(xvect));
                
                %  KS-Test statistic for goodness of fit
                normlap2(ll)= mRcCross(:,23);
                mKsstat = reshape(normlap2,length(yvect),length(xvect));
                
                %  KS-Test p-value
                normlap2(ll)= mRcCross(:,24);
                mKsp = reshape(normlap2,length(yvect),length(xvect));
                
                % RMS value for goodness of fit
                normlap2(ll)= mRcCross(:,25);
                mRMS = reshape(normlap2,length(yvect),length(xvect));
            catch
                disp('Values not calculated')
            end
            
            % Initial map set to relative rate change
            valueMap = mRelchange;
            lab1 = 'Rate change';
            nlammap
            [xsecx xsecy,  inde] =mysect(catalog.Latitude',catalog.Longitude',catalog.Depth,ZG.xsec_defaults.WidthKm,0,lat1,lon1,lat2,lon2);
            % Plot all grid points
            set(gca,'NextPlot','add')
            
            old = valueMap;
            % Plot
            view_rccross_a2(lab1,valueMap);
        else
            return
        end
    end
    
end
