function plot_McBwtime(catalog, sPar) 
    % plot Mc and b as a function of time using the bootstrap approach
    % Uses the result matrix from calc_McBwtime
    % updated: 14.02.2005
    % J. Woessner
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    % Get input
    
    % Initial values
    nSampleSize = 500;
    nOverlap = 4;
    nMethod = 1;
    nBstSample = 200;
    minEventCount = 50;
    fBinning = 0.1;
    nWindowSize = 5;
    fMcCorr = 0;
    inpr1=McMethods.MaxCurvature; % default method
    figure_w_normalized_uicontrolunits(...
        'Name','Mc Input Parameter',...
        'NumberTitle','off', ...
        'NextPlot','new', ...
        'units','points',...
        'Visible','off', ...
        'Position',[ 200 200 500 200]);
    axis off
    
    % Input parameters
    
    zdlg = ZmapDialog();
    zdlg.AddMcMethodDropdown('nMethod', inpr1);
    zdlg.AddEdit('nSampleSize', 'Sample window size',      nSampleSize,    'number of events in each window');
    zdlg.AddEdit('minEventCount', 'Min. # of events',      minEventCount,  'minimum number of events in order to calc. window');
    zdlg.AddEdit('nOverlap',   'Window overlap', nOverlap,      'Samplesize/nOverlap determines overlap of moving windows');
    zdlg.AddEdit('nBstSample', 'Bootstraps',               nBstSample,     'Number of samples in bootstrap(?)');
    zdlg.AddEdit('fMcCorr',    'Mc correction',            fMcCorr,        'correction for the magnitude of completeness');
    zdlg.AddEdit('fBinning',   'Magnitude Binning',        fBinning,       'size of magnitude bins');
    zdlg.AddEdit('windowSize','Smooth plot',              nWindowSize,    'smooth plot');
    [zans,okPressed] = zdlg.Create('Name', 'Mc Input Parameter');
    
    if ~okPressed
        return
    end
    
    %% calculate  time series
    windowSize = zans.windowSize;
    catalog.sort('Date');
    
    [mResult] = calc_McBwtime(catalog, zans.nSampleSize, zans.nOverlap, zans.nMethod, zans.nBstSample, zans.minEventCount, zans.fBinning, zans.fMcCorr);
    
    errbarParams={'LineStyle','-.','Linewidth',2,'Color',[0.5 0.5 0.5]};
    
    % Plot Mc time series
    if sPar == "mc"
        fig = figure_w_normalized_uicontrolunits('tag','Mc time series', 'visible','on', 'Name','Mc time series');
        resultCol=[mResult.mcMeanWithTime];
        stdevcol=[mResult.mcStdDevBoot];
        DisplayName='min Mag. Completeness (Mc)';
        errNames={'Mc - std', 'Mc + std'};
        myYLabel='Mc';
        myLegend={'Mc','\delta Mc'};
    else
        % plot B-value
        fig=figure_w_normalized_uicontrolunits('tag','b-value time series', 'visible','on', 'Name','b-value time series');
        resultCol=[mResult.bMeanWithTime];
        stdevcol=[mResult.bStdDevBoot];
        DisplayName='b-value';
        errNames={'b - std', 'b + std'};
        myYLabel='b-value';
        myLegend={'b-value','\delta b'};
    end
    
    y = filter(ones(1,windowSize)/windowSize, 1, resultCol(:)); %was mMc or mB
    yStd = filter(ones(1,windowSize)/windowSize, 1, stdevcol(:)); % was mMcstd1 or mBstd1
    
    if length(resultCol) > windowSize
        y(1:windowSize,1)=resultCol(1:windowSize);
        yStd(1:windowSize,1)=stdevcol(1:windowSize);
    end
    
    x = [mResult.meanSampleTime];
    
    
    %% plot
    ax=axes(fig);
    plot(ax, x, y, '-', 'Linewidth', 2, 'Color', [0.2 0.2 0.2],'DisplayName',DisplayName);
    ax.NextPlot='add';
    plot(ax, x, y-yStd, errbarParams{:},'DisplayName',errNames{1});
    plot(ax, x, y+yStd, errbarParams{:},'DisplayName',errNames{2});
    xlabel(ax,'Time / [dec. year]','Fontweight','bold','FontSize',12)
    ylabel(ax,myYLabel,'Fontweight','bold','FontSize',12);
    ax.NextPlot='replace';
    
    xlim(ax, bounds2(x))
    ylim(ax, [floor(min(y-yStd)) ceil(max(y+yStd))]);
    
    l1=legend(ax,myLegend{:});
    set(l1,'Fontweight','bold')
    
    set(ax,'Fontweight','bold','FontSize',10,'Linewidth',2,'Tickdir','out')
    %{
    
function callbackfun_go(mysrc,~)
        inpr1=hndl2.Value;
        close;
        my_calculate();
    end
    %}
end
