function out = load_plates(~, filename, vname)
    %load crustal plates
    % returns a structure containing fields for Longitude, Latitude, and Depth (which is 0 km)
    
    %hardwired.
    
    if ~exist('filename','var')
        filename  ='features/plates.mat';
    end
    if ~exist('vname','var')
        vname  ='data';
    end
    
    try
        tmp = load(filename,vname);
        out=tmp.data;
        for i=1:numel(tmp.data)
            out(i).Depth=zeros(size(tmp.data(i).Longitude));
        end
       % out = struct('Longitude',tmp.plates.Longitude, 'Latitude', tmp.plates(:,2), 'Depth', zeros(size(tmp.plates(:,1))));
    catch ME
        errordlg('unable to load plate coordinates');
        rethrow(ME);
    end
    
end