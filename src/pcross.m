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

    def = {'30'};
    ni2 = inputdlg('Time length considered in days?','Input',1,def);
    l = ni2{:};
    tlen = str2double(l);


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

    freq_field2=uicontrol('Style','edit',...
        'Position',[.60 .40 .22 .10],...
        'Units','normalized','String',num2str(dx),...
        'Callback','dx=str2double(get(freq_field2,''String'')); set(freq_field2,''String'',num2str(dx));');

    freq_field3=uicontrol('Style','edit',...
        'Position',[.60 .30 .22 .10],...
        'Units','normalized','String',num2str(dd),...
        'Callback','dd=str2double(get(freq_field3,''String'')); set(freq_field3,''String'',num2str(dd));');

    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.60 .05 .15 .12 ],...
        'Units','normalized','Callback','close;done','String','Cancel');

    go_button1=uicontrol('Style','Pushbutton',...
        'Position',[.20 .05 .15 .12 ],...
        'Units','normalized',...
        'Callback','close,sel =''ca''; pcross',...
        'String','Go');


    txt3 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.30 0.65 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.l ,...
        'FontWeight','bold',...
        'String',' Grid Parameter');
    txt5 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.42 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing along projection [km]');

    txt6 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.32 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in depth in km:');

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

    figure_w_normalized_uicontrolunits(xsec_fig)
    hold on

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


    plos2 = plot(x,y,'b-','era','xor');        % plot outline
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

    ll = polygon_filter(x,y, XI, YI, 'inside');
    %grid points in polygon
    newgri=tmpgri(ll,:);

    % Plot all grid points
    plot(newgri(:,1),newgri(:,2),'+k')

    if length(xvect) < 2  ||  length(yvect) < 2
        errordlg('Selection too small! (not a matrix)');
        return
    end

    itotal = length(newgri(:,1));

    zmap_message_center.set_info(' ','Running... ');think
    %  make grid, calculate start- endtime etc.  ...
    %
    t0b = min(newa.Date)  ;
    n = newa.Count;
    teb = newa(n,3) ;
    tdiff = round((teb - t0b)*365/par1);
    loc = zeros(3, length(gx)*length(gy));

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
    M = max(newt2.Magnitude) - 5.;

    %
    for i= 1:length(newgri(:,1))
        x = newgri(i,1);y = newgri(i,2);
        allcount = allcount + 1.;
        i2 = i2+1;

        % calculate distance from center point and sort wrt distance
        l = sqrt(((xsecx' - x)).^2 + ((xsecy + y)).^2) ;
        [s,is] = sort(l);
        b = newa(is(:,1),:) ;       % re-orders matrix to agree row-wise

        % take first ni points
        b = b(1:ni,:);      % new data per grid point (b) is sorted in distance
        l2 = sort(l); di = l2(ni);

        [st,ist] = sort(b);   % re-sort wrt time for cumulative count
        b = b(ist(:,3),:);

        % call the p-value function
        % first find out what magco is
        l = b.Date > mati + 3/365;
        %[bv magco stan av me mer me2,  pr] =  bvalca3(b(l,:),1,1);
        %l = b.Magnitude > magco+0.1;
        newt2 = b;
        tmin1 =0.05;

        calcp
        load aspar3.out
        re = aspar3;

        bvg = [bvg ; re(1,2) re(1,4) x y re(2,2) re(2,4) bv 0 di];
        waitbar(allcount/itotal)
    end  % for  newgri

    % save data
    %
    %  set(txt1,'String', 'Saving data...')
    drawnow
    gx = xvect;gy = yvect;

    %   catSave3 =...
    % [ 'zmap_message_center.set_info(''Save Grid'',''  '');think;',...
    %  '[file1,path1] = uiputfile(fullfile(hodi, ''eq_data'', ''*.mat''), ''Grid Datafile Name?'') ;',...
    %  ' sapa2 = [''save '' path1 file1 '' ll tmpgri bvg xvect yvect gx gy dx dd par1 ni newa maex maey maix maiy ''];',...
    %  ' if length(file1) > 1, eval(sapa2),end , done']; eval(catSave3)

    close(wai)
    watchoff

    % reshape a few matrices
    %
    normlap2=ones(length(tmpgri(:,1)),1)*nan;
    normlap2(ll)= bvg(:,1);
    re3=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,2);
    dp =reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,6);
    db =reshape(normlap2,length(yvect),length(xvect));


    normlap2(ll)= bvg(:,9);
    r =reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,5);
    bv=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,7);
    bv2=reshape(normlap2,length(yvect),length(xvect));


    normlap2(ll)= bvg(:,8);
    pmap =reshape(normlap2,length(yvect),length(xvect));


    normlap2(ll)= bvg(:,1);
    Pv=reshape(normlap2,length(yvect),length(xvect));

    old = re3;

    % View the b-value map
    view_pv2

end   %  if sel = ca

% Load exist b-grid
if sel == 'lo'
    load_existing_bgrid_version_A
end

