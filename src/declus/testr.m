function rtest = testr(ci,bgdiff)
    %testr.m                                         A.Allmann
    %calculates the testarea in which the programm searches for related eqs
    %

    global r1 rmain bg k1

    %rcrust=30;             %maximum value for spatial interaction zone


    %if size(bgdiff)==0
    % rtest=r1(ci);
    if ci<bg(k1)         %foreshocks
        rtest=r1(ci);       %testradius is respective fracture zone

    elseif ci==bg(k1)         %mainshock
        rtest=r1(ci)+rmain(ci);

    else
        rtest=rmain(bg(k1))+r1(ci);
    end

    %if rtest> rcrust         %to avoid that rtest bigger as crustal thickness
    % rtest=rcrust;                       %requires input of crustal thickness
    %end
