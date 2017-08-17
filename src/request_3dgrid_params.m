function [dLon_deg,dLat_deg,dz_km,maxZ_km,minZ_km] = request_3dgrid_params(tit)
    % prompt for grid spacing.
    % uses catalog "a" for default depth limits
    
    dx = 0.1;
    dy = 0.1 ;
    dz = 5.00 ;
    ZG=ZmapGlobal.Data;
    
    def= {dx, dy, dz, max(ZG.a.Depth), min(ZG.a.Depth)}; % as numbers
    defstr = cellfun(@num2str,def,'UniformOutput',false); % converted to strings
    
    if ~exist('tit','var') || isempty(tit)
        tit ='Three dimesional analysis params';
    end
    prompt={ 'Spacing in Longitude (dx in [deg])',...
        'Spacing in Latitude  (dy in [deg])',...
        'Spacing in Depth    (dz in [km ])',...
        'Depth Range: deep limit [km] ',...
        'Depth Range: shallow limit [km] ',...
        };
    
    
    ni2 = inputdlg(prompt,tit,1,defstr); %as strings
    ni2 = cellfun(@str2double,ni2); %converted to numbers
    
    dLon_deg = ni2(1);
    dLat_deg = ni2(2);
    dz_km = ni2(3);
    maxZ_km = ni2(4);
    minZ_km = ni2(5);
end