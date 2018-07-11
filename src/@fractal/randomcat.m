function params = randomcat(obj)
    %
    % Input window for the random catalogue parameters. Called from
    % startfd.m.%
    
    % Creates the input window
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    zdlg = ZmapDialog();
    tooltip = 'no tooltip';
    zdlg.AddBasicEdit('numran', 'Number of random events', numran, tooltip);
    zdlg.AddBasicPopup(obj, 'input2', 'Distribution', ...
        {'Random in a box','Sier. Gasket 2D','Sier. Gasket 3D','Real with normal error'}, 1, tooltip);
    zdlg.AddBasicEdit('long1', 'Longitude 1 [deg]', long1, tooltip);
    zdlg.AddBasicEdit('longi', 'Longitude 2 [deg]', long2, tooltip);
    zdlg.AddBasicEdit('lati1', 'Latitude 1 [deg]', lati1, tooltip);
    zdlg.AddBasicEdit('lati2', 'Latitude 2 [deg]', lati2, tooltip);
    zdlg.AddBasicEdit('dept1', 'Minimum depth [km]', dept1, tooltip);
    zdlg.AddBasicEdit('dept2', 'Maximum depth [km]', dept2, tooltip);
    zdlg.AddBasicEdit('stdx', 'Std. deviation in longitude [km]', stdx, tooltip);
    zdlg.AddBasicEdit('stdy', 'Std. deviation in latitude [km]', stdy, tooltip);
    zdlg.AddBasicEdit('stdz', 'Std. deviation in Depth [km]', stdz, tooltip);
    [params, okPressed] = zdlg.Create('Random Catalog Parameters');
    
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
