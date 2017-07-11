function eqtime = clustime(var1,ZG.newcat)
% These routine calculates the time in days of the eqs. in ZG.newcat relative
% to the year 1902
%clustime.m                                          A.Allmann
%Last change  6/95

%global ZG.newcat ttcat tmpcat
load day1902.mat      %days relative to 1902 stored in variable c

mday= [0,31,59,90,120,151,181,212,243,273,304,334]';%cumulative days in one year
mdayl=[0,31,60,91,121,152,182,213,244,274,305,335]'; %leapyear
eqtime=[];%time of eqs. calculated according routine
% if var1==2
%   ZG.newcat=ttcat;
% elseif var1==3
%  ZG.newcat=tmpcat;
% end

if max(ZG.newcat.Date) < 100
   eqtime = datenum(floor(ZG.newcat.Date)+1900, ZG.newcat.Date.Month, ZG.newcat.Date.Day, ZG.newcat.Date.Hour, ZG.newcat.Date.Minute,ZG.newcat.Date.Minute*0)-datenum(1902,1,1);
else
   eqtime = datenum(floor(ZG.newcat.Date), ZG.newcat.Date.Month, ZG.newcat.Date.Day, ZG.newcat.Date.Hour, ZG.newcat.Date.Minute,ZG.newcat.Date.Minute*0)-datenum(1902,1,1);
end
return

 l =  find(rem(fix(ZG.newcat.Date),4)==0);     %leapyears
 if size(l,1) > 0
  if length(ZG.newcat.subset(1))>=9
   eqtime(l)=mdayl(ZG.newcat(l,4),1)+(ZG.newcat(l,5)-1)+ZG.newcat(l,8)/24+ZG.newcat(l,9)/1440+...
        c(fix(ZG.newcat(l,3))-1,1);
  else
    eqtime(l)=mdayl(ZG.newcat(l,4),1)+(ZG.newcat(l,5)-1)+c(fix(ZG.newcat(l,3))-1,1);
  end
 end

 l =  find(rem(fix(ZG.newcat.Date),4)~=0);   %normal years
 if size(l,1) > 0
  if length(ZG.newcat.subset(1))>=9
   eqtime(l)=mday(ZG.newcat(l,4),1)+(ZG.newcat(l,5)-1)+ZG.newcat(l,8)/24+ZG.newcat(l,9)/1440+...
        c(fix(ZG.newcat(l,3))-1,1);
  else
   eqtime(l)=mday(ZG.newcat(l,4),1)+(ZG.newcat(l,5)-1)+c(fix(ZG.newcat(l,3))-1,1);
  end
 end

 eqtime=eqtime';

 return
