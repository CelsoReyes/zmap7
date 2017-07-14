% This subroutine assigns creates a grid with
% spacing dx,dy (in degreees). The size will
% be selected interactiVELY. The bvalue in each
% volume around a grid point containing ni earthquakes
% will be calculated as well as the magnitude
% of completness
%   Stefan Wiemer 1/95

report_this_filefun(mfilename('fullpath'));

global maex maey maix maiy


if sel == 'in'
    % get the grid parameter
    % initial values
    %
    dd = 1.00;
    dx = 1.00 ;
    ni = 100;

    % make the interface
    %
    figure_w_normalized_uicontrolunits(...
        'Name','Grid Input Parameter',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','new', ...
        'units','points',...
        'Visible','off', ...
        'Position',[ ZG.wex+200 ZG.wey-200 600 250]);
    axis off

    % creates a dialog box to input grid parameters
    %
    freq_field=uicontrol('Style','edit',...
        'Position',[.30 .50 .12 .10],...
        'Units','normalized','String',num2str(ni),...
        'Callback','ni=str2double(freq_field.String); freq_field.String=num2str(ni);tgl2.Value=0; tgl1.Value=1;');


    freq_field0=uicontrol('Style','edit',...
        'Position',[.70 .50 .12 .10],...
        'Units','normalized','String',num2str(ra),...
        'Callback','ra=str2double(freq_field0.String); freq_field0.String=num2str(ra); tgl2.Value=1; tgl1.Value=0;');

    tgl1 = uicontrol('Style','checkbox',...
        'string','Number of Events:',...
        'Position',[.05 .50 .2 .10], 'Callback','tgl2.Value=0;',...
        'Units','normalized');

    set(tgl1,'value',1);

    tgl2 =  uicontrol('Style','checkbox',...
        'string','OR: Constant Radius',...
        'Position',[.47 .50 .2 .10], 'Callback','tgl1.Value=0;',...
        'Units','normalized');



    % freq_field=uicontrol('Style','edit',...
    %         'Position',[.60 .50 .22 .10],...
    %        'Units','normalized','String',num2str(ni),...
    %        'Callback','ni=str2double(freq_field.String); freq_field.String=num2str(ni);');

    freq_field2=uicontrol('Style','edit',...
        'Position',[.60 .40 .22 .10],...
        'Units','normalized','String',num2str(dd),...
        'Callback','dd=str2double(freq_field2.String); freq_field2.String=num2str(dd);');

    freq_field3=uicontrol('Style','edit',...
        'Position',[.60 .30 .22 .10],...
        'Units','normalized','String',num2str(dx),...
        'Callback','dx=str2double(freq_field3.String); freq_field3.String=num2str(dx);');

    freq_field6B=uicontrol('Style','edit',...
        'Position',[.60 .20 .22 .10],...
        'Units','normalized','String',num2str(par1),...
        'Callback','par1=str2double(freq_field6B.String);');

    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.60 .05 .15 .12 ],...
        'Units','normalized','Callback','close;done','String','Cancel');

    go_button1=uicontrol('Style','Pushbutton',...
        'Position',[.20 .05 .15 .12 ],...
        'Units','normalized',...
        'Callback','tgl1=tgl1.Value;tgl2=tgl2.Value;close,sel =''ca'', magrcros',...
        'String','Go');

    text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.20 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Time steps in days:');


    txt3 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.30 0.84 0 ],...
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
        'String','Spacing along strike in km');

    txt6 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.32 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in depth in km:');

    
    set(gcf,'visible','on');
    watchoff

end   % sel = in

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

    hold on
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
    plot(newgri(:,1),newgri(:,2),'+k','era','back')

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
    teb = newa.Date(n) ;
    tdiff = round(days(teb-t0b)/par1);
    cumu = zeros(length(t0b:days(par1):teb)+2);
    ncu = length(cumu);
    cumuall = zeros(ncu,length(newgri(:,1)))*nan;
    loc = zeros(3,length(newgri(:,1)));

    % loop over  all points
    %
    i2 = 0.;
    i1 = 0.;
    bvg = [];
    allcount = 0.;
    wai = waitbar(0,' Please Wait ...  ');
    set(wai,'NumberTitle','off','Name',' grid - percent done');;
    drawnow
    %
    % longitude  loop
    %
    for i= 1:length(newgri(:,1))
        x = newgri(i,1);y = newgri(i,2);
        allcount = allcount + 1.;
        % calculate distance from center point and sort wrt distance
        l = sqrt(((xsecx' - x)).^2 + ((xsecy + y)).^2) ;

        if tgl1 == 0   % take point within r
            l3 = l <= ra;
            b = newa.subset(l3);      % new data per grid point (b) is sorted in distanc
            rd = b.Count;
        else
            % take first ni points
            [s,is] = sort(l);
            b = newa(is(:,1),:) ;       % re-orders matrix to agree row-wise
            b = b(1:ni,:);      % new data per grid point (b) is sorted in distance
            l2 = sort(l); rd = l2(ni);
        end
        if isempty(b) == 0
            if b.Count > 4
                [st,ist] = sort(b);   % re-sort wrt time for cumulative count
                b = b(ist(:,3),:);
                cumu = cumu * 0;
                % time (bin) calculation
                n = b.Count;
                cumu = histogram(b(1:n,3),t0b:days(par1):teb);
                l = sort(l);
                cumuall(:,allcount) = [cumu';  x; rd];
                loc(:,allcount) = [x ; y; rd];
                waitbar(allcount/itotal)
            end
        end
    end  % for newgr

    % save  bvalgrid.mat bvg gx gy ni dx dy

    catSave3 =...
        [ 'zmap_message_center.set_info(''Save Grid'',''  '');think;',...
        '[file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.data_dir, ''*.mat''), ''Grid Datafile Name?'');',...
        ' sapa2 = [''save '' path1 file1 '' cumuall pos gx gy ni dx dy par1 newa maex maix maey maiy tmpgri ll newgri xvect yvect ''];',...
        ' if length(file1) > 1, eval(sapa2),end , done']; eval(catSave3)
    %corrected window positioning error
    close(wai)
    watchoff

    % Plot the results
    %

    det = 'nop'
    in2 = 'nocal'
    menucros
end   % if sel = ca

% Load exist z-grid
if sel == 'lo'
    [file1,path1] = uigetfile(['*.mat'],'z-value gridfile');
    if length(path1) > 1
        think
        load([path1 file1])
        det = 'nop'
        in2 = 'nocal'
        menucros
    else
        return
    end
end

