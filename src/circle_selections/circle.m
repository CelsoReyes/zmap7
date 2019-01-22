function circle() 
    %   This subroutine "circle"  selects the Ni closest earthquakes
    %   around a interactively selected point.  Resets ZG.newcat and ZG.newt2
    %   Operates on "primeCatalog".
    %
    % axis: h1
    % plots to: plos1 as xk
    % inCatalog: a
    % outCatalog: newt2, newcat
    % mouse controlled
    % closest events
    %
    % turned into function by Celso G Reyes 2017
    %
% 
%
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    report_this_filefun();

    ShapeGeneral.clearplot(); % was tag plos1
    

    % interactively get the circle of interest
    shape=ShapeCircle(newa.CoordinateSystem);

    [ZG.newt2, max_km] = selectCircle(newa, shape.toStruct());

    fprintf('Radius of selected Circle: %s km\n', num2str(max_km) );
    
    % plot Ni clostest events on map as 'x':
    
    set(gca,'NextPlot','add')
    plot(ZG.newt2.Longitude,ZG.newt2.Latitude,'xk','Tag','plos1');
    
    %
    ZG.newcat = ZG.newt2;                   % resets ZG.newcat and ZG.newt2
    
    timeplot(2)
    
end
