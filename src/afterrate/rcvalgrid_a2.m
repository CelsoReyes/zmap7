% Scrip: rcvalgrid_a2.m
% Calculates relative rate change map, p-,c-,k- values and standard deviations after model selection by AIC
% Uses view_rcva_a2 to plot the results
%
% For the execution of this program, the "Cumulative Window" should have been opened before.
% Otherwise the matrix "maepi", used by this program, does not exist.
%
% J. Woessner
% last update: 14.02.05

global no1 bo1 inb1 inb2 valeg valeg2 CO valm1

report_this_filefun(mfilename('fullpath'));

valeg = 1;
valm1 = min(a(:,6));
prf = NaN;
if sel == 'in'
    % Set the grid parameter
    % Initial values
    dx = 0.02; % Grid size latitude [deg]
    dy = 0.02; % Grid size longitude [deg]
    ni = 150;  % Minimum number
    Nmin = 100; % Minimum number
    time = 47;  % Learning period [days]
    timef= 20;  % Forecast period [days]
    bootloops = 100; % Bootstrap
    ra = 5;          % Radius [km]
    fMaxRadius = 5;  % Max. radius [km] in case of constant number
    bMap = 1; % Map view
    bGridEntireArea = 0; % Grid area, interactive or entire map

    % cut catalog at mainshock time:
    l = a(:,3) > maepi(1,3);
    a = a(l,:);

    % cat at selecte magnitude threshold
    l = a(:,6) < valm1;
    a(l,:) = [];
    newt2 = a;

    ho2 = 'hold';
    timeplot
    ho2 = 'noho';


    %The definitions in the following line were present in the initial bvalgrid.m file.
    %stan2 = NaN; stan = NaN; prf = NaN; av = NaN;

    % make the interface
    % creates a dialog box to input grid parameters
    %
    figure_w_normalized_uicontrolunits(...
        'Name','Grid Input Parameter',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','new', ...
        'units','points',...
        'Visible','off', ...
        'Position',[ wex+200 wey-200 650 250]);
    axis off
    %     labelList2=[' Automatic Mcomp (max curvature) | Fixed Mc (Mc = Mmin) | Automatic Mcomp (90% probability) | Automatic Mcomp (95% probability) | Best (?) combination (Mc95 - Mc90 - max curvature) | Constant Mc'];
    %     labelPos = [0.2 0.8  0.6  0.08];
    %     hndl2=uicontrol(...
    %         'Style','popup',...
    %         'Position',labelPos,...
    %         'Units','normalized',...
    %         'String',labelList2,...
    %         'Callback','inb2 =get(hndl2,''Value''); ');
    %
    %     set(hndl2,'value',5);


    % creates a dialog box to input grid parameters
    %

    oldfig_button = uicontrol('BackGroundColor',[.60 .92 .84], ...
        'Style','checkbox','string','Plot in Current Figure',...
        'Position',[.78 .7 .20 .08],...
        'Units','normalized');

    set(oldfig_button,'value',1);


    freq_field=uicontrol('Style','edit',...
        'Position',[.30 .60 .12 .08],...
        'Units','normalized','String',num2str(ni),...
        'Callback','ni=str2double(get(freq_field,''String'')); set(freq_field,''String'',num2str(ni));set(tgl2,''value'',0); set(tgl1,''value'',1)');


    freq_field0=uicontrol('Style','edit',...
        'Position',[.30 .50 .12 .08],...
        'Units','normalized','String',num2str(ra),...
        'Callback','ra=str2double(get(freq_field0,''String'')); set(freq_field0,''String'',num2str(ra)) ; set(tgl2,''value'',1); set(tgl1,''value'',0)');

    freq_field2=uicontrol('Style','edit',...
        'Position',[.30 .40 .12 .08],...
        'Units','normalized','String',num2str(dx),...
        'Callback','dx=str2double(get(freq_field2,''String'')); set(freq_field2,''String'',num2str(dx));');

    freq_field3=uicontrol('Style','edit',...
        'Position',[.30 .30 .12 .080],...
        'Units','normalized','String',num2str(dy),...
        'Callback','dy=str2double(get(freq_field3,''String'')); set(freq_field3,''String'',num2str(dy));');

    freq_field4=uicontrol('Style','edit',...
        'Position',[.6 .30 .12 .080],...
        'Units','normalized','String',num2str(time),...
        'Callback','time=str2double(get(freq_field4,''String'')); set(freq_field4,''String'',num2str(time));');

    freq_field5=uicontrol('Style','edit',...
        'Position',[.6 .40 .12 .080],...
        'Units','normalized','String',num2str(timef),...
        'Callback','timef=str2double(get(freq_field5,''String'')); set(freq_field5,''String'',num2str(timef));');

    freq_field6=uicontrol('Style','edit',...
        'Position',[.6 .50 .12 .080],...
        'Units','normalized','String',num2str(bootloops),...
        'Callback','bootloops=str2double(get(freq_field6,''String'')); set(freq_field6,''String'',num2str(bootloops));');

    freq_field7=uicontrol('Style','edit',...
        'Position',[.30 .20 .12 .080],...
        'Units','normalized','String',num2str(Nmin),...
        'Callback','Nmin=str2double(get(freq_field7,''String'')); set(freq_field7,''String'',num2str(Nmin));');

    freq_field8=uicontrol('Style','edit',...
        'Position',[.6 .60 .12 .080],...
        'Units','normalized','String',num2str(fMaxRadius),...
        'Callback','fMaxRadius=str2double(get(freq_field8,''String'')); set(freq_field8,''String'',num2str(fMaxRadius));');

    tgl1 = uicontrol('Style','radiobutton',...
        'string','Number of Events:',...
        'Position',[.05 .60 .2 .0800], 'Callback','set(tgl2,''value'',0)',...
        'Units','normalized');

    set(tgl1,'value',0);

    tgl2 =  uicontrol('Style','radiobutton',...
        'string','OR: Constant Radius',...
        'Position',[.05 .50 .2 .080], 'Callback','set(tgl1,''value'',0)',...
        'Units','normalized');
    set(tgl2,'value',1);

    create_grid =  uicontrol('Style','radiobutton',...
        'string','Calculate a new grid', 'Callback','set(load_grid,''value'',0), set(prev_grid,''value'',0)','Position',[.78 .55 .2 .080],...
        'Units','normalized');

    set(create_grid,'value',1);

    prev_grid =  uicontrol('Style','radiobutton',...
        'string','Reuse the previous grid', 'Callback','set(load_grid,''value'',0),set(create_grid,''value'',0)','Position',[.78 .45 .2 .080],...
        'Units','normalized');


    load_grid =  uicontrol('Style','radiobutton',...
        'string','Load a previously saved grid', 'Callback','set(prev_grid,''value'',0),set(create_grid,''value'',0)','Position',[.78 .35 .2 .080],...
        'Units','normalized');

    save_grid =  uicontrol('Style','checkbox',...
        'string','Save selected grid to file',...
        'Position',[.78 .22 .2 .080],...
        'Units','normalized');



    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.60 .05 .15 .12 ],...
        'Units','normalized','Callback','close;done','String','Cancel');

    go_button1=uicontrol('Style','Pushbutton',...
        'Position',[.20 .05 .15 .12 ],...
        'Units','normalized',...
        'Callback','tgl1 =get(tgl1,''Value'');tgl2 =get(tgl2,''Value'');prev_grid = get(prev_grid,''Value'');create_grid = get(create_grid,''Value''); load_grid = get(load_grid,''Value''); save_grid = get(save_grid,''Value''); oldfig_button = get(oldfig_button,''Value''); close,sel =''ca'', rcvalgrid_a2',...
        'String','Go');

    text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.10 0.98 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.l ,...
        'FontWeight','bold',...
        'String','Please choose an Mc estimation option   ');
    txt3 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.30 0.75 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.l ,...
        'FontWeight','bold',...
        'String',' Grid Parameter');
    txt5 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[-0.1 0.4 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in x (dx) in deg:');

    txt6 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[-0.1 0.3 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in y (dy) in deg:');

    txt7 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[-0.1 0.18 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.m ,...
        'FontWeight','bold',...
        'String','Min. No. of events > Mc:');

    txt8 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.42 0.4 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.s ,...
        'FontWeight','bold',...
        'String','Forecast period:');
    txt9 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.42 0.28 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.s ,...
        'FontWeight','bold',...
        'String','Learning period:');

    txt10 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.42 0.51 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.s ,...
        'FontWeight','bold',...
        'String','Bootstrap samples:');

    txt11 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.42 0.62 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.s ,...
        'FontWeight','bold',...
        'String','Max. Radius /[km]:');

    set(gcf,'visible','on');
    watchoff

end   % if nargin ==0

% get the grid-size interactively and
% calculate the b-value in the grid by sorting
% thge seimicity and selectiong the ni neighbors
% to each grid point

if sel == 'ca'
    %In the following line, the program .m is called, which creates a rectangular grid from which then selects,
    %on the basis of the vector ll, the points within the selected poligon.
    hWindow =  findobj('Name','Coulomb-map');
    if ~isempty(hWindow)
        map = hWindow;
    else
        map = findobj('Name','Seismicity Map');
    end

    % Select grid
    if load_grid == 1
        [file1,path1] = uigetfile(['*.mat'],'previously saved grid');
        if length(path1) > 1
            think
            load([path1 file1])
            gx = xvect;
            gy = yvect;
        end
        plot(newgri(:,1),newgri(:,2),'k+')
    elseif load_grid ==0  &&  prev_grid == 0
        % Create new grid
        [newgri, xvect, yvect, ll] = ex_selectgrid(map, dx, dy, bGridEntireArea);
        gx = xvect;
        gy = yvect;
    elseif prev_grid == 1
        plot(newgri(:,1),newgri(:,2),'k+')
    end
    %   end

    % Waitbar counting
    itotal = length(newgri(:,1));
    % Plot all grid points
    plot(newgri(:,1),newgri(:,2),'+k','era','back')
    drawnow
    welcome(' ','Running... ');think
    %  make grid, calculate start- endtime etc.  ...
    %
    t0b = a(1,3)  ;
    n = length(a(:,1));
    teb = a(n,3) ;
    tdiff = round((teb - t0b)*365/par1);

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

        % calculate distance from center point and sort with distance
        l = sqrt(((a(:,1)-x)*cos(pi/180*y)*111).^2 + ((a(:,2)-y)*111).^2) ;
        [s,is] = sort(l);
        b = a(is(:,1),:) ;       % re-orders matrix to agree row-wise

        % Choose between constant radius or constant number of events with maximum radius
        if tgl1 == 0   % take point within r
            % Use Radius to determine grid node catalogs
            l3 = l <= ra;
            b = a(l3,:);      % new data per grid point (b) is sorted in distance
            rd = ra;
            vDist = sort(l(l3));
            fMaxDist = max(vDist);
            % Calculate number of events per gridnode in learning period time
            vSel = b(:,3) <= maepi(1,3)+time/365;
            mb_tmp = b(vSel,:);
        else
            % Determine ni number of events in learning period
            % Set minimum number to constant number
            Nmin = ni;
            % Select events in learning time period
            vSel = (b(:,3) <= maepi(1,3)+time/365);
            b_learn = b(vSel,:);
            vSel2 = (b(:,3) > maepi(1,3)+time/365 & b(:,3) <= maepi(1,3)+(time+timef)/365);
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
                vSel4 = (l < fMaxRadius & b(:,3) <= maepi(1,3)+time/365);
                b = b(vSel4,:);
                b_learn = b;
            end
            length(b_learn)
            length(b_forecast)
            length(b)
            mb_tmp = b_learn;
        end % End If on tgl1

        % Calculate the relative rate change, p, c, k, resolution
        if length(mb_tmp(:,1)) >= Nmin  % enough events?
            [mRc] = calc_rcloglike_a2(b,time,timef,bootloops, maepi);
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
            mRcGrid = [mRcGrid; NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
        end
        waitbar(allcount/itotal)
    end  % for newgr

    % Save the data to rcval_grid.mat
    % save rcval_grid.mat mRcGrid gx gy dx dy par1 tdiff t0b teb a main faults mainfault coastline yvect xvect tmpgri ll bo1 newgri gll ra time timef bootloops maepi
    [sFilename, sPathname] = uiputfile('*.mat', 'Save MAT-file');
    sFileSave = [sPathname sFilename];
    save(sFileSave,'mRcGrid','gx','gy','dx','dy','a','main','yvect','xvect','ll','newgri','ra','time','timef','bootloops','maepi');
    save rcval_grid.mat mRcGrid gx gy dx dy a main yvect xvect ll newgri ra time timef bootloops maepi
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
    re3 = mRelchange;
    lab1 = 'Rate change';

    % View the map
    view_rcva_a2

end   % if sel = na

% Load exist b-grid
if sel == 'lo'
    [file1,path1] = uigetfile(['*.mat'],'b-value gridfile');
    if length(path1) > 1
        think
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
        re3 = mRelchange;
        lab1 = 'Rate change';

        old = re3;
        % Plot
        view_rcva_a2;
    else
        return
    end
end
