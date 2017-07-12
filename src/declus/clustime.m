function eqtime = clustime(some_cat)
    % These routine calculates the time in days of the eqs. in ZG.newcat relative
    % to the year 1902
    %clustime.m                                          A.Allmann
  
    %rewritten by Celso Reyes 2017
    
    ZG=ZmapGlobal.Data;
    if exist('some_cat','var')
        ZG.newcat = some_cat;
    else
        % just use ZG.newcat
    end
    eqtime = days(ZG.newcat.Date - datetime(1902,01,01));
end