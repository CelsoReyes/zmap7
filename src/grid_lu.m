% This subroutine assigns creates a grid with
% spacing dx,dy (in degreees). The size will
% be selected interactiVELY. The bvalue in each
% volume around a grid point containing ni earthquakes
% will be calculated as well as the magnitude
% of completness
%   Stefan Wiemer 1/95

report_this_filefun(mfilename('fullpath'));
global fontsz
res = [];

if sel == 'in'
    % get the grid parameter
    % initial values
    %
    dx = 0.01;
    dy = 0.01 ;
    r0 = 2.0;

    % make the interface
    %
    figure_w_normalized_uicontrolunits(...
        'Name','Grid Input Parameter',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','new', ...
        'units','points',...
        'Visible','off', ...
        'Position',[ 200 200 450 250]);
    axis off

    % creates a dialog box to input grid parameters
    %
    freq_field=uicontrol('Style','edit',...
        'Position',[.60 .50 .22 .10],...
        'Units','normalized','String',num2str(r0),...
        'Callback','r0=str2double(get(freq_field,''String'')); set(freq_field,''String'',num2str(r0));');

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
        'Units','normalized','Callback','close;','String','Cancel');

    go_button1=uicontrol('Style','Pushbutton',...
        'Position',[.20 .05 .15 .12 ],...
        'Units','normalized',...
        'Callback','close,sel =''ca'', grid_lu',...
        'String','Go');

    txt3 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.30 0.74 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.m ,...
        'FontWeight','bold',...
        'String',' Grid Parameter');
    txt5 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.42 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.s ,...
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
        'String','Radius in km :');
    set(gcf,'visible','on');
    watchoff

end   % if  sel = in

% get the grid-size interactively and
% calculate the b-value in the grid by sorting
% thge seimicity and selectiong the ni neighbors
% to each grid point

if sel == 'ca'
    res = [];
    message2 = ['Please wait until cursor changes to a CROSS   '
        'and Select the lower left corner of rectangle '
        'on the map (using the left mouse buton).      '
        'Wait for point selected, then select the upper'
        'right corner (with same mouse button). Allow  '
        'some time to complete calculation of curves.  '];
    %echo(message2)

    % plot the map here
    %
    clf
    plot(a.Longitude,a.Latitude,'o')
    hold on

    % Now find the grid-size
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

    %  make grid, calculate start- endtime etc.  ...
    %
    % loop over  all points
    %
    i2 = 0.;
    i1 = 0.;
    bvg = [];
    allcount = 0.;
    drawnow
    %
    % longitude  loop
    %
    for x =  x0:dx:x1
        i1 = i1+ 1;

        % latitude loop
        %
        for  y = y0:dy:y1
            y
            allcount = allcount + 1.;
            i2 = i2+1;

            % calculate distance from center point and sort wrt distance
            l = sqrt(((a.Longitude-x)*cos(pi/180*y)*111).^2 + ((a.Latitude-y)*111).^2) ;
            [s,is] = sort(l);
            b = a(is(:,1),:) ;       % re-orders matrix to agree row-wise


            % take first ni points
            %b = b(1:ni,:);      % new data per grid point (b) is sorted in distance

            % take points with r0
            l2 = l < r0;
            b = b(l2,:);

            % calculate the statistic
            if length(b) > 1
                std(b(:,1));
                mean(b(:,1));
                length(b(:,1));
                l = sort(l2);
                res = [res ; x y  std(b(:,3))  mean(b(:,3)) length(b(:,1))];
            else
                res = [res ; x y  0  0 1 ];
            end   % if length(b)
        end  % for y0
        i2 = 0;
    end  % for x0
end   % if nargin ==3
