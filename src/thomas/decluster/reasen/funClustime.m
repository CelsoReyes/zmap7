function eqtime = clustime(var1,mycat)
% These routine calculates the time in days of the eqs. in mycat relative
% to the year 1902
%clustime.m                                          A.Allmann
%

load day1902.mat      %days relative to 1902 stored in variable c

mday= [0,31,59,90,120,151,181,212,243,273,304,334]';%cumulative days in one year
mdayl=[0,31,60,91,121,152,182,213,244,274,305,335]'; %leapyear
eqtime=[];%time of eqs. calculated according routine

if max(mycat.Date) < 100
   eqtime = datenum(floor(mycat.Date)+1900, mycat.Date.Month, mycat.Date.Day, mycat.Date.Hour, mycat.Date.Minute,mycat.Date.Minute*0)-datenum(1902,1,1);
else
   eqtime = datenum(floor(mycat.Date), mycat.Date.Month, mycat.Date.Day, mycat.Date.Hour, mycat.Date.Minute,mycat.Date.Minute*0)-datenum(1902,1,1);
end
return
%{
 l =  find(rem(fix(mycat.Date),4)==0);     %leapyears
 if size(l,1) > 0
  if length(mycat.subset(1))>=9
   eqtime(l)=mdayl(mycat(l,4),1)+(mycat(l,5)-1)+mycat(l,8)/24+mycat(l,9)/1440+...
        c(fix(mycat(l,3))-1,1);
  else
    eqtime(l)=mdayl(mycat(l,4),1)+(mycat(l,5)-1)+c(fix(mycat(l,3))-1,1);
  end
 end

 l =  find(rem(fix(mycat.Date),4)~=0);   %normal years
 if size(l,1) > 0
  if length(mycat.subset(1))>=9
   eqtime(l)=mday(mycat(l,4),1)+(mycat(l,5)-1)+mycat(l,8)/24+mycat(l,9)/1440+...
        c(fix(mycat(l,3))-1,1);
  else
   eqtime(l)=mday(mycat(l,4),1)+(mycat(l,5)-1)+c(fix(mycat(l,3))-1,1);
  end
 end

 eqtime=eqtime';

 return
 %}
