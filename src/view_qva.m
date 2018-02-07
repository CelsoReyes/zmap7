function view_qva(lab1,valueMap)
    % view_maxz plots the maxz LTA values calculated
    % with maxzlta.m or other similar values as a color map
    % needs valueMap, gx, gy, stri
    %
    % define size of the plot etc.
    %
%     The Z-Value Map Window      
%
%                                                          
%           This window displays seismicity rate changes    
%           as z-values using a color code. Negative        
%           z-values indicate an increase in the seismicity
%           rate, positive values a decrease.               
%           Some of the menu-bar options are                
%           described below:                                
%                                                           
%           Threshold: You can set the maximum size that    
%             a volume is allowed to have in order to be    
%             displayed in the map. Therefore, areas with   
%             a low seismicity rate are not displayed.      
%             edit the size (in km) and click the mouse     
%             outside the edit window.                      
%         'FixAx: You can chose the minimum and maximum     
%                  values of the color-legend used.         
%         'Polygon: You can select earthquakes in a         
%           polygon either by entering the coordinates or   
%           defining the corners with the mouse             
%
%         'Circle: Select earthquakes in a circular volume:
%                Ni, the number of selected earthquakes can
%                be edited in the upper right corner of the
%                window.                                    
%           Refresh Window: Redraws the figure, erases      
%                 selected events.                          
%         
%           zoom: Selecting Axis -> zoom on allows you to   
%                 zoom into a region. Click and drag with   
%                 the left mouse button. type <help zoom>   
%                 for details.                              
%           Aspect: select one of the aspect ratio options 
%           Text: You can select text items by clicking. The
%                 selected text can be rotated, moved, you 
%                 can change the font size etc.             
%                 Double click on text allows editing it.   

    
    report_this_filefun(mfilename('fullpath'));
    ZG=ZmapGlobal.Data;
    % Find out if figure already exists
    %
    qmap=findobj('Type','Figure','-and','Name','q-detect-map');
    
    
    % Set up the Seismicity Map window Enviroment
    %
    if isempty(qmap)
        qmap = figure_w_normalized_uicontrolunits( ...
            'Name','q-detect-map',...
            'NumberTitle','off', ...
            'NextPlot','new', ...
            'backingstore','on',...
            'Visible','off', ...
            'Position',position_in_current_monitor(ZG.map_len(1), ZG.map_len(2)));
        
        lab1 = 'day/night ratio';
        create_my_menu();
        
        
        uicontrol('Units','normal',...
            'Position',[.0 .93 .08 .06],'String','Info ',...
            'callback',@callbackfun_001);
        
        
        uicontrol('Units','normal',...
            'Position',[.92 .80 .08 .05],'String','set ni',...
            'callback',@callbackfun_006)
        
        
        set_nia = uicontrol('style','edit','value',ni,'string',num2str(ni));
        set(set_nia,'callback',@callbackfun_007);
        set(set_nia,'units','norm','pos',[.94 .85 .06 .05],'min',10,'max',10000);
        nilabel = uicontrol('style','text','units','norm','pos',[.90 .85 .04 .05]);
        set(nilabel,'string','ni:','background',[.7 .7 .7]);
        

        
        ZG.tresh_km = nan; re4 = valueMap;
        nilabel2 = uicontrol('style','text','units','norm','pos',[.60 .92 .25 .06]);
        set(nilabel2,'string','MinRad (in km):','background',color_fbg);
        set_ni2 = uicontrol('style','edit','value',ZG.tresh_km,'string',num2str(ZG.tresh_km),...
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
    figure(qmap);
    delete(findobj(qmap,'Type','axes'));
    % delete(sizmap);
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
    ZG.maxc = max(valueMap(:));
    ZG.maxc = fix(ZG.maxc)+1;
    ZG.minc = min(valueMap(:));
    ZG.minc = fix(ZG.minc)-1;
    
    % set values gretaer ZG.tresh_km = nan
    %
    re4 = valueMap;
    l = r > ZG.tresh_km;
    re4(l) = nan(1,length(find(l)));
    
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
    
    shading(ZG.shading_style);

    fix_caxis.ApplyIfFrozen(gca); 
    
    
    title([name ';  '   num2str(t0b) ' to ' num2str(teb) ],'FontSize',ZmapGlobal.Data.fontsz.s,...
        'Color','r','FontWeight','bold')
    
    xlabel('Longitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
    ylabel('Latitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
    
    % plot overlay
    %
    hold on
    zmap_update_displays();
    ploeq = plot(ZG.primeCatalog.Longitude,ZG.primeCatalog.Latitude,'k.');
    set(ploeq,'Tag','eq_plot','MarkerSize',ZG.ms6,'Marker',ty,'Color',ZG.someColor,'Visible','on')
    
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
        'Units','normalized',...
        'Position',[ 0.33 0.07 0 ],...
        'HorizontalAlignment','right',...
        'FontSize',ZmapGlobal.Data.fontsz.s,....
        'FontWeight','bold',...
        'String',lab1);
    
    % Make the figure visible
    %
    set(gca,'FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','TickDir','out')
    figure(qmap);
    axes(h1)
    watchoff(qmap)
    whitebg(gcf,[ 0 0 0 ])
    
    
    %% ui functions
    function create_my_menu()
        add_menu_divider();
        
        add_symbol_menu('eq_plot');
        
        options = uimenu('Label',' Select ');
        uimenu(options,'Label','Refresh ', 'callback',@callbackfun_002)
        uimenu(options,'Label','Select EQ in Circle', 'callback',@callbackfun_003)
        uimenu(options,'Label','Select EQ in Polygon ', 'callback',@callbackfun_004)
        
        op1 = uimenu('Label',' Maps ');
        uimenu(op1,'Label','day/night value map',...
            'callback',@callbackfun_005)
        
        
        add_display_menu(1);
    end
    
    %% callback functions
    
    function callbackfun_001(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        web(['file:' hodi '/help/quarry.htm']) ;
    end
    
    function callbackfun_002(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        delete(findobj(qmap,'Type','axes'));
        view_qva(lab1,valueMap);
    end
    
    function callbackfun_003(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        circle;
        watchoff(qmap);
        hisgra(ZG.newt2.Date.Hour,'Hour',ZG.newt2.Name);
    end
    
    function callbackfun_004(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        stri = 'Polygon';
        h1 = gca;
        cufi = gcf;
        selectp;
        hisgra(ZG.newt2,'Hour');
    end
    
    function callbackfun_005(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1 ='day/night ratio';
        valueMap = old;
        view_qva(lab1,valueMap);
    end
    
    function callbackfun_006(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ni=str2num(set_nia.String);
        'String';
        num2str(ni);
    end
    
    function callbackfun_007(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        %FIXME callback does nothing
    end
    
    function callbackfun_008(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.tresh_km=str2double(set_ni2.String);
        set_ni2.String=num2str(ZG.tresh_km);
    end
    
    function callbackfun_009(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ;
        pause(1);
        re4 =valueMap;
        view_bva(lab1,valueMap);
    end
end
