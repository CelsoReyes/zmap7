function [vMags, vClusTime, vDist]=plot_cluscomp(vmain, vcluster, mCatalog, nMethod)
    % PLOT_CLUSCOMP  Compare actual cluster length with applied windowing technique (Gardner & Knopoff)
    % [vMags, vClusTime,vDist]=PLOT_CLUSCOMP(vmain, vcluster, mCatalog, nMethod)
    % ------------------------------------------------------------------------------
    % Compare actual cluster length with applied windowing technique (Gardner & Knopoff)
    %
    % Incoming variables:
    % vmain    : Vector of mainshocks
    % vcluster : Vector with cluster numbers
    % mCatalog : EQ catalog in ZMAP format
    % nMethod  : decluster window calculation method  (see DeclusterWindowingMethods)
    %
    % Outgoing variable:
    % vMags     : Vector of magnitudes
    % vClusTime : Vector of length of cluster
    % vDist     : Vector of cluster distances
    % J. Woessner
    % updated: 14.08.02
    %
    % 28.08.02: Changed distance determination using distance now
    
    % error('Developer: plot_cluscomp Needs to be updated to handle new catalogs')
        
    % Select cluster
    clusterNumbers = reshape(unique(vmain(vmain~=0)), 1,[]);
    
    for nCevent = clusterNumbers
        vSelClus = (vcluster == nCevent);
        vSelMain = (vmain == nCevent);
        events = mCatalog.subset(vSelClus);
        mainshock = mCatalog.subset(vSelMain);
        assert(length(mainshock) == 1,'There is expected to be exactly one mainshock per cluster')
        
        % --  Calculating time differences --
        minClusTimes(nCevent) = min(min(events.Date), mainshock.Date); %#ok<*AGROW>
        maxClusTimes(nCevent) = max(max(events.Date), mainshock.Date);
        vClusTime(nCevent) = days(maxClusTimes(nCevent) - minClusTimes(nCevent));
        
        % -- Calculate spatial extent of cluster --
        minClusLat = min(events.Latitude);
        minClusLon = min(events.Longitude);
        maxClusLat = max(events.Latitude);
        maxClusLon = max(events.Longitude);
        
        % by using the RefEllipsoid, distances are returned in appropriate units
        assert(mCatalog.RefEllipsoid.LengthUnit == "kilometer", 'Gardiner-Knopoff expects distances in KM') %TODO remove restriction and do conversions
        % removed abs(...) because distances should always be positive. -CGR
        
        % get the permutations of all four corners
        % originally, only the min,min and max,max were compared -CGR
        lats = [minClusLat; maxClusLat; minClusLat; maxClusLat];  
        lons = [minClusLon; minClusLon; maxClusLon; maxClusLon]; 
        vDists = distance(mainshock.Latitude, mainshock.Longitude, lats, lons, mCatalog.RefEllipsoid);
        vDist(nCevent) = max(vDists);
        
        %-- End of calculating spacial extend of cluster --
        vMags(nCevent) = mainshock.Magnitude;
    end
    
    % Figures
    if exist('hd1_clus_fig','var') && ishandle(hd1_clus_fig)
        set(0,'Currentfigure',hd1_clus_fig);
        disp('Figure exists');
    else
        hd1_clus_fig = figure('tag','fig_clus','Name','Cluster length in time and space','Units','normalized','Nextplot','add',...
            'Numbertitle','off');
    end
    
    vMagnitude = (0:0.1:10);
    vMagnitudea = (0:0.1:6.5);
    vMagnitudeb = (6.5:0.1:10);
    
    subplot(2,1,1);
    set(gca,'tag','ax1_clus','Nextplot','replace','box','on','Xlim', [0 8]);
    axs1=findobj('tag','ax1_clus');
    axes(axs1(1));
    semilogy(vMags,vClusTime,'*');
    set(gca,'NextPlot','add');
    
    switch nMethod
        case 1
            % Gardner & Knopoff
            vTimeGaKn74 = 10.^(0.5409*vMagnitudea-0.547);
            vTimeGaKn74b = 10.^(0.032*vMagnitudeb+2.7389); % M>=6.5
            semilogy(vMagnitudea,vTimeGaKn74,'Color',[1 0 0],'Linewidth', 2);
            semilogy(vMagnitudeb,vTimeGaKn74b,'Color',[1 0 0],'Linewidth', 2);
        case 2
            % Gruenthal, pers. communication
            vTimeGra = exp(-3.95+sqrt(0.62+17.32*vMagnitudea));
            vTimeGrb = 10.^(2.8+0.024*vMagnitudeb); % M >= 6.5
            semilogy(vMagnitudea,vTimeGra,'Color',[0 0.8 0],'Linewidth', 2);
            semilogy(vMagnitudeb,vTimeGrb,'Color',[0 0.8 0],'Linewidth', 2);
        case 3
            % Uhrhammer 1976
            vTimeUr = exp(-2.87+1.235*vMagnitude);
            semilogy(vMagnitude,vTimeUr,'Color',[0.5 0 0],'Linewidth', 2);
        otherwise
            disp('Unknown method');
    end
    set(gca,'Xlim', [0 ceil(max(vMags))]);
    xlabel('Magnitude');
    ylabel('Time / [days]');
    set(gca,'NextPlot','replace');
    
    subplot(2,1,2);
    set(gca,'tag','ax2_clus','Nextplot','replace','box','on','Xlim', [0 8]);
    axs2=findobj('tag','ax2_clus');
    axes(axs2(1));
    semilogy(vMags,vDist,'*');
    set(gca,'NextPlot','add');
    switch nMethod
        case 1
            % % Gardner & Knopoff
            vSpaceGaKn74 = 10.^(0.1238*vMagnitude+0.983);
            semilogy(vMagnitude,vSpaceGaKn74,'Color',[1 0 0],'Linewidth', 2);
        case 2
            % Gruenthal, pers. communication
            vSpaceGr = exp(1.77+sqrt(0.037+1.02*vMagnitude));
            semilogy(vMagnitude,vSpaceGr,'Color',[0 0.8 0],'Linewidth', 2);
        case 3
            % Uhrhammer 1976
            vSpaceUr = exp(-1.024+0.804*vMagnitude);
            semilogy(vMagnitude,vSpaceUr,'Color',[0.5 0 0],'Linewidth', 2);
        otherwise
            disp('Unknown method');
    end
    set(gca,'Xlim', [0 ceil(max(vMags))],'Ylim', [0 ceil(max(vDist))+100]);
    xlabel('Magnitude');
    ylabel('Distance / [km]');
    set(gca,'NextPlot','replace');
end
