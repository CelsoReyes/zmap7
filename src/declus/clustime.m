function eqtime = clustime(some_cat)
    % These routine calculates the time in days of the eqs. in newcat relative
    % to the year 1902
    %clustime.m                                          A.Allmann
  
    %rewritten by Celso Reyes 2017
    
    global newcat
    if exist('some_cat','var')
        newcat = some_cat;
    else
        % just use newcat
    end
    eqtime = days(newcat.Date - datetime(1902,01,01));
end