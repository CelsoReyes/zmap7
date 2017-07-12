
function [timp] = timabs(catalog)


    l=1:length(catalog(:,1));

    %  This routine calculates the number of minutes from
    %  the reference date (january 1, 1926 00:00) to the time
    %  (iyr,imo,iday,ihr,min) in catalog.
    %  This value is returned as argument timp.
    %  The routine is the adapted version for Matlab of the subroutine timabs, din aspar.
    %  modified 5/2001. B. Enescu

    Datad = [0,31,59,90,120,151,181,212,243,273,304,334]';

    %timp1 is number of minutes since 00:00 1/1/iyr
    timp1 = ((Datad(catalog(l,4)) + catalog(l,5)-1)*24 + catalog(l,8))*60 + catalog(l,9);

    %timp2 is number of days from 00:00 1/1/1926 to 00:00 1/1/iyr
    timp2 = (floor(catalog(l,3))-1926)*365 + floor((floor(catalog(l,3))-1926)/4);
    timp  = timp1 + timp2 * 24*60;

    %add one day for every february 29 that has passed since 1/1/1926
    ldays = ((floor(catalog(l,3))-1924)*12 + catalog(l,4) - 3)/48;
    ldays = floor(ldays);
    timp = timp + ldays*(24*60);


