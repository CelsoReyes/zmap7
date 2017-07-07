%function bvalgrid(dx,dy,ni)
% This subroutine assigns creates a grid with
% spacing dx,dy (in degreees). The size will
% be selected interactiVELY. The bvalue in each
% volume around a grid point containing ni earthquakes
% will be calculated as well as the magnitude
% of completness
%   Stefan Wiemer 1/95

report_this_filefun(mfilename('fullpath'));

if sel == 'in'
    % get the grid parameter
    % initial values
    %
    dx = 0.10;
    dy = 0.10 ;
    ni = 1000;

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
        'Callback','close,sel =''ca'', meandgrnew',...
        'String','Go');

    txt3 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.30 0.74 0 ],...
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
        'String','Spacing in x (dx) in deg:');

    txt6 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.32 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in y (dy) in deg:');

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

end   % if nargin ==0

% get the grid-size interactively and
% calculate the b-value in the grid by sorting
% thge seimicity and selectiong the ni neighbors
% to each grid point

if sel == 'ca'
    message2 = ['Please wait until cursor changes to a CROSS   '
        'and Select the lower left corner of rectangle '
        'on the map (using the left mouse buton).      '
        'Wait for point selected, then select the upper'
        'right corner (with same mouse button). Allow  '
        'some time to complete calculation of curves.  '];
    zmap_message_center.set_message(' ',message2);
    figure_w_normalized_uicontrolunits(map)
    [x0,y0]  = ginput(1);
    mark1 =    plot(x0,y0,'ro','era','normal');
    set(mark1,'MarkerSize',10,'LineWidth',2.0)
    [x1,y1]  = ginput(1);
    f = [x0 y0 ; x1 y0 ; x1 y1 ; x0 y1 ; x0 y0];
    fplo = plot(f(:,1),f(:,2),'r','era','normal');
    set(fplo,'LineWidth',2)

    if x0 > x1; temp = x1; x1 = x0; x0 = temp; end
    if y0 > y1; temp = y1; y1 = y0; y0 = temp; end

    gx = x0:dx:x1;
    gy = y0:dy:y1;
    itotal = length(gx) * length(gy);
    if length(gx) < 2  ||  length(gy) < 2
        errordlg('Selection too small! (not a matrix)');
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
    meall = [];
    R = [];
    allcount = 0.;
    wai = waitbar(0,' Please Wait ...  ');
    set(wai,'NumberTitle','off','Name','b-value grid - percent done');;
    drawnow
    %
    % longitude  loop
    %
    iwln = 50;
    step = 10;
    len = ni;
    t2 = a(500,3)+2:0.3:max(a.Date)-0.2;
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
            r = l(ni);

            % take first ni points
            b = b(1:ni,:);      % new data per grid point (b) is sorted in distance
            % sort b i time
            [s,is] = sort(b(:,3));
            b = b(is(:,1),:) ;
            ind = 0;
            clear xt2 meand

            % calculate mean depth
            for it=1:step:len-iwln
                ind = ind + 1;
                meand(ind) = mean(b(it:it+iwln-1,7)) ;
                xt2(ind) = b(it+iwln,3);        % time is end of window
            end    % for it
            s = spline(xt2,meand-mean(b(:,7)),t2);
            meall = [meall ; s];
            R = [R  r];
            waitbar(allcount/itotal)
        end  % for y0
        i2 = 0;
    end  % for x0

    close(wai)
    watchoff

    % plot the results
    %
    %view_bva

end   % if nargin ==3
