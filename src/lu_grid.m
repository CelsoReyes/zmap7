% This subroutine assigns creates a grid with
% spacing dx,dy (in degrees). The size will
% be selected interactively. The bvalue in each
% volume around a grid point containing ni earthquakes
% will be calculated as well as the magnitude
% of completness
%   Stefan Wiemer 1/95

% TODO delete this. I'm higly suspicious this plays a role in anything. Message2 was not fully defined -CGR
report_this_filefun(mfilename('fullpath'));

if sel == 'in'
    % get the grid parameter
    % initial values
    %
    dx = 1.00;
    dy = 1.00 ;
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
        'Position',[ wex+200 wey-200 450 250]);
    axis off

    % creates a dialog box to input grid parameters
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
        'Units','normalized','String',num2str(dy),...
        'Callback','dy=str2double(get(freq_field3,''String'')); set(freq_field3,''String'',num2str(dy));');

    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.60 .05 .15 .12 ],...
        'Units','normalized','Callback','close;done','String','Cancel');

    go_button1=uicontrol('Style','Pushbutton',...
        'Position',[.20 .05 .15 .12 ],...
        'Units','normalized',...
        'Callback','close,sel =''ca'', bvalgrid',...
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
        'String','Spacing in x (dx) in deg:');

    txt6 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.32 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in y (dy) in deg:');

    txt1 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.53 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.m,...
        'FontWeight','bold',...
        'String','Number of Events (Ni):');
    set(gcf,'visible','on');
    watchoff

end   % if nargin ==0

% get the grid-size interactively and
% calculate the b-value in the grid by sorting
% thge seimicity and selectiong the ni neighbors
% to each grid point

if sel == 'ca'
    message2 = ['right corner (with same mouse button). Allow  '
        'some time to complete calculation of curves.  '];
    try
        zmap_message_center.set_message(' ',message2);
    end

    figure_w_normalized_uicontrolunits(map)
    [x0,y0]  = ginput(1);
    mark1 =    plot(x0,y0,'ro','era','normal');
    set(mark1,'MarkerSize',10,'LineWidth',2.0)
    [x1,y1]  = ginput(1);
    f = [x0 y0 ; x1 y0 ; x1 y1 ; x0 y1 ; x0 y0];

    fplo = plot(f(:,1),f(:,2),'r','era','normal');
    set(fplo,'LineWidth',2)
    gx = x0:dx:x1;
    gy = y0:dy:y1;
    itotal = length(gx) * length(gy);

    zmap_message_center.set_info(' ','Running... ');think
    %  make grid, calculate start- endtime etc.  ...
    %
    t0b = a(1,3)  ;
    n = a.Count;
    teb = a(n,3) ;
    tdiff = round((teb - t0b)*365/par1);
    cumu = zeros(length(t0b:par1/365:teb)+2);
    ncu = length(cumu);
    cumuall = zeros(ncu,length(gx)*length(gy));
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
    % longitude  loop
    %
    for x =  x0:dx:x1
        i1 = i1+ 1;

        % latitude loop
        %
        for  y = y0:dy:y1
            allcount = allcount + 1.;
            i2 = i2+1;

            % calculate distance from center point and sort wrt distance
            l = sqrt(((a.Longitude-x)*cos(pi/180*y)*111).^2 + ((a.Latitude-y)*111).^2) ;
            [s,is] = sort(l);
            b = a(is(:,1),:) ;       % re-orders matrix to agree row-wise

            % take first ni points
            b = b(1:ni,:);      % new data per grid point (b) is sorted in distance

            % call the b-value function
            [bv, magco] =  bvalcalc(b);
            l = sort(l);
            bvg = [bvg ; bv magco x y l(ni)];
            waitbar(allcount/itotal)
        end  % for y0
        i2 = 0;
    end  % for x0

    save  bvalgrid.mat bvg gx gy ni dx dy

    close(wai)
    watchoff

    % plot the results
    %
    % old and re3 (initially ) is the b-value matrix
    re3 = reshape(bvg(:,1),length(gy),length(gx));
    r = reshape(bvg(:,5),length(gy),length(gx));
    old = re3;
    % old1 is the magnitude of completness matrx
    old1 = reshape(bvg(:,2),length(gy),length(gx));
    view_bva

end   % if nargin ==3
