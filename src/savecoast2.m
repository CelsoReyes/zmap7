function savecoast2() 
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    delete coastl.mat
    if inpr3 == 1
        FILNAME='private/gshhs_c.b';
        m_gshhs_c('save','coastl.mat');
        
    elseif inpr3 == 2
        FILNAME='private/gshhs_l.b';
        m_gshhs_l('save','coastl.mat');
        
    elseif inpr3 == 3
        FILNAME='private/gshhs_i.b';
        m_gshhs_i('save','coastl.mat');
        
        
    elseif inpr3 == 4
        FILNAME='private/gshhs_h.b';
        m_gshhs_h('save','coastl.mat');
    end
    load coastl.mat
    
    coastline = ncst;
    zmap_update_displays();
    clear  ncst coastl
end
