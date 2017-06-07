function [fYr, nMn, nDay, nHr, nMin, nSec]=decyear2mat(fDy)
% function [fYr, nMn, nDay, nHr, nMin, nSec] = decyear2mat(fDy)
% ------------------------------------------------------------------------------------------------
% Calculate decimal year format (from zmap-function decyear, i.e. 1998.734)
% to matrix with columns year, month, day, hour, minute, and second.
% This function was programmed because datevec.m does not work with decimal
% year input format
%
% Input parameters:
%   fDy     Decimal year (like 1998.2515) as vector or float
%
% Output parameters:
%   fYr     decimal year
%   nMn     month
%   nDay    day
%   nHr     hour
%   nMin    minute
%   nSec    second
%
% Example [fYr, nMn, nDay, nHr, nMin, nSec]=decyear2mat(decyear([1989 12 31 10 35 44.3]))
%
% Thomas van Stiphout
% Mai 9, 2007

% disp('~/zmap/src/decyear2mat.m')

% intercept the case where where the year is exactly 1975.00000000000
% add 10^-12 (a fraction of a second) to prevent error
if rem(fDy,1)<10^-11
    fDy=fDy+10^-11;
end
% save year in decimal format
fYr=fDy;

% define leap years
bLeapYr = rem(fix(fDy),4) == 0 & rem(fix(fDy),100) ~= 0 | rem(fix(fDy),400) == 0 ;

% loop over each date
for i=1:size(bLeapYr,1)
    if bLeapYr(i) % for leap years
        mDay=[0,31,60,91,121,152,182,213,244,274,305,335]'; %leapyear
        nMn(i)=sum(mDay<rem(fDy(i),1).*366); % calculate year
        nDay(i)=ceil(rem(fDy(i),1).*366)-mDay(nMn(i)); % calculate days
        nHr(i)=rem(fDy(i),1).*366.*24-(mDay(nMn(i))+nDay(i)-1).*24;
        nMin(i)=rem(nHr(i),1).*60;
        nHr(i)=fix(nHr(i)); % hours
        nSec(i)=rem(nMin(i),1).*60; % seconds
        nMin(i)=fix(nMin(i)); % minutes

    else
        mDay= [0,31,59,90,120,151,181,212,243,273,304,334]';%cumulative days in one year
        nMn(i)=sum(mDay<rem(fDy(i),1)*365);
        nDay(i)=ceil(rem(fDy(i),1)*365)-mDay(nMn(i));
        nHr(i)=rem(fDy(i),1)*365*24-(mDay(nMn(i))+nDay(i)-1)*24;
        nMin(i)=rem(nHr(i),1)*60;
        nHr(i)=fix(nHr(i));
        nSec(i)=rem(nMin(i),1)*60;
        nMin(i)=fix(nMin(i));
    end
end
