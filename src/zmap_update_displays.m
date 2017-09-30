function zmap_update_displays(opt)
    % zmap_update updates the various likely open dialogs & figures

    %    persistent ZG
%    if isempty(ZG)
%        ZG=ZmapGlobal.Data;
%    end
    if ~exist('opt','var')
        opt='';
    end
    zmap_message_center.update_catalog();
    m = mainmap();
    
    if ~isempty(m)
        if strcmp(opt,'showmap')
            m.update('show');
        else
            m.update();
        end
    end
        
end