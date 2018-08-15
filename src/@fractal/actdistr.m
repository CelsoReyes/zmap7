function actdistr() 
    % activate deviation input editors in random parameters window
    %
    % This code is responsable for the activation (enable, on) of the std. deviation input
    % editors in the random parameters input window. It is called from randomcat.m,
    % Francesco Pacchiani 6/2000
    %
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    if distr == 4
        
        set(input9, 'enable', 'on');
        set(input10, 'enable', 'on');
        set(input11, 'enable', 'on');
        set(tx9, 'color', 'k');
        set(tx10, 'color', 'k');
        set(tx11, 'color', 'k');
        
    elseif distr == 6
        
        set(input3, 'enable', 'off');
        set(input4, 'enable', 'off');
        set(input5, 'enable', 'off');
        set(input6, 'enable', 'off');
        set(input7, 'enable', 'off');
        set(input8, 'enable', 'off');
        set(input9, 'enable', 'off');
        set(input10, 'enable', 'off');
        set(input11, 'enable', 'off');
        set(tx3, 'color', 'w');
        set(tx4, 'color', 'w');
        set(tx5, 'color', 'w');
        set(tx6, 'color', 'w');
        set(tx7, 'color', 'w');
        set(tx8, 'color', 'w');
        set(tx9, 'color', 'w');
        set(tx10, 'color', 'w');
        set(tx11, 'color', 'w');
        
        
    elseif distr == 1  ||  distr == 2  ||  distr == 3  ||  distr == 5
        
        set(input3, 'enable', 'on');
        set(input4, 'enable', 'on');
        set(input5, 'enable', 'on');
        set(input6, 'enable', 'on');
        set(input7, 'enable', 'on');
        set(input8, 'enable', 'on');
        set(input9, 'enable', 'off');
        set(input10, 'enable', 'off');
        set(input11, 'enable', 'off');
        set(tx3, 'color', 'k');
        set(tx4, 'color', 'k');
        set(tx5, 'color', 'k');
        set(tx6, 'color', 'k');
        set(tx7, 'color', 'k');
        set(tx8, 'color', 'k');
        set(tx9, 'color', 'w');
        set(tx10, 'color', 'w');
        set(tx11, 'color', 'w');
        
    end
    
    
end
