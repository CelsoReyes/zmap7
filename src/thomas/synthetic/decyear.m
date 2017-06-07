function [decyr] = decyear(date)

% function [decyr] = decyear(date)
%
% This Matlab function converts dates in year,month,day into
% year+fraction of yr. Takes into account leap years.
% date is a matrix with dates as yr, mn, dy , etc
% It returns a n-vector (decyr) with results
%
% If you need days after first of january of each year do the following
%        days = (decyr - date(:,cy))*365;
%  where cy is the column in matrix date corresponding to years
%
%  ------------------
% Last modification 6/95, A.Allmann
%
% transformation including seconds added, Samuel Neukomm, 3/12/04

%report_this_filefun(mfilename('fullpath'));

mday= [0,31,59,90,120,151,181,212,243,273,304,334]';%cumulative days in one year
mdayl=[0,31,60,91,121,152,182,213,244,274,305,335]'; %leapyear
l=1:length(date(:,1));
if length(date(1,:))==3 % yr,mon,day!!!
    decyr = mday(date(l,2))/365+(date(l,3)-1)/365 + floor(date(l,1));
elseif length(date(1,:))==5 % yr,mon,day,hr,min !!!
    decyr = mday(date(l,2))/365+((date(l,3)-1) + date(l,4)/24 + date(l,5)/1440)/365 + floor(date(l,1));
elseif length(date(1,:))==6 % yr,mon,day,hr,min,sec !!!
    decyr = mday(date(l,2))/365+((date(l,3)-1) + date(l,4)/24 + date(l,5)/1440+date(l,6)/86400)/365 + floor(date(l,1));
end
%
% test for leap year
%
leapy = rem(fix(date(:,1)),4) == 0 & rem(fix(date(:,1)),100) ~= 0 | rem(fix(date(:,1)),400) == 0  ;
ones = find(leapy);
if length(ones) >= 1
    if length(date(1,:))==3
        decyr(ones) = (mdayl(date(ones,2))+(date(ones,3)-1))/366 + floor(date(leapy,1));
    elseif length(date(1,:))==5
        decyr(ones)=(mdayl(date(ones,2))+(date(ones,3)-1)+date(ones,4)/24+date(ones,5)/1440)/366 + floor(date(ones,1));
    elseif length(date(1,:))==6
        decyr(ones)=(mdayl(date(ones,2))+(date(ones,3)-1)+date(ones,4)/24+date(ones,5)/1440+date(ones,6)/86400)/366 + floor(date(ones,1));
    end
end
