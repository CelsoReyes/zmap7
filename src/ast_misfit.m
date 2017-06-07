%  This is subroutine "ast.m". A as(t) value is calculated for
%  a given cumulative number curve and displayed in the plot.
%

report_this_filefun(mfilename('fullpath'));

dat(:,2)=mi2(:,2);
dat(:,1)=[1:length(mi2(:,1))]';
cumu = dat(:,2);
xt = dat(:,1);
cumu2 = cumsum(cumu);

%  iwl is the cutoff at the beginning and end of the analyses
%  to avoid spikes at the end
iwl = 5;

%
% calculate mean and z value
ncu = length(xt);
as = zeros(1,ncu);

t0b = dat(1,1);
n = length(dat(:,1));
teb = dat(n,1);
%tdiff = round((teb - t0b));
tdiff = ncu;



for i = iwl+1:tdiff-iwl
    mean1 = mean(cumu(1:i));
    mean2 = mean(cumu(i+1:ncu));
    %mean2 = mean(cumu(i:ncu));
    var1 = cov(cumu(1:i));
    var2 = cov(cumu(i+1:ncu));
    %var2 = cov(cumu(i:ncu));
    as(i) = (mean1 - mean2)/(sqrt(var1/i+var2/(tdiff-i)));
end     % for i

%  Plot the as(t)
%clf
figure;
orient landscape
% orient tall
rect = [0.1,  0.10, 0.8, 0.7];
% rect = [0.2,  0.20, 0.55, 0.75];
axes('position',rect);
%pyy = plotyy(xt,cumu2,'ob',xt,as,'r',[0 0 0 NaN NaN NaN NaN min(as)*3-1 %max(as*3)+1  ])
pyy = plotyy(xt,as,xt,cumu2);
xlabel('Event');
ylabel('z-value');
%y2label('Cumulative Misfit');
grid

hold on;

%  show option from here
%
uicontrol('Units','normal','Position',[.9 .86 .10 .05],'String','Close', 'Callback','close')

str2 = ['AS of Earthquake Number'];
title(str2);
