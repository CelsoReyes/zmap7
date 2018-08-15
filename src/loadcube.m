function loadcube() 
    
    report_this_filefun();
    
    cupa = pwd;
    
    
    [file1,path1] = uigetfile(['*.mat'],'Cube Data File');
    
    if length(path1) > 1
        
        load([path1 file1])
        abo2 = abo;
        plotala()
    else
        return
    end
    
end
