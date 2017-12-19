function rc_cross_a2()
    % Calculate relative rate changes and Omori_parameters on cross section.
    % This subroutine assigns creates a grid with spacing dx,dy (in degreees). The size will
    % be selected interactively or the entire area. The values are calculated for in each volume
    % around a grid point containing ni earthquakes
    % J. Woessner
    % updated: 31.08.03
    
    
    report_this_filefun(mfilename('fullpath'));
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
    bGridEntireArea = 0;
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
        'Position',[ ZG.wex+200 ZG.wey-200 550 300], ...
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
    
    zdlg = ZmapFunctionDlg([]);
    zdlg.AddEventSelectionParameters('evsel',ni,ra,Nmin);
    zdlg.AddGridParameters('gridparam',dx,'km',[],[],dd,'km'); %gridparam.dx->dx %gridparam.dz ->dd
    zdlg.AddBasicEdit('time','learning period (days)',time,'learning period');
    zdlg.AddBasicEdit('timef','forecast period (days)',timef,'forecast period');
    zdlg.AddBasicEdit('bootloops','bootstrap samples',bootloops,'Bootstrap samples');
    
    [res,okPressed]=zdlg.Create('Grid Parameters');
    
    % put response values back into variables expected by program
    ni=res.evsel.numNearbyEvents;
    ra=res.evsel.radius_km;
    tgl1=res.evsel.useNumNearbyEvents;
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
    % the seimicity and selecting the ni neighbors
    % to each grid point
    
    function my_calculate()
        %
        % TOFIX needs xsecx and xsecy
        figure(xsec_fig);
        hold on
        
        if bGridEntireArea % Use entire area for grid
            vXLim = get(gca, 'XLim');
            vYLim = get(gca, 'YLim');
            x = [vXLim(1); vXLim(1); vXLim(2); vXLim(2)];
            y = [vYLim(2); vYLim(1); vYLim(1); vYLim(2)];
            x = [x ; x(1)];
            y = [y ; y(1)];     %  closes polygon
            clear vXLim vYLim;
        else
            ax = mainmap('axes')
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
        set(wai,'NumberTitle','off','Name','b-value grid - percent done');;
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
                [mRc] = calc_rcloglike_a2(b,time,timef,bootloops, ZG.maepi);
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
            [xsecx xsecy,  inde] =mysect(catalog.Latitude',catalog.Longitude',catalog.Depth,ZG.xsec_width_km,0,lat1,lon1,lat2,lon2);
            % Plot all grid points
            hold on
            
            old = valueMap;
            % Plot
            view_rccross_a2(lab1,valueMap);
        else
            return
        end
    end
   
    
    function callbackfun_001(mysrc,myevt)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.inb2=hndl2.Value;
    end
    
end
