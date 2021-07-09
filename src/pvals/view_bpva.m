function view_bpva(res, idx)
    % view_bpva plots the b and p values calculated with bpvalgrid.m or other similar values as a color map.
    % needs valueMap, gx, gy, stri
    %
    % define size of the plot etc.
    %
    
    % FIXME this, it broke when turned into a function.

    
    report_this_filefun();
    
    
    % This is the info window text
    %
    ttlStr='The b and p -Value Map Window                 ';
    hlpStr1zmap= ...
        ['                                                '
        ' This window displays b-values and p-values     '
        ' using a color code.                            '
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
    
    % Find out if figure already exists
    %
    ZG=ZmapGlobal.Data;
    bpmap=findobj('Type','Figure','-and','Name','bp-value-map');   
    delete(bpmap);
    try
    res=res.Result; %FIXME
    catch
    end
    curval = res.values(:,idx);
    
    if isempty(bpmap)
        oldfig_button = false;
    else
        oldfig_button = true;
    end
    if ~exist('Mmin','var')
        Mmin = nan;
    end
    if ~exist('minsd','var')
        minsd = nan;
    end
    if ~oldfig_button
        bpmap = figure_w_normalized_uicontrolunits( ...
            'Name','bp-value-map',...
            'NumberTitle','off', ...
            'NextPlot','new', ...
            'backingstore','on',...
            'Visible','off', ...
            'Position',position_in_current_monitor(ZG.map_len(1), ZG.map_len(2)));
        % make menu bar
        create_my_menu();
        
        %lab1 = 'p-value:';
        
        
        uicontrol('Units','normal',...
            'Position',[.0 .93 .08 .06],'String','Info ',...
            'callback',@callbackfun_001);
        
        
        
        %valueMap = pvalg;
        ZG.tresh_km = nan; 
        re4 = curval;
        oldfig_button = true;
        
        colormap(jet)
        ZG.tresh_km = nan; 
       %  minpe = nan; 
        Mmin = nan;
        minsd = nan;
    end   % This is the end of the figure setup.
    
    assert(istable(res.values))
    
    
    % Now plot the color-map!
    %
    set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','SortMethod','childorder')
    
    rect = [0.18,  0.10, 0.7, 0.75];
    rect1 = rect;
    
    
    lab1 = res.values.Properties.VariableDescriptions{idx};
    fn = res.values.Properties.VariableNames{idx};
    
    % find max and min of data for automatic scaling
    ZG.maxc = max(res.values.(fn));
    ZG.maxc = fix(ZG.maxc)+1;
    ZG.minc = min(res.values.(fn));
    ZG.minc = fix(ZG.minc)-1;
    
    % set values greater ZG.tresh_km = nan
    %
    re4 = curval;
    
    %THIS might actually stay.
    invalid_idx =  res.values.rd > ZG.tresh_km | ...
        res.values.prf < res.minpe |...
        res.values.magco < Mmin | ...
        res.values.pstd < minsd;
    
    re4{invalid_idx,1}=nan;
    
    % plot image
    %
    orient landscape
    %set(gcf,'PaperPosition', [0.5 1 9.0 4.0])
    
    
    figure(bpmap)
    set(bpmap,'name','p-values')
    delete(findobj(bpmap,'Type','axes'));
    colormap('jet')
    res.Grid.pcolor([],re4{:,1},lab1);
    shading(ZG.shading_style)
    set(gca,'NextPlot','add')
    res.Grid.plot()
    ft=ZG.features('borders');
    %newft=copyobj(ft,gca)
    ft.plot(gca); %FIXME
    colorbar
    title(lab1)
    xlabel('Longitude')
    ylabel('Latitude')
    
    %{
    %Plots re4, which contains the filtered values.
    axes('position',rect)
    set(gca,'NextPlot','add')
    pco1 = pcolor(gx,gy,re4);
    
    axis([ min(gx) max(gx) min(gy) max(gy)])
    axis image
    set(gca,'NextPlot','add')
    
    shading(ZG.shading_style);
%}
    % make the scaling for the recurrence time map reasonable
    if lab1(1) =='T'
        re = valueMap(~isnan(valueMap));
        caxis([min(re) 5*min(re)]);
    end
    

    fix_caxis.ApplyIfFrozen(gca); 
    
%{    
    title([name ';  '   num2str(t0b) ' to ' num2str(teb) ],'FontSize',ZmapGlobal.Data.fontsz.s,...
        'Color','r','FontWeight','bold')
    
    xlabel('Longitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
    ylabel('Latitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
    %}
    % plot overlay
    %
    set(gca,'NextPlot','add')
    zmap_update_displays();
    ploeq = plot(ZG.primeCatalog.Longitude,ZG.primeCatalog.Latitude,'k.');
    %set(ploeq,'Tag','eq_plot','MarkerSize',ZG.ms6,'Color',ZG.someColor,'Visible','on')
    
    
    
    %set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
    %    'FontWeight','bold','LineWidth',1.5,...
    %    'Box','on','TickDir','out')
    %h1 = gca;
    hzma = gca;
    
    % Create a colorbar
    %
    %{
    h5 = colorbar('horiz');
    set(h5,'Pos',[0.35 0.05 0.4 0.02],...
        'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s,'TickDir','out')
    
    rect = [0.00,  0.0, 1 1];
    axes('position',rect)
    axis('off')
    %  Text Object Creation
    txt1 = text(...
        'Units','normalized',...
        'Position',[ 0.33 0.06 0 ],...
        'HorizontalAlignment','right',...
        'FontSize',ZmapGlobal.Data.fontsz.s,....
        'FontWeight','bold',...
        'String',lab1);
    
    % Make the figure visible
    %
    set(gca,'FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','TickDir','out')
    figure(bpmap);
    axes(h1)
    watchoff(bpmap)
    %}
    colormap('jet')
    %% ui functions
    function create_my_menu()
        add_menu_divider();
        add_symbol_menu('eq_plot');
        options = uimenu('Label',' Select ');
        uimenu(options,'Label','Refresh ','MenuSelectedFcn',@callbackfun_002)
        uimenu(options,'Label','Select EQ in Circle',...
            'enable','off',...
            'MenuSelectedFcn',@callbackfun_003)
        uimenu(options,'Label','Select EQ in Circle - Constant R',...
            'enable','off',...
            'MenuSelectedFcn',@callbackfun_004)
        uimenu(options,'Label','Select EQ in Circle - Overlay existing plot',...
            'enable','off',...
            'MenuSelectedFcn',@callbackfun_005)
        
        uimenu(options,'Label','Select EQ in Polygon -new ',...
            'enable','off',...
            'MenuSelectedFcn', @(~,~)select_polygon(false));
        uimenu(options,'Label','Select EQ in Polygon - hold ',...
            'enable','off',...
            'MenuSelectedFcn', @(~,~)select_polygon(true));
        
        op1 = uimenu('Label',' Maps ');
        
        %Meniu for adjusting several parameters.
        adjmenu =  uimenu(op1,'Label','Adjust Map Display Parameters'),...
            uimenu(adjmenu,'Label','Adjust Mmin cut',...
            'enable','off',...
            'MenuSelectedFcn',@(~,~)cb_adjust('mag')); %8
        uimenu(adjmenu,'Label','Adjust Rmax cut',...
            'enable','off',...
            'MenuSelectedFcn',@(~,~)cb_adjust('rmax')); %9
        uimenu(adjmenu,'Label','Adjust goodness of fit cut',...
            'enable','off',...
            'MenuSelectedFcn',@(~,~)cb_adjust('gofi')); %10
        uimenu(adjmenu,'Label','Adjust p-value st. dev. cut',...
            'enable','off',...
            'MenuSelectedFcn',@(~,~)cb_adjust('pstdc')); %11
        
        
        uimenu(op1,'Label','b-value map (WLS)',... % b-value / old
            'MenuSelectedFcn', @(~,~)cb_changeIdx(1))  %12
        uimenu(op1,'Label','b(max likelihood) map',... % b-value / meg
            'MenuSelectedFcn', @(~,~)cb_changeIdx(6)) %13
        uimenu(op1,'Label','Mag of completness map',...% Mcomp / old1
            'MenuSelectedFcn', @(~,~)cb_changeIdx(2)) %14
        uimenu(op1,'Label','max magnitude map',... %Mmax / maxm
            'MenuSelectedFcn', @(~,~)cb_changeIdx(13)) %15
        uimenu(op1,'Label','Magnitude range map (Mmax - Mcomp)',... % dM / maxm-magco
            'MenuSelectedFcn',@cb_magrange) %16
        
        uimenu(op1,'Label','p-value',...
            'MenuSelectedFcn', @(~,~)cb_changeIdx(11))    % 17
        uimenu(op1,'Label','p-value standard deviation',...
            'MenuSelectedFcn', @(~,~)cb_changeIdx(12)) %18
        
        uimenu(op1,'Label','a-value map',...
            'MenuSelectedFcn', @(~,~)cb_changeIdx(8)) %19
        uimenu(op1,'Label','Standard error map',...
            'MenuSelectedFcn', @(~,~)cb_changeIdx(7)) %20
        uimenu(op1,'Label','(WLS-Max like) map',...
            'MenuSelectedFcn',@cb_deltaB)
        
        uimenu(op1,'Label','Resolution Map',...
            'MenuSelectedFcn', @(~,~)cb_changeIdx(5))
        uimenu(op1,'Label','c map',...
            'MenuSelectedFcn', @(~,~)cb_changeIdx(14))
        
        uimenu(op1,'Label','Histogram ','MenuSelectedFcn',@(~,~)zhist())
        
        add_display_menu(1);
    end
    
    %% callback functions
    
    function cb_changeIdx(idx)
        view_bpva(res,idx)
    end
    
    function cb_adjust(name)
        asel=name
        adju2
        view_bpva(res,idx);
    end
    
    function callbackfun_001(~,~)
        web(['file:' hodi '/zmapwww/chp11.htm#996756']) ;
    end
    
    function callbackfun_002(~,~)
        view_bpva;
    end
    
    function callbackfun_003(~,~)
        h1 = gca;
        met = 'ni';
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        cirpva;
        watchoff(bpmap);
    end
    
    function callbackfun_004(~,~)
        h1 = gca;
        met = 'ra';
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        cirpva;
        watchoff(bpmap);
    end
    
    function callbackfun_005(~,~)
        h1 = gca;
        ZG=ZmapGlobal.Data;
        ZG.hold_state2=true;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=true;
        cirpva;
        watchoff(bpmap);
    end
    
    function select_polygon(newstate)
        cufi = gcf;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=newstate;
        selectp;
    end
   
    
    function cb_magrange(~,~)

        %lab1='dM ';
        %valueMap = maxm-magco;
        res.values.dM=res.values.maxmg - res.values.magco;
        idx=find(res.values.Properties.VariableNames == "dM");
        res.values.Properties.VariableDescriptions(idx)='Magnitude range(Mmax - Mcomp)';
        view_bpva(res,idx);
    end
    
    function cb_deltaB(~,~)
        %lab1='difference in b';
        %valueMap = old-meg;
        res.values.deltaB=res.values.bv - res.values.bv2;
        idx=find(res.values.Propertes.VariableNames == "deltaB");
        res.values.Properties.VariableDescriptions(idx)='difference in b';
        view_bpva(res,idx);
    end
    
end
