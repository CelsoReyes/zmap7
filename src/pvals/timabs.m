function [timp] = timabs(catalog)
    % Number of minutes since january 1, 1926 00:00) to the catalog time
    % seconds are not considered.
    %  modified 5/2001. B. Enescu
    % rewritten by C Reyes 2017

    referenceDate = datetime(1926,1,1,0,0,0);
    timp = fix(minutes(catalog.Date - referenceDate));
