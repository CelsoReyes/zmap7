function vi_cucro() % autogenerated function wrapper
    % vi_cucroz plots the maxz LTA values calculated
    % with maxzlta.m or other similar values as a color map
    % needs re3, gx, gy, stri
    %
    % define size of the plot etc.
    %
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    if isempty(name)
        name = '  '
    end
    think
    report_this_filefun(mfilename('fullpath'));
    co = 'k';
    
    if det == 'pro'
        re3 = old;
        l = re3 < 2.57;
        re3(l) = ones(1,length(find(l)))*2.65;
        pr = 0.0024 + 0.03*(re3 - 2.57).^2;
        pr = (1-1./(exp(pr)));
        re3 = pr;
    end   % if det = pro
    
    % Find out if figure already exists
    %
    zmapc=findobj('Type','Figure','-and','Name','Z-Value-Cross-section');
    
    
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
    if isempty(zmapc)
        zmapc = figure_w_normalized_uicontrolunits( ...
            'Name','Z-Value-Cross-section',...
            'NumberTitle','off', ...
            'NextPlot','new', ...
            'backingstore','on',...
            'Visible','off', ...
            'Position',[ (fipo(3:4) - [600 400]) ZmapGlobal.Data.map_len]);
        % make menu bar
        
        create_my_menu();
        
        
        uicontrol('Units','normal',...
            'Position',[.92 .80 .08 .05],'String','set ni',...
            'callback',@callbackfun_037)
        
        
        set_nia = uicontrol('style','edit','value',ni,'string',num2str(ni));
        set(set_nia,'callback',@callbackfun_038);
        set(set_nia,'units','norm','pos',[.94 .85 .06 .05],'min',10,'max',10000);
        nilabel = uicontrol('style','text','units','norm','pos',[.90 .85 .04 .05]);
        set(nilabel,'string','ni:','background',[.7 .7 .7]);
        
        % tx = text(0.07,0.95,[name],'Units','Norm','FontSize',18,'Color','k','FontWeight','bold');
        
        tresh = max(max(r)); re4 = re3;
        nilabel2 = uicontrol('style','text','units','norm','pos',[.60 .92 .25 .06]);
        set(nilabel2,'string','MinRad (in km):','background',color_fbg);
        set_ni2 = uicontrol('style','edit','value',tresh,'string',num2str(tresh),...
            'background','y');
        set(set_ni2,'callback',@callbackfun_039);
        set(set_ni2,'units','norm','pos',[.85 .92 .08 .06],'min',0.01,'max',10000);
        
        uicontrol('Units','normal',...
            'Position',[.95 .93 .05 .05],'String','Go ',...
            'callback',@callbackfun_040)
        sha = 'in';
        colormap(jet)
        
        
    end   % This is the end of the figure setup
    
    % Now lets plot the color-map of the z-value
    % (changed following 3 lines from mapc to zmapc because it seemed out of place that way.)
    zmapc=findobj('Type','Figure','-and','Name','Z-Value-Cross-section');
    figure(zmapc);
    delete(findobj(zmapc,'Type','axes'));
    
    watchon;
    rect = [0.22  0.20, 0.8, 0.65];
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
    [n1, n2] = size(cumuall);
    s = cumuall(n1,:);
    normlap2(ll)= s(:);
    %construct a matrix for the color plot
    r=reshape(normlap2,length(yvect),length(xvect));
    l = r > tresh;
    re4(l) = zeros(1,length(find(l)))*nan;
    
    % plot image
    %
    orient landscape
    axes('position',pos)
    hold on
    pco1 = pcolor(gx,gy,re4);
    hold on
    
    if sha == 'fl'
        shading flat
    else
        shading interp
    end
    
    axis equal
    if fre == 1
        caxis([fix1 fix2])
    end
    if  in == 'per'
        coma = jet;
        coma = coma(64:-1:1,:);
        colormap(coma)
    end
    
    title([name ' (' in '); ' num2str(t0b,6) ' to ' num2str(teb,6) ' - cut at ' num2str(it,6) '; iwl = ' num2str(ZG.compare_window_yrs) ' yr'],'FontSize',ZmapGlobal.Data.fontsz.s,...
        'Color','k','FontWeight','normal')
    
    ylabel('Depth in  [km]','FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s)
    xlabel('Distance along projection in [km]','FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s)
    
    % plot overlay
    %
    ploeqc = plot(newa(:,length(newa(1,:))),-newa(:,7),'.k');
    set(ploeqc,'MarkerSize',ZG.ms6,'Marker',ty,'Color',co,'visible', vi);
    
    if ~exist('maex', 'var'); maex =[];maey = [];end
    if ~isempty(maex)
        pl = plot(maex,-maey,'hm');
        %set(pl,'MarkerSize',12,'LineWidth',1)
        set(pl,'LineWidth',1.,'MarkerSize',12,...^M
            'MarkerFaceColor','w','MarkerEdgeColor','k')
        
    end
    if ~exist('maix', 'var'); maex =[];maey = [];end
    if ~isempty(maix)
        pl = plot(maix,maiy,'*k');
        set(pl,'MarkerSize',10,'LineWidth',2)
    end
    
    set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','normal',...
        'FontWeight','normal','LineWidth',1.,...
        'Box','on','TickDir','out','Ticklength',[0.015 0.015])
    h1 = gca;
    hzma = gca;
    
    % Create a colobar
    %
    h5 = colorbar('vert');
    apo = get(h1,'Position');
    set(h5,'Pos',[apo(1)+apo(3)+0.14 apo(2) 0.01 apo(4)-0.05],...
        'FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s, 'Box','on','TickDir','out','Ticklength',[0.02 0.02])
    
    %Text Object Creation
    txt1 = text(...
        'Color',[ 0 0 0 ],...
        'EraseMode','normal',...
        'Units','normalized',...
        'Position',[ 1.40 0.4 0 ],...
        'Rotation',[ 90 ],...
        'FontSize',ZmapGlobal.Data.fontsz.m,....
        'FontWeight','normal',...
        'String','z-value:');
    if in =='per'
        set(txt1,'String','Change in %')
    end
    if det =='pro'
        set(txt1,'String','Probability')
    end
    if det =='res'
        set(txt1,'String','Radius in km')
    end
    
    % Make the figure visible
    %
    set(gcf,'color','w');
    figure(zmapc);
    axes(h1)
    %whitebg(gcf,[ 0 0 0 ]);
    watchoff(zmapc)
    done
    
    %% ui functions
    function create_my_menu()
        add_menu_divider();
        
        symbolmenu = uimenu('Label',' Symbol ');
        SizeMenu = uimenu(symbolmenu,'Label',' Symbol Size ');
        TypeMenu = uimenu(symbolmenu,'Label',' Symbol Type ');
        ColorMenu = uimenu(symbolmenu,'Label',' Symbol Color ');
        
        uimenu(SizeMenu,'Label','3','callback',@callbackfun_001);
        uimenu(SizeMenu,'Label','6','callback',@callbackfun_002);
        uimenu(SizeMenu,'Label','9','callback',@callbackfun_003);
        uimenu(SizeMenu,'Label','12','callback',@callbackfun_004);
        uimenu(SizeMenu,'Label','14','callback',@callbackfun_005);
        uimenu(SizeMenu,'Label','18','callback',@callbackfun_006);
        uimenu(SizeMenu,'Label','24','callback',@callbackfun_007);
        
        uimenu(TypeMenu,'Label','dot','callback',@callbackfun_008);
        uimenu(TypeMenu,'Label','+','callback',@callbackfun_009);
        uimenu(TypeMenu,'Label','o','callback',@callbackfun_010);
        uimenu(TypeMenu,'Label','x','callback',@callbackfun_011);
        uimenu(TypeMenu,'Label','*','callback',@callbackfun_012);
        uimenu(TypeMenu,'Label','none','callback',@callbackfun_013);
        
        uimenu(ColorMenu,'Label','black','callback',@callbackfun_014);
        uimenu(ColorMenu,'Label','white','callback',@callbackfun_015);
        uimenu(ColorMenu,'Label','red','callback',@callbackfun_016);
        uimenu(ColorMenu,'Label','blue','callback',@callbackfun_017);
        uimenu(ColorMenu,'Label','yellow','callback',@callbackfun_018);
        
        cal8 = ...
            [ 'vi=''on'';set(ploeqc,''MarkerSize'',ZG.ms6,''LineStyle'',ty,''Color'',co,''visible'',''on'')'];
        
        %
        options = uimenu('Label',' Select ');
        uimenu(options,'Label','Refresh ', 'callback',@callbackfun_019)
        uimenu(options,'Label','Select EQ in Circle (fixed ni)', 'callback',@callbackfun_020);
        uimenu(options,'Label','Select EQ in Circle (fixed radius)', 'callback',@callbackfun_021)
        
        uimenu(options,'Label','Select EQ in Polygon ', 'callback',@callbackfun_022)
        
        op1 = uimenu('Label',' Tools ');
        uimenu(op1,'Label','ZMAP Menu', 'callback',@callbackfun_023)
        uimenu(op1,'Label','Fix color (z) scale', 'callback',@callbackfun_024)
        uimenu(op1,'Label','Histogram of z-values', 'callback',@callbackfun_025)
        uimenu(op1,'Label','Probability Map', 'callback',@callbackfun_026)
        uimenu(op1,'Label','Back to z-value Map', 'callback',@callbackfun_027)
        uimenu(op1,'Label','Colormap Invertjet',...
            'callback',@callbackfun_028)
        
        uimenu(op1,'Label','Colormap InvertGray', 'callback',@callbackfun_029)
        uimenu(op1,'Label','Resolution Map', 'callback',@callbackfun_030)
        uimenu(op1,'Label','Show Grid ',...
            'callback',@callbackfun_031)
        uimenu(op1,'Label','Show Circles ', 'callback',@callbackfun_032)
        uimenu(op1,'Label','shading flat', 'callback',@callbackfun_033)
        uimenu(op1,'Label','shading interpolated',...
            'callback',@callbackfun_034)
        uimenu(op1,'Label','Brigten +0.4',...
            'callback',@callbackfun_035)
        uimenu(op1,'Label','Brigten -0.4',...
            'callback',@callbackfun_036)
    end
    
    %% callback functions
    
    function callbackfun_001(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.ms6 =3;
        eval(cal8);
    end
    
    function callbackfun_002(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.ms6 =6;
        eval(cal8);
    end
    
    function callbackfun_003(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.ms6 =9;
        eval(cal8);
    end
    
    function callbackfun_004(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.ms6 =12;
        eval(cal8);
    end
    
    function callbackfun_005(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.ms6 =14;
        eval(cal8);
    end
    
    function callbackfun_006(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.ms6 =18;
        eval(cal8);
    end
    
    function callbackfun_007(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.ms6 =24;
        eval(cal8);
    end
    
    function callbackfun_008(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ty ='.';
        eval(cal8);
    end
    
    function callbackfun_009(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ty='+';
        eval(cal8);
    end
    
    function callbackfun_010(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ty='o';
        eval(cal8);
    end
    
    function callbackfun_011(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ty='x';
        eval(cal8);
    end
    
    function callbackfun_012(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ty='*';
        eval(cal8);
    end
    
    function callbackfun_013(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        vi='off';
        set(ploeqc,'visible','off');
    end
    
    function callbackfun_014(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        co='k';
        eval(cal8);
    end
    
    function callbackfun_015(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        co='w';
        eval(cal8);
    end
    
    function callbackfun_016(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        co='r';
        eval(cal8);
    end
    
    function callbackfun_017(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        co='b';
        eval(cal8);
    end
    
    function callbackfun_018(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        co='y';
        eval(cal8);
    end
    
    function callbackfun_019(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        vi_cucro;
    end
    
    function callbackfun_020(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        met = 'ni';
        cicros2;
        watchoff(zmapc);
    end
    
    function callbackfun_021(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        met = 'ra';
        cicros2;
        watchoff(zmapc);
    end
    
    function callbackfun_022(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        polycz ;
    end
    
    function callbackfun_023(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        menucros ;
    end
    
    function callbackfun_024(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        fixax3 ;
    end
    
    function callbackfun_025(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        zhist;
    end
    
    function callbackfun_026(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        det = 'pro';
        vi_cucro;
    end
    
    function callbackfun_027(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        det = 'nop';
        re3 = old;
        vi_cucro;
    end
    
    function callbackfun_028(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        g=jet;
        g = g(64:-1:1,:);
        colormap(g);
    end
    
    function callbackfun_029(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        g=gray;
        g = g(64:-1:1,:);
        colormap(g);
        brighten(.4);
    end
    
    function callbackfun_030(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        re3 = r;
        det = 'res';
        vi_cucro;
    end
    
    function callbackfun_031(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        plot(newgri(:,1),newgri(:,2),'+k');
    end
    
    function callbackfun_032(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        plotcirc;
    end
    
    function callbackfun_033(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        sha='fl';
        axes(hzma);
        shading flat;
    end
    
    function callbackfun_034(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        sha='in';
        axes(hzma);
        shading interp;
    end
    
    function callbackfun_035(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        axes(hzma);
        brighten(0.4);
    end
    
    function callbackfun_036(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        axes(hzma);
        brighten(-0.4);
    end
    
    function callbackfun_037(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ni=str2num(set_nia.String);
        'String';
        num2str(ni);
    end
    
    function callbackfun_038(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
    end
    
    function callbackfun_039(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        tresh=str2double(set_ni2.String);
        set_ni2.String=num2str(tresh);
    end
    
    function callbackfun_040(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        think;
        pause(1);
        re4 =re3;
        vi_cucro;
    end
    
end
