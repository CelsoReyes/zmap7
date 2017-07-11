% This subroutine compares seismicity rates
% for two time periods. The differences are
% displayed as z- and beta-values and as
% percent change.
%   Stefan Wiemer 1/95
%   Rev. R.Z. 4/2001

global no1 bo1 inb1 inb2

report_this_filefun(mfilename('fullpath'));

if sel == 'in'
    % get the grid parameter
    % initial values
    %
    dx = 1.00;
    dy = 1.00 ;
    ra = 5 ;

    t1 = t0b;
    t4 = teb;
    t2 = t0b + (teb-t0b)/2;
    t3 = t2+0.01;


    def = {num2str(t1),num2str(t2),num2str(t3),num2str(t4), '50'}
    tit ='Please define the two periods';
    prompt={'T1 = ', 'T2= ', 'T3 = ', 'T4= '};

    ni2 = inputdlg(prompt,tit,1,def);

    l = ni2{4};
    t4 = str2double(l);
    l = ni2{3};
    t3 = str2double(l);
    l = ni2{2};
    t2 = str2double(l);
    l = ni2{1};
    t1 = str2double(l);


    % make the interface
    %
    figure_w_normalized_uicontrolunits(...
        'Name','Grid Input Parameter',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','new', ...
        'units','points',...
        'Visible','off', ...
        'Position',[ wex+100 wey-100 620 300]);
    axis off





    % creates a dialog box to input grid parameters
    %


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

    tgl1 = uicontrol('Style','radiobutton',...
        'string','Number of Events:',...
        'Position',[.05 .60 .2 .0800], 'Callback','set(tgl2,''value'',0)',...
        'Units','normalized');

    set(tgl1,'value',1);

    tgl2 =  uicontrol('Style','radiobutton',...
        'string','OR: Constant Radius',...
        'Position',[.05 .50 .2 .080], 'Callback','set(tgl1,''value'',0)',...
        'Units','normalized');

    create_grid =  uicontrol('Style','radiobutton',...
        'string','Calculate a new grid', 'Callback','set(load_grid,''value'',0), set(prev_grid,''value'',0)','Position',[.55 .55 .2 .080],...
        'Units','normalized');

    set(create_grid,'value',1);

    prev_grid =  uicontrol('Style','radiobutton',...
        'string','Reuse the previous grid', 'Callback','set(load_grid,''value'',0),set(create_grid,''value'',0)','Position',[.55 .45 .2 .080],...
        'Units','normalized');


    load_grid =  uicontrol('Style','radiobutton',...
        'string','Load a previously saved grid', 'Callback','set(prev_grid,''value'',0),set(create_grid,''value'',0)','Position',[.55 .35 .2 .080],...
        'Units','normalized');

    save_grid =  uicontrol('Style','checkbox',...
        'string','Save selected grid to file',...
        'Position',[.55 .22 .2 .080],...
        'Units','normalized');

    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.60 .05 .15 .12 ],...
        'Units','normalized','Callback','close;done','String','Cancel');

    go_button1=uicontrol('Style','Pushbutton',...
        'Position',[.20 .05 .15 .12 ],...
        'Units','normalized',...
        'Callback',' tgl1 =get(tgl1,''Value'');tgl2 =get(tgl2,''Value'');prev_grid = get(prev_grid,''Value'');create_grid = get(create_grid,''Value''); load_grid = get(load_grid,''Value''); save_grid = get(save_grid,''Value''); close,sel =''ca'',comp2periodz',...
        'String','Go');

    text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.10 0.98 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Please choose rate change estimation option   ');
    txt3 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.30 0.75 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String',' Grid Parameter');
    txt5 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[-0.1 0.4 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.s ,...
        'FontWeight','bold',...
        'String','Spacing in x (dx) in deg:');

    txt6 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[-0.1 0.3 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.s ,...
        'FontWeight','bold',...
        'String','Spacing in y (dy) in deg:');



    set(gcf,'visible','on');
    watchoff

end   % if nargin ==0

% get the grid-size interactively and
% calculate the b-value in the grid by sorting
% thge seimicity and selectiong the ni neighbors
% to each grid point

if sel == 'ca'
    do = ['close(wai)'] ; err = [' ']; eval(do,err);

    %get new grid if needed
    if load_grid == 1
        [file1,path1] = uigetfile(['*.mat'],'previously saved grid');
        if length(path1) > 1
            think
            load([path1 file1])
            plot(newgri(:,1),newgri(:,2),'k+')
        end
    elseif load_grid ==0  &&  prev_grid == 0
        selgp
        if length(gx) < 4  ||  length(gy) < 4
            errordlg('Selection too small! (Dx and Dy are in degreees! ');
            return
        end
    end


    if save_grid == 1
        grid_save =...
            [ 'zmap_message_center.set_info(''Saving Grid'',''  '');think;',...
            '[file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.data_dir,''*.mat''), ''Grid File Name?'') ;',...
            ' gs = [''save '' path1 file1 '' newgri dx dy gx gy xvect yvect tmpgri ll''];',...
            ' if length(file1) > 1, eval(gs),end , done']; eval(grid_save)
    end

    itotal = length(newgri(:,1));
    zmap_message_center.set_info(' ','Running... ');think
    %  make grid, calculate start- endtime etc.  ...
    %
    t0b = min(ZG.a.Date)  ;
    n = ZG.a.Count;
    teb = a(n,3) ;
    tdiff = round((teb - t0b)*365/par1);
    loc = zeros(3, length(gx)*length(gy));

    % loop over  all points
    %
    i2 = 0.;
    i1 = 0.;
    bvg = [];
    allcount = 0.;
    wai = waitbar(0,' Please Wait ...  ');
    set(wai,'NumberTitle','off','Name','rate grid - percent done');;
    drawnow
    %
    bvg = zeros(length(newgri(:,1)),4)*nan;
    lt =  ZG.a.Date >= t1 &  ZG.a.Date < t2  | ZG.a.Date >= t3 &  ZG.a.Date <= t4;
    aa = ZG.a.subset(lt);

    % loop over all points
    for i= 1:length(newgri(:,1))
        x = newgri(i,1);y = newgri(i,2);
        allcount = allcount + 1.;
        i2 = i2+1;
        % calculate distance from center point and sort wrt distance
        l = sqrt(((aa(:,1)-x)*cosd(y)*111).^2 + ((aa(:,2)-y)*111).^2 ) ;
        [s,is] = sort(l);
        b = aa(is(:,1),:) ;       % re-orders matrix to agree row-wise

        if tgl1 == 0   % take point within r
            l3 = l <= ra;
            b = b(l3,:);      % new data per grid point (b) is sorted in distanc
            rd = ra;
        else
            % take first ni points
            b = b(1:ni,:);      % new data per grid point (b) is sorted in distance
            l2 = sort(l); rd = l2(ni);

        end
        [s,is] = sort(b.Date);
        b = b(is(:,1),:) ;

        lt =  b.Date >= t1 &  b.Date < t2 ;
        tback = b(lt,:);
        [cumu1, xt1] = hist(tback(:,3),(t1:par1/365:t2));

        lt =  b.Date >= t3 &  b.Date <= t4 ;
        tafter = b(lt,:);
        [cumu2, xt2] = hist(tafter(:,3),(t3:par1/365:t4));

        mean1 = mean(cumu1);        % mean seismicity rate in first interval
        mean2 = mean(cumu2);        % mean seismicity rate in second interval
        sum1 = sum(cumu1);          % number of earthquakes in the first interval
        sum2 = sum(cumu2);          % number of earthquakes in the second interval
        var1 = cov(cumu1);          % variance of cumu1
        var2 = cov(cumu2);          % variance of cumu2
        % remark (db): cov and var calculate the same value when applied to a vector
        ncu1 = length(xt1);         % number of bins in first interval
        ncu2 = length(xt2);         % number of bins in second interval

        as = (mean1 - mean2)/(sqrt(var1/ncu1 +var2/ncu2));
        per = -((mean1-mean2)./mean1)*100;

        % beta nach reasenberg & simpson 1992, time of second interval normalised by time of first interval
        bet = (sum2-sum1*ncu2/ncu1)/sqrt(sum1*(ncu2/ncu1));

        bvg(allcount,:) = [as  per rd bet ];
        waitbar(allcount/itotal)
    end  % for newgr

    % save data
    %
    close(wai)
    watchoff

    % plot the results
    % old and re3 (initially ) is the z-value matrix
    %
    normlap2=ones(length(tmpgri(:,1)),1)*nan;
    normlap2(ll)= bvg(:,1);
    re3=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,2);
    per=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,3);
    reso=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,4);
    beta_map=reshape(normlap2,length(yvect),length(xvect));



    old = re3;
    det =  'ast'; sha = 'in';
    % View the b-value map
    storedcat=a;
    ZG.a=aa;
    view_ratecomp

end   % if sel = ca
