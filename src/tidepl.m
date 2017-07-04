function tidepl()
    %  tidpl  plots a time depth plot of the seismicity
    %  Stefan Wiemer 5/95
    %
    %TODO delete this, replaced by TimeDepthPlotter.plot(catalog)
    global maepi dep1 dep2 dep3 newt2 ms6 ty1 ty2 ty3 a wex wey
    report_this_filefun(mfilename('fullpath'));
    
    
    newcat = a;
    xt2  = [ ];
    meand = [ ];
    er = [];
    ind = 0;
    
    % Find out of figure already exists
    %
    figNumber = findobj(0,'Tag','time_depth_figure');
    
    % Set up the Seismicity Map window Enviroment
    %
    if isempty(figNumber)
        
        figNumber = figure_w_normalized_uicontrolunits(...
            'Name','Time Depth',...
            'visible','off',...
            'NumberTitle','off', ...
            'MenuBar','none', ...
            'NextPlot','new', ...
            'Tag','time_depth_figure',...
            'Units','Pixel',  'Position',[wex wey 550 400'])
        hold on
        matdraw
        
        % Make the menu to change symbol size and type
        %
        symbolmenu = uimenu('Label',' Symbol ');
        SizeMenu = uimenu(symbolmenu,'Label',' Symbol Size ');
        TypeMenu = uimenu(symbolmenu,'Label',' Symbol Type ');
        uimenu(SizeMenu,'Label','3','Callback','ms6 =3;eval(cal6)');
        uimenu(SizeMenu,'Label','6','Callback','ms6 =6;eval(cal6)');
        uimenu(SizeMenu,'Label','9','Callback','ms6 =9;eval(cal6)');
        uimenu(SizeMenu,'Label','12','Callback','ms6 =12;eval(cal6)');
        uimenu(SizeMenu,'Label','14','Callback','ms6 =14;eval(cal6)');
        uimenu(SizeMenu,'Label','18','Callback','ms6 =18;eval(cal6)');
        uimenu(SizeMenu,'Label','24','Callback','ms6 =24;eval(cal6)');
        
        uimenu(TypeMenu,'Label','dot',...
            'Callback','ty1=''.'';ty2=''.'';ty3=''.'';eval(cal6)');
        uimenu(TypeMenu,'Label','red+ blue o green x',...
            'Callback','ty1=''+'';ty2=''o'';ty3=''x'';eval(cal6)');
        uimenu(TypeMenu,'Label','o','Callback',...
            'ty1=''o'';ty2=''o'';ty3=''o'';eval(cal6)');
        uimenu(TypeMenu,'Label','x','Callback',...
            'ty1=''x'';ty2=''x'';ty3=''x'';eval(cal6)');
        uimenu(TypeMenu,'Label','*',...
            'Callback','ty1=''*'';ty2=''*'';ty3=''*'';eval(cal6)');
        uimenu(TypeMenu,'Label','none','Callback','set(deplo1,''visible'',''off'');set(deplo2,''visible'',''off'');set(deplo3,''visible'',''off''); ');
        cal6 = ...
            [ 'set(deplo1,''MarkerSize'',ms6,''LineStyle'',ty1,''visible'',''on'');',...
            'set(deplo2,''MarkerSize'',ms6,''LineStyle'',ty2,''visible'',''on'');',...
            'set(deplo3,''MarkerSize'',ms6,''LineStyle'',ty3,''visible'',''on'');' ];
        
        
        
    end  % if figure exist
    figure(figNumber)
    p5 = findobj(figNumber,'Tag','time_depth_plot');%assumes we only need one plot
    if isempty(p5)
        orient tall
        rect = [0.15, 0.15, 0.75, 0.65];
        p5 = gca;
        p5.Tag = 'time_depth_plot';
        p5.Position = rect;
    end
    
    depidx = newt2.Depth<=dep1;
    plotTimeDepthSection(p5, newt2, depidx, [ty1 'b'], 'shallower', 'timedepth_depths1');
    %{
    deplo1 = findobj(p5,'Tag','timedepth_depths1');
    if isempty(deplo1)
        deplo1 =plot(p5, newt2.Date(depidx), -newt2.Depth(depidx),'.b','DisplayName','shallower','Tag','timedepth_depths1');
    else
        set(deplo1,'Xdata',newt2.Date(depidx),'YData',newt2.Depth(depidx));
    end
    set(deplo1,'MarkerSize',ms6,'Marker',ty1)
    %}
    hold on
    
    depidx = newt2.Depth<=dep2&newt2.Depth>dep1;
    plotTimeDepthSection(p5, newt2, depidx, [ty2 'g'], 'mid-depth', 'timedepth_depths2');
    
    %deplo2 =plot(p5, newt2.Date(depidx),-newt2.Depth(depidx),'.g','DisplayName','mid-depth','Tag','timedepth_depths2');
    %set(deplo2,'MarkerSize',ms6,'Marker',ty2);
    
    depidx = dep3 >= newt2.Depth & newt2.Depth > dep2;
    plotTimeDepthSection(p5, newt2, depidx, [ty3 'r'], 'mid-depth', 'timedepth_depths3');
    
    %deplo3 =plot(p5, newt2.Date(depidx),-newt2.Depth(depidx),'.r', 'DisplayName','deeper','Tag','timedepth_depths3');
    %set(deplo3,'MarkerSize',ms6,'Marker',ty3)
    
    if ~isempty(maepi)
        if isnumeric(maepi)
            maepi = ZmapCatalog(maepi);
            warning('converted maepi to ZmapCatalog in tidepl');
        end
        pl = findobj(p5,'Tag','timedepth_bigevents');
        if isempty(pl)
            pl =   plot(p5, maepi.Date, -maepi.Depth,'xm','Tag','timedepth_bigevents');
        else
            set(pl,'XData',maepi.Date, 'YData', -maepi.Depth,'Color','m','Marker','x');
        end
        set(pl,'LineWidth',2.0)
    end
    
    xlabel(p5,'Time in Years','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    ylabel(p5,'Depth in [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    
    set(p5,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
    
    grid
    hold off
    done
end
function plotTimeDepthSection(ax, catalog, idx, linechars, displayname, tag)
    % add a part to the time-depth plot
    % reuses if possible
    global ms6
    lineh = findobj(ax,'Tag', tag);
    if isempty(lineh)
        lineh = plot(ax, catalog.Date(idx), -catalog.Depth(idx),linechars,'DisplayName',displayname,'Tag',tag);
    else
        
        set(lineh,'Xdata',catalog.Date(idx),'YData',-catalog.Depth(idx), 'color',linechars(2),'Marker',linechars(1));
    end
    set(lineh,'MarkerSize',ms6);%,'Marker',ty1);
end