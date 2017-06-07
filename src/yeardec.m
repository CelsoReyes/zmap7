function [yrdec] = yeardec(date2)
    %
    % Sintax  [decyr] = decyear(date2)
    %
    % This Matlab function converts dates in year,month,day into
    % year+fraction of yr. Takes into account leap years.
    % date is a matrix with dates as yr, mn, dy , etc
    % It returns a n-vector (decyr) with results
    %
    % If you need days after first of january of each year do the following
    %        days = (decyr - date2(:,cy))*365;
    %  where cy is the column in matrix date corresponding to years
    %
    %  ------------------                          R. Zuniga, GI-UAF, 4/94
    %

    report_this_filefun(mfilename('fullpath'));

    %  format long ;
    yr = floor(dec);
    mo = floor((dec - yr)*365/30.333333333333333333 +1)
    day = floor((((dec - yr)*365/30.333333333333333333 +1) -mo)*30.3333333333333 +1.000000001)
    hr = day - ((((dec - yr)*365/30.333333333333333333 +1) -mo)*30.3333333333333 +1.000000001)
    hr = floor(hr*24+1)
    min = hr - (hr*24+1)
    date2(:,2) = date2(:,2) -1;
    decyr = (floor(30.3333333333*date2(:,2))+date2(:,3))/365 + floor(date2(:,1));
    %
    % test for leap year
    %
    leapy = rem(date2(:,1),4) == 0 && rem2(date2(:,1),100) ~= 0 | ...
        rem(date2(:,1),400) == 0  ;
    ones = find(leapy);
    if length(ones) >= 1
        decyr(leapy) = (floor(30.34*date2(leapy,2))+date2(leapy,3))/365 + floor(date2(leapy,1));
    end
