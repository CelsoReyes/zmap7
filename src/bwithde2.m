function bwithde2(catalog)
    % BWITHDE2 plot b-values with depth
    % BWITHDE2(catalog);
    
    % turned into function by Celso G Reyes 2017
    
    ZG = ZmapGlobal.Data; % used by get_zmap_globals
    
    BV3 = [];
    Nmin = 50;
    zdlg = ZmapDialog();
    nEventsPerWindow = 150;
    overlap = 5;
    
    minMag = min(catalog.Magnitude);
    
    zdlg.AddEdit('nEventsPerWindow', 'Number of events in each window', nEventsPerWindow, 'tooltip');
    zdlg.AddEdit('overlap', 'Overlap Factor (advances 1/overlap)', overlap, 'tooltip');
    zdlg.AddPopup('mcCalculator', 'Determine Mc using:', {'Automatic','Fixed Mc=Mmin'},1, 'tooltip',...
        {@auto_mc, @(~)minMag });
    
    [res, okPressed] = zdlg.Create('Name','B-value with depth parameters');
    if ~okPressed
        return
    end
    watchon;
    
    [allDepths, I] = sort(catalog.Depth);
    allMagnitudes = catalog.Magnitude(I);
    
    nEventsPerWindow = res.nEventsPerWindow;
    overlap = res.overlap;
    
    
    stepSize = nEventsPerWindow / overlap;
    stepSize = max(stepSize, 1);
    startIdxs = 1 : stepSize : numel(allDepths) - nEventsPerWindow;
    endIdxs = startIdxs + nEventsPerWindow - 1;
    nSteps = numel(startIdxs);
    
    
    for t = 1 : nSteps
        % calculate b-value based an weighted LS
        startIdx = startIdxs(t);
        endIdx   = endIdxs(t);
        magnitudes = allMagnitudes(startIdx : endIdx);
        
        magco = res.mcCalculator(magnitudes);
        
        l = magnitudes >= magco - 0.05;
        if sum(l) >= Nmin
            [bv, stan, ~] = calc_bmemag(magnitudes(l), 0.1);
        else
            [bv, stan] = deal(nan);
        end
        minDepth = allDepths(startIdx);
        maxDepth = allDepths(endIdx);
        medianDepth = allDepths(startIdx + round(nEventsPerWindow/2));
        tripleidx = t.*3 - 2;
        bvalueTriplet(tripleidx : tripleidx+2, 1)     = [bv; bv; inf];
        mimaDepTriplet(tripleidx : tripleidx+2, 1) = [minDepth; maxDepth; inf];
        
        BV3(t,1:3) = [bv, medianDepth, stan];
    end
    
    watchoff
    
    plot_it(bvalueTriplet, mimaDepTriplet, BV3(:,1), BV3(:,2), BV3(:,3))
    return
    
    
    function plot_it(bvTriplet, minmaxDepthTriplet, bv, medianDepth, stan)
        myFigName='b-value with depth';
        errorColor = [0.5, 0.5, 0.5];
        % Find out if figure already exists
        %
        bdep = findobj('Type','Figure','-and','Name', myFigName);
        
        % Set up the Cumulative Number window
        
        if isempty(bdep)
            bdep = figure('Name'  , myFigName,...
                'NumberTitle'   , 'off', ...
                'NextPlot'      , 'add', ...
                'backingstore'  , 'on',...
                'Visible'       , 'on', ...
                'Position'      , position_in_current_monitor(ZG.map_len(1)-50, ZG.map_len(2)-20));
        else
            figure(bdep);
            clf(bdep);
        end
        orient tall
        rect    = [0.25, 0.15, 0.5, 0.75];
        ax      = axes(bdep, 'position',rect);
        ple     = errorbar(ax, medianDepth, bv, stan, stan, 'k');
        ple(1).Color = errorColor;
        
        ax.NextPlot = 'add';
        plot(ax, minmaxDepthTriplet, bvTriplet, 'color', errorColor);
        plot(ax, medianDepth, bv, 'sk', 'LineWidth', 1.0, 'MarkerSize', 4,...
            'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k', 'Marker','s');
        
        set(ax, 'box','on', 'SortMethod', 'childorder',...
            'TickDir', 'out', 'Ticklength', [ 0.02, 0.02],...
            'FontWeight', 'bold', 'FontSize', ZmapGlobal.Data.fontsz.m,...
            'Linewidth', 1)
        strib = sprintf('%s, ni = %g, Mmin = %g', catalog.Name, nEventsPerWindow, minMag);
        ylabel(ax, 'b-value')
        xlabel(ax, sprintf('Depth [%s]', catalog.LengthUnit))
        title(ax, strib, 'FontWeight', 'bold', ...
            'FontSize', ZmapGlobal.Data.fontsz.m,...
            'Color', 'k',...
            'Interpreter', 'none')
        
        view(ax, [90 90])
    end
    
end

function [magco] = auto_mc(magnitudes)
    [Mc90, Mc95] = mcperc_ca3(magnitudes);
    if ~isnan(Mc95)
        magco = Mc95;
    elseif ~isnan(Mc90)
        magco = Mc90;
    else
        [magco] =  bvalca3(magnitudes, McAutoEstimate.auto);
    end
end