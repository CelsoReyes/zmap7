function [mCluster,out]=declus_wintec(mCatalog, nMethod)
    % DECLUS_WINTEC  execute declustering by windowing technique
    %
    % DECLUS_WINTEC(catalog, nMethod)
    %
    % Incoming variables:
    % mCatalog : EQ catalog in ZMAP format
    % nMethod  : Number describing the window used for declustering
    %
    %
    % mCluster : catalog containing only events that are in clusters
    % out : struct of declustered details [output from CALC_DECLUSTER]
    % J. Woessner, woessner@seismo.ifg.ethz.ch
    % updated: 14.08.02
    %
    % see DECLUS_INP, CALC_DECLUSTER
    
    
    report_this_filefun(mfilename('fullpath'));
    
    %%% Decluster catalog using window technique
    out = struct;
    [out.mCatDecluster, out.mCatAfter, out.vCluster, out.vCl, out.vMain] = calc_decluster(mCatalog,nMethod);
    vSel = (out.vMain(:,1) > 0); % Selects mainshocks of clusters
    mCluster = mCatalog.subset(vSel);
    
    %%% Plot comparison to window length
    %[vMags, vClusTime, vDist]= plot_cluscomp(vMain, vCluster, mCatalog, nMethod);
    plot_cluscomp(out.vMain, vCluster, mCatalog, nMethod); % output arguments weren't being used
    
    %%% Plot seismicity map, clusters and mainshocks
    replaceMainCatalog(out.mCatDecluster);
    zmap_update_displays();
    plot(mCluster.Longitude, mCluster.Latitude,'m+');
    
    describe_clusters(mCatalog, out)
    plot_mag_histogram(catalog, mCatAfter)
    
end

function describe_clusters(mCatalog, out)
    %%% Calculate moment release [local variables], only used for description
    [fMomentCluster, vMomentCluster] = calc_moment(out.mCatAfter);
    
    [fMomentorg, vMomentorg] = calc_moment(out.mCatalog);
    
    fMomentpercentage = 100*fMomentCluster/fMomentorg;
    
    fEventpercentage = 100*out.mCatAfter.Count/mCatalog.Count; % Percentage of events in clusters
    
    %% Setup message box
    sInfost1 = sprintf(...
        [' The declustering found %d clusters of earthquakes, a total of %d (%g\%) events out of %d. ',...
        ' The map window now displays the declustered catalog containing %d events as blue dots.', ....
        ' The individual clusters are displayed as magenta pluses. The seismic moment released by the clusters'...
        ' is %g Nm which is about %g\% of the total seismic moment (%g Nm) of the catalog.'],...
        max(out.vMain) , out.mCatAfter.Count, fEventpercentage, mCatalog.Count,...
        out.mCatDecluster.Count,...
        fMomentCluster, fMomentpercentage, fMomentorg);
    
    msgbox(sInfost1,'Declustering Information')
end


function plot_mag_histogram(origCatalog, declusteredCatalog)
    %%% Plotting magnitude histogram
    if exist('hd1_declus_wintec','var') && ishandle(hd1_declus_wintec)
        set(0,'Currentfigure',hd1_declus_wintec);
        disp('Figure exists');
    else
        hd1_win_fig=figure('tag','fig_declus_wintec','Name','Histogram','Units','normalized','Nextplot','add',...
            'Numbertitle','off','Position',[0.4 0.2 .4 .6],'Menubar','none');
    end
    
    set(gca,'tag','ax_declus_wintec_mag','Nextplot','replace','box','on','Xticklabel', [0 10 100]);
    axs1=findobj('tag','ax_declus_wintec_mag');
    axes(axs1(1));
    maxMagLimit=max(origCatalog.Magnitude);
    magEdges = 0:0.1:maxMagLimit;
    histogram(declusteredCatalog.Magnitude, magEdges);
    xlabel('Magnitude (events of all clusters)');
end
