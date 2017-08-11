%function mifigrid(var1)
% mifigrid.m                              Alexander Allmann
% This function creates a grid with spacing dx, dy (in degrees)
% The size is selected interactively in an input window.
% The relative quiescence will be calculated for every grid point
% for a specific time and plotted in a Seismolap-Quiescence map
%

report_this_filefun(mfilename('fullpath'));


global freq_field1 freq_field2 freq_field3 freq_field4 freq_field5
global freq_field6 ni mi me1 va1
global a h1 map dx dy ldx tlap Mmin stime lap1 seismap
global normlap1 normlap2 mif1 mifmap

if var1==1


    %input window
    %
    %default parameters
    dx= .5;                      %grid spacing east-west
    dy= .5;                      %grid spacing north-south
    ldx=100;                     %side length of interaction zone in km
    tlap=300;                    %interaction time in days
    Mmin=3;                      %minimum magnitude
    stime=a(find(ZG.a.Magnitude==max(ZG.a.Magnitude)),3);
    stime=stime(1);


    %create a input window
    figure_w_normalized_uicontrolunits(...
        'Name','Grid Input Parameter',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','new', ...
        'units','points',...
        'Visible','off', ...
        'Position',[ ZG.wex+200 ZG.wey-200 450 250]);
    axis off

    %create a dialog box for the input
    freq_field1=uicontrol('Style','edit',...
        'Position',[.60 .36 .15 .08],...
        'Units','normalized','String',num2str(dx),...
        'Callback','dx=str2double(freq_field1.String); freq_field1.String=num2str(dx);');

    freq_field2=uicontrol('Style','edit',...
        'Position',[.60 .27 .15 .08],...
        'Units','normalized','String',num2str(dy),...
        'Callback','dy=str2double(freq_field2.String); freq_field2.String=num2str(dy);');

    freq_field3=uicontrol('Style','edit',...
        'Position',[.60 .48 .15 .08],...
        'Units','normalized','String',num2str(ni),...
        'Callback','ni=str2double(freq_field3.String); freq_field3.String=num2str(ni);');

    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.70 .05 .15 .12 ],...
        'Units','normalized','Callback','close;done','String','Cancel');


    go_button1=uicontrol('Style','Pushbutton',...
        'Position',[.20 .05 .15 .12 ],...
        'Units','normalized',...
        'Callback','close; var1 = 2; mificrgr;',...
        'String','Go');

    txt4 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0.50 0.74 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.l ,...
        'FontWeight','bold',...
        'String',' Grid Parameter');
    txt5 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.35 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in x (dx) in km:');

    txt6 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.25 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in depth (dy) in km:');

    txt2 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.5 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String',' # of EQ Ni:');

    set(gcf,'visible','on');
    watchoff

elseif var1==2           %area selection

    messtext=...
        ['To select a polygon for a grid.       '
        'Please use the LEFT mouse button of   '
        'or the cursor to the select the poly- '
        'gon. Use the RIGTH mouse button for   '
        'the final point.                      '];
    zmap_message_center.set_message('Select Polygon for a grid',messtext);


    [existFlag,figNumber]=figure_exists('Cross -Section',1);
    newMapWindowFlag=~existFlag;
    if newMapWindowFlag
        nlammap
    else
        figure_w_normalized_uicontrolunits(figNumber)
    end

    hold on
    ax = findobj('Tag','main_map_ax');
    [x,y, mouse_points_overlay] = select_polygon(ax);
    zmap_message_center.set_info('Message',' Thank you .... ')

    figure(xsec_fig)

    plos2 = plot(x,y,'b-','era','xor');        % plot outline
    sum3 = 0.;
    pause(0.3)

    %create a rectangular grid
    xvect=[min(x):dx:max(x)];
    yvect=[min(y):dy:max(y)];
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
    gcf
    plot(newgri(:,1),newgri(:,2),'+k')
    drawnow

    if length(xvect) < 2  ||  length(yvect) < 2
        errordlg('Selection too small! (not a matrix)');
        return
    end

    think

    %
    ZG.newcat=a;                   %ZG.newcat is only a local variable
    bcat=ZG.newcat;

    me1=zeros(length(newgri(:,1)),1);
    va1=zeros(length(newgri(:,1)),1);
    mic = mi(inde,:);

    wai = waitbar(0,' Please Wait ...  ');
    set(wai,'NumberTitle','off','Name','Makegrid - Percent completed');;
    drawnow

    for i= 1:length(me1)   %all eqs which are in spacewindow in east-west direction
        x = newgri(i,1);y = newgri(i,2);

        l = sqrt(((xsecx' - x)).^2 + ((xsecy + y)).^2) ;
        [s,is] = sort(l);
        b = ZG.newcat(is(:,1),:) ;       % re-orders matrix to agree row-wise
        mi2 = mic(is(:,1),2);    % take first ni points
        mi2 = mi2(1:ni);
        me1(i) = mean(mi2);
        va1(i) = std(mi2);
        if rem(i,20)==0;  waitbar(i/length(me1));end
    end


    close(wai)
    %make a color map
    % Find out of figure already exists
    %
    [existFlag,figNumber]=figure_exists('Misfit-Map 2',1);
    newlapWindowFlag=~existFlag;
    % Set up the Seismicity Map window Enviroment
    %
    if newlapWindowFlag
        mifmap = figure_w_normalized_uicontrolunits( ...
            'Name','Misfit-Map 2',...
            'NumberTitle','off', ...
            'MenuBar','none', ...
            'NextPlot','replace', ...
            'backingstore','on',...
            'Visible','off', ...
            'Position',[ 600 400 500 650]);
        % make menu bar
        matdraw
        

        hold on
    end

    [existFlag,mifmap]=figure_exists('Misfit-Map 2',1);
    figure_w_normalized_uicontrolunits(mifmap)

    delete(gca);delete(gca); delete(gca);delete(gca);
    delete(gca);delete(gca); delete(gca);delete(gca);

    set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','SortMethod','childorder')

    %minimum and maximum of normlap2 for automatic scaling
    ZG.maxc = max(normlap2);
    ZG.minc = min(normlap2);

    %construct a matrix for the color plot
    normlap1=ones(length(tmpgri(:,1)),1);
    normlap2=ones(length(tmpgri(:,1)),1)*nan;
    normlap3=ones(length(tmpgri(:,1)),1)*nan;
    normlap1(ll)=me1;
    normlap2(ll)=normlap1(ll);
    normlap1(ll)=va1;
    normlap3(ll)=normlap1(ll);

    normlap2=reshape(normlap2,length(yvect),length(xvect));
    normlap3=reshape(normlap3,length(yvect),length(xvect));

    %plot color image
    orient tall
    gx = xvect; gy = yvect;
    memifig
    done
    return

    rect = [0.25,  0.60, 0.7, 0.35];
    axes('position',rect)
    hold on
    pco1 = pcolor(xvect,yvect,normlap2);
    shading interp
    colormap(jet)
    %axis([ s2 s1 s4 s3])
    axis([ min(gx) max(gx) min(gy) max(gy)])
    axis image

    hold on
    colorbar
    if exist('maex', 'var')
        hold on
        pl = plot(maex,-maey,'*m');
        set(pl,'MarkerSize',8,'LineWidth',2)
    end

    %overlay
    title('Mean of the Misfit','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    xlabel('Distance in [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    ylabel('Depth in [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)

    set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','TickDir','out')

    rect = [0.25,  0.10, 0.7, 0.35];
    axes('position',rect)
    hold on
    pco1 = pcolor(xvect,yvect,normlap3);
    axis([ min(gx) max(gx) min(gy) max(gy)])
    axis image

    if exist('maex', 'var')
        hold on
        pl = plot(maex,-maey,'*w');
        set(pl,'MarkerSize',8,'LineWidth',2)
    end


    hold on
    shading interp
    colormap(jet)
    hold on
    colorbar
    title(' Variance of the Misfit','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    xlabel('Distance in [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    ylabel('Depth in [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)

    set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','TickDir','out')

end
