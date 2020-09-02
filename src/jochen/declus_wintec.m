function out=declus_wintec(mCatalog, eMethod)
    % DECLUS_WINTEC execute declustering by windowing technique
    %
    % DECLUS_WINTEC(catalog, nMethod)
    %
    % Incoming variables:
    % mCatalog : EQ catalog in ZMAP format
    % eMethod  : a choice from DeclusterWindowingMethods
    %
    %
    % out : struct of declustered details [output from CALC_DECLUSTER]
    % J. Woessner, woessner@seismo.ifg.ethz.ch
    % updated: 14.08.02
    %
    % see DECLUS_INP, CALC_DECLUSTER
    
    
    report_this_filefun();
    
    %%% Decluster catalog using window technique
    out = struct;
    % [out.mCatDecluster, out.mCatAfter, out.vCluster, out.vCl, out.vMain] = calc_decluster(mCatalog,eMethod);
    [out.declusteredCatalog, out.aftershockCatalog, out.aftershockClusterIdx, out.allClusterIdx, out.mainshockClusterIdx] = calc_decluster(mCatalog,eMethod);
    %vSel = (out.vMain(:,1) > 0); % Selects mainshocks of clusters
    %mCluster = mCatalog.subset(vSel);
    out.description = ["Decluster results have been written to gk_decluster_output with the following fields";...
    	"  declusteredCatalog: Declustered earthquake catalog (with mainshocks, no fore/aftershocks)";...
        "  aftershockCatalog: Catalog of aftershocks (and foreshocks)";...
        "  aftershockClusterIdx : Vector indicating only aftershocks/foreshocks in cluster using a cluster number (background seismicity == 0)";...
        "  allClusterIdx: Vector indicating all events in clusters using a cluster number (background seismicity == 0)";...
        "  mainshockClusterIdx: index into original catalog, indicating mainshocks, where any non-zero value is the cluster number"];
    
    %%% Plot comparison to window length
    %[vMags, vClusTime, vDist]= plot_cluscomp(vMain, vCluster, mCatalog, eMethod);
    % plot_cluscomp(out.mainshockClusterIdx, out.aftershockClusterIdx, mCatalog, eMethod); % output arguments weren't being used
    return % CGR - Sep 1 2020
    
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
        hd1_win_fig=figure('tag','fig_declus_wintec','Name','Histogram',...
            'Units','normalized','Nextplot','add',...
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
