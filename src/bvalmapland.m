% This subroutine assigns creates a grid with
% spacing dx,dy (in degreees). The size will
% be selected interactiVELY. The bvalue in each
% volume around a grid point containing ni earthquakes
% will be calculated as well as the magnitude
% of completness
%   Stefan Wiemer 1/95

report_this_filefun(mfilename('fullpath'));

global no1 bo1 inb1 inb2

if sel == 'in'
    % get the grid parameter
    % initial values
    %
    dx = 1.00;
    dy = 1.00 ;
    dd= 1;
    Nmin = 50;
    ra = 5 ;


    t1 = t0b;
    t4 = teb;
    t2 = t0b + (teb-t0b)/2;
    t3 = t2+0.01;


    def = {num2str(t1),num2str(t2),num2str(t3),num2str(t4), '50'}
    tit ='differntial b-value map ';
    prompt={'T1 = ', 'T2= ', 'T3 = ', 'T4= ', 'Min # of events in each period?'};

    ni2 = inputdlg(prompt,tit,1,def);
    l = ni2{5};
    minnu = str2double(l);
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
        'Visible','on', ...
        'Position',[ wex+200 wey-200 550 350]);
    axis off
    labelList2=[' Automatic Mcomp (max curvature) | Fixed Mc (Mc = Mmin) | Automatic Mcomp (90% probability) | Automatic Mcomp (95% probability) | Best (?) combination (Mc95 - Mc90 - max curvature)'];
    labelPos = [0.2 0.77  0.6  0.08];
    hndl2=uicontrol(...
        'Style','popup',...
        'Position',labelPos,...
        'Units','normalized',...
        'String',labelList2,...
        'Callback','inb2 =get(hndl2,''Value''); ');

    set(hndl2,'value',5);


    % creates a dialog box to input grid parameters
    %
    freq_field=uicontrol('Style','edit',...
        'Position',[.30 .50 .12 .10],...
        'Units','normalized','String',num2str(ni),...
        'Callback','ni=str2double(get(freq_field,''String'')); set(freq_field,''String'',num2str(ni));set(tgl2,''value'',0); set(tgl1,''value'',1)');


    freq_field0=uicontrol('Style','edit',...
        'Position',[.70 .50 .12 .10],...
        'Units','normalized','String',num2str(ra),...
        'Callback','ra=str2double(get(freq_field0,''String'')); set(freq_field0,''String'',num2str(ra)) ; set(tgl2,''value'',1); set(tgl1,''value'',0)');

    freq_field2=uicontrol('Style','edit',...
        'Position',[.30 .40 .12 .10],...
        'Units','normalized','String',num2str(dx),...
        'Callback','dx=str2double(get(freq_field2,''String'')); set(freq_field2,''String'',num2str(dx));');

    freq_field3=uicontrol('Style','edit',...
        'Position',[.30 .30 .12 .10],...
        'Units','normalized','String',num2str(dy),...
        'Callback','dy=str2double(get(freq_field3,''String'')); set(freq_field3,''String'',num2str(dy));');

    tgl1 = uicontrol('Style','checkbox',...
        'string','Number of Events:',...
        'Position',[.05 .50 .2 .10], 'Callback','set(tgl2,''value'',0)',...
        'Units','normalized');

    set(tgl1,'value',1);

    tgl2 =  uicontrol('Style','checkbox',...
        'string','OR: Constant Radius',...
        'Position',[.47 .50 .2 .10], 'Callback','set(tgl1,''value'',0)',...
        'Units','normalized');


    freq_field5 = uicontrol('Style','edit',...
        'Position',[.30 .20 .12 .10],...
        'Units','normalized','String',num2str(Nmin),...
        'Callback','Nmin=str2double(get(freq_field5,''String'')); set(freq_field5,''String'',num2str(Nmin));');

    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.50 .05 .15 .12 ],...
        'Units','normalized','Callback','close;done','String','Cancel');

    help_button=uicontrol('Style','Pushbutton',...
        'Position',[.70 .05 .15 .12 ],...
        'Units','normalized','Callback','close;done','String','Help');


    go_button1=uicontrol('Style','Pushbutton',...
        'Position',[.20 .05 .15 .12 ],...
        'Units','normalized',...
        'Callback','inb1 =get(hndl2,''Value'');tgl1 =get(tgl1,''Value'');tgl2 =get(tgl2,''Value'');close,sel =''ca'', bvalmapland',...
        'String','Go');

    text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.20 1.0 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.l ,...
        'FontWeight','bold',...
        'String','Please choose and Mc estimation option ');

    txt3 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.30 0.67 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.l ,...
        'FontWeight','bold',...
        'String',' Grid Parameter');
    txt5 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[-0.1 0.42 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.m ,...
        'FontWeight','bold',...
        'String','Lon Spacing [deg]');

    txt6 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[-0.1 0.32 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.m ,...
        'FontWeight','bold',...
        'String','Lat spacing [deg]:');

    txt1 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[-0.1 0.2 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.m,...
        'FontWeight','bold',...
        'String','Min No. of events:');

end   % if nargin ==0

% get the grid-size interactively and
% calculate the b-value in the grid by sorting
% thge seimicity and selectiong the ni neighbors
% to each grid point

if sel == 'ca'
    try
        close(wai);
    catch ME
        error_handler(ME,@do_nothing);
    end
    selgp
    itotal = length(newgri(:,1));
    zmap_message_center.set_info(' ','Running... ');think
    %  make grid, calculate start- endtime etc.  ...
    %
    t0b = a(1,3)  ;
    n = a.Count;
    teb = a(n,3) ;
    tdiff = round((teb - t0b)*365/par1);
    loc = zeros(3,length(gx)*length(gy));

    % loop over  all points
    %
    i2 = 0.;
    i1 = 0.;
    bvg = [];
    allcount = 0.;
    wai = waitbar(0,' Please Wait ...  ');
    set(wai,'NumberTitle','off','Name','b-value grid - percent done');;
    drawnow
    %
    % overall b-value
    [bv magco stan av me mer me2,  pr] =  bvalca3(a,inb1,inb2);
    bo1 = bv; no1 = a.Count;
    magco1 = nan; magco2 = nan;

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
            % take first ni points
            b = b(1:ni,:);      % new data per grid point (b) is sorted in distance
            l2 = sort(l); rd = l2(ni);
        end



        % call the b-value function
        lt =  b(:,3) >= t1 &  b(:,3) <t2 ;
        if  length(b(lt,1)) >= Nmin;
            mcperc_ca3;
            if isnan(Mc95) == 0 
                magco = Mc95;
            elseif isnan(Mc90) == 0 
                magco = Mc90;
            else
                [bv magco stan av me mer me2,  pr] =  bvalca3(b,1,1);
            end
            l = b(:,6) >= magco-0.05;
            if length(b(l,:)) >= Nmin
                [bvb magco0 stan av me mer me2,  pr] =  bvalca3(b(l,:),2,2);
                [av2 bvb2 stan2 ] =  bmemag(b(l,:));
                P6b = 10^(av-bvb*5)/(t2-t1);
            else
                bvb = nan; bvb2 = nan, magco = nan; av = nan; av2 = nan; P6b = nan;
            end
        end


        % 2nd period
        lt =  b(:,3) >= t3 &  b(:,3) <= t4 ;

        if  length(b(lt,1)) >= Nmin;
            mcperc_ca3;
            if isnan(Mc95) == 0 
                magco = Mc95;
            elseif isnan(Mc90) == 0 
                magco = Mc90;
            else
                [bv magco stan av me mer me2,  pr] =  bvalca3(b,1,1);
            end
            l = b(:,6) >= magco-0.05;
            if length(b(l,:)) >= Nmin
                [bva magco0 stan av me mer me2,  pr] =  bvalca3(b(l,:),2,2);
                [av2 bva2 stan2 ] =  bmemag(b(l,:));
                P6a = 10^(av-bva2*5)/(t4-t3);
            else
                bva = nan; bva2 = nan, magco = nan; av = nan; av2 = nan; P6a = nan;
            end
        end


        l2 = sort(l);
        b2 = b;
        bvg = [bvg ; bvb magco1 x y length(b(:,1)) bva P6b av P6a  magco1-magco2  bva-bvb  magco2 P6a/P6b];


        waitbar(allcount/itotal)
    end  % for newgr

    % save data
    %
    catSave3 =...
        [ 'zmap_message_center.set_info(''Save Grid'',''  '');think;',...
        '[file1,path1] = uiputfile(fullfile(hodi, ''eq_data'', ''*.mat''), ''Grid Datafile Name?'') ;',...
        ' sapa2 = [''save '' path1 file1 '' bvg gx gy dx dy par1 tdiff t0b teb a main faults mainfault coastline yvect xvect tmpgri ll''];',...
        ' if length(file1) > 1, eval(sapa2),end , done']; eval(catSave3)

    close(wai)
    watchoff

    % plot the results
    % old and re3 (initially ) is the b-value matrix
    %
    normlap2=ones(length(tmpgri(:,1)),1)*nan;
    normlap2(ll)= bvg(:,1);
    bm1=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,5);
    r=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,6);
    bm2=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,2);
    magco1=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,12);
    magco2=reshape(normlap2,length(yvect),length(xvect));

    dmag = magco1 - magco2;

    normlap2(ll)= bvg(:,7);
    pro=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,8);
    avm=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,9);
    stanm=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,13);
    maxm=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,11);
    db12=reshape(normlap2,length(yvect),length(xvect));

    re3 = db12;
    old = re3;

    % View the b-value map
    view_bvtmap

end   % if sel = na

% Load exist b-grid
if sel == 'lo'
    [file1,path1] = uigetfile(['*.mat'],'b-value gridfile');
    if length(path1) > 1
        think
        load([path1 file1])
        normlap2=ones(length(tmpgri(:,1)),1)*nan;
        normlap2(ll)= bvg(:,1);
        re3=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,5);
        r=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,6);
        meg=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,2);
        old1=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,7);
        pro=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,8);
        avm=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,9);
        stanm=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,10);
        maxm=reshape(normlap2,length(yvect),length(xvect));

        old = re3;

        view_bva
    else
        return
    end
end

