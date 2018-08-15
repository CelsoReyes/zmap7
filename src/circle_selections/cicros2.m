function cicros2() 
    %   This subroutine "circle"  selects the Ni closest earthquakes
    %   around a interactively selected point.  Resets ZG.newcat and ZG.newt2
    %   Operates on "primeCatalog".
    %
    % axis: h1
    % plots to: plos1 as xk
    % inCatalog: newa
    % outCatalog: newt2, newcat
    % mouse controlled
    % closest events OR radius
    % calls: timeplot
    %
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    %  Input Ni:
    %
    report_this_filefun();
    ZG=ZmapGlobal.Data;

    delete(findobj('Tag','plos1'));

    axes(h1)

    % interactively get the circle of interest
    shape=ShapeCircle();

    [ZG.newt2, ~] = selectCircle(newa, shape.toStruct());
    
    % used to plot #columns of newt2 vs -depth. This made no sense
    
    %
    ZG.newcat = ZG.newt2;                   % resets ZG.newcat and ZG.newt2
    
    % Call program "timeplot to plot cumulative number
    %
    ctp=CumTimePlot(ZG.newt2);
    ctp.plot();
    
    
end
