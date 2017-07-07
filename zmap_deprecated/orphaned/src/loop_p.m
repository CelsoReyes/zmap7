% tHis subroutine assigns creates a grid with
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
    dd = 1.00;
    dx = 1.00 ;
    ni = 500;

    def = {num2str(maepi(1,3))};
    ni2 = inputdlg('Input Time of Mainshock ?','Input',1,def);
    l = ni2{:};
    mati = str2double(l);

    % make the interface
    %
    figure_w_normalized_uicontrolunits(...
        'Name','Grid Input Parameter',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'units','points',...
        'Visible','off', ...
        'Position',[ wex+200 wey-200 550 300]);
    axis off

    %
    freq_field=uicontrol('Style','edit',...
        'Position',[.60 .50 .22 .10],...
        'Units','normalized','String',num2str(ni),...
        'Callback','ni=str2double(get(freq_field,''String'')); set(freq_field,''String'',num2str(ni));');


    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.60 .05 .15 .12 ],...
        'Units','normalized','Callback','close;done','String','Cancel');

    go_button1=uicontrol('Style','Pushbutton',...
        'Position',[.20 .05 .15 .12 ],...
        'Units','normalized',...
        'Callback','close,sel =''ca''; loop_p',...
        'String','Go');


    txt3 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.30 0.65 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.l ,...
        'FontWeight','bold',...
        'String',' Grid Parameter');
    txt1 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.53 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m,...
        'FontWeight','bold',...
        'String','Number of Events (Ni):');
    
    set(gcf,'visible','on');
    watchoff

end   % if sel == in

% get the grid-size interactively and
% calculate the b-value in the grid by sorting
% thge seimicity and selectiong the ni neighbors
% to each grid point

if sel == 'ca'


    x = [];
    y = [];

    itotal = length(newgri(:,1));

    zmap_message_center.set_info(' ','Running... ');think
    %  make grid, calculate start- endtime etc.  ...
    %
    t0b = min(a.Date)  ;
    n = a.Count;
    teb = a(n,3) ;
    tdiff = round((teb - t0b)*365/par1);

    % loop over  all points
    %
    i2 = 0.;
    i1 = 0.;
    bvg = [];
    allcount = 0.;
    wai = waitbar(0,' Please Wait ...  ');
    set(wai,'NumberTitle','off','Name','p-value grid - percent done');;
    drawnow
    %
    % loop
    dm = 0.1;
    dt = 0.01;

    %
    for i= 1:length(newgri(:,1))
        x = newgri(i,2);
        y =  newgri(i,1);
        z = newgri(i,3);
        allcount = allcount + 1.;
        i2 = i2+1;

        % calculate distance from center point and sort wrt distance
        l = sqrt(((a.Longitude-x)*cos(pi/180*y)*111).^2 + ((a.Latitude-y)*111).^2 + ((a.Depth - z)).^2 ) ;
        [s,is] = sort(l);
        b = a(is(:,1),:) ;       % re-orders matrix to agree row-wise

        % take first ni points
        b = b(1:ni,:);      % new data per grid point (b)
        l2 = sort(l); di = l2(ni);

        [st,ist] = sort(b);   % re-sort wrt time for cumulative count
        b = b(ist(:,3),:);

        % call the p-value function
        % first find out what magco is
        l = b(:,3) > mati + 3/365;
        [bv magco stan av me mer me2,  pr] =  bvalca3(b(l,:),1,1);
        %l = b(:,6) > magco+0.1;
        newt2 = b;
        tmin1 = 0.01;

        save_aspar2;
        do = [ ' ! '  hodi '/aspar/myaspar' ];
        eval(do)

        load aspar3.out
        re = aspar3;

        bvg = [bvg ; re(1,2) re(1,4) x y re(2,2) re(2,4) bv magco di z ];
        waitbar(allcount/itotal)
    end  % for  newgri

    % save data
    %
    %  set(txt1,'String', 'Saving data...')
    drawnow
    r =reshape(normlap2,length(yvect),length(xvect));

end   %  if sel = ca

plot(bvg(:,7),newgri(:,4),'ok')


