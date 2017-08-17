function [fYr, nMn, nDay, nHr, nMin, nSec]=decyear2matS(fDy)
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
    
    disp('~/zmap/src/decyear2matS.m')
    
    % save year in decimal format
    fYr=fDy;
    % define leap years
    %bLeapYr = rem(fix(fDy),4) == 0 & rem(fix(fDy),100) ~= 0 | rem(fix(fDy),400) == 0 ;
    bLeapYr=isleap(floor(fYr));
    
    lep=(find(bLeapYr==1));
    
    
    % for leap years
    mDay=[0,31,60,91,121,152,182,213,244,274,305,335]'; %leapyear
    dadi=mDay*ones(size(lep),1)';
    
    
    subtra=ones(1,size(mDay))'*(rem(fDy(lep),1).*366)';
    zer=(0<(dadi-subtra));
    [irt, jkl, v] = find(zer);
    tse = logical(diff([0;jkl]));           % calculate year
    i = repmat(13, [size(zer,2) 1]);
    
    
    i(jkl(tse)) = irt(tse);
    
    nMn(lep)=i-1;
    nDay(lep)=ceil(rem(fDy(lep),1).*366)-mDay(nMn(lep)); % calculate days
    
    
    nHr(lep)=rem(fDy(lep),1)'.*366.*24-(mDay(nMn(lep))'+nDay(lep)-1).*24;
    nMin(lep)=rem(nHr(lep),1).*60;
    nHr(lep)=fix(nHr(lep)); % hours
    nSec(lep)=rem(nMin(lep),1).*60; % seconds
    nMin(lep)=fix(nMin(lep)); % minutes
    
    
    
    %normal years
    lep=(find(bLeapYr==0));
    mDay= [0,31,59,90,120,151,181,212,243,273,304,334]';%cumulative days in one year
    dadi=mDay*ones(size(lep),1)';
    
    
    subtra=ones(1,size(mDay))'*(rem(fDy(lep),1).*365)' ;
    zer=(0<(dadi-subtra));
    [irt, jkl, v] = find((0<(zer)));
    tse = logical(diff([0;jkl]));           % calculate year
    i = repmat(13, [size(zer,2) 1]);
    i(jkl(tse)) = irt(tse);
    nMn(lep)=i-1;
    
    nDay(lep)=ceil(rem(fDy(lep),1).*365)-mDay(nMn(lep)); % calculate days
    
    
    nHr(lep)=rem(fDy(lep),1)'.*365.*24-(mDay(nMn(lep))'+nDay(lep)-1).*24;
    nMin(lep)=rem(nHr(lep),1)*60;
    nHr(lep)=fix(nHr(lep));
    nSec(lep)=rem(nMin(lep),1)*60;
    nMin(lep)=fix(nMin(lep));
end
