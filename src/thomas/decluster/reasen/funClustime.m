function eqtime = clustime(var1,newcat)
% These routine calculates the time in days of the eqs. in newcat relative
% to the year 1902
%clustime.m                                          A.Allmann
%Last change  6/95

%global newcat ttcat tmpcat
load day1902.mat      %days relative to 1902 stored in variable c

mday= [0,31,59,90,120,151,181,212,243,273,304,334]';%cumulative days in one year
mdayl=[0,31,60,91,121,152,182,213,244,274,305,335]'; %leapyear
eqtime=[];%time of eqs. calculated according routine
% if var1==2
%   newcat=ttcat;
% elseif var1==3
%  newcat=tmpcat;
% end

if max(newcat(:,3)) < 100
   eqtime = datenum(floor(newcat(:,3))+1900, newcat(:,4), newcat(:,5), newcat(:,8), newcat(:,9),newcat(:,9)*0)-datenum(1902,1,1);
else
   eqtime = datenum(floor(newcat(:,3)), newcat(:,4), newcat(:,5), newcat(:,8), newcat(:,9),newcat(:,9)*0)-datenum(1902,1,1);
end
return

 l =  find(rem(fix(newcat(:,3)),4)==0);     %leapyears
 if size(l,1) > 0
  if length(newcat(1,:))>=9
   eqtime(l)=mdayl(newcat(l,4),1)+(newcat(l,5)-1)+newcat(l,8)/24+newcat(l,9)/1440+...
        c(fix(newcat(l,3))-1,1);
  else
    eqtime(l)=mdayl(newcat(l,4),1)+(newcat(l,5)-1)+c(fix(newcat(l,3))-1,1);
  end
 end

 l =  find(rem(fix(newcat(:,3)),4)~=0);   %normal years
 if size(l,1) > 0
  if length(newcat(1,:))>=9
   eqtime(l)=mday(newcat(l,4),1)+(newcat(l,5)-1)+newcat(l,8)/24+newcat(l,9)/1440+...
        c(fix(newcat(l,3))-1,1);
  else
   eqtime(l)=mday(newcat(l,4),1)+(newcat(l,5)-1)+c(fix(newcat(l,3))-1,1);
  end
 end

 eqtime=eqtime';

 return
