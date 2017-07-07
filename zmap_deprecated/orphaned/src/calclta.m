%   This subroutine is called from displatlta. It calculates the
%   z value for the LTA function for a given windowlength iwl in bins
%

report_this_filefun(mfilename('fullpath'));

ncu = length(xt);
lta = 1:1:ncu;
lta = lta* 0;
iwl = round(iwl3*365/par1);
%
%  calculated mean, var etc
%
for i = 1:tdiff-iwl
    mean1 = mean(cumu(1:ncu));
    mean2 = mean(cumu(i:i+iwl));
    var1 = cov(cumu(1:ncu));
    var2 = cov(cumu(i:i+iwl));
    lta(i+round(iwl/2)) = (mean1 - mean2)/(sqrt(var1/ncu+var2/(iwl)));
end     % for i

%
% plot  the data
%
hold off
pyy = plotyy(xt,cumu2,'ob',xt,lta,'r',[0 0 0 NaN NaN NaN NaN min(lta)*3-1 max(lta*3)+1  ])

xlabel('Time in [years]')
ylabel('Cumulative Number')
str2 = ['LTA of ' file1];
title(str2)

y2label('z-value')
grid
k = gca;
te1 = text(min(xt),max(cumu2)-0.1,stri) ;
set(te1,'FontSize',12,'Color','k')
text(...
    'Color','k',...
    'Units','normalized',...
    'EraseMode','normal',...
    'Position',[-0.25 -0.32 0 ],...
    'Rotation',0 ,...
    'FontSize',12,...
    'String','LTA window length (years):');




