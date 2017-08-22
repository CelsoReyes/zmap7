function rc_cross_a2()
    % Calculate relative rate changes and Omori_parameters on cross section.
    % This subroutine assigns creates a grid with spacing dx,dy (in degreees). The size will
    % be selected interactively or the entire area. The values are calculated for in each volume
    % around a grid point containing ni earthquakes
    % J. Woessner
    % last update: 31.08.03
    
    report_this_filefun(mfilename('fullpath'));

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
    time = 47;
    timef= 20;
    bootloops = 50;
    ra = 5;
    fMaxRadius = 5;
    
    % cut catalog at mainshock time:
    l = ZG.a.Date > ZG.maepi.Date(1);
    ZG.a=ZG.a.subset(l);
    
    % Create the dialog box
    figure_w_normalized_uicontrolunits(...
        'Name','Grid Input Parameter',...
        'NumberTitle','off', ...
        'units','points',...
        'Visible','on', ...
        'Position',[ ZG.wex+200 ZG.wey-200 550 300], ...
        'Color', [0.8 0.8 0.8]);
    axis off
    
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
    
    % Edit fields, radiobuttons, and checkbox
    freq_field=uicontrol('Style','edit',...
        'Position',[.30 .70 .12 .08],...
        'Units','normalized','String',num2str(ni),...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'callback',@callbackfun_002);
    
    freq_field0=uicontrol('Style','edit',...
        'Position',[.30 .60 .12 .08],...
        'Units','normalized','String',num2str(ra),...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'callback',@callbackfun_003);
    
    freq_field2=uicontrol('Style','edit',...
        'Position',[.30 .40 .12 .08],...
        'Units','normalized','String',num2str(dx),...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'callback',@callbackfun_004);
    
    freq_field3=uicontrol('Style','edit',...
        'Position',[.30 .30 .12 .08],...
        'Units','normalized','String',num2str(dd),...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'callback',@callbackfun_005);
    
    freq_field7=uicontrol('Style','edit',...
        'Position',[.68 .40 .12 .080],...
        'Units','normalized','String',num2str(time),...
        'callback',@callbackfun_006);
    
    freq_field5=uicontrol('Style','edit',...
        'Position',[.68 .50 .12 .080],...
        'Units','normalized','String',num2str(timef),...
        'callback',@callbackfun_007);
    
    freq_field6=uicontrol('Style','edit',...
        'Position',[.68 .60 .12 .080],...
        'Units','normalized','String',num2str(bootloops),...
        'callback',@callbackfun_008);
    
    freq_field8=uicontrol('Style','edit',...
        'Position',[.68 .70 .12 .080],...
        'Units','normalized','String',num2str(fMaxRadius),...
        'callback',@callbackfun_009);
    
    tgl1 = uicontrol('BackGroundColor', [0.8 0.8 0.8], ...
        'Style','radiobutton',...
        'string','Number of events:',...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'Position',[.02 .70 .28 .08], 'callback',@callbackfun_010,...
        'Units','normalized');
    
    % Set to constant number of events
    set(tgl1,'value',1);
    
    tgl2 =  uicontrol('BackGroundColor',[0.8 0.8 0.8],'Style','radiobutton',...
        'string','Constant radius [km]:',...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'Position',[.02 .60 .28 .08], 'callback',@callbackfun_011,...
        'Units','normalized');
    
    freq_field4 =  uicontrol('Style','edit',...
        'Position',[.30 .20 .12 .08],...
        'Units','normalized','String',num2str(Nmin),...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'callback',@callbackfun_013);
    
    chkGridEntireArea = uicontrol('BackGroundColor', [0.8 0.8 0.8], ...
        'Style','checkbox',...
        'string','Create grid over entire area',...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'Position',[.02 .06 .40 .08], 'Units','normalized', 'Value', 0);
    
    % Buttons
    uicontrol('BackGroundColor', [0.8 0.8 0.8], 'Style', 'pushbutton', ...
        'Units', 'normalized', 'Position', [.80 .05 .15 .12], ...
        'Callback', 'close;done', 'String', 'Cancel');
    
    uicontrol('BackGroundColor', [0.8 0.8 0.8], 'Style', 'pushbutton', ...
        'Units', 'normalized', 'Position', [.60 .05 .15 .12], ...
        'Callback',@callbackfun_myca,...
        'String', 'OK');
    
    % Labels
    %     text('Units', 'normalized', ...
    %         'Position', [0.2 1 0], 'HorizontalAlignment', 'left',  ...
    %         'FontSize', fontsz.l, 'FontWeight', 'bold', 'String', 'Please select a Mc estimation option');
    %
    text('Units', 'normalized', ...
        'Position', [0.3 0.95 0], 'HorizontalAlignment', 'left',  ...
        'FontSize', fontsz.l, 'FontWeight', 'bold', 'String', 'Grid parameters');
    
    text('Units', 'normalized', ...
        'Position', [-.14 .42 0], 'HorizontalAlignment', 'left',  ...
        'FontSize',ZmapGlobal.Data.fontsz.m, 'FontWeight', 'bold', 'String','Horizontal spacing [km]:');
    
    text('Units', 'normalized', ...
        'Position', [-0.14 0.30 0],  'HorizontalAlignment', 'left', ...
        'FontSize',ZmapGlobal.Data.fontsz.m, 'FontWeight', 'bold', 'String', 'Depth spacing [km]:');
    
    text('Units', 'normalized', ...
        'Position', [-0.14 0.18 0],  'HorizontalAlignment', 'left', ...
        'FontSize',ZmapGlobal.Data.fontsz.m, 'FontWeight', 'bold', 'String', 'Min. number of events:');
    
    txt8 = text(...
        'Position',[0.42 0.55 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Forecast period:');
    txt9 = text(...
        'Position',[0.42 0.43 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Learning period:');
    
    txt10 = text(...
        'Position',[0.42 0.66 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Bootstrap samples:');
    
    txt11 = text(...
        'Position',[0.42 0.78 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Max. Radius /[km]:');
    
    set(gcf,'visible','on');
    watchoff
    
    % get the grid-size interactively and
    % calculate the b-value in the grid by sorting
    % the seimicity and selecting the ni neighbors
    % to each grid point
    
    function my_calculation()
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
            messtext=...
                ['To select a polygon for a grid.       '
                'Please use the LEFT mouse button of   '
                'or the cursor to the select the poly- '
                'gon. Use the RIGTH mouse button for   '
                'the final point.                      '
                'Mac Users: Use the keyboard "p" more  '
                'point to select, "l" last point.      '
                '                                      '];
            zmap_message_center.set_message('Select Polygon for a grid',messtext);
            
            ax = findobj('Tag','main_map_ax');
            [x,y, mouse_points_overlay] = select_polygon(ax);
            
            zmap_message_center.set_info('Message',' Thank you .... ')
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
        t0b = min(newa.Date)  ;
        n = newa.Count;
        teb = max(newa.Date) ;
        tdiff = round((teb-t0b)/ZG.bin_days);
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
                b = ZG.a.subset(l3);      % new data per grid point (b) is sorted in distance
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
        save rcval_grid.mat mRcCross gx gy dx dy ZG.bin_days tdiff t0b teb a main faults mainfault coastline yvect xvect tmpgri ll ZG.bo1 newgri ra time timef bootloops ZG.maepi xsecx xsecy
        
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
        re3 = mRelchange;
        lab1 = 'Rate change';
        
        % View the map
        view_rccross_a2(lab1,re3)
        
    end
    
    % Load exist b-grid
    function my_load()
        [file1,path1] = uigetfile(['*.mat'],'b-value gridfile');
        if length(path1) > 1
            think
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
            re3 = mRelchange;
            lab1 = 'Rate change';
            nlammap
            [xsecx xsecy,  inde] =mysect(ZG.a.Latitude',ZG.a.Longitude',ZG.a.Depth,ZG.xsec_width_km,0,lat1,lon1,lat2,lon2);
            % Plot all grid points
            hold on
            
            old = re3;
            % Plot
            view_rccross_a2(lab1,re3);
        else
            return
        end
    end
    
    function callbackfun_myca(mysrc,myevt)
        tgl1=tgl1.Value;
        tgl2=tgl2.Value;
        bGridEntireArea = get(chkGridEntireArea, 'Value');
        close,
        my_calculation()
    end
    
    function callbackfun_001(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.inb2=hndl2.Value;
        
    end
    
    function callbackfun_002(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ni=str2double(freq_field.String);
        freq_field.String=num2str(ni);
        tgl2.Value=0;
        tgl1.Value=1;
    end
    
    function callbackfun_003(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ra=str2double(freq_field0.String);
        freq_field0.String=num2str(ra);
        tgl2.Value=1;
        tgl1.Value=0;
    end
    
    function callbackfun_004(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        dx=str2double(freq_field2.String);
        freq_field2.String=num2str(dx);
    end
    
    function callbackfun_005(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        dd=str2double(freq_field3.String);
        freq_field3.String=num2str(dd);
    end
    
    function callbackfun_006(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        time_field.Value=str2double(time_field.String);
        time=days(time_field.Value);
    end
    
    function callbackfun_007(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        timef=str2double(freq_field5.String);
        freq_field5.String=num2str(timef);
    end
    
    function callbackfun_008(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        bootloops=str2double(freq_field6.String);
        freq_field6.String=num2str(bootloops);
    end
    
    function callbackfun_009(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        fMaxRadius=str2double(freq_field8.String);
        freq_field8.String=num2str(fMaxRadius);
    end
    
    function callbackfun_010(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        tgl2.Value=0;
    end
    
    function callbackfun_011(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        tgl1.Value=0;
    end
    
    
    function callbackfun_013(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        Nmin=str2double(freq_field4.String);
        freq_field4.String=num2str(Nmin);
    end
end
