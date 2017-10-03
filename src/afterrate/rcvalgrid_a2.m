function [sel]=rcvalgrid_a2()
    % Calculates relative rate change map, p-,c-,k- values and standard deviations after model selection by AIC
    % Uses view_rcva_a2 to plot the results
    %
    % For the execution of this program, the "Cumulative Window" should have been opened before.
    % Otherwise the matrix "ZG.maepi", used by this program, does not exist.
    %
    % J. Woessner
    % updated: 14.02.05
    
    ZG=ZmapGlobal.Data;
    report_this_filefun(mfilename('fullpath'));

    minThreshMag = min(ZG.primeCatalog.Magnitude);
    
    % Set the grid parameter
    % Initial values
    dx = 0.02; % Grid size latitude [deg]
    dy = 0.02; % Grid size longitude [deg]
    ni = 150;  % Minimum number
    Nmin = 100; % Minimum number
    time = days(47);  % Learning period [days]
    timef= days(20);  % Forecast period [days]
    bootloops = 100; % Bootstrap
    ra = 5;          % Radius [km]
    fMaxRadius = 5;  % Max. radius [km] in case of constant number
    bMap = 1; % Map view
    bGridEntireArea = 0; % Grid area, interactive or entire map
    useEventsInRadius=false; % required for variable scoping.
    load_grid=false; % required for variable scoping.
    prev_grid=false; % required for variable scoping.
    Grid=[];
    EventSelector=[];
    
    if ~ensure_mainshock()
        return
    end
    % cut catalog at mainshock time:
    l = ZG.primeCatalog.Date > ZG.maepi.Date(1) & ZG.primeCatalog.Magnitude > minThreshMag;
    ZG.newt2=ZG.primeCatalog.subset(l);
    ff=gcf;
    %ZG.hold_state2=true;
    %timeplot(ZG.newt2)
    %ZG.hold_state2=false;
    figure(ff);
    
    
    %The definitions in the following line were present in the initial file.
    %stan2 = NaN; stan = NaN;  av = NaN;
    
    % make the interface
    % creates a dialog box to input grid parameters
    %
    fig=figure_w_normalized_uicontrolunits(...
        'Name','Grid Input Parameter',...
        'NumberTitle','off', ...
        'NextPlot','new', ...
        'units','points',...
        'Visible','off', ...
        'Position',[ ZG.wex+200 ZG.wey-200 700 250]);
    axis off
    %     labelList2=[' Automatic Mcomp (max curvature) | Fixed Mc (Mc = Mmin) | Automatic Mcomp (90% probability) | Automatic Mcomp (95% probability) | Best (?) combination (Mc95 - Mc90 - max curvature) | Constant Mc'];
    %     labelPos = [0.2 0.8  0.6  0.08];
    %     hndl2=uicontrol(...
    %         'Style','popup',...
    %         'Position',labelPos,...
    %         'Units','normalized',...
    %         'String',labelList2,...
    %         'callback',@callbackfun_001);
    %
    %     set(hndl2,'value',5);
    
    
    % creates a dialog box to input grid parameters
    %
    
    
        zdlg = ZmapFunctionDlg();
        
        
        McMethods={'Automatic Mcomp (max curvature)',...
            'Fixed Mc (Mc = Mmin)',...
            'Automatic Mcomp (90% probability)',...
            'Automatic Mcomp (95% probability)',...
            'Best (?) combination (Mc95 - Mc90 - max curvature)',...
            'Constant Mc'};
        
        zdlg.AddBasicPopup('mc_methods','Mc  Method:',McMethods,5,...
            'Please choose an Mc estimation option');
        
        zdlg.AddGridParameters('Grid',dx,'deg',dy,'deg',[],'');
        % add fMaxRadius
        zdlg.AddEventSelectionParameters('EventSelector', ni, ra, Nmin) %selOpt
        zdlg.AddBasicEdit('boot_samp','# boot loops', bootloops,' number of bootstraps');
        zdlg.AddBasicEdit('forec_period','forecast period [days]', timef, 'forecast period [days]');
        zdlg.AddBasicEdit('learn_period','learn period [days]', time, 'learning period [days]');
        zdlg.AddBasicCheckbox('addtofig','plot in current figure', true,[],'plot in the current figure');
        % zdlg.AddBasicEdit('Mmin','minMag', nan, 'Minimum magnitude');
        % TOFIX min number of events should be the number > Mc
        
        [res, okpressed]=zdlg.Create('relative rate change map');
        if ~okpressed
            return
        end
        disp(res)
        Grid=ZmapGrid('rcvalgrid',res.Grid);
        EventSelector=res.EventSelector;
        
        error('This feature hasn''t been completely implemented yet.')
        %{
        figure
        % addtofig -> oldfig_button
        
    selOpt=[];%EventSelectionChoice(fig,'evsel',[],ni,ra);
    oldfig_button = uicontrol('BackGroundColor',[.60 .92 .84], ...
        'Style','checkbox','string','Plot in Current Figure',...
        'Position',[.78 .7 .20 .08],...
        'Units','normalized');
    
    set(oldfig_button,'value',1);
    
    uicontrol('Style','edit',...
        'Position',[.6 .30 .12 .080],...
        'Units','normalized','String',string(days(time)),...
        'callback',@callbackfun_006);
    uicontrol('Style','edit',...
        'Position',[.6 .40 .12 .080],...
        'Units','normalized','String',string(days(timef)),...
        'callback',@callbackfun_007);
    
    uicontrol('Style','edit',...
        'Position',[.6 .50 .12 .080],...
        'Units','normalized','String',num2str(bootloops),...
        'callback',@callbackfun_008);
    
    uicontrol('Style','edit',...
        'Position',[.30 .20 .12 .080],...
        'Units','normalized','String',num2str(Nmin),...
        'callback',@callbackfun_009);
    
    uicontrol('Style','edit',...
        'Position',[.6 .60 .12 .080],...
        'Units','normalized','String',num2str(fMaxRadius),...
        'callback',@callbackfun_010);
    
    uicontrol('Style','Pushbutton',...
        'Position',[.60 .05 .15 .12 ],...
        'Units','normalized','callback',@callbackfun_cancel,'String','Cancel');
    
    uicontrol('Style','Pushbutton',...
        'Position',[.20 .05 .15 .12 ],...
        'Units','normalized',...
        'callback',@callbackfun_go,...
        'String','Go');
    
    text(...
        'Position',[0.10 0.98 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.l ,...
        'FontWeight','bold',...
        'String','Please choose an Mc estimation option   ');
    text(...
        'Position',[0.30 0.75 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.l ,...
        'FontWeight','bold',...
        'String',' Grid Parameter');
    
    text(...
        'Position',[-0.1 0.18 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Min. No. of events > Mc:');
    
    text(...
        'Position',[0.42 0.4 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.s ,...
        'FontWeight','bold',...
        'String','Forecast period:');
    text(...
        'Position',[0.42 0.28 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.s ,...
        'FontWeight','bold',...
        'String','Learning period:');
    
    text(...
        'Position',[0.42 0.51 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.s ,...
        'FontWeight','bold',...
        'String','Bootstrap samples:');
    %{
    txt11 = text(...
        'Position',[0.42 0.62 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.s ,...
        'FontWeight','bold',...
        'String','Max. Radius /[km]:');
        %}
        set(gcf,'visible','on');
        watchoff
        
        %}
        
    function my_calculate() % 'ca'
        % get the grid-size interactively and
        % calculate the b-value in the grid by sorting
        % thge seimicity and selectiong the ni neighbors
        % to each grid point
        %In the following line, the program .m is called, which creates a rectangular grid from which then selects,
        %on the basis of the vector ll, the points within the selected poligon.
        hWindow =  findobj('Name','Coulomb-map');
        if ~isempty(hWindow)
            map = hWindow;
        else
            map = findobj('Name','Seismicity Map');
        end
        
        % Select grid
        if load_grid
            [file1,path1] = uigetfile(['*.mat'],'previously saved grid');
            if length(path1) > 1
                
                load([path1 file1])
                gx = xvect;
                gy = yvect;
            end
            plot(newgri(:,1),newgri(:,2),'k+')
        elseif ~load_grid &&  ~prev_grid
            % Create new grid
            [newgri, xvect, yvect, ll] = ex_selectgrid(map, dx, dy, bGridEntireArea);
            gx = xvect;
            gy = yvect;
        elseif prev_grid
            plot(newgri(:,1),newgri(:,2),'k+')
        end
        %   end
        
        % Waitbar counting
        itotal = length(newgri(:,1));
        % Plot all grid points
        plot(newgri(:,1),newgri(:,2),'+k')
        drawnow
        
        %  make grid, calculate start- endtime etc.  ...
        %
        t0b = min(ZG.primeCatalog.Date)  ;
        n = ZG.primeCatalog.Count;
        teb = max(ZG.primeCatalog.Date) ;
        tdiff = round((teb-t0b)/ZG.bin_dur);
        
        % Container
        mRcGrid =[];
        allcount = 0.;
        % Waiting bar
        wai = waitbar(0,' Please Wait ...  ');
        set(wai,'NumberTitle','off','Name','Rate change grid - percent done');
        drawnow
        %
        % Loop over all points
        for i= 1:length(newgri(:,1))
            i/length(newgri(:,1));
            % Grid node point
            x = newgri(i,1);y = newgri(i,2);
            allcount = allcount + 1.;
            
            % Choose between constant radius or constant number of events with maximum radius
            if useEventsInRadius   % take point within r
                b = ZG.primeCatalog.selectRadius(y,x,ra);
                fMaxDist = max(b.epicentralDistanceTo(y,x));
                % Calculate number of events per gridnode in learning period time
                vSel = b.Date <= ZG.maepi.Date(1)+days(time);
                mb_tmp = b.subset(vSel);
            else
                % Determine ni number of events in learning period
                % Set minimum number to constant number
                Nmin = ni;
                % Select events in learning time period
                vSel = (b.Date <= ZG.maepi.Date(1)+days(time));
                b_learn = b.subset(vSel);
                
                vSel2 = (b.Date > ZG.maepi.Date(1)+days(time) & b.Date <= ZG.maepi.Date(1)+(time+timef)/365);
                b_forecast = b.subset(vSel2);
                
                % Distance from grid node for learning period and forecast period
                [b_learn, fMaxDist] = b_learn.selectClosestEvents(ni);
                
                if fMaxDist <= fMaxRadius
                    vSel3 = b_forecast.epicentralDistanceTo(y,x) <= fMaxDist;
                    b_forecast = b_forecast.subset(vSel3);
                    b = [b_learn; b_forecast]; %TOFIX I'm sure this isn't concatenating properly
                else
                    vSel4 = (b.epicentralDistanceTo(y,x) < fMaxRadius & b.Date <= ZG.maepi.Date(1)+days(time));
                    b = b.subset(vSel4);
                    b_learn = b;
                end
                b_learn.Count
                b_forecast.Count
                b.Count
                mb_tmp = b_learn;
            end
            
            % Calculate the relative rate change, p, c, k, resolution
            if mb_tmp.Count >= Nmin  % enough events?
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
                mRcGrid = [mRcGrid; mRc.time mRc.absdiff mRc.numreal mRc.nummod mRc.pval1 mRc.pmedStd1 mRc.cval1 mRc.cmedStd1...
                    mRc.kval1 mRc.kmedStd1 mRc.fStdBst mRc.nMod mRc.nY mRc.fMaxDist mRc.fRcBst...
                    mRc.pval2 mRc.pmedStd2 mRc.cval2 mRc.cmedStd2 mRc.kval2 mRc.kmedStd2 mRc.H mRc.KSSTAT mRc.P mRc.fRMS mRc.fTBigAf];
            else
                mRcGrid = [mRcGrid; nan(1,26)];
            end
            waitbar(allcount/itotal)
        end  % for newgr
        
        % Save the data to rcval_grid.mat
        % save rcval_grid.mat mRcGrid gx gy dx dy ZG.bin_dur tdiff t0b teb a main faults mainfault coastline yvect xvect tmpgri ll ZG.bo1 newgri gll ra time timef bootloops ZG.maepi
        [sFilename, sPathname] = uiputfile('*.mat', 'Save MAT-file');
        sFileSave = [sPathname sFilename];
        save(sFileSave,'mRcGrid','gx','gy','dx','dy','a','main','yvect','xvect','ll','newgri','ra','time','timef','bootloops','ZG.maepi');
        save rcval_grid.mat mRcGrid gx gy dx dy a main yvect xvect ll newgri ra time timef bootloops ZG.maepi
        disp('Saving data to rcval_grid.mat in current directory')
        
        close(wai)
        watchoff
        
        %normlap2=NaN(length(xvect(1,:)),1);
        normlap2=NaN(length(ll),1);
        % Relative rate change
        normlap2(ll)= mRcGrid(:,15);
        mRelchange = reshape(normlap2,length(yvect),length(xvect));
        
        %%% p,c,k- values for period before large aftershock or just modified Omori law
        % p-value
        normlap2(ll)= mRcGrid(:,5);
        mPval=reshape(normlap2,length(yvect),length(xvect));
        
        % p-value standard deviation
        normlap2(ll)= mRcGrid(:,6);
        mPvalstd = reshape(normlap2,length(yvect),length(xvect));
        
        % c-value
        normlap2(ll)= mRcGrid(:,7);
        mCval = reshape(normlap2,length(yvect),length(xvect));
        
        % c-value standard deviation
        normlap2(ll)= mRcGrid(:,8);
        mCvalstd = reshape(normlap2,length(yvect),length(xvect));
        
        % k-value
        normlap2(ll)= mRcGrid(:,9);
        mKval = reshape(normlap2,length(yvect),length(xvect));
        
        % k-value standard deviation
        normlap2(ll)= mRcGrid(:,10);
        mKvalstd = reshape(normlap2,length(yvect),length(xvect));
        
        %%% Resolution parameters
        % Number of events per grid node
        normlap2(ll)= mRcGrid(:,13);
        mNumevents = reshape(normlap2,length(yvect),length(xvect));
        
        % Radii of chosen events, Resolution
        normlap2(ll)= mRcGrid(:,14);
        vRadiusRes = reshape(normlap2,length(yvect),length(xvect));
        
        % Chosen fitting model
        normlap2(ll)= mRcGrid(:,12);
        mMod = reshape(normlap2,length(yvect),length(xvect));
        
        try
            %%% p,c,k- values for period AFTER large aftershock
            % p-value
            normlap2(ll)= mRcGrid(:,16);
            mPval2=reshape(normlap2,length(yvect),length(xvect));
            
            % p-value standard deviation
            normlap2(ll)= mRcGrid(:,17);
            mPvalstd2 = reshape(normlap2,length(yvect),length(xvect));
            
            % c-value
            normlap2(ll)= mRcGrid(:,18);
            mCval2 = reshape(normlap2,length(yvect),length(xvect));
            
            % c-value standard deviation
            normlap2(ll)= mRcGrid(:,19);
            mCvalstd2 = reshape(normlap2,length(yvect),length(xvect));
            
            % k-value
            normlap2(ll)= mRcGrid(:,20);
            mKval2 = reshape(normlap2,length(yvect),length(xvect));
            
            % k-value standard deviation
            normlap2(ll)= mRcGrid(:,21);
            mKvalstd2 = reshape(normlap2,length(yvect),length(xvect));
            
            % KS-Test (H-value) binary rejection criterion at 95% confidence level
            normlap2(ll)= mRcGrid(:,22);
            mKstestH = reshape(normlap2,length(yvect),length(xvect));
            
            %  KS-Test statistic for goodness of fit
            normlap2(ll)= mRcGrid(:,23);
            mKsstat = reshape(normlap2,length(yvect),length(xvect));
            
            %  KS-Test p-value
            normlap2(ll)= mRcGrid(:,24);
            mKsp = reshape(normlap2,length(yvect),length(xvect));
            
            % RMS value for goodness of fit
            normlap2(ll)= mRcGrid(:,25);
            mRMS = reshape(normlap2,length(yvect),length(xvect));
            
            % Times of secondary afterhsock
            normlap2(ll)= mRcGrid(:,26);
            mBigAf = reshape(normlap2,length(yvect),length(xvect));
            
        catch
            disp('Values not calculated')
        end
        % Data to plot first map
        valueMap = mRelchange;
        lab1 = 'Rate change';
        
        % View the map
        view_rcva_a2(lab1,valueMap)
        
    end
    function my_load() %'lo'
        % Load exist b-grid
        [file1,path1] = uigetfile(['*.mat'],'b-value gridfile');
        if length(path1) > 1
            
            load([path1 file1])
            
            normlap2=NaN(length(ll),1);
            % Relative rate change
            normlap2(ll)= mRcGrid(:,15);
            mRelchange = reshape(normlap2,length(yvect),length(xvect));
            
            %%% p,c,k- values for period before large aftershock or just modified Omori law
            % p-value
            normlap2(ll)= mRcGrid(:,5);
            mPval=reshape(normlap2,length(yvect),length(xvect));
            
            % p-value standard deviation
            normlap2(ll)= mRcGrid(:,6);
            mPvalstd = reshape(normlap2,length(yvect),length(xvect));
            
            % c-value
            normlap2(ll)= mRcGrid(:,7);
            mCval = reshape(normlap2,length(yvect),length(xvect));
            
            % c-value standard deviation
            normlap2(ll)= mRcGrid(:,8);
            mCvalstd = reshape(normlap2,length(yvect),length(xvect));
            
            % k-value
            normlap2(ll)= mRcGrid(:,9);
            mKval = reshape(normlap2,length(yvect),length(xvect));
            
            % k-value standard deviation
            normlap2(ll)= mRcGrid(:,10);
            mKvalstd = reshape(normlap2,length(yvect),length(xvect));
            
            %%% Resolution parameters
            % Number of events per grid node
            normlap2(ll)= mRcGrid(:,13);
            mNumevents = reshape(normlap2,length(yvect),length(xvect));
            
            % Radii of chosen events, Resolution
            normlap2(ll)= mRcGrid(:,14);
            vRadiusRes = reshape(normlap2,length(yvect),length(xvect));
            
            % Chosen fitting model
            normlap2(ll)= mRcGrid(:,12);
            mMod = reshape(normlap2,length(yvect),length(xvect));
            
            try
                %%% p,c,k- values for period AFTER large aftershock
                % p-value
                normlap2(ll)= mRcGrid(:,16);
                mPval2=reshape(normlap2,length(yvect),length(xvect));
                
                % p-value standard deviation
                normlap2(ll)= mRcGrid(:,17);
                mPvalstd2 = reshape(normlap2,length(yvect),length(xvect));
                
                % c-value
                normlap2(ll)= mRcGrid(:,18);
                mCval2 = reshape(normlap2,length(yvect),length(xvect));
                
                % c-value standard deviation
                normlap2(ll)= mRcGrid(:,19);
                mCvalstd2 = reshape(normlap2,length(yvect),length(xvect));
                
                % k-value
                normlap2(ll)= mRcGrid(:,20);
                mKval2 = reshape(normlap2,length(yvect),length(xvect));
                
                % k-value standard deviation
                normlap2(ll)= mRcGrid(:,21);
                mKvalstd2 = reshape(normlap2,length(yvect),length(xvect));
                
                % KS-Test (H-value) binary rejection criterion at 95% confidence level
                normlap2(ll)= mRcGrid(:,22);
                mKstestH = reshape(normlap2,length(yvect),length(xvect));
                
                %  KS-Test statistic for goodness of fit
                normlap2(ll)= mRcGrid(:,23);
                mKsstat = reshape(normlap2,length(yvect),length(xvect));
                
                %  KS-Test p-value
                normlap2(ll)= mRcGrid(:,24);
                mKsp = reshape(normlap2,length(yvect),length(xvect));
                
                % RMS value for goodness of fit
                normlap2(ll)= mRcGrid(:,25);
                mRMS = reshape(normlap2,length(yvect),length(xvect));
                
                % Times of secondary afterhsock
                normlap2(ll)= mRcGrid(:,26);
                mBigAf = reshape(normlap2,length(yvect),length(xvect));
            catch
                disp('Values not calculated')
            end
            
            % Initial map set to relative rate change
            valueMap = mRelchange;
            lab1 = 'Rate change';
            
            old = valueMap;
            % Plot
            view_rcva_a2(lab1,valueMap);
        else
            return
        end
    end
    %{
function callbackfun_001(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.inb2=hndl2.Value;
        ;
    end
    %}
    
    
    function callbackfun_006(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        mysrc.Value=str2double(mysrc.String);
        time=days(mysrc.Value);
    end
    
    function callbackfun_007(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        timef=str2double(mysrc.String);
    end
    
    function callbackfun_008(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        bootloops=str2double(mysrc.String);
    end
    
    function callbackfun_009(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        Nmin=str2double(mysrc.String);
    end
    
    function callbackfun_010(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        fMaxRadius=str2double(mysrc.String);
    end
    
    function callbackfun_cancel(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close;
        
    end
    
    function callbackfun_go(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        useEventsInRadius=selOpt.UseEventsInRadius;
        ni=selOpt.ni;
        ra=selOpt.ra;
        dx=gridOpt.dx;
        dy=gridOpt.dy;
        bGridEntireArea=gridOpt.GridEntireArea;
        
        prev_grid=prev_grid.Value;
        create_grid=create_grid.Value;
        load_grid=gridOpt.LoadGrid;
        save_grid=gridOpt.SaveGrid;
        oldfig_button=oldfig_button.Value;
        close;
        my_calculate();
    end
end
