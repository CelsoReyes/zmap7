%  This is subroutine " ast2.m". A as(t) value is calculated for
%  a given cumulative number curve and displayed in the plot.
%

report_this_filefun(mfilename('fullpath'));

cumu = dat(:,2);
xt = dat(:,1);
cumu2 = cumsum(cumu);


%
%  iwl is the cutoff at the beginning and end of the analyses
%  to afoid spikes at the end
iwl = 10;

%
disp('Input the starting and ending point to get AS of the specified range!!');
t0 = str2double(input('type the starting event number, then return  ','s'));
t1= str2double(input('type the ending event number, then return  ','s'));
% calculate mean and z value
%
ncu = length(xt);
as = zeros(1,ncu);

%t0b = dat(1,1);
%n = length(dat(:,1));
%teb = dat(n,1);
%tdiff = round((teb - t0b));
%tdiff = ncu;



for i = iwl+t0:t1-iwl
    mean1 = mean(cumu(t0:i));
    mean2 = mean(cumu(i+1:t1));
    var1 = cov(cumu(t0:i));
    var2 = cov(cumu(i+1:t1));
    as(i) = (mean1 - mean2)/(sqrt(var1/(i-t0+1)+var2/(t1-i)));
end     % for i


%
%  Plot the as(t)
%
%figure_w_normalized_uicontrolunits(2)
figure
orient landscape
% orient tall
%rect = [0.1,  0.10, 0.9, 0.7];
rect = [0.2,  0.20, 0.75, 0.55];
% rect = [0.2,  0.20, 0.55, 0.75];
axes('position',rect)
%pyy = plotyy(xt,cumu2,'ob',xt,as,'r',[0 0 0 NaN NaN NaN NaN min(as)*3-1 %max(as*3)+1  ])
pyy = plotyy(xt(t0:t1),as(t0:t1),'r',xt(t0:t1),cumu2(t0:t1),'.')
%plot(xt(t0:t1),as(t0:t1),'r');
xlabel('Event')
ylabel('z-value')
%y2label(pyy,'Cumulative Misfit')
grid

hold on;


%
%  show option from here
%
uicontrol('Units','normal','Position',[.9 .86 .10 .05],'String','Close', 'Callback','close')

str2 = ['AS of Aleutians'];
title(str2)
