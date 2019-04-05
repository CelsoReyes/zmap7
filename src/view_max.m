function view_max(valueMap,gx,gy,stri,myselector) 
    % view_maxz plots the maxz LTA values calculated
    % with maxzlta.m or other similar values as a color map
    %
    % define size of the plot etc.
    %
%         The Z-Value Map Window   
%                                                    
%           This window displays seismicity rate changes    
%           as z-values using a color code. Negative        
%           z-values indicate an increase in the seismicity'
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
%          FixAx: You can chose the minimum and maximum     
%                  values of the color-legend used.         
%          Polygon: You can select earthquakes in a         
%           polygon either by entering the coordinates or   
%           defining the corners with the mouse           
%                 
%          Circle: Select earthquakes in a circular volume:'
%                Ni, the number of selected earthquakes can'
%                be edited in the upper right corner of the'
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
        
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals

    
    report_this_filefun();
    ZG.someColor = 'w';

    if isempty(myselector)
        error('empty  selector?')
    end
    
    if myselector == 'pro'
        valueMap = old;
        valueMap(valueMap < 2.57) = 2.57;
        pr = 0.0024 + 0.03*(valueMap - 2.57).^2;
        pr = (1-1./(exp(pr)));
        valueMap = pr;
    end   % if myselector = pro
    
    % Find out if figure already exists
    %
    zmap=findobj('Type','Figure','-and','Name','Z-Value-Map');
    
    
    % This is the info window text
    %

    
    % Set up the Seismicity Map window Enviroment
    %
    if isempty(zmap)
        zmap = figure_w_normalized_uicontrolunits( ...
            'Name','Z-Value-Map',...
            'NumberTitle','off', ...
            'NextPlot','replace', ...
            'backingstore','on',...
            'Visible','off', ...
            'Position',position_in_current_monitor(ZG.map_len(1), ZG.map_len(2)));
        
        uicontrol('Units','normal',...
            'Position',[.0 .93 .08 .06],'String','Print ',...
            'callback',@callbackfun_001)
        
        uicontrol('Units','normal',...
            'Position',[.0 .75 .08 .06],'String','Close ',...
            'callback',@callbackfun_002)
        
        uicontrol('Units','normal',...
            'Position',[.0 .85 .08 .06],'String','Info ',...
            'callback',@callbackfun_003);
        
        
        uicontrol('Units','normal',...
            'Position',[.92 .80 .08 .05],'String','set ni',...
            'callback',@callbackfun_020)
        
        create_my_menu();
        
        set_nia = uicontrol('style','edit','value',ni,'string',num2str(ni));
        set(set_nia, 'Callback', @callbackfun_021);
        set(set_nia,'units','norm','pos',[.94 .85 .06 .05],'min',10,'max',10000);
        nilabel = uicontrol('style','text','units','norm','pos',[.90 .85 .04 .05]);
        set(nilabel,'string','ni:','background',[.7 .7 .7]);

        
        ZG.tresh_km = max(r(:)); re4 = valueMap;
        nilabel2 = uicontrol('style','text','units','norm','pos',[.60 .92 .25 .06]);
        set(nilabel2,'string','MinRad (in km):','background',color_fbg);
        set_ni2 = uicontrol('style','edit','value',ZG.tresh_km,'string',num2str(ZG.tresh_km),...
            'background','y');
        set(set_ni2, 'Callback', @callbackfun_022); %FIXME callback does nothing!
        set(set_ni2,'units','norm','pos',[.85 .92 .08 .06],'min',0.01,'max',10000);
        
        uicontrol('Units','normal',...
            'Position',[.95 .93 .05 .05],'String','Go ',...
            'callback',@callbackfun_023)
        
        colormap(jet)
        
    end   % This is the end of the figure setup
    
    % Now lets plot the color-map of the z-value
    %
    figure(zmap);
    delete(findobj(zmap,'Type','axes'));
    % delete(sizmap);
    reset(gca)
    cla
    set(gca,'NextPlot','replace')
    watchon;
    set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
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
    [len, ncu] = size(cumuall);
    %
    [n1, n2] = size(cumuall);
    s = cumuall(n1,:);
    normlap2(ll)= s(:);
    %construct a matrix for the color plot
    r=reshape(normlap2,length(yvect),length(xvect));
    
    
    
    %r = reshape(cumuall(len,:),length(gy),length(gx));
    re4(r > ZG.tresh_km) = nan;
    
    % plot image
    %
    orient landscape
    set(gcf,'PaperPosition',[ 0.1 0.1 8 6])
    axes('position',rect)
    set(gca,'NextPlot','add')
    pco1 = pcolor(gx,gy,re4);
    axis([ s2_west s1_east s4_south s3_north])

    shading(ZG.shading_style);

    fix_caxis.ApplyIfFrozen(gca); 
    
    if  myselector == 'per'
        colormap( flipud(jet(64)) )
    end
    set(gca,'dataaspect',[1 cosd(mean(ZG.primeCatalog.Latitude)) 1]);
    
    title([name ' (' myselector '); ' num2str(t0b) ' to ' num2str(teb) ' - cut at ' num2str(it) '; winlen_days = ' char(ZG.compare_window_dur)],'FontSize',ZmapGlobal.Data.fontsz.m,...
        'Color','k','FontWeight','bold')
    
    xlabel('Longitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    ylabel('Latitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    
    % plot overlay
    %
    overlay
    set(ploeq,'MarkerSize',ZG.ms6,'Marker',ty,'Color',ZG.someColor,'visible','on');
    
    set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','TickDir','out')
    h1 = gca;
    hzma = gca;
    
    % Create a colobar
    %
    h5 = colorbar('horiz');
    set(h5,'Pos',[0.25 0.09 0.5 0.05],'TickDir','out',...
        'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m','YTick',[]')
    
    %  Text Object Creation
    txt1 = text(...
        'Units','normalized',...
        'Position',[ -0.20 -0.2 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.m,....
        'FontWeight','bold',...
        'String','z-value:');
    if myselector =='per'
        set(txt1,'String','Change in %')
    end
    if myselector =='pro'
        set(txt1,'String','Probability')
    end
    if myselector =='res'
        set(txt1,'String','Radius in km')
    end
    
    % Make the figure visible
    %
    set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,'Color','k',...
        'Box','on','TickDir','out')
    figure(zmap);
    axes(h1)
    watchoff(zmap)
    
    
    %% ui functions
    % TODO Create Select MENU - select eq in circle, polygon, refresh
    function create_my_menu()
        add_menu_divider();
        op1 = uimenu('Label',' Tools ');
        uimenu(op1,'Label','ZMAP Menu',MenuSelectedField(),@callbackfun_004)
        uimenu(op1,'Label','Plot Map in Lambert projection',MenuSelectedField(),@callbackfun_005)
        uimenu(op1,'Label','Fix color (z) scale',MenuSelectedField(),@callbackfun_006)
        uimenu(op1,'Label','Histogram of z-values',MenuSelectedField(),@(~,~)zhist())
        uimenu(op1,'Label','Probability Map',MenuSelectedField(),@callbackfun_008)
        uimenu(op1,'Label','Back to z-value Map',MenuSelectedField(),@callbackfun_009)
        uimenu(op1,'Label','Colormap InvertGray',MenuSelectedField(),@callbackfun_010)
        uimenu(op1,'Label','Colormap Invertjet',...
            MenuSelectedField(),@callbackfun_011)
        
        uimenu(op1,'Label','Resolution Map',MenuSelectedField(),@callbackfun_012)
        uimenu(op1,'Label','Show Grid ',...
            MenuSelectedField(),@callbackfun_013)
        uimenu(op1,'Label','Show Circles ',MenuSelectedField(),@callbackfun_014)
        uimenu(op1,'Label','shading flat',MenuSelectedField(),@callbackfun_015)
        uimenu(op1,'Label','shading interpolated',...
            MenuSelectedField(),@callbackfun_016)
        uimenu(op1,'Label','Brigten +0.4',...
            MenuSelectedField(),@callbackfun_017)
        uimenu(op1,'Label','Brigten -0.4',...
            MenuSelectedField(),@callbackfun_018)
        
        uimenu(op1,'Label','Redraw Overlay',...
            MenuSelectedField(),@callbackfun_019)
    end
    
    %% callback functions
    function callbackfun_001(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        printdlg;
    end
    
    function callbackfun_002(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        f1=gcf; 
        f2=gpf; 
        set(f1,'Visible','off');
        close(zmap);
        if f1~=f2
            figure(map); 
        end
    end
    
    function callbackfun_003(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        helpdlg(help('view_max'),'Help for view_max')
    end
    
    function callbackfun_004(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        zmapmenu ;
    end
    
    function callbackfun_005(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        plotmap ;
    end
    
    function callbackfun_006(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        fix_caxis(ZGvalueMap,'horiz') ;
    end
    
    function callbackfun_008(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        myselector = 'pro';
        ZG.freeze_colorbar = false;
        view_max(valueMap,gx,gy,myselector);
    end
    
    function callbackfun_009(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        myselector = 'nop';
        ZG.freeze_colorbar = false;
        valueMap = old;
        view_max(valueMap,gx,gy,stri,myselector);
    end
    
    function callbackfun_010(mysrc,myevt)
        colormap( flipud(gray(64)) );
        brighten(.4);
    end
    
    function callbackfun_011(mysrc,myevt)
        colormap( flipud( jet(64) ));
    end
    
    function callbackfun_012(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        valueMap = r;
        ZG.freeze_colorbar = false;
        myselector = 'res';
        view_max(valueMap,gx,gy,stri,myselector);
    end
    
    function callbackfun_013(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        plot(newgri(:,1),newgri(:,2),'+k');
    end
    
    function callbackfun_014(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        plotci2;
    end
    
    function callbackfun_015(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.shading_style='flat';
        axes(hzma);
        shading flat;
    end
    
    function callbackfun_016(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.shading_style='interp';
        axes(hzma);
        shading interp;
    end
    
    function callbackfun_017(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        axes(hzma);
        brighten(0.4);
    end
    
    function callbackfun_018(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        axes(hzma);
        brighten(-0.4);
    end
    
    function callbackfun_019(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        set(gca,'NextPlot','add');
        zmap_update_displays();
    end
    
    function callbackfun_020(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ni=str2num(set_nia.String);
        'String';
        num2str(ni);
    end
    
    function callbackfun_021(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
    end
    
    function callbackfun_022(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.tresh_km=str2double(set_ni2.String);
        set_ni2.String=num2str(ZG.tresh_km);
    end
    
    function callbackfun_023(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ;
        pause(1);
        re4 =valueMap;
        view_maxview_max(valueMap,gx,gy,myselector);
    end
    
end
