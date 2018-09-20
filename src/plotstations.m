function plotstations(ax, options)
    %plotstations plots stations on specified axes
    % (Not fully IMPLEMENTED)
    % plotstatiosn(ax) plots the default station list, cropped to the current window
    % to the axis AX.
    % to the specified axes. STATIONS is a structure or table
    % with fields Network, Name, Latitude, Longitude,
    % additionally, it should have Elevation, StartTime, and EndTime.
    % by default, only plots stations active during main catalog dates.
    %
    % if stations is a file, then it should have a variable `'stations' with the
    % same fields.
    % options would be a struct with filtervalues
    %
    % eg.
    %  options=struct('Network','CH'); % show only stations belonging to network CH
    %  options=struct('Network',{'CH','DK'}) % show only stations belonging either to CH or DK
    %  valid options are:
    %  Network, Station, StartBefore, EndAfter, Marker, MarkerSize, MarkerColor
    %
    % FileName:
    % path&name of a station file meeting above criteria. Samples that come with Zmap:
    %  resrc/features/stations_irisall_20170714.mat       %unfiltered IRIS station list
    %  or  resrc/features/stations_sedall_20170714.mat    %unfiltered SED station list
    
    % TODO Maybe these should be actually go into a get/load stations file.
    % TODO Provide ability to update the stations file?
    % TODO set default network?
    
    
    % all swiss stations:
    % http://eida.ethz.ch/fdsnws/station/1/query?format=text&level=station&nodata=404
    unimplemented_error()
    report_this_filefun();
    
    ZG=ZmapGlobal.Data;
    if ~exist('options','var')
        options=struct();
    end
    
    if ~isfield(options,'Marker'), options.Marker='s';end
    if ~isfield(options,'MarkerSize'), options.MarkerSize=6;end
    if ~isfield(options,'MarkerEdgeColor'), options.MarkerEdgeColor='gray';end
    if ~isfield(options,'MarkerFaceColor'), options.MarkerFaceColor='gray';end
    if ~isfield(options,'StartBefore')
        %     w   [x   y ]  z   want stations that start some time before y and end some time after x
        options.StartTime=max(ZG.primeCatalog.Date);
    end
    if ~isfield(options,'EndAfter')
        options.EndTime=min(ZG.primeCatalog.Date);
    end
    stations=ZG.features('stations');
    if isempty(stations)
        stations.load();
    end
    
    % filter the stations down to something managable
    % WARNING: If same station has multiple periods at same place, it gets plotted twice.
    yl = ylim(ax);
    xl = xlim(ax);
    idx = stations.Latitude <= yl(2) & ...
        stations.Latitude >= yl(1) & ...
        stations.Longitude <= xl(2) & ...
        stations.Longitude >= xl(1); %doesn't account for dateline
    if isa(stations,'Table')
        if ismember('StartTime',stations.Properties.VariableNames) && ~isempty(options.StartBefore)
            idx=idx & stations.StartTime <= options.StartBefore;
        end
        if ismember('EndTime',stations.Properties.VariableNames) && ~isempty(options.EndAfter)
            idx=idx & stations.EndTime >= options.EndAfter;
        end
        if isfield(options.Network) && ~isempty(options.Network)
            idx=idx & ismember(stations.Network, options.Network);
        end
        stas = stations(idx,:);
    else % struct
        if isfield(stations,'StartTime') && ~isempty(options.StartBefore)
            idx=idx & stations.StartTime <= options.StartBefore;
        end
        if isfield(stations,'EndTime') && ~isempty(options.EndAfter)
            idx=idx & stations.EndTime >= options.EndAfter;
        end
        if isfield(options.Network) && ~isempty(options.Network)
            idx=idx & ismember(stations.Value.Network, options.Network);
        end
        stas = stations(idx);
    end
    
    showNames = ~isfield(options,'ShowNames') || options.ShowNames;
    options = rmfield(options, {'StartTime','EndTime','Network', 'ShowNames'});
    
    set(gca,'NextPlot','add')
    dx = abs(s1-s2)/130;
    pl = plot(ax, stas.Longitude,stas.Latitude,options.Marker);
    set(pl,'LineWidth',1,options);
    if showNames
        te1 = text(stas.Longitude+dx,lastas.Latitudet,char(stas.Name),'clipping','on');
        set(te1,'FontWeight','bold','Color','k','FontSize',9);
    end
    drawnow
    set(gca,'NextPlot','replace')
end


