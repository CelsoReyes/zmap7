function [hwm,hwmm]=webmap_of_catalog(catalog,force)
    % webmap_of_catalog plot earthquakes in a browser window
    % using the geoweb toolbox
    %
    % see webmap, webmarker
    
    disp(['Plotting events on web map.  They will plot from smallest to largest. ', newline,...
        'Within each magnitude bin, they are plotted according to depth range']); 
    MAXQUAKES=1000;
    if catalog.Count >= 1000 && (~exist('force','var') || ~force)
        errordlg('Too many events for webmap.  Reduce events to < 1000, and try again');
        return
    end
    % dep2color= @(x) [(x - min(x)) /max(x- min(x)), repmat(0,numel(x),1), sqrt(1-(x - min(x)) /max(x- min(x)))];
    smallestEvent=min(catalog.Magnitude);
    biggestEvent=max(catalog.Magnitude);
    eventRange=biggestEvent-smallestEvent;
    
    
    scaleit = @(n) ((n-smallestEvent) ./ eventRange ).*1.4 + 0.6;
    %scaleit = @(n)(( n + abs(min(n)) + 1 )/4) .^ (1/3);
    %TODO include the MagnitudeType
    %disp('desc')
    desc=splitlines(sprintf('(%8.4f, %8.4f) depth: %4.2f km, mag %3.2f\n',...
        catalog.Latitude, catalog.Longitude, catalog.Depth, catalog.Magnitude)); 
    desc(end)=[];
    %disp('title');
    tit=cellstr(char(catalog.Date,'uuuu-MM-dd hh:mm:ss'));
    hwm=webmap('World Topographic Map');
    wmlimits(hwm,[min(catalog.Latitude) max(catalog.Latitude)],...
        [min(catalog.Longitude) max(catalog.Longitude)])
    %disp('wmmarker');
    
    magrange = [10:-0.5:-2]; 
    cmp=jet(numel(magrange));
    
    for j=2:numel(magrange)
        name(j)={sprintf('%.1f <= M < %.1f',magrange(j),magrange(j-1))};
        idx(j)={catalog.Magnitude >= magrange(j) & catalog.Magnitude < magrange(j-1)};
        nInRange(j)=sum(idx{j});
    end
    
    % get rid of empty categories
    magrange(nInRange==0)=[];
    name(nInRange==0)=[];
    idx(nInRange==0)=[];
    nInRange(nInRange==0)=[];
    tot=cumsum(nInRange);
    toomany = find(tot > MAXQUAKES,1,'first');
    nDepthBins=5;
    [bins,edgs]=discretize(catalog.Depth,nDepthBins);
    cmp=jet(nDepthBins);
    for q=1:numel(edgs)-1
    depthnames(q) ={ sprintf(' %.1f <= Z < %.1f km', edgs(q),edgs(q+1))};
    end
    %% using multi-color option for wmmarker is super slow. It is much faster to do a double loop.
    for j=numel(magrange) : -1 :1
        %if j > toomany+1
        %    continue;
        %end
        for q=nDepthBins:-1:1
            thisidx = idx{j} & bins==q;
            %sum(thisidx)
            if ~any(thisidx), continue, end
            thiscolor = cmp(q,:);
            
            if ~exist('hwmm','var')
                hwmm=wmmarker(catalog.Latitude(thisidx),catalog.Longitude(thisidx),...
                    'OverlayName',[ name{j}, ', ', depthnames{q}],...
                    'Color',thiscolor,...
                    'Description',desc(thisidx),...
                    'FeatureName',tit(thisidx),...
                    'IconScale',scaleit(catalog.Magnitude(thisidx)),'Autofit',false);
            else
                hwmm(end+1)=wmmarker(catalog.Latitude(thisidx),catalog.Longitude(thisidx),...
                    'OverlayName',[ name{j}, ', ', depthnames{q}],...
                    'Color',thiscolor,...
                    'Description',desc(thisidx),...
                    'FeatureName',tit(thisidx),...
                    'IconScale',scaleit(catalog.Magnitude(thisidx)),'Autofit',false);
            end
        end
    end
    %if ~isempty(toomany)
    %    fprintf('Only the largest %d events (of %d) were shown\n',tot(toomany),sum(nInRange));
    %end
    %{
    hwmm=wmmarker(catalog.Latitude, catalog.Longitude, 'FeatureName',tit);...,...
        ...'IconScale',scaleit(catalog.Magnitude),...
        ...'Description',desc,'Color',dep2color(catalog.Depth), 'FeatureName',tit);
    %}
end