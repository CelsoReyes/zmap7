function view_bvt(lab1,valueMap)
    % plots the maxz LTA values calculated
    % with maxzlta.m or other similar values as a color map
    % needs valueMap, gx, gy, stri
    %
    % define size of the plot etc.
    %

    
    report_this_filefun(mfilename('fullpath'));
    ZG=ZmapGlobal.Data;
    ZG.someColor = 'k';
    
    
    % Find out if figure already exists
    %
    bmapc=findobj('Type','Figure','-and','Name','b-value cross-section');
    
    
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
    if isempty(bmapc)
        bmapc = figure_w_normalized_uicontrolunits( ...
            'Name','b-value cross-section',...
            'NumberTitle','off', ...
            'backingstore','on',...
            'Visible','off', ...
            'Position',position_in_current_monitor(ZG.map_len(1), ZG.map_len(2)));
        % make menu bar
        
        lab1 = 'b-value';
        
        
        uicontrol('Units','normal',...
            'Position',[.0 .93 .08 .06],'String','Print ',...
            'callback',@callbackfun_001)
        
        callbackStr= ...
            ['f1=gcf; f2=gpf; set(f1,''Visible'',''off'');close(bmapc);', ...
            'if f1~=f2, figure(map); end'];
        
        uicontrol('Units','normal',...
            'Position',[.0 .75 .08 .06],'String','Close ',...
            'callback',@callbackfun_002)
        
        uicontrol('Units','normal',...
            'Position',[.0 .85 .08 .06],'String','Info ',...
            'callback',@callbackfun_003)
        
        uicontrol('Units','normal',...
            'Position',[.92 .80 .08 .05],'String','set ni',...
            'callback',@callbackfun_024)
        
        
        set_nia = uicontrol('style','edit','value',ni,'string',num2str(ni));
        set(set_nia,'callback',@callbackfun_025);
        set(set_nia,'units','norm','pos',[.94 .85 .06 .05],'min',10,'max',10000);
        nilabel = uicontrol('style','text','units','norm','pos',[.90 .85 .04 .05]);
        set(nilabel,'string','ni:','background',[.7 .7 .7]);
        
        ZG.tresh_km = max(r(:)); re4 = valueMap;
        nilabel2 = uicontrol('style','text','units','norm','pos',[.60 .92 .25 .06]);
        set(nilabel2,'string','MinRad (in km):','background',color_fbg);
        set_ni2 = uicontrol('style','edit','value',ZG.tresh_km,'string',num2str(ZG.tresh_km),...
            'background','y');
        set(set_ni2,'callback',@callbackfun_026)
        set(set_ni2,'units','norm','pos',[.85 .92 .08 .06],'min',0.01,'max',10000);
        
        uicontrol('Units','normal',...
            'Position',[.95 .93 .05 .05],'String','Go ',...
            'callback',@callbackfun_027)
        
        create_my_menu();
        
        colormap(jet)
    end   % This is the end of the figure setup
    
    % Now lets plot the color-map of the z-value
    %
    figure(bmapc);
    delete(findobj(bmapc,'Type','axes'));
    % delete(sizmap);
    reset(gca);
    cla
    hold off
    watchon;
    set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','SortMethod','childorder')
    
    
    % set values greater ZG.tresh_km = nan
    %
    re4 = valueMap;
    l = r > ZG.tresh_km;
    re4(l) = NaN(1,length(find(l)));
    
    % plot image
    %
    orient portrait
    set(gcf,'PaperPosition', [2. 1 7.0 5.0])
    
    hold on
    pco1 = pcolor(gx,gy,db12);
    axis([ min(gx) max(gx) min(gy) max(gy)])
    hold on;  shading flat; axis image
    
    hocm = hot;
    
    hocm(33,:) = [0.4 0.4 0.4];
    colormap(hocm)
    %brighten(0.7)
    caxis([-0.3 0.3])
    set(gca,'Color',[1.0 1.0 1.0]  )
    set(gca,'visible','on','FontSize',10,...
        'FontWeight','normal','LineWidth',1.5,...
        'Box','on','TickDir','out')
    hold on
    
    % plot overlay
    %
    ploeqc = plot(newa(:,length(newa(1,:))),-newa(:,7),'.k');
    set(ploeqc,'Tag','eqc_plot','MarkerSize',ZG.ms6,'Marker',ty,'Color',ZG.someColor,'Visible','on')
    
    if exist('vox', 'var')
        plovo = plot(vox,voy,'*b');
        set(plovo,'MarkerSize',6,'LineWidth',1)
    end
    
    if exist('maix', 'var')
        pl = plot(maix,maiy,'*k');
        set(pl,'MarkerSize',12,'LineWidth',2)
    end
    
    if exist('maex', 'var')
        pl = plot(maex,-maey,'*k');
        set(pl,'MarkerSize',8,'LineWidth',2)
    end
    %overlay
    
    
    set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','TickDir','out')
    h1 = gca;
    hzma = gca;
    
    % Create a colorbar
    %
    h5 = colorbar('horz');
    set(h5,'Pos',[0.35 0.05 0.4 0.04],...
        'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s,'TickDir','out')
    
    rect = [0.00,  0.0, 1 1];
    axes('position',rect)
    axis('off')
    %  Text Object Creation
    txt1 = text(...
        'Position',[ 0.33 0.07 0 ],...
        'HorizontalAlignment','right',...
        'FontSize',ZmapGlobal.Data.fontsz.s,....
        'FontWeight','bold',...
        'String',lab1);
    
    % Make the figure visible
    %
    axes(h1)
    set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','TickDir','out')
    figure(bmapc);
    watchoff(bmapc)
    
    
    %% ui functions
    function create_my_menu()
        add_menu_divider();
        
    end
    
    %% callback functions
    
    function callbackfun_001(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        myprint;
    end
    
    function callbackfun_002(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        eval(callbackStr);
    end
    
    function callbackfun_003(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        helpdlg(help('view_bvt'),'Help for view_bvt')
    end
    
    function callbackfun_004(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        view_bv2(lab1,valueMap);
    end
    
    function callbackfun_005(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        cicros(1);
    end
    
    function callbackfun_006(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        cicros(2);
    end
    
    function callbackfun_007(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=true;
        cicros(0);
    end
    
    function callbackfun_008(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        cicros(3);
    end
    
    function callbackfun_009(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        polyb;
    end
    
    function callbackfun_010(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG=ZmapGlobal.Data;
        ZG.hold_state=true;
        polyb;
    end
    
    function callbackfun_011(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1 ='b-value change';
        valueMap = dbperc;
        view_bvt(lab1,valueMap);
    end
    
    function callbackfun_012(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='b-value';
        valueMap = old;
        view_bvt(lab1,valueMap);
    end
    
    function callbackfun_013(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='b-value';
        valueMap = meg;
        view_bvt(lab1,valueMap);
    end
    
    function callbackfun_014(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='a-value';
        valueMap = avm;
        view_bvt(lab1,valueMap);
    end
    
    function callbackfun_015(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='error in b';
        valueMap = stanm;
        view_bvt(lab1,valueMap);
    end
    
    function callbackfun_016(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='difference in b';
        valueMap = old-meg;
        view_bvt(lab1,valueMap);
    end
    
    function callbackfun_017(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='Mmax';
        valueMap = maxm;
        view_bvt(lab1,valueMap);
    end
    
    function callbackfun_018(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='dM ';
        valueMap = maxm-magco;
        view_bvt(lab1,valueMap);
    end
    
    function callbackfun_019(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        def = {'6'};
        m = inputdlg('Magnitude of projected mainshock?','Input',1,def);
        m1 = m{:};
        m = str2num(m1);
        lab1 = 'Tr in yrs. (only smallest values shown)';
        valueMap =(teb - t0b)./(10.^(avm-m*old));
        view_bvt(lab1,valueMap);
    end
    
    function callbackfun_020(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='Probability';
        valueMap = pro;
        view_bvt(lab1,valueMap);
    end
    
    function callbackfun_021(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='Mcomp';
        valueMap = old1;
        view_bv2(lab1,valueMap);
    end
    
    function callbackfun_022(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='Radius in [km]';
        valueMap = r;
        view_bvt(lab1,valueMap);
    end
    
    function callbackfun_024(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ni=str2num(set_nia.String);
        num2str(ni);
    end
    
    function callbackfun_025(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
    end
    
    function callbackfun_026(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.tresh_km=str2double(set_ni2.String);
        set_ni2.String=num2str(ZG.tresh_km);
    end
    
    function callbackfun_027(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        
        pause(1);
        re4 =valueMap;
        view_bv2(lab1,valueMap);
    end
end
