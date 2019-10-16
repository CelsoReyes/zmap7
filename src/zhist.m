function zhist(values) 
    % this script plots the z-values from a timecut of the map
    % works off ZG.valueMap
    % Stefan Wiemer  11/94
    % turned into function by Celso G Reyes 2017
        
    % This is the info window text
    %
    ttlStr='The Histogram Window                                ';
    hlpStr1= ...
        ['                                                '
        ' This window displays all z-values displayed in '
        ' the z-value map, therefore all the z-values at '
        ' this specific cut in time for the applied      '
        'statstical function.                            '];
    
    
    watchon
    hi = findobj('Type','Figure','-and','Name','Histogram');
    
    %
    % Set up the Cumulative Number window
    
    if isempty(hi)
        hi= figure_w_normalized_uicontrolunits( ...
            'Name','Histogram',...
            'NumberTitle','off', ...
            'NextPlot','new', ...
            'Visible','off', ...
            'Position',position_in_current_monitor(ZmapGlobal.Data.map_len(1)-200, ZmapGlobal.Data.map_len(2)-200));
        
    else
        figure(hi);
        clf(hi)
    end
    ax = axes(hi, 'position', [0.25, 0.18, 0.60, 0.70]);
    orient(hi,'tall')
    set(ax,'visible','off',...
        'FontSize',ZmapGlobal.Data.fontsz.m,...
        'FontWeight','bold',...
        'LineWidth',1.5,...
        'Box','on',...
        'Units','normalized',...
        'NextPlot','add');
    
    [n,edges] = histcounts(values,30);
    x = mean([edges(1:end-1); edges(2:end)]); % bin centers
    bar(ax, x, n, 'k');
    grid(ax,'on')
    xlabel(ax, 'z-value','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m) %what is lab1, at the moment just print 'z-value'
    ylabel(ax, 'Number ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    
    set(hi,'Visible','on');
    watchoff;    
end
