function view_bvt(lab1,re3)
    % This .m file "view_x
    % maxz.m" plots the maxz LTA values calculated
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
    co = 'k';
    
    
    % Find out of figure already exists
    %
    [existFlag,figNumber]=figure_exists('b-value cross-section',1);
    newbmapcWindowFlag=~existFlag;
    
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
    if newbmapcWindowFlag
        bmapc = figure_w_normalized_uicontrolunits( ...
            'Name','b-value cross-section',...
            'NumberTitle','off', ...
            ...
            'backingstore','on',...
            'Visible','off', ...
            'Position',[ (fipo(3:4) - [600 400]) ZmapGlobal.Data.map_len]);
        % make menu bar
        
        lab1 = 'b-value';
        
        
        uicontrol('Units','normal',...
            'Position',[.0 .93 .08 .06],'String','Print ',...
            'callback',@callbackfun_001)
        
        callbackStr= ...
            ['f1=gcf; f2=gpf; set(f1,''Visible'',''off'');close(bmapc);', ...
            'if f1~=f2, figure_w_normalized_uicontrolunits(map);done; end'];
        
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
        
        % tx = text(0.07,0.95,[name],'Units','Norm','FontSize',18,'Color','k','FontWeight','bold');
        
        tresh = max(max(r)); re4 = re3;
        nilabel2 = uicontrol('style','text','units','norm','pos',[.60 .92 .25 .06]);
        set(nilabel2,'string','MinRad (in km):','background',color_fbg);
        set_ni2 = uicontrol('style','edit','value',tresh,'string',num2str(tresh),...
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
    figure_w_normalized_uicontrolunits(bmapc)
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
    
    
    % set values greater tresh = nan
    %
    re4 = re3;
    l = r > tresh;
    re4(l) = NaN(1,length(find(l)));
    
    %l = re4 > min(bvgr(:,1)) &  re4 < max(bvgr(:,1)) ;
    %l = re4 > mean(bvgr(:,1))-2*std(bvgr(:,1)) &  re4 <  mean(bvgr(:,1))+2*std(bvgr(:,1));
    %re4(l) = NaN(1,length(find(l)));
    %re4(l) = zeros(1,length(find(l)))+ mean(bvgr(:,1));
    
    % plot image
    %
    orient portrait
    set(gcf,'PaperPosition', [2. 1 7.0 5.0])
    %col = [hot(64) ; cool(64)];
    %col = col(128:-1:1,:);
    %load /home/2ken/stefan/after_figs/moslip.mat
    
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
    %  cs =contour(-gxd,gyd,sl/100,[0 0.2 0.4 0.6 0.8  1] ,'k');
    %set(gca,'YTick',[ -10 -5 0 ])
    %set(gca,'YTickLabels',[10 5 0 ])
    
    
    % plot overlay
    %
    ploeqc = plot(newa(:,length(newa(1,:))),-newa(:,7),'.k');
    set(ploeqc,'Tag','eqc_plot','MarkerSize',ZG.ms6,'Marker',ty,'Color',co,'Visible',vi)
    
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
        'Color',[ 0 0 0 ],...
        'EraseMode','normal',...
        'Position',[ 0.33 0.07 0 ],...
        'HorizontalAlignment','right',...
        'Rotation',[ 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.s,....
        'FontWeight','bold',...
        'String',lab1);
    
    % Make the figure visible
    %
    axes(h1)
    set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','TickDir','out')
    figure_w_normalized_uicontrolunits(bmapc);
    watchoff(bmapc)
    done
    
    %% ui functions
function create_my_menu()
	add_menu_divider();
    
end

%% callback functions

    function callbackfun_001(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        myprint;
    end
    
    function callbackfun_002(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        eval(callbackStr);
    end
    
    function callbackfun_003(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        zmaphelp(ttlStr,hlpStr1zmap,hlpStr2zmap);
    end
    
    function callbackfun_004(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        view_bv2(lab1,re3);
    end
    
    function callbackfun_005(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        cicros(1);
    end
    
    function callbackfun_006(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        cicros(2);
    end
    
    function callbackfun_007(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=true;
        cicros(0);
    end
    
    function callbackfun_008(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        cicros(3);
    end
    
    function callbackfun_009(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        polyb;
    end
    
    function callbackfun_010(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG=ZmapGlobal.Data;
        ZG.hold_state=true;
        polyb;
    end
    
    function callbackfun_011(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1 ='b-value change';
        re3 = dbperc;
        view_bvt(lab1,re3);
    end
    
    function callbackfun_012(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='b-value';
        re3 = old;
        view_bvt(lab1,re3);
    end
    
    function callbackfun_013(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='b-value';
        re3 = meg;
        view_bvt(lab1,re3);
    end
    
    function callbackfun_014(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='a-value';
        re3 = avm;
        view_bvt(lab1,re3);
    end
    
    function callbackfun_015(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='error in b';
        re3 = stanm;
        view_bvt(lab1,re3);
    end
    
    function callbackfun_016(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='difference in b';
        re3 = old-meg;
        view_bvt(lab1,re3);
    end
    
    function callbackfun_017(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='Mmax';
        re3 = maxm;
        view_bvt(lab1,re3);
    end
    
    function callbackfun_018(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='dM ';
        re3 = maxm-magco;
        view_bvt(lab1,re3);
    end
    
    function callbackfun_019(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        def = {'6'};
        m = inputdlg('Magnitude of projected mainshock?','Input',1,def);
        m1 = m{:};
        m = str2num(m1);
        lab1 = 'Tr in yrs. (only smallest values shown)';
        re3 =(teb - t0b)./(10.^(avm-m*old));
        view_bvt(lab1,re3);
    end
    
    function callbackfun_020(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='Probability';
        re3 = pro;
        view_bvt(lab1,re3);
    end
    
    function callbackfun_021(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='Mcomp';
        re3 = old1;
        view_bv2(lab1,re3);
    end
    
    function callbackfun_022(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='Radius in [km]';
        re3 = r;
        view_bvt(lab1,re3);
    end
    
    function callbackfun_023(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        zhist;
    end
    
    function callbackfun_024(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ni=str2num(set_nia.String);
        'String';
        num2str(ni);
    end
    
    function callbackfun_025(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ;
    end
    
    function callbackfun_026(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        tresh=str2double(set_ni2.String);
        set_ni2.String=num2str(tresh);
    end
    
    function callbackfun_027(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        think;
        pause(1);
        re4 =re3;
        view_bv2(lab1,re3);
    end
end
