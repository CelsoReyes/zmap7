function TF = ensure_mainshock()
    %makes sure main shock isn't empty. returns true if exists
    
    ZG=ZmapGlobal.Data;
    
    TF=true
    if isempty(ZG.maepi)
        ZmapMessageCenter.set_error('missing mainshock',...
        'No Mainshock exists. Select one before choosing this option')
        TF=false
    end
end