function rotateit() 
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    if ~exist('lat1')
        errordlg('Create a cross-section first!');
    else
        [lat1, lat2, lon1, lon2] = rotate_xsection(lat1, lat2, lon1, lon2, ZG.xsec_rotation_deg);
        
        [xsecx xsecy,  inde] = mysect(tmp1,tmp2,ZG.primeCatalog.Depth,ZG.xsec_defaults.WidthKm,0,lat1,lon1,lat2,lon2);
        nlammap2;
    end
    
end
