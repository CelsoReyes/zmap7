function out = load_volcanoes(filename, vname)
    % loads volcano information from a file
    % by default, this loads volcao.mat, which contains
    % a Table called GVPHoloceneVolcanoes
    % This table has several fields that describe the volcano.
    % Most importantly: 
    %  VolcanoName - name of volcano
    %  LastKnownEruption - year in which eruption occurred (numeric, not a datetime)
    %  Latitude, Longitude - lat & lon in degrees
    %  Elevationm - elevation in meters
    %  Depth - negative elevation in km

    if ~exist('filename','var')
        filename = 'features/volcano.mat';
    end
    
    if ~exist('vname','var')
        vname = 'data';
    end
    
    out = [];
    
    try
        XX = load(filename, vname);
    catch ME
        error('unable to load volcanoes. Expected variable "%s" in file "%s"',...
        vname, filename)
    end
    
    if isfield(XX,vname)
        out = XX.(vname);
    end
    
    if ~isfield(out,'Depth')
        out.Depth= -(out.Elevationm ./ 1000);
    end
    
    fn = fieldnames(out);
    if ~all(ismember({'VolcanoName','Latitude','Longitude','Elevationm','LastKnownEruption'}, fn))
        warning('loaded volcano file, but it doesn''t appear to have all the required fields');
     end

end