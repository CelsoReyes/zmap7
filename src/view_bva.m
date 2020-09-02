function view_bva(lab1, valueMap,gx,gy)
    % view_maxz plots the maxz LTA values calculated
    % with maxzlta.m or other similar values as a color map
    % needs valueMap, gx, gy, stri
    %
    % define size of the plot etc.
    %
    
    %% function steps
    %   - create a figure if it doesn't exist   Name: b-value-map
    %      * should it overlay on the Main Map, instead? If so, it would need
    
    %%
    
    if ~exist('Prmap') || isempty(Prmap)
        Prmap = nan(size(valueMap));
    end
    ZG=ZmapGlobal.Data;
    
    report_this_filefun();
    ZG.someColor = 'w';
    
    
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
            'Position',[ (ZG.fipo(3:4) - [600 400]) ZG.map_len]);
        % make menu bar
        
        
        lab1 = 'b-value:';
        create_my_menu();
        
        ZG.tresh_km = nan; re4 = valueMap;
        
        colormap(jet)
        ZG.tresh_km = nan; minpe = nan; Mmin = nan;
        
    end   % This is the end of the figure setup
    
    % Now lets plot the color-map of the z-value
    %
    figure(bmap);
    delete(findobj(bmap,'Type','axes'));
    % delete(sizmap);
    reset(gca)
    cla
    set(gca,'NextPlot','replace')
    watchon;
    set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','normal',...
        'FontWeight','normal','LineWidth',1,...
        'Box','on','SortMethod','childorder')
    
    rect = [0.18,  0.10, 0.7, 0.75];
    rect1 = rect;
    
    % find max and min of data for automatic scaling
    %
    ZG.maxc = max(valueMap(:));
    ZG.maxc = fix(ZG.maxc)+1;
    ZG.minc = min(valueMap(:));
    ZG.minc = fix(ZG.minc)-1;
    
    % plot image
    %
    orient landscape
    %set(gcf,'PaperPosition', [0.5 1 9.0 4.0])
    
    axes('position',rect)
    set(gca,'NextPlot','add')
    pco1 = pcolor(gx,gy,valueMap);
    
    axis([ min(gx) max(gx) min(gy) max(gy)])
    set(gca,'dataaspect',[1 cosd(nanmean(ZG.primeCatalog.Latitude)) 1]);
    set(gca,'NextPlot','add')
    
    shading(ZG.shading_style);

    % make the scaling for the recurrence time map reasonable
    if ~isempty(lab1)&& lab1(1) =='T'
        re = valueMap(~isnan(valueMap));
        caxis([min(re) 5*min(re)]);
    end

    fix_caxis.ApplyIfFrozen(gca); 
    
    title([ZG.primeCatalog.Name ';  '   num2str(ZG.t0b) ' to ' num2str(ZG.teb) ],'FontSize',ZmapGlobal.Data.fontsz.s,...
        'Color','r','FontWeight','normal','Interpreter','none')
    
    xlabel('Longitude [deg]','FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s)
    ylabel('Latitude [deg]','FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s)
    
    % plot overlay
    %
    set(gca,'NextPlot','add')
    zmap_update_displays();
    ploeq = plot(ZG.primeCatalog.Longitude,ZG.primeCatalog.Latitude,'k.');
    set(ploeq,'Tag','eq_plot','MarkerSize',ZG.ms6,'Marker',ty,'Color',ZG.someColor,'Visible','on')
    
    
    set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','normal',...
        'FontWeight','normal','LineWidth',1,...
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
        'Units','normalized',...
        'Position',[ 0.2 0.06 0 ],...
        'HorizontalAlignment','right',...
        'FontSize',ZmapGlobal.Data.fontsz.s,....
        'FontWeight','normal',...
        'String',lab1);
    
    % Make the figure visible
    %
    set(gca,'FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','normal',...
        'FontWeight','normal','LineWidth',1,...
        'Box','on','TickDir','out')
    figure(bmap);
    %sizmap = signatur('ZMAP','',[0.01 0.04]);
    %set(sizmap,'Color','k')
    axes(h1)
    set(gcf,'color','w');
    watchoff(bmap)
    %whitebg(gcf,[ 0 0 0 ])
    
    
    function adju()
        report_this_filefun();
        
        
        prompt={'Enter the minimum magnitude cut-off',...
            'Enter the maximum radius cut-off:',...
            'Enter the minimum goodness of fit percatge'};
        def={'nan','nan','nan'};
        dlgTitle='Input Map subselection Criteria';
        lineNo=1;
        answer=inputdlg(prompt,dlgTitle,lineNo,def);
        re4 = valueMap;
        Mmin = str2double(answer{1,1}) ;
        ZG.tresh_km = str2double(answer{2,1}) ;
        minpe = str2double(answer{3,1}) ;
    end
    
    %% ui functions
    function create_my_menu()
        add_menu_divider();
        
        add_symbol_menu('eq_plot');
        
        options = uimenu('Label',' Select ');
        uimenu(options,'Label','Refresh ','MenuSelectedFcn',@cb_refresh)
        uimenu(options,'Label','Select EQ in Circle',...
            'MenuSelectedFcn',@cb_seleq_cir)
        uimenu(options,'Label','Select EQ in Circle - Constant R',...
            'MenuSelectedFcn',@cb_seleq_cir_r)
        uimenu(options,'Label','Select EQ in Circle - Overlay existing plot',...
            'MenuSelectedFcn',@cb_seleq_cir_overlay)
        
        uimenu(options,'Label','Select EQ in Polygon -new ',...
            'MenuSelectedFcn',@cb_seleq_poly_new)
        uimenu(options,'Label','Select EQ in Polygon - hold ',...
            'MenuSelectedFcn',@cb_seleq_poly_hold)
        
        
        op1 = uimenu('Label',' Maps ');
        
        adjmenu =  uimenu(op1,'Label','Adjust Map Display Parameters');
        uimenu(adjmenu,'Label','Adjust Mmin cut',...
            'MenuSelectedFcn',@cb_adjust_min_cut)
        uimenu(adjmenu,'Label','Adjust Rmax cut',...
            'MenuSelectedFcn',@cb_adjust_max_cut)
        uimenu(adjmenu,'Label','Adjust goodness of fit cut',...
            'MenuSelectedFcn',@cb_adjust_goodness_cut)
        
        
        uimenu(op1,'Label','b-value map (max likelihood)',...
            'MenuSelectedFcn',@cb_bval_maxlikelihood)
        uimenu(op1,'Label','Standard deviation of b-Value (max likelihood) map',...
            'MenuSelectedFcn',@cb_std_bval)
        uimenu(op1,'Label','Magnitude of completness map',...
            'MenuSelectedFcn',@cb_magcomp)
        uimenu(op1,'Label','Standard deviation of magnitude of completness',...
            'MenuSelectedFcn',@cb_std_magcomp)
        uimenu(op1,'Label','Goodness of fit to power law map',...
            'MenuSelectedFcn',@cb_goodfit_powerlaw)
        uimenu(op1,'Label','Resolution map',...
            'MenuSelectedFcn',@cb_resolution)
        uimenu(op1,'Label','Earthquake density map',...
            'MenuSelectedFcn',@cb_eqdensity)
        uimenu(op1,'Label','a-value map',...
            'MenuSelectedFcn',@cb_avalue)
        
        
        if exist('mStdDevB')
            AverageStdDevMenu = uimenu(op1,'Label', 'Additional random simulation');
            uimenu(AverageStdDevMenu,'Label', 'Bootstrapped standard deviation of b-value',...
                'MenuSelectedFcn',@cb_bootstrap_std_bval)
            uimenu(AverageStdDevMenu,'Label', 'Bootstrapped standard deviation of Mc',...
                'MenuSelectedFcn',@cb_bootstrap_std_mc)
            uimenu(AverageStdDevMenu,'Label', 'b-value map (max likelihood) with std. deviation',...
                'MenuSelectedFcn',@cb_bval_with_std)
        end
        
        recmenu = uimenu(op1,'Label','recurrence time map ')...
        
        uimenu(recmenu,'Label','recurrence time map ',...
            'MenuSelectedFcn',@cb_recurrence_time)
        
        uimenu(recmenu,'Label','(1/Tr)/area map ',...
            'MenuSelectedFcn',@cb_oneovertroverarea)
        
        uimenu(recmenu,'Label','recurrence time percentage ',...
            'MenuSelectedFcn',@cb_recperc)
        
        
        
        uimenu(op1,'Label','Histogram ','MenuSelectedFcn',@(~,~)zhist())
        uimenu(op1,'Label','Reccurrence Time Histogram ','MenuSelectedFcn',@cb_rechist)
        uimenu(op1,'Label','Save map to ASCII file ','MenuSelectedFcn',@callbackfun_026)
        
        add_display_menu(4);
    end
    
    %% callback functions
    
    function cb_refresh(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        view_bva(lab1,valueMap);
    end
    
    function cb_seleq_cir(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        met = 'ni';
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        cirbva;
        watchoff(bmap);
    end
    
    function cb_seleq_cir_r(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        met = 'ra';
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        cirbva;
        watchoff(bmap);
    end
    
    function cb_seleq_cir_overlay(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=true;
        cirbva;
        watchoff(bmap);
    end
    
    function cb_seleq_poly_new(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        cufi = gcf;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        selectp;
    end
    
    function cb_seleq_poly_hold(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        cufi = gcf;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=true;
        selectp;
    end
    
    function cb_adjust_min_cut(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        asel = 'mag';
        adju();
        view_bva(lab1,valueMap) ;
    end
    
    function cb_adjust_max_cut(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        asel = 'rmax';
        adju();
        view_bva(lab1,valueMap);
    end
    
    function cb_adjust_goodness_cut(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        asel = 'gofi';
        adju();
        view_bva(lab1,valueMap) ;
    end
    
    function cb_bval_maxlikelihood(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1 ='b-value';
        valueMap = mBvalue;
        view_bva(lab1,valueMap);
    end
    
    function cb_std_bval(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='SdtDev b-Value';
        valueMap = mStdB;
        view_bva(lab1,valueMap);
    end
    
    function cb_magcomp(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1 = 'Mcomp';
        valueMap = mMc;
        view_bva(lab1,valueMap);
    end
    
    function cb_std_magcomp(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1 = 'Mcomp';
        valueMap = mStdMc;
        view_bva(lab1,valueMap);
    end
    
    function cb_goodfit_powerlaw(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1 = ' % ';
        valueMap = Prmap;
        view_bva(lab1,valueMap);
    end
    
    function cb_resolution(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='Radius in [km]';
        valueMap = r;
        view_bva(lab1,valueMap);
    end
    
    function cb_eqdensity(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='log(EQ per km^2)';
        valueMap = log10(mNumEq./(r.^2*pi));
        view_bva(lab1,valueMap);
    end
    
    function cb_avalue(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='a-value';
        valueMap = mAvalue;
        view_bva(lab1,valueMap);
    end
    
    function cb_bootstrap_std_bval(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='standard deviation of b-value';
        valueMap = mStdDevB;
        view_bva(lab1,valueMap);
    end
    
    function cb_bootstrap_std_mc(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='standard deviation of Mc';
        valueMap = mStdDevMc;
        view_bva(lab1,valueMap);
    end
    
    function cb_bval_with_std(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='b-value';
        valueMap = mBvalue;
        bOverlayTransparentStdDev = true;
        view_bva(lab1,valueMap);
    end
    
    function cb_recurrence_time(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        def = {'6'};
        m = inputdlg('Magnitude of projected mainshock?','Input',1,def);
        m1 = m{:};
        m = str2num(m1);
        lab1 = 'Tr (yrs) (sm. values only)';
        valueMap =(teb - t0b)./(10.^(mAvalue-m*mBvalue));
        mrt = m;
        view_bva(lab1,valueMap);
    end
    
    function cb_oneovertroverarea(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        def = {'6'};
        m = inputdlg('Magnitude of projected mainshock?','Input',1,def);
        m1 = m{:};
        m = str2num(m1);
        lab1 = '1/Tr/area ';
        valueMap =(teb - t0b)./(10.^(mAvalue-m*mBvalue));
        valueMap = 1./valueMap/(2*pi*ra*ra);
        mrt = m;
        view_bva(lab1,valueMap);
    end
    
    function cb_recperc(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        recperc;
    end
    
    function cb_rechist(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        rechist;
    end
    
    function callbackfun_026(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        savemap;
    end
end
