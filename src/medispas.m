%  This is subroutine " displayas.m". A as(t) value is calculated for
%  a given mean depth curve and displayed in the plot.
%  Operates on catalogue newcat                              A.Allmann

report_this_filefun(mfilename('fullpath'));

%
% start and end time
%
%b = newcat;
%select big evenets
%l = b(:,6) > minmag;
%big = b(l,:);


%
%  iwl is the cutoff at the beginning and end of the analyses
%  to afoid spikes at the end
iwl = 5;

%
% calculate mean and z value
%
ncu = length(xt2);
as = zeros(1,ncu);
%tdiff = round((teb - t0b)*365/par1);



for i = iwl:ind-iwl
    mean1 = mean(meand(1:i));
    mean2 = mean(meand(i:ncu));
    var1 = cov(meand(1:i));
    var2 = cov(meand(i:ncu));
    as(i) = (mean1 - mean2)/(sqrt(var1/i+var2/(ind-i)));
end     % for i


%
%  Plot the as(t)
%
%figure_w_normalized_uicontrolunits(2)
delete(p5);
orient tall
rect = [0.1, 0.55, 0.75, 0.30];
axes('position',rect)

pyy1 = plotyy(xt2,meand,'ob',xt2,as,'r',[0 0 0 NaN NaN min(meand*1.5) 0 min(as)*3-1  max(as*3)+1  ])

xlabel('Time  [years]')
ylabel('Mean Depth (km)')
y2label('z-value')
stri = ['Mean depth and z-value of ' file1];
title(stri)
grid

%hold on;

% plot big events on curve
%
%if ~isempty(big)
% f = cumu2((big(:,3) -t0b)*365/par1);
% bigplo = plot(big(:,3),f,'xb');
% set(bigplo,'MarkerSize',10,'LineWidth',2.5)
% stri2 = [];
% [le1,le2] = size(big);
% for i = 1:le1;
%  s = sprintf('|  M=%3.1f',big(i,6));
%  stri2 = [stri2 ; s];
% end   % for i
% te1 = text(big(:,3),f,stri2);
% set(te1,'FontWeight','bold','Color','m','FontSize',12)
% end % if big
