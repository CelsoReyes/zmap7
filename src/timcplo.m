function timcplo(newa) 
    %  tidpl  plots a time projection plot of the seismicity
    %  Stefan Wiemer 5/95
    %
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    report_this_filefun();
    
    
    ZG.newcat = newa;
    xt2  = [ ];
    meand = [ ];
    er = [];
    ind = 0;
    
    % Find out if figure already exists
    %
    tifg=findobj('Type','Figure','-and','Name','Time Distance');
    
    
    % Set up the Seismicity Map window Enviroment
    %
    if isempty(tifg)
        
        tifg=figure_w_normalized_uicontrolunits(...
            'Name','Time Distance',...
            'visible','off',...
            'NumberTitle','off', ...
            'NextPlot','new', ...
            'Units','Pixel',  'Position',[ZG.welcome_pos 550 400'])
        set(gca,'NextPlot','add')
        axis off
        
        %create_my_menu();
        
    end  % if figure exist
    
    figure(tifg);
    delete(findobj(tifg,'Type','axes'));
    set(gca,'visible','off');
    
    orient tall
    rect = [0.15, 0.15, 0.75, 0.65];
    axes('position',rect)
    p5 = gca;
    
    scatter(newa.DistAlongStrike, newa.Date, mag2dotsize(newa.Magnitude),newa.Magnitude)%,'.b','MarkerSize',ZG.ms6,'Marker','+');
    c=colorbar;
    c.Label.String='Magnitude';
    %{
    targ = newa.Depth<=dep1;
    plot(DistAlongStrike(targ),newa.Date(targ),'.b','MarkerSize',ZG.ms6,'Marker',ty1);
    set(gca,'NextPlot','add')
    targ=newa.Depth<=dep2&newa.Depth>dep1;
    plot(DistAlongStrike(targ),newa.Date(targ),'.g','MarkerSize',ZG.ms6,'Marker',ty2);
    targ=newa.Depth<=dep3&newa.Depth>dep2;
    plot(DistAlongStrike(targ),newa.Date(targ),'.r','MarkerSize',ZG.ms6,'Marker',ty3);
    %}
    title('Events along strike through time')
    xlabel(['Distance in [',newa.HorizontalUnit,'] '],'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    ylabel('Time  in years ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    
    set(gca,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
    
    grid
    set(gca,'NextPlot','replace')
    
    
    %% ui functions
    function create_my_menu()
        add_menu_divider();
        add_symbol_menu();
    end
    
    %% callback functions
    % none.
end
