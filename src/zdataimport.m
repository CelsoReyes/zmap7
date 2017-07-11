% this is zdataimport

ver = version;
ver = str2double(ver(1));

% check if Matlab 6+
if ver < 6
    helpdlg('Sorry - these import filters only work for Matlab version 6.0 and higher','Sorry');
    return
end

% start filters

[a] = import_start(fullfle(ZmapGlobal.Data.hodi, 'importfilters'));
if isnan(a)
    % import cancelled / failed
    return
end
if isnumeric(a)
    ZG.a=ZmapCatalog(a);
    ZG.a.sort('Date');
end
disp(['Catalog loaded with ' num2str(ZG.a.Count) ' events ']);
minmag = max(ZG.a.Magnitude)-0.2;       %  as a default to be changed by inpu

% call the setup
inpu
