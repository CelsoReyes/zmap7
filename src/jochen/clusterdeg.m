function clusterdeg(mCatalog, vCluster)
    % Determines degree of clustering of a catalog
    % Necessary variables:
    % mCatalog: EQ catalog
    % vCluster: Vector with cluster numbers
    %
    % J. Woessner, woessner@seismo.ifg.ethz.ch
    % updated: 27.08.02
    
    % Check for declustered catalog
    
    if (isempty(vCluster) || isempty(mCatalog.Longitude))
        errordlg('No declustered catalog availbale.','Error');
        return
    else
        sPrompt  = {'Max. number of events:','Maximum radius (km):','Minimum Number of Events','Grid spacing / [deg]'};
        sTitle   = 'Parameters for degree of clustering map';
        nLines= 1;
        sDef     = {'200','40','20','0.5'};
        sAnswer  = inputdlg(sPrompt,sTitle,nLines,sDef);
        
        nNumberEvents = str2double(sAnswer(1));
        fRadius = str2double(sAnswer(2)); % km
        nMinEvents = str2double(sAnswer(3));
        fGridSpacing = str2double(sAnswer(4)); % dec. degree
        mCat = [vCluster mCatalog];
        
        % Create grid
        [mGrid, vXVector, vYVector, vUsedNodes] = ex_selectgrid(3, fGridSpacing, fGridSpacing, 1);
        
        for nCount = 1:length(mGrid(:,1))
            mPos = [mGrid(nCount,1) mGrid(nCount,2)]; % Grid position
            mPos = repmat(mPos,length(mCat(:,1)),1);
            vRadDist = abs(distance(mCat(:,2), mCat(:,3), mPos(:,1), mPos(:,2)));
            [s,is] = sort(vRadDist);
            mCatClose = mCat(is(:,1),:);
            vSkm = deg2km(s,almanac('earth','radius','km','grs80'));
            vSel = (vSkm <= fRadius);
            mCatClose = mCatClose(vSel,:);
            if (isempty(isempty(mCatClose)) ||  length(mCatClose(:,1)) < nMinEvents )
                mCatClose = NaN;
            elseif length(mCatClose(:,1)) > nNumberEvents
                mCatClose = mCatClose(1:nNumberEvents,:);
            end
            %    mCatClose(:,1)
            fClusterDeg(nCount) = calc_ClusterDeg(mCatClose, mCatClose(:,1));
        end
        
        hd1_clusterdeg_fig=figure_w_normalized_uicontrolunits('tag','fig_clusdeg','Name','Degree of Clustering','Units','normalized','Nextplot','add',...
            'Numbertitle','off');
        set(gca,'tag','ax1_clusterdeg','Nextplot','replace','box','on');
        axs1=findobj('tag','ax1_clusterdeg');
        axes(axs1(1));
        
        mClusterDeg = [mGrid(:,1) mGrid(:,2) fClusterDeg'];
        [X,Y]=meshgrid(linspace(min(mClusterDeg(:,1)),max(mClusterDeg(:,1)),200),...
            linspace(min(mClusterDeg(:,2)),max(mClusterDeg(:,2)),200));
        Z = griddata(mClusterDeg(:,1),mClusterDeg(:,2),mClusterDeg(:,3),X,Y,'linear');
        pcolor(X,Y,Z);
        shading interp;
        set(gca,'NextPlot','add');
        plot(coastline(:,1),coastline(:,2),'k');
        xlabel('Longitude / [deg]');
        ylabel('Latitude / [deg]');
        colorbar('horiz');
        set(gca,'NextPlot','replace');
    end
end
