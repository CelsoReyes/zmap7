function out=load_stations(level, filename)
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
    % options would be a struct with fieldnames & filtervalues
    %
    % eg.
    %  options=struct('Network','CH'); % show only stations belonging to network CH
    %  options=struct('Network',{'CH','DK'}) % show only stations belonging either to CH or DK
    %  valid options are:
    %  Network, Station, StartBefore, EndAfter, Marker, MarkerSize, MarkerColor, FileName
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
    
    report_this_filefun();
    
    if ~exist('filename','var')
        filename = 'features/stations_irisall_20170714.mat';
    elseif isempty(filename)
        % do the UI stuff to get the station file
    end
    
    
    % load the default station list if none exists
    TMP=load(filename,'stations');
    out=TMP.stations;
    
    % get rid of synthetic stations
    out=out(out.Network ~= "SY",:);
    
    out.Properties.VariableNames{2}='StaName';
    out.Name=strcat(out.Network,'.',out.StaName,' : [',out.SiteName,']');
    out.Depth=-out.Elevation / 1000;
end

