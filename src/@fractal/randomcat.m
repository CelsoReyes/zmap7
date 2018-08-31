function params = randomcat(obj)
    % Input window for the random catalogue parameters.
    % Called from startfd.m.%
    
    % Creates the input window
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    zdlg = ZmapDialog();
    tooltip = 'no tooltip';
    zdlg.AddEdit('numran', 'Number of random events', numran, tooltip);
    zdlg.AddPopup(obj, 'input2', 'Distribution', ...
        {'Random in a box','Sier. Gasket 2D','Sier. Gasket 3D','Real with normal error'}, 1, tooltip);
    zdlg.AddEdit('long1', 'Longitude 1 [deg]', long1, tooltip);
    zdlg.AddEdit('longi', 'Longitude 2 [deg]', long2, tooltip);
    zdlg.AddEdit('lati1', 'Latitude 1 [deg]', lati1, tooltip);
    zdlg.AddEdit('lati2', 'Latitude 2 [deg]', lati2, tooltip);
    zdlg.AddEdit('dept1', 'Minimum depth [km]', dept1, tooltip);
    zdlg.AddEdit('dept2', 'Maximum depth [km]', dept2, tooltip);
    zdlg.AddEdit('stdx', 'Std. deviation in longitude [km]', stdx, tooltip);
    zdlg.AddEdit('stdy', 'Std. deviation in latitude [km]', stdy, tooltip);
    zdlg.AddEdit('stdz', 'Std. deviation in Depth [km]', stdz, tooltip);
    [params, okPressed] = zdlg.Create('Name', 'Random Catalog Parameters');
    
    if ~okPressed
        return
    end
    
    if distr == 6
        params.rndsph = 'distr3a';
    else
        params.rndsph = '';
    end
    
    rc = obj.dorand(zans);
    
end
