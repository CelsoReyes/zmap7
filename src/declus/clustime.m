function eqtime = clustime(some_cat)
    % These routine calculates the time in days of the eqs. in ZG.newcat relative
    % to the year 1902
    % A.Allmann
    % used to modify / use newcat.
  
    %rewritten by Celso Reyes 2017
    
    eqtime = days(some_cat.Date - datetime(1902,01,01));
end
