% This subroutine assigns creates a grid with
% spacing dx,dy (in degreees). The size will
% be selected interactively. The b-value and p-value in each
% volume around a grid point containing between Nmin and ni earthquakes
% will be calculated as well as the magnitude of completness.
%   Stefan Wiemer 1/95
%
%For the execution of this program, the "Cumulative Window" should have been opened before.
%Otherwise the matrix "maepi", used by this program, does not exist.

global no1 bo1 inb1 inb2 valeg valeg2 CO valm1
ZG=ZmapGlobal.Data;
report_this_filefun(mfilename('fullpath'));


valeg = 1;
valm1 = min(a.Magnitude);
prf = nan;
if sel == 'in'
    % get the grid parameter
    % initial values
    %

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
    dx = 0.025;
    dy = 0.025;
    ni = 150;
    Nmin = 100;

    %The definitions in the following line were present in the initial bvalgrid.m file.
    %stan2 = nan; stan = nan; prf = nan; av = nan;

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
    %labelList2=[' Automatic Mcomp (max curvature) | Fixed Mc (Mc = Mmin) | Automatic Mcomp (90% probability) | Automatic Mcomp (95% probability) | Best (?) combination (Mc95 - Mc90 - max curvature) | Constant Mc'];
    labelList2={'Automatic Mcomp (max curvature)','Fixed Mc (Mc = Mmin)','Automatic Mcomp (90% probability)','Automatic Mcomp (95% probability)','Best (?) combination (Mc95 - Mc90 - max curvature)','Constant Mc'};
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
        'Position',[.78 .52 .20 .08],...
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

    rgroup1 = uibuttongroup('Title','event grouping','Position',[0.05 0.48 0.25 0.25]);
    rgroup2 = uibuttongroup('Title','grid source','Position',[.48 0.3 0.28 0.39]);
    
    tgl1 = uicontrol(rgroup1,'Style','radiobutton',...
        'string','Number of Events:',...
        'Position',[.08 .6 .9 .35],...[.05 .60 .2 .0800],...
        'Units','normalized');

    set(tgl1,'value',1);

    tgl2 =  uicontrol(rgroup1,'Style','radiobutton',...
        'string','Constant Radius:',...
        'Position',[0.08 0.1 .9 .35],...
        ...'Position',[.05 .50 .2 .080],...
        'Units','normalized');

    create_grid =  uicontrol(rgroup2,'Style','radiobutton',...
        'string','Calculate a new grid','Position',[.05 .7 .8 .25],...[.55 .55 .2 .080],...
        'Units','normalized');

    set(create_grid,'value',1);

    prev_grid =  uicontrol(rgroup2,'Style','radiobutton',...
        'string','Reuse the previous grid','Position',[.05 .4 .8 .25],...[.55 .45 .2 .080],...
        'Units','normalized');


    load_grid =  uicontrol(rgroup2,'Style','radiobutton',...
        'string','Load a previously saved grid','Position',[.05 .1 .8 .25],...[.55 .35 .2 .080],...
        'Units','normalized');

    save_grid =  uicontrol('Style','checkbox',...
        'string','Save selected grid to file',...
        'Position',[.55 .22 .2 .080],...
        'Units','normalized');

    uicontrol('Style','edit',...
        'Position',[.30 .20 .12 .080],...
        'Units','normalized','String',num2str(Nmin),...
        'Callback','Nmin=str2double(get(freq_field4,''String'')); set(freq_field4,''String'',num2str(Nmin));');


    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.60 .05 .15 .12 ],...
        'Units','normalized','Callback','close;done','String','Cancel');

    go_button1=uicontrol('Style','Pushbutton',...
        'Position',[.20 .05 .15 .12 ],...
        'Units','normalized',...
        'Callback',' inb1 =get(hndl2,''Value'');tgl1 =get(tgl1,''Value'');tgl2 =get(tgl2,''Value'');prev_grid = get(prev_grid,''Value'');create_grid = get(create_grid,''Value''); load_grid = get(load_grid,''Value''); save_grid = get(save_grid,''Value''); oldfig_button = get(oldfig_button,''Value''); close,sel =''ca'', bpvalgrid',...
        'String','Go');

    text(...
        'Color',[0 0 0 ],...
        'Position',[0.10 0.98 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.l ,...
        'FontWeight','bold',...
        'String','Please choose an Mc estimation option   ');
    txt3 = text(...
        'Color',[0 0 0 ],...
        'Position',[0.30 0.75 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.l ,...
        'FontWeight','bold',...
        'String',' Grid Parameter');
    txt5 = text(...
        'Color',[0 0 0 ],...
        'Position',[-0.1 0.4 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in x (dx) in deg:');

    txt6 = text(...
        'Color',[0 0 0 ],...
        'Position',[-0.1 0.3 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in y (dy) in deg:');

    txt7 = text(...
        'Color',[0 0 0 ],...
        'Position',[-0.1 0.18 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Min. No. of events > Mc:');

    %
    %


    set(gcf,'visible','on');
    watchoff

end   % if nargin ==0

% get the grid-size interactively and
% calculate the b-value in the grid by sorting
% thge seimicity and selectiong the ni neighbors
% to each grid point

if sel == 'ca'



    %In the following line, the program selgp.m is called, which creates a rectangular grid from which then selects,
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
        if length(gx) < 4  ||  length(gy) < 4
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
            '[file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.data_dir, ''*.mat''), ''Grid File Name?'') ;',...
            ' gs = [''save '' path1 file1 '' newgri dx dy gx gy xvect yvect newgri ll''];',...
            ' if length(file1) > 1, eval(gs),end , done']; eval(grid_save)
    end

    %   selgp
    itotal = length(newgri(:,1));
    %   if length(gx) < 4 | length(gy) < 4
    %      errordlg('Selection too small! (Dx and Dy are in degreees! ');
    %      return
    %   end

    prompt = {'If you wish a fixed c in Omori formula, please enter a negative value'};
    title = 'Input parameter';
    lines = 1;
    valeg2 = 2;
    def = {num2str(valeg2)};
    answer = inputdlg(prompt,title,lines,def);
    valeg2=str2double(answer{1});

    if valeg2 <= 0
        prompt = {'Enter c'};
        title = 'Input parameter';
        lines = 1;
        CO = 0;
        def = {num2str(CO)};
        answer = inputdlg(prompt,title,lines,def);
        CO=str2double(answer{1});
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
    bpvg = [];
    allcount = 0.;
    wai = waitbar(0,' Please Wait ...  ');
    set(wai,'NumberTitle','off','Name','bp-value grid - percent done');;
    drawnow
    %
    % overall b-value
    [bv magco stan av me mer me2,  pr] =  bvalca3(a,inb1,inb2);
    bo1 = bv; no1 = a.Count;

    % loop over all points
    for i= 1:length(newgri(:,1))
        x = newgri(i,1);y = newgri(i,2);
        allcount = allcount + 1.;
        i2 = i2+1;

        % calculate distance from center point and sort wrt distance
        l = sqrt(((a.Longitude-x)*cos(pi/180*y)*111).^2 + ((a.Latitude-y)*111).^2) ;
        [s,is] = sort(l);
        b = a(is(:,1),:) ;       % re-orders matrix to agree row-wise

        if tgl1 == 0   % take point within r
            l3 = l <= ra;
            b = a.subset(l3);      % new data per grid point (b) is sorted in distanc
            rd = ra;
        else
            % TOFIX crash if ni < #selected earthquakes
            % take first ni points
            b = b(1:ni,:);      % new data per grid point (b) is sorted in distance
            l2 = sort(l); rd = l2(ni);

        end


        %estimate the completeness and b-value
        newt2 = b;
        num_atnode = length(newt2);
        if length(b) >= Nmin  % enough events?

            if inb1 == 3
                mcperc_ca3;  l = b.Magnitude >= Mc90-0.05; magco = Mc90;
                if length(b(l,:)) >= Nmin
                    [bv magco0 stan av me mer me2,  pr] =  bvalca3(b(l,:),2,2);
                    [magnm bv2 stan2,  av2] =  bmemag(b(l,:));
                    maxcat = b(l,:);
                    maxmg = max(maxcat(:,6));
                    [pv pstd cv cstd kv kstd mmav,  mbv] = mypval2m(b(l,:));
                else
                    [bv, bv2, magco, av, av2, stan2, stan, pv, pstd, maxmg, prf, pr, cv, cstd, kv, mmav, mbv, kstd] = deal(nan);
                end

            elseif inb1 == 4
                mcperc_ca3;  l = b.Magnitude >= Mc95-0.05; magco = Mc95;
                if length(b(l,:)) >= Nmin
                    [bv magco0 stan av me mer me2,  pr] =  bvalca3(b(l,:),2,2);
                    [magnm bv2 stan2,  av2] =  bmemag(b(l,:));
                    maxcat = b(l,:);
                    maxmg = max(maxcat(:,6));
                    [pv pstd cv cstd kv kstd mmav,  mbv] = mypval2m(b(l,:));
                else
                    [bv, bv2, magco, av, av2, stan2, stan, pv, pstd, maxmg, prf, pr, cv, cstd, kv, mmav, mbv, kstd] = deal(nan);
                end
            elseif inb1 == 5
                mcperc_ca3;
                if isnan(Mc95) == 0 
                    magco = Mc95;
                elseif isnan(Mc90) == 0 
                    magco = Mc90;
                else
                    [bv magco stan av me mer me2,  pr] =  bvalca3(b,1,1);
                end
                l = b.Magnitude >= magco-0.05;
                if length(b(l,:)) >= Nmin
                    [bv magco0 stan av me mer me2,  pr] =  bvalca3(b(l,:),2,2);
                    maxcat = b(l,:);
                    maxmg = max(maxcat(:,6));
                    [magnm bv2 stan2,  av2] =  bmemag(b(l,:));
                    [pv pstd cv cstd kv kstd mmav,  mbv] = mypval2m(b(l,:));
                else
                    [bv, bv2, magco, av, av2, stan2, stan, pv, pstd, maxmg, prf, pr, cv, cstd, kv, mmav, mbv, kstd] = deal(nan);
                end

            elseif inb1 == 1
                [bv magco stan av me mer me2,  pr] =  bvalca3(b,1,1);
                l = b.Magnitude >= magco-0.05;
                if length(b(l,:)) >= Nmin
                    [magnm bv2 stan2,  av2] =  bmemag(b(l,:));
                    maxcat = b(l,:);
                    maxmg = max(maxcat(:,6));
                    [pv pstd cv cstd kv kstd mmav,  mbv] = mypval2m(b(l,:));
                else
                    [bv, bv2, magco, av, av2, stan2, stan, pv, pstd, maxmg, prf, pr, cv, cstd, kv, mmav, mbv, kstd] = deal(nan);
                    
                end

            elseif inb1 == 2
                [bv magco stan av me mer me2,  pr] =  bvalca3(b,2,2);
                [magnm bv2 stan2,  av2] =  bmemag(b);
                maxcat = b(l,:);
                maxmg = max(maxcat(:,6));
                [pv pstd cv cstd kv kstd mmav,  mbv] = mypval2m(b(l,:));
            end

        else
            [bv, bv2, magco, av, av2, stan2, stan, pv, pstd, maxmg, prf, pr, cv, cstd, kv, mmav, mbv, kstd] = deal(nan);
        end

        bpvg = [bpvg ; bv magco x y rd bv2 stan2 av stan prf pv pstd maxmg cv tgl1 mmav kv mbv num_atnode];
        %bpvg = [bpvg ; bv magco x y rd bv2 stan2 av stan prf pv pstd maxmg pr];

        waitbar(allcount/itotal)
    end  % for newgr
    %save cnssgrid.mat
    %quit
    % save data
    %
    catSave3 =...
        [ 'zmap_message_center.set_info(''Save Grid'',''  '');think;',...
        '[file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.data_dir, ''*.mat''), ''Grid Datafile Name?'') ;',...
        ' sapa2 = [''save '' path1 file1 '' bpvg gx gy dx dy par1 tdiff t0b teb a main faults mainfault coastline yvect xvect tmpgri ll bo1 newgri gll''];',...
        ' if length(file1) > 1, eval(sapa2),end , done']; eval(catSave3)

    close(wai)
    watchoff

    % plot the results
    % old and re3 (initially ) is the b-value matrix
    %
    normlap2=ones(length(tmpgri(:,1)),1)*nan;
    normlap2(ll)= bpvg(:,1);
    re3=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bpvg(:,5);
    r=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bpvg(:,6);
    meg=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bpvg(:,2);
    old1=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bpvg(:,7);
    pro=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bpvg(:,8);
    avm=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bpvg(:,9);
    stanm=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bpvg(:,10);
    Prmap=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bpvg(:,11);
    pvalg=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bpvg(:,12);
    pvstd=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bpvg(:,13);
    maxm=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bpvg(:,14);
    cmap2=reshape(normlap2,length(yvect),length(xvect));


    old = re3;

    re3 = pvalg;
    lab1 = 'p-value';

    % View the b-value and p-value map
    view_bpva

end   % if sel = na

% Load exist b-grid
if sel == 'lo'
    [file1,path1] = uigetfile(['*.mat'],'b-value gridfile');
    if length(path1) > 1
        think
        load([path1 file1])
        normlap2=ones(length(tmpgri(:,1)),1)*nan;
        normlap2(ll)= bpvg(:,1);
        re3=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bpvg(:,5);
        r=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bpvg(:,6);
        meg=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bpvg(:,2);
        old1=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bpvg(:,7);
        pro=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bpvg(:,8);
        avm=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bpvg(:,9);
        stanm=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bpvg(:,10);
        Prmap=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bpvg(:,11);
        pvalg=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bpvg(:,12);
        pvstd=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bpvg(:,13);
        maxm=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bpvg(:,14);
        cmap2=reshape(normlap2,length(yvect),length(xvect));

        old = re3;

        view_bpva
    else
        return
    end
end
