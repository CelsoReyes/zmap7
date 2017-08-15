function view_qva(lab1,re3)
    % This .m file "view_maxz.m" plots the maxz LTA values calculated
    % with maxzlta.m or other similar values as a color map
    % needs re3, gx, gy, stri
    %
    % define size of the plot etc.
    %
    if isempty(name)
        name = '  '
    end
    think
    report_this_filefun(mfilename('fullpath'));
    %co = 'w';
    
    
    % Find out of figure already exists
    %
    [existFlag,figNumber]=figure_exists('q-detect-map',1);
    newbmapWindowFlag=~existFlag;
    
    % This is the info window text
    %
    ttlStr='The Z-Value Map Window                        ';
    hlpStr1zmap= ...
        ['                                                '
        ' This window displays seismicity rate changes   '
        ' as z-values using a color code. Negative       '
        ' z-values indicate an increase in the seismicity'
        ' rate, positive values a decrease.              '
        ' Some of the menu-bar options are               '
        ' described below:                               '
        '                                                '
        ' Threshold: You can set the maximum size that   '
        '   a volume is allowed to have in order to be   '
        '   displayed in the map. Therefore, areas with  '
        '   a low seismicity rate are not displayed.     '
        '   edit the size (in km) and click the mouse    '
        '   outside the edit window.                     '
        'FixAx: You can chose the minimum and maximum    '
        '        values of the color-legend used.        '
        'Polygon: You can select earthquakes in a        '
        ' polygon either by entering the coordinates or  '
        ' defining the corners with the mouse            '];
    hlpStr2zmap= ...
        ['                                                '
        'Circle: Select earthquakes in a circular volume:'
        '      Ni, the number of selected earthquakes can'
        '      be edited in the upper right corner of the'
        '      window.                                   '
        ' Refresh Window: Redraws the figure, erases     '
        '       selected events.                         '
        
        ' zoom: Selecting Axis -> zoom on allows you to  '
        '       zoom into a region. Click and drag with  '
        '       the left mouse button. type <help zoom>  '
        '       for details.                             '
        ' Aspect: select one of the aspect ratio options '
        ' Text: You can select text items by clicking.The'
        '       selected text can be rotated, moved, you '
        '       can change the font size etc.            '
        '       Double click on text allows editing it.  '
        '                                                '
        '                                                '];
    
    % Set up the Seismicity Map window Enviroment
    %
    if newbmapWindowFlag
        qmap = figure_w_normalized_uicontrolunits( ...
            'Name','q-detect-map',...
            'NumberTitle','off', ...
            'MenuBar','none', ...
            'NextPlot','new', ...
            'backingstore','on',...
            'Visible','off', ...
            'Position',[ (fipo(3:4) - [600 400]) ZmapGlobal.Data.map_len]);
        % make menu bar
        matdraw
        
        lab1 = 'day/night ratio';
        
        add_symbol_menu('eq_plot');
        
        uicontrol('Units','normal',...
            'Position',[.0 .93 .08 .06],'String','Info ',...
            'callback',@callbackfun_001);
        
        
        
        options = uimenu('Label',' Select ');
        uimenu(options,'Label','Refresh ', 'callback',@callbackfun_002)
        uimenu(options,'Label','Select EQ in Circle', 'callback',@callbackfun_003)
        uimenu(options,'Label','Select EQ in Polygon ', 'callback',@callbackfun_004)
        
        op1 = uimenu('Label',' Maps ');
        uimenu(op1,'Label','day/night value map',...
            'callback',@callbackfun_005)
        
        
        add_display_menu(1);
        
        uicontrol('Units','normal',...
            'Position',[.92 .80 .08 .05],'String','set ni',...
            'callback',@callbackfun_006)
        
        
        set_nia = uicontrol('style','edit','value',ni,'string',num2str(ni));
        set(set_nia,'callback',@callbackfun_007);
        set(set_nia,'units','norm','pos',[.94 .85 .06 .05],'min',10,'max',10000);
        nilabel = uicontrol('style','text','units','norm','pos',[.90 .85 .04 .05]);
        set(nilabel,'string','ni:','background',[.7 .7 .7]);
        
        % tx = text(0.07,0.95,[name],'Units','Norm','FontSize',18,'Color','k','FontWeight','bold');
        
        tresh = nan; re4 = re3;
        nilabel2 = uicontrol('style','text','units','norm','pos',[.60 .92 .25 .06]);
        set(nilabel2,'string','MinRad (in km):','background',color_fbg);
        set_ni2 = uicontrol('style','edit','value',tresh,'string',num2str(tresh),...
            'background','y');
        set(set_ni2,'callback',@callbackfun_008);
        set(set_ni2,'units','norm','pos',[.85 .92 .08 .06],'min',0.01,'max',10000);
        
        uicontrol('Units','normal',...
            'Position',[.95 .93 .05 .05],'String','Go ',...
            'callback',@callbackfun_009)
        
        colormap(cool)
        
    end   % This is the end of the figure setup
    
    % Now lets plot the color-map of the z-value
    %
    figure_w_normalized_uicontrolunits(qmap)
    delete(gca)
    delete(gca)
    delete(gca)
    dele = 'delete(sizmap)';er = 'disp('' '')'; eval(dele,er);
    reset(gca)
    cla
    hold off
    watchon;
    set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','SortMethod','childorder')
    
    rect = [0.18,  0.10, 0.7, 0.75];
    rect1 = rect;
    
    % find max and min of data for automatic scaling
    %
    ZG.maxc = max(max(re3));
    ZG.maxc = fix(ZG.maxc)+1;
    ZG.minc = min(min(re3));
    ZG.minc = fix(ZG.minc)-1;
    
    % set values gretaer tresh = nan
    %
    re4 = re3;
    l = r > tresh;
    re4(l) = zeros(1,length(find(l)))*nan;
    
    % plot image
    %
    orient landscape
    %set(gcf,'PaperPosition', [0.5 1 9.0 4.0])
    
    axes('position',rect)
    hold on
    pco1 = pcolor(gx,gy,re4);
    
    axis([ min(gx) max(gx) min(gy) max(gy)])
    axis image
    hold on
    if sha == 'fl'
        shading flat
    else
        shading interp
    end
    
    if fre == 1
        caxis([fix1 fix2])
    end
    
    
    title([name ';  '   num2str(t0b) ' to ' num2str(teb) ],'FontSize',ZmapGlobal.Data.fontsz.s,...
        'Color','r','FontWeight','bold')
    
    xlabel('Longitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
    ylabel('Latitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
    
    % plot overlay
    %
    hold on
    overlay_
    ploeq = plot(ZG.a.Longitude,ZG.a.Latitude,'k.');
    set(ploeq,'Tag','eq_plot','MarkerSize',ZG.ms6,'Marker',ty,'Color',co,'Visible',vi)
    
    
    
    set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','TickDir','out')
    h1 = gca;
    hzma = gca;
    
    % Create a colorbar
    %
    h5 = colorbar('horiz');
    set(h5,'Pos',[0.35 0.05 0.4 0.02],...
        'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
    
    rect = [0.00,  0.0, 1 1];
    axes('position',rect)
    axis('off')
    %  Text Object Creation
    txt1 = text(...
        'Color',[ 0 0 0 ],...
        'EraseMode','normal',...
        'Units','normalized',...
        'Position',[ 0.33 0.07 0 ],...
        'HorizontalAlignment','right',...
        'Rotation',[ 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.s,....
        'FontWeight','bold',...
        'String',lab1);
    
    % Make the figure visible
    %
    set(gca,'FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','TickDir','out')
    figure_w_normalized_uicontrolunits(qmap);
    axes(h1)
    watchoff(qmap)
    whitebg(gcf,[ 0 0 0 ])
    done
    
    function callbackfun_001(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        web(['file:' hodi '/help/quarry.htm']) ;
    end
    
    function callbackfun_002(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        delete(gca);
        delete(gca);
        delete(gca);
        delete(gca);
        view_qva(lab1,re3);
    end
    
    function callbackfun_003(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        circle;
        watchoff(qmap);
        hisgra(ZG.newt2.Date.Hour,'Hour',ZG.newt2.Name);
    end
    
    function callbackfun_004(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        stri = 'Polygon';
        h1 = gca;
        cufi = gcf;
        selectp;
        hisgra(ZG.newt2,'Hour');
    end
    
    function callbackfun_005(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1 ='day/night ratio';
        re3 = old;
        view_qva(lab1,re3);
    end
    
    function callbackfun_006(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ni=str2num(set_nia.String);
        'String';
        num2str(ni);
    end
    
    function callbackfun_007(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        %TOFIX callback does nothing
    end
    
    function callbackfun_008(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        tresh=str2double(set_ni2.String);
        set_ni2.String=num2str(tresh);
    end
    
    function callbackfun_009(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        think;
        pause(1);
        re4 =re3;
        view_bva(lab1,re3);
    end
end
