function view_bva(lab1, re3)
    % This .m file "view_maxz.m" plots the maxz LTA values calculated
    % with maxzlta.m or other similar values as a color map
    % needs re3, gx, gy, stri
    %
    % define size of the plot etc.
    %
    
    if ~exist('Prmap') || isempty(Prmap)
        Prmap = nan(size(re3));
    end
    
    if isempty(name)
        name = '  '
    end
    think
    report_this_filefun(mfilename('fullpath'));
    co = 'w';
    
    
    % Find out if figure already exists
    %
    bmap=findobj('Type','Figure','-and','Name','b-value-map');
    
    
    % Set up the Seismicity Map window Enviroment
    %
    if isempty(bmap)
        bmap = figure_w_normalized_uicontrolunits( ...
            'Name','b-value-map',...
            'NumberTitle','off', ...
            'NextPlot','new', ...
            'backingstore','on',...
            'Visible','off', ...
            'Position',[ (fipo(3:4) - [600 400]) ZmapGlobal.Data.map_len]);
        % make menu bar
        
        
        lab1 = 'b-value:';
        create_my_menu();
        
        tresh = nan; re4 = re3;
        
        colormap(jet)
        tresh = nan; minpe = nan; Mmin = nan;
        
    end   % This is the end of the figure setup
    
    % Now lets plot the color-map of the z-value
    %
    figure(bmap);
    delete(findobj(bmap,'Type','axes'));
    % delete(sizmap);
    reset(gca)
    cla
    hold off
    watchon;
    set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','normal',...
        'FontWeight','normal','LineWidth',1.,...
        'Box','on','SortMethod','childorder')
    
    rect = [0.18,  0.10, 0.7, 0.75];
    rect1 = rect;
    
    % find max and min of data for automatic scaling
    %
    ZG.maxc = max(max(re3));
    ZG.maxc = fix(ZG.maxc)+1;
    ZG.minc = min(min(re3));
    ZG.minc = fix(ZG.minc)-1;
    
    % plot image
    %
    orient landscape
    %set(gcf,'PaperPosition', [0.5 1 9.0 4.0])
    
    axes('position',rect)
    hold on
    pco1 = pcolor(gx,gy,re3);
    
    axis([ min(gx) max(gx) min(gy) max(gy)])
    set(gca,'dataaspect',[1 cosd(nanmean(ZG.a.Latitude)) 1]);
    hold on
    if sha == 'fl'
        shading flat
    else
        shading interp
    end
    % make the scaling for the recurrence time map reasonable
    if lab1(1) =='T'
        l = isnan(re3);
        re = re3;
        re(l) = [];
        caxis([min(re) 5*min(re)]);
    end
    if fre == 1
        caxis([fix1 fix2])
    end
    
    title([name ';  '   num2str(t0b) ' to ' num2str(teb) ],'FontSize',ZmapGlobal.Data.fontsz.s,...
        'Color','r','FontWeight','normal')
    
    xlabel('Longitude [deg]','FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s)
    ylabel('Latitude [deg]','FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s)
    
    % plot overlay
    %
    hold on
    update(mainmap())
    ploeq = plot(ZG.a.Longitude,ZG.a.Latitude,'k.');
    set(ploeq,'Tag','eq_plot','MarkerSize',ZG.ms6,'Marker',ty,'Color',co,'Visible',vi)
    
    
    set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','normal',...
        'FontWeight','normal','LineWidth',1.,...
        'Box','on','TickDir','out')
    
    h1 = gca;
    hzma = gca;
    
    % Create a colorbar
    %
    h5 = colorbar('horiz');
    set(h5,'Pos',[0.35 0.07 0.4 0.02],...
        'FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s,'TickDir','out')
    
    rect = [0.00,  0.0, 1 1];
    axes('position',rect)
    axis('off')
    %  Text Object Creation
    txt1 = text(...
        'Color',[ 0 0 0 ],...
        'EraseMode','normal',...
        'Units','normalized',...
        'Position',[ 0.2 0.06 0 ],...
        'HorizontalAlignment','right',...
        'Rotation',[ 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.s,....
        'FontWeight','normal',...
        'String',lab1);
    
    % Make the figure visible
    %
    set(gca,'FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','normal',...
        'FontWeight','normal','LineWidth',1.,...
        'Box','on','TickDir','out')
    figure(bmap);
    %sizmap = signatur('ZMAP','',[0.01 0.04]);
    %set(sizmap,'Color','k')
    axes(h1)
    set(gcf,'color','w');
    watchoff(bmap)
    %whitebg(gcf,[ 0 0 0 ])
    done
    
    function adju()
        report_this_filefun(mfilename('fullpath'));
        
        
        prompt={'Enter the minimum magnitude cut-off','Enter the maximum radius cut-off:','Enter the minimum goodness of fit percatge'};
        def={'nan','nan','nan'};
        dlgTitle='Input Map subselection Criteria';
        lineNo=1;
        answer=inputdlg(prompt,dlgTitle,lineNo,def);
        re4 = re3;
        l = answer{1,1}; Mmin = str2double(l) ;
        l = answer{2,1}; tresh = str2double(l) ;
        l = answer{3,1}; minpe = str2double(l) ;
    end
    
    %% ui functions
    function create_my_menu()
        add_menu_divider();
        
        add_symbol_menu('eq_plot');
        
        options = uimenu('Label',' Select ');
        uimenu(options,'Label','Refresh ', 'callback',@callbackfun_001)
        uimenu(options,'Label','Select EQ in Circle',...
            'callback',@callbackfun_002)
        uimenu(options,'Label','Select EQ in Circle - Constant R',...
            'callback',@callbackfun_003)
        uimenu(options,'Label','Select EQ in Circle - Overlay existing plot',...
            'callback',@callbackfun_004)
        
        uimenu(options,'Label','Select EQ in Polygon -new ',...
            'callback',@callbackfun_005)
        uimenu(options,'Label','Select EQ in Polygon - hold ',...
            'callback',@callbackfun_006)
        
        
        op1 = uimenu('Label',' Maps ');
        
        adjmenu =  uimenu(op1,'Label','Adjust Map Display Parameters');
        uimenu(adjmenu,'Label','Adjust Mmin cut',...
            'callback',@callbackfun_007)
        uimenu(adjmenu,'Label','Adjust Rmax cut',...
            'callback',@callbackfun_008)
        uimenu(adjmenu,'Label','Adjust goodness of fit cut',...
            'callback',@callbackfun_009)
        
        
        uimenu(op1,'Label','b-value map (max likelihood)',...
            'callback',@callbackfun_010)
        uimenu(op1,'Label','Standard deviation of b-Value (max likelihood) map',...
            'callback',@callbackfun_011)
        uimenu(op1,'Label','Magnitude of completness map',...
            'callback',@callbackfun_012)
        uimenu(op1,'Label','Standard deviation of magnitude of completness',...
            'callback',@callbackfun_013)
        uimenu(op1,'Label','Goodness of fit to power law map',...
            'callback',@callbackfun_014)
        uimenu(op1,'Label','Resolution map',...
            'callback',@callbackfun_015)
        uimenu(op1,'Label','Earthquake density map',...
            'callback',@callbackfun_016)
        uimenu(op1,'Label','a-value map',...
            'callback',@callbackfun_017)
        
        
        if exist('mStdDevB')
            AverageStdDevMenu = uimenu(op1,'Label', 'Additional random simulation');
            uimenu(AverageStdDevMenu,'Label', 'Bootstrapped standard deviation of b-value',...
                'callback',@callbackfun_018)
            uimenu(AverageStdDevMenu,'Label', 'Bootstrapped standard deviation of Mc',...
                'callback',@callbackfun_019)
            uimenu(AverageStdDevMenu,'Label', 'b-value map (max likelihood) with std. deviation',...
                'callback',@callbackfun_020)
        end
        
        % recmenu =  uimenu(op1,'Label','recurrence time map '),...
        
        uimenu(recmenu,'Label','recurrence time map ',...
            'callback',@callbackfun_021)
        
        uimenu(recmenu,'Label','(1/Tr)/area map ',...
            'callback',@callbackfun_022)
        
        uimenu(recmenu,'Label','recurrence time percentage ',...
            'callback',@callbackfun_023)
        
        
        
        uimenu(op1,'Label','Histogram ', 'callback',@callbackfun_024)
        uimenu(op1,'Label','Reccurrence Time Histogram ', 'callback',@callbackfun_025)
        uimenu(op1,'Label','Save map to ASCII file ', 'callback',@callbackfun_026)
        
        add_display_menu(4);
    end
    
    %% callback functions
    
    function callbackfun_001(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        view_bva(lab1,re3);
    end
    
    function callbackfun_002(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        met = 'ni';
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        cirbva;
        watchoff(bmap);
    end
    
    function callbackfun_003(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        met = 'ra';
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        cirbva;
        watchoff(bmap);
    end
    
    function callbackfun_004(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=true;
        cirbva;
        watchoff(bmap);
    end
    
    function callbackfun_005(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        cufi = gcf;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        selectp;
    end
    
    function callbackfun_006(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        cufi = gcf;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=true;
        selectp;
    end
    
    function callbackfun_007(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        asel = 'mag';
        adju();
        view_bva(lab1,re3) ;
    end
    
    function callbackfun_008(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        asel = 'rmax';
        adju();
        view_bva(lab1,re3);
    end
    
    function callbackfun_009(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        asel = 'gofi';
        adju();
        view_bva(lab1,re3) ;
    end
    
    function callbackfun_010(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1 ='b-value';
        re3 = mBvalue;
        view_bva(lab1,re3);
    end
    
    function callbackfun_011(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='SdtDev b-Value';
        re3 = mStdB;
        view_bva(lab1,re3);
    end
    
    function callbackfun_012(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1 = 'Mcomp';
        re3 = mMc;
        view_bva(lab1,re3);
    end
    
    function callbackfun_013(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1 = 'Mcomp';
        re3 = mStdMc;
        view_bva(lab1,re3);
    end
    
    function callbackfun_014(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1 = ' % ';
        re3 = Prmap;
        view_bva(lab1,re3);
    end
    
    function callbackfun_015(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='Radius in [km]';
        re3 = r;
        view_bva(lab1,re3);
    end
    
    function callbackfun_016(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='log(EQ per km^2)';
        re3 = log10(mNumEq./(r.^2*pi));
        view_bva(lab1,re3);
    end
    
    function callbackfun_017(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='a-value';
        re3 = mAvalue;
        view_bva(lab1,re3);
    end
    
    function callbackfun_018(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='standard deviation of b-value';
        re3 = mStdDevB;
        view_bva(lab1,re3);
    end
    
    function callbackfun_019(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='standard deviation of Mc';
        re3 = mStdDevMc;
        view_bva(lab1,re3);
    end
    
    function callbackfun_020(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='b-value';
        re3 = mBvalue;
        bOverlayTransparentStdDev = 1;
        view_bva(lab1,re3);
    end
    
    function callbackfun_021(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        def = {'6'};
        m = inputdlg('Magnitude of projected mainshock?','Input',1,def);
        m1 = m{:};
        m = str2num(m1);
        lab1 = 'Tr (yrs) (sm. values only)';
        re3 =(teb - t0b)./(10.^(mAvalue-m*mBvalue));
        mrt = m;
        view_bva(lab1,re3);
    end
    
    function callbackfun_022(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        def = {'6'};
        m = inputdlg('Magnitude of projected mainshock?','Input',1,def);
        m1 = m{:};
        m = str2num(m1);
        lab1 = '1/Tr/area ';
        re3 =(teb - t0b)./(10.^(mAvalue-m*mBvalue));
        re3 = 1./re3/(2*pi*ra*ra);
        mrt = m;
        view_bva(lab1,re3);
    end
    
    function callbackfun_023(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        recperc;
    end
    
    function callbackfun_024(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        zhist;
    end
    
    function callbackfun_025(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        rechist;
    end
    
    function callbackfun_026(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        savemap;
    end
end
