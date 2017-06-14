% This subroutine assigns creates a grid with
% spacing dx,dy (in degreees). The size will
% be selected interactiVELY. The bvalue in each
% volume around a grid point containing ni earthquakes
% will be calculated as well as the magnitude
% of completness
%   Stefan Wiemer 1/95

report_this_filefun(mfilename('fullpath'));

global no1 bo1

if sel == 'in'
    % get the grid parameter
    % initial values
    %
    dd = 1.00;
    dx = 1.00 ;
    ni = 100;
    ra = 5.

    % make the interface
    %
    figure_w_normalized_uicontrolunits(...
        'Name','Grid Input Parameter',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'units','points',...
        'Visible','off', ...
        'Position',[ wex+200 wey-200 450 250]);
    axis off

    % creates a dialog box to input grid parameters
    %
    freq_field=uicontrol('Style','edit',...
        'Position',[.60 .50 .22 .10],...
        'Units','normalized','String',num2str(ra),...
        'Callback','ra=str2double(get(freq_field,''String'')); set(freq_field,''String'',num2str(ra));');

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
        'Callback','close,sel =''ca'', bcrossV',...
        'String','Go');

    txt3 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.30 0.74 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.l ,...
        'FontWeight','bold',...
        'String',' Grid Parameter');
    txt5 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.42 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing along projection [km]');

    txt6 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.32 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in depth in km:');

    txt1 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.53 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.m,...
        'FontWeight','bold',...
        'String','Radius in km:');
    if term == 1 ; whitebg(gcf,[1 1 1 ]);end
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

    welcome('Select Polygon for a grid',messtext);

    hold on
    ax = findobj('Tag','main_map_ax');

    [x,y, mouse_points_overlay] = select_polygon(ax);
    welcome('Message',' Thank you .... ')

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

    welcome(' ','Running... ');think
    %  make grid, calculate start- endtime etc.  ...
    %
    t0b = newa(1,3)  ;
    n = length(newa(:,1));
    teb = newa(n,3) ;
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
    % loop


    % overall b-value
    [bv magco stan av me mer me2 rt,  pr] =  bvalca3(newa);

    bo1 = bv; no1 = length(newa(:,1));
    %
    for i= 1:length(newgri(:,1))
        x = newgri(i,1);y = newgri(i,2);
        allcount = allcount + 1.;
        i2 = i2+1;

        % calculate distance from center point and sort wrt distance
        l = sqrt(((xsecx' - x)).^2 + ((xsecy + y)).^2) ;
        %[s,is] = sort(l);
        %b = newa(is(:,1),:) ;       % re-orders matrix to agree row-wise

        % take first ni points
        l = l <= ra;
        b = newa(l,:);      % new data per grid point (b) is sorted in distance


        if isempty(b) == 1; b = newa(1,:); end
        if length(b(:,1)) >= 30;
            % call the b-value function
            [bv magco stan av me mer me2 rt,  pr] =  bvalca3(b);
            l = b(:,6) >= magco;
            %[av bv stan ] =  bmemag(b(l,:));
            %rt = (teb-t0b)/(10.^(av-bv*6));
            l = sort(l);
            bvg = [bvg ; bv magco x y length(b(:,1)) bv rt  pr av];
        else
            bvg = [bvg ; NaN NaN x y length(b(:,1)) NaN NaN  NaN NaN];
        end

        waitbar(allcount/itotal)
    end  % for  newgri

    % save data
    %
    %  set(txt1,'String', 'Saving data...')
    drawnow
    gx = xvect;gy = yvect;

    catSave3 =...
        [ 'welcome(''Save Grid'',''  '');think;',...
        '[file1,path1] = uiputfile(fullfile(hodi, ''eq_data'', ''*.mat''), ''Grid Datafile Name?'') ;',...
        ' sapa2 = [''save '' path1 file1 '' ll tmpgri bvg xvect yvect gx gy ni dx dd par1 ni newa maex maey maix maiy ''];',...
        ' if length(file1) > 1, eval(sapa2),end , done']; eval(catSave3)

    close(wai)
    watchoff

    % reshape a few matrices
    %
    normlap2=ones(length(tmpgri(:,1)),1)*nan;
    normlap2(ll)= bvg(:,1);
    re3=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,5);
    r=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,6);
    meg=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,7);
    ret=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,2);
    old1 =reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,8);
    pro=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,9);
    avm=reshape(normlap2,length(yvect),length(xvect));

    old = re3;

    % View the b-value map
    view_bv2

end   %  if sel = ca

% Load exist b-grid
if sel == 'lo'
    [file1,path1] = uigetfile(['*.mat'],'b-value gridfile');
    if length(path1) > 1
        think
        load([path1 file1])
        xsecx = newa(:,length(newa(1,:)))';
        xsecy = newa(:,7);
        xvect = gx; yvect = gy;
        tmpgri=zeros((length(xvect)*length(yvect)),2);
        normlap2=ones(length(tmpgri(:,1)),1)*nan;
        normlap2(ll)= bvg(:,1);
        re3=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,5);
        r=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,6);
        meg=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= bvg(:,2);
        ret=reshape(normlap2,length(yvect),length(xvect));

        if length(bvg(1,:)) > 7;
            normlap2(ll)= bvg(:,8);
            pro=reshape(normlap2,length(yvect),length(xvect));
        end

        old = re3;

        view_bv2
    else
        return
    end
end

