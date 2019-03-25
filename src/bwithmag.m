function bwithmag(catalog) 
    % calculate b-value with magnitude
    
    % turned into function by Celso G Reyes 2017
    ZG = ZmapGlobal.Data;
    
    BV3 = [];
    Nmin = 20;
    
    magnitudes = sort(catalog.Magnitude);
    newt1=copy(catalog);
    newt1.sort('Magnitude');
    binCenters = magnitudes(1) : 0.1 :magnitudes(end);
    
    for idx = 1: numel(binCenters)
        t = binCenters(idx);
        % calculate b-value based an weighted LS
        b = magnitudes(magnitudes >= t - 0.05);
        
        if numel(b) >= Nmin
            [~, ~, stan, ~] =  bvalca3(b, McAutoEstimate.manual);
            bv = calc_bmemag(b, 0.1);
            
        else
            [bv] = deal(nan);
        end
        BV3 = [BV3 ; bv t stan ];
        
    end
    
    watchoff
    
    %% plot it
    myFigName='b-value with magnitude';
    errorColor = [0.5, 0.5, 0.5];
        
    bdep = findobj('Type', 'Figure', '-and', 'Name', myFigName);
    % Set up the Cumulative Number window
    
    if isempty(bdep)
        bdep = figure( ...
            'Name'          , myFigName,...
            'NumberTitle'   , 'off', ...
            'NextPlot'      , 'add', ...
            'backingstore'  , 'on',...
            'Visible'       , 'on', ...
            'Position'      , position_in_current_monitor(ZG.map_len(1)-50, ZG.map_len(2)-20));
    else
        figure(bdep);
        clf(bdep);
    end
    
    orient tall;
    rect  = [0.15 0.15 0.7 0.7];
    ax    = axes(bdep, 'position', rect);
    ple   = errorbar(BV3(:,2),BV3(:,1),BV3(:,3),BV3(:,3),'k');
    ple(1).Color = errorColor;
    
    ax.NextPlot = 'add';
    plot(ax, BV3(:,2), BV3(:,1), 'sk', 'LineWidth', 1.0, 'MarkerSize', 4,...
        'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k', 'Marker', 's');
    
    set(ax, 'box','on', 'SortMethod', 'childorder',...
            'TickDir', 'out', 'Ticklength', [ 0.02, 0.02],...
            'FontWeight', 'bold', 'FontSize', ZmapGlobal.Data.fontsz.m,...
            'Linewidth', 1)
    strib = sprintf('%s,  Mmax = %g', catalog.Name, min(magnitudes));
    ylabel(ax, 'b-value')
    xlabel(ax, 'Magnitude')
    title(ax, strib, 'FontWeight', 'bold',...
        'FontSize', ZmapGlobal.Data.fontsz.m,...
        'Interpreter', 'none',...
        'Color', 'k')
end
