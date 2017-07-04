function out = load_plates(filename, varname)
    %load crustal plates
    % returns a structure containing fields for Longitude, Latitude, and Depth (which is 0 km)
    
    %hardwired.
    
    if ~exist('filename','var')
        filename  ='plates.mat';
    end
    if ~exist('varname','var')
        varname  ='plates';
    end
    
    try
        tmp = load(filename,varname);
        out = struct('Longitude',tmp.plates(:,1), 'Latitude', tmp.plates(:,2), 'Depth', zeros(size(tmp.plates(:,1))));
    catch ME
        errordlg('unable to load plate coordinates');
        rethrow(ME);
    end
    
end