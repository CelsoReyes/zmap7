function [tt1,tt2]=timesel(var1)
% timesel.m                       Alexander Allmann
% function to select time intervalls for further examination
% Last change                  8/95

% works on newt2

global newt2 ccum tiplo2 ho statime cum

report_this_filefun(mfilename('fullpath'));

%timeselection with mouse in cumulative number plot
if var1==1 | var1==4
 messtext=...
  ['To select a time window for further examination'
   'Please select the start- and endtime of the    '
   'sequence with the LEFT mouse button            '];
 welcome('Time Selection ',messtext);
if var1==1
 figure_w_normalized_uicontrolunits(ccum)
else
 figure_w_normalized_uicontrolunits(cum)
end
 hold on
 seti = uicontrol('Units','normal',...
                 'Position',[.4 .01 .2 .05],'String','Select Time1 ');
 % XLim=get(tiplot2,'Xdata');
 M1b = [];
 M1b= ginput(1);
 tt1= M1b(1);
 plot(M1b(1),0,'o');
  set(seti,'String','Select Time2');
 %pause(1)
 M2b = [];
set(gcf,'Pointer','cross')
 M2b = ginput(1);
 plot(M2b(1),0,'o')
 tt2= M2b(1);
 delete(seti)
 if tt1>tt2     % if start and end time are switched
  tt3=tt2;
  tt2=tt1;
  tt1=tt3;
 end
% build new catalog newt2
  if ~isempty(statime)
   ll=find(newt2(:,3)>statime+tt1/365 & newt2(:,3)<statime+tt2/365);
   tt1=statime+tt1/365;
   tt2=statime+tt2/365;
  else
   ll=find(newt2(:,3)>tt1 & newt2(:,3)<tt2);
  end
  newt2=newt2(ll,:);
  ho ='noho';
end
