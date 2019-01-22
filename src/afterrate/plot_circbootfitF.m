function plot_circbootfitF()
    % plot_circbootfitF Selects earthquakes in the radius ra around a grid node and calculates the forecast
    % by using calc_bootfitF.m
    %
    % Jochen Woessner
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    report_this_filefun();
    
    ShapeGeneral.clearplot(); % was axes h1, tag plos1
    
    % interactively get the circle of interest
    shape=ShapeCircle(newa.CoordinateSystem);
    [ZG.newt2, max_km] = selectCircle(newa, shape.toStruct());
    
    % Select radius in time
    newt3=ZG.newt2;
    vSel = (ZG.newt2.Date <= ZG.maepi.Date+days(time));
    ZG.newt2 = ZG.newt2.subset(vSel);
    R2 = ZG.newt2.Count;
    messtext = ['Number of selected events: ' num2str(ZG.newt2.Count)  ];
    disp(messtext)
    
    
    % Sort the catalog
    ZG.newt2.sort('Date');
    R2 = ra;
    
    % Plot selected earthquakes
    shape.plot([],ZG.newt2); % linespec was xk, tag was plos1
    
    % Compute and Plot the forecast
    calc_bootfitF(newt3.Date,time,timef,bootloops,ZG.maepi.Date)
    
    ZG.newcat = ZG.newt2;
    ctp=CumTimePlot(ZG.newt2);
    ctp.plot();
    
    
end
