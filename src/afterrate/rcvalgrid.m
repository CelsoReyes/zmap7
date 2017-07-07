% Scrip: rcvalgrid.m
% Calculates relative rate change map, p-,c-,k- values and standard deviations
% Uses view_rcva to plot the results
%
% For the execution of this program, the "Cumulative Window" should have been opened before.
% Otherwise the matrix "maepi", used by this program, does not exist.
%
% J. Woessner
% last update: 17.07.03

report_this_filefun(mfilename('fullpath'));


global no1 bo1 inb1 inb2 valeg valeg2 CO valm1
ZG=ZmapGlobal.Data;
valeg = 1;
valm1 = min(a.Magnitude);
prf = NaN;
if sel == 'in'
    % Set the grid parameter
    %Initial values
    dx = 0.02;
    dy = 0.02;
    ni = 150;
    Nmin = 100;
    time = 47;
    timef= 20;
    bootloops = 50;
    ra = 5;
    fMaxRadius = 5;

    % cut catalog at mainshock time:
    l = a.Date > maepi(1,3);
    a = a.subset(l);

    % cat at selecte magnitude threshold
    l = a.Magnitude < valm1;
    a(l,:) = [];
    newt2 = a;

    ZG.hold_state2=true;
    timeplot
    ZG.hold_state2=false;


    %The definitions in the following line were present in the initial bvalgrid.m file.
    %stan2 = NaN; stan = NaN; prf = NaN; av = NaN;

    % make the interface
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
    labelList2=[' Automatic Mcomp (max curvature) | Fixed Mc (Mc = Mmin) | Automatic Mcomp (90% probability) | Automatic Mcomp (95% probability) | Best (?) combination (Mc95 - Mc90 - max curvature)'];
    labelPos = [0.2 0.7  0.6  0.08];
    hndl2=uicontrol(...
        'Style','popup',...
        'Position',labelPos,...
        'Units','normalized',...
        'String',labelList2,...
        'Callback','inb2 =get(hndl2,''Value''); ');

    set(hndl2,'value',5);


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
    labelList2=[' Automatic Mcomp (max curvature) | Fixed Mc (Mc = Mmin) | Automatic Mcomp (90% probability) | Automatic Mcomp (95% probability) | Best (?) combination (Mc95 - Mc90 - max curvature) | Constant Mc'];
    labelPos = [0.2 0.8  0.6  0.08];
    hndl2=uicontrol(...
        'Style','popup',...
        'Position',labelPos,...
        'Units','normalized',...
        'String',labelList2,...
        'Callback','inb2 =get(hndl2,''Value''); ');

    set(hndl2,'value',5);


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
        'Callback',' inb1 =get(hndl2,''Value'');tgl1 =get(tgl1,''Value'');tgl2 =get(tgl2,''Value'');prev_grid = get(prev_grid,''Value'');create_grid = get(create_grid,''Value''); load_grid = get(load_grid,''Value''); save_grid = get(save_grid,''Value''); oldfig_button = get(oldfig_button,''Value''); close,sel =''ca'', rcvalgrid',...
        'String','Go');

    text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.10 0.98 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.l ,...
        'FontWeight','bold',...
        'String','Please choose an Mc estimation option   ');
    txt3 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.30 0.75 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.l ,...
        'FontWeight','bold',...
        'String',' Grid Parameter');
    txt5 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[-0.1 0.4 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in x (dx) in deg:');

    txt6 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[-0.1 0.3 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in y (dy) in deg:');

    txt7 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[-0.1 0.18 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Min. No. of events > Mc:');

    txt8 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.42 0.4 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.s ,...
        'FontWeight','bold',...
        'String','Forecast period:');
    txt9 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.42 0.28 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.s ,...
        'FontWeight','bold',...
        'String','Learning period:');

    txt10 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.42 0.51 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.s ,...
        'FontWeight','bold',...
        'String','Bootstrap samples:');

    txt11 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.42 0.62 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.s ,...
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

    % get new grid if needed
    if load_grid == 1
        [file1,path1] = uigetfile(['*.mat'],'previously saved grid');
        if length(path1) > 1
            think
            load([path1 file1])
        end
        plot(newgri(:,1),newgri(:,2),'k+')
    elseif load_grid ==0  &&  prev_grid == 0
        selgp
        if length(gx) < 2  ||  length(gy) < 2
            errordlg('Selection too small! (Dx and Dy are in degreees! ');
            return
        end
    elseif prev_grid == 1
        plot(newgri(:,1),newgri(:,2),'k+')
    end
    %   end

    gll = ll;

    if save_grid == 1
        grid_save =...
            [ 'zmap_message_center.set_info(''Saving Grid'',''  '');think;',...
            '[file1,path1] = uiputfile(fullfile(hodi, ''eq_data'', ''*.mat''), ''Grid File Name?'') ;',...
            ' gs = [''save '' path1 file1 '' newgri dx dy gx gy xvect yvect tmpgri ll''];',' if length(file1) > 1, eval(gs),end , done'];
        eval(grid_save)
    end

    %   selgp
    itotal = length(newgri(:,1));
    if length(gx) < 4  ||  length(gy) < 4
        errordlg('Selection too small! (Dx and Dy are in degreees! ');
        return
    end

    zmap_message_center.set_info(' ','Running... ');think
    %  make grid, calculate start- endtime etc.  ...
    %
    t0b = min(a.Date)  ;
    n = a.Count;
    teb = a(n,3) ;
    tdiff = round((teb - t0b)*365/par1);
    loc = zeros(3, length(gx)*length(gy));

    % loop over  all points
    %
    i2 = 0.;
    i1 = 0.;
    mRcGrid =[];
    allcount = 0.;
    wai = waitbar(0,' Please Wait ...  ');
    set(wai,'NumberTitle','off','Name','Rate change grid - percent done');
    drawnow
    %
    % overall b-value
    %    [bv magco stan av me mer me2,  pr] =  bvalca3(a,inb1,inb2);
    %    bo1 = bv; no1 = a.Count;

    % loop over all points
    for i= 1:length(newgri(:,1))
        i/length(newgri(:,1))
        % Grid node point
        x = newgri(i,1);y = newgri(i,2);
        allcount = allcount + 1.;
        i2 = i2+1;

        % calculate distance from center point and sort with distance
        l = sqrt(((a.Longitude-x)*cos(pi/180*y)*111).^2 + ((a.Latitude-y)*111).^2) ;
        [s,is] = sort(l);
        b = a(is(:,1),:) ;       % re-orders matrix to agree row-wise

        % Choose between constant radius or constant number of events with maximum radius
        if tgl1 == 0   % take point within r
            % Use Radius to determine grid node catalogs
            l3 = l <= ra;
            b = a.subset(l3);      % new data per grid point (b) is sorted in distance
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
        if length(b) >= Nmin  % enough events?
            [mRc] = calc_ratechangeF(b,time,timef,bootloops, maepi);
            % Relative rate change normalized to sigma from Fehlerfortpflanzungsgesetz
            if mRc(:,3)~=0
                fRelchange = mRc(:,2)/mRc(:,3);
            else
                fRelchange = NaN;
            end
            mRcGrid_tmp =  [fRelchange mRc];
            % Relative rate change normalized to sigma of bootstrap
            if mRc(:,12)~=0
                fRcBst = mRc(:,2)/mRc(:,12);
            else
                fRcBst = NaN;
            end
        else
            fRelchange = NaN;
            mRcGrid_tmp =  [fRelchange NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
            fRcBst = NaN;
        end

        % Number of events per gridnode
        [nY,nX]=size(mb_tmp);
        % Final grid
        mRcGrid = [mRcGrid; mRcGrid_tmp nY fMaxDist fRcBst];
        waitbar(allcount/itotal)
    end  % for newgr

    % Save the data to rcval_grid.mat
    save rcval_grid.mat mRcGrid gx gy dx dy par1 tdiff t0b teb a main faults mainfault coastline yvect xvect tmpgri ll bo1 newgri gll ra time timef bootloops maepi
    disp('Saving data to rcval_grid.mat in current directory')
    %     catSave3 =...
    %         [ 'zmap_message_center.set_info(''Save Grid'',''  '');think;',...
    %             '[file1,path1] = uiputfile(fullfile(hodi, ''eq_data'', ''*.mat''), ''Grid Datafile Name?'') ;',...
    %             ' sapa2 = [''save '' path1 file1 '' mRcGrid gx gy dx dy par1 tdiff t0b teb a main faults mainfault coastline yvect xvect tmpgri ll bo1 newgri gll''];',...
    %             ' if length(file1) > 1, eval(sapa2),end , done']; eval(catSave3)

    close(wai)
    watchoff

    % plot the results
    % old and re3 (initially ) is the b-value matrix

    % mRcGrid = fRelchange time absdiff sigma numreal nummod pval pvalstd cval cvalstd kval kvalstd
    normlap2=NaN(length(tmpgri(:,1)),1);
    normlap2(ll)= mRcGrid(:,1);
    % Relative rate change
    mRelchange = reshape(normlap2,length(yvect),length(xvect));

    % p-value
    normlap2(ll)= mRcGrid(:,7);
    mPval=reshape(normlap2,length(yvect),length(xvect));

    % p-value standard deviation
    normlap2(ll)= mRcGrid(:,8);
    mPvalstd = reshape(normlap2,length(yvect),length(xvect));

    % c-value
    normlap2(ll)= mRcGrid(:,9);
    mCval = reshape(normlap2,length(yvect),length(xvect));

    % c-value standard deviation
    normlap2(ll)= mRcGrid(:,10);
    mCvalstd = reshape(normlap2,length(yvect),length(xvect));

    % k-value
    normlap2(ll)= mRcGrid(:,11);
    mKval = reshape(normlap2,length(yvect),length(xvect));

    % c-value standard deviation
    normlap2(ll)= mRcGrid(:,12);
    mKvalstd = reshape(normlap2,length(yvect),length(xvect));

    % Number of events per grid node
    normlap2(ll)= mRcGrid(:,14);
    mNumevents = reshape(normlap2,length(yvect),length(xvect));

    % Radii of chosen events, Resolution
    normlap2(ll)= mRcGrid(:,15);
    vRadiusRes = reshape(normlap2,length(yvect),length(xvect));

    % Relative rate change normalized to boostrap standard deviation
    normlap2(ll)= mRcGrid(:,16);
    vRcBst = reshape(normlap2,length(yvect),length(xvect));

    % Data to plot first map
    re3 = mRelchange;
    lab1 = 'Rate change';

    % View the b-value and p-value map
    view_rcva

end   % if sel = na

% Load exist b-grid
if sel == 'lo'
    [file1,path1] = uigetfile(['*.mat'],'b-value gridfile');
    if length(path1) > 1
        think
        load([path1 file1])

        % mRcGrid = fRelchange time absdiff sigma numreal nummod pval pvalstd cval cvalstd kval kvalstd
        normlap2=NaN(length(tmpgri(:,1)),1);
        normlap2(ll)= mRcGrid(:,1);
        % Relative rate change
        mRelchange = reshape(normlap2,length(yvect),length(xvect)); %

        % p-value
        normlap2(ll)= mRcGrid(:,7);
        mPval=reshape(normlap2,length(yvect),length(xvect)); % old1

        % p-value standard deviation
        normlap2(ll)= mRcGrid(:,8);
        mPvalstd = reshape(normlap2,length(yvect),length(xvect)); % pro

        % c-value
        normlap2(ll)= mRcGrid(:,9);
        mCval = reshape(normlap2,length(yvect),length(xvect)); % avm

        % c-value standard deviation
        normlap2(ll)= mRcGrid(:,10);
        mCvalstd = reshape(normlap2,length(yvect),length(xvect)); % r

        % k-value
        normlap2(ll)= mRcGrid(:,11);
        mKval = reshape(normlap2,length(yvect),length(xvect)); %meg

        % k-value standard deviation
        normlap2(ll)= mRcGrid(:,12);
        mKvalstd = reshape(normlap2,length(yvect),length(xvect));

        % This is to load older grids! May be removed!
        % Number of events per grid node
        normlap2(ll)= mRcGrid(:,13);
        mNumevents = reshape(normlap2,length(yvect),length(xvect));

        try

            % Number of events per grid node
            normlap2(ll)= mRcGrid(:,14);
            mNumevents = reshape(normlap2,length(yvect),length(xvect));

            % Radii of chosen events, Resolution
            normlap2(ll)= mRcGrid(:,15);
            vRadiusRes = reshape(normlap2,length(yvect),length(xvect));

            % Relative rate change normalized to boostrap standard deviation
            normlap2(ll)= mRcGrid(:,16);
            vRcBst = reshape(normlap2,length(yvect),length(xvect));
        catch
            disp('Columns radius resolution and RC Bootstrap not available')
        end

        re3 = mRelchange;
        lab1 = 'Rate change';


        old = re3;

        view_rcva;
    else
        return
    end
end
