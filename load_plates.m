function out = load_plates(filename, varname)
    %load crustal plates
    % returns out = [lon(:) , lat(:)]
    
    %hardwired.
    out = [nan nan];
    if ~exist('filename','var')
        filename  ='plates.mat';
    end
    if ~exist('varname','var')
        varname  ='plates';
    end
    
    try
        tmp = load(filename,varname);
        out = tmp.plates;
    catch ME
        errordlg('unable to load plate coordinates');
        rethrow(ME);
    end
    
end