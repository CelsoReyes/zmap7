function TF = ensure_mainshock()
    %makes sure main shock isn't empty. returns true if exists
    
    ZG=ZmapGlobal.Data;
    
    TF=true;
    if isempty(ZG.maepi)
        msg.errordisp(        'No Mainshock exists. Select one before choosing this option',...
        'missing mainshock');
        TF=false;
    end
end