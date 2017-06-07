report_this_filefun(mfilename('fullpath'));

figure
clf
bvfig = gcf;
%whitebg;
set(bvfig,'Units','normalized','NumberTitle','off','Name','b-value curves');
%set(gcf,'pos',[ 0.435  0.8 0.6 0.9])
orient tall
%rect = [0.2,  0.7, 0.60, 0.25];           % plot Freq-Mag curves
%axes('position',rect)
cla
subplot(2,1,2),semilogy(xt3,bvalsum3,'-.m')
hold on
subplot(2,1,2),semilogy(xt3,bvalsum3,'om')
ll = xt3 > M1b(1) & xt3 < M2b(1);
x = xt3(ll);
y = backg_ab(ll);
[p,s] = polyfit(x,y,1);                   % fit a line to background
f = polyval(p,x);
f = 10.^f;
semilogy(x,f,'r')                   % plot fit to backg
semilogy(x,f,':r')
%title(['o: ' num2str(t1p(1)) ' - ' num2str(t2p(1)) '     x: ' num2str(t3p(1)) ' %- '  num2str(t4p(1)) ])
title('NAM')
xlabel('Magnitude ')
ylabel('Cumulative Number -normalized')
aa = p(2) *1000.0;
aa = round(aa);
aa = aa/1000.0;
bb = p(1) *1000.0;
bb = round(bb);
bb = bb/1000.0;          % round to 0.001
stri = [' Log N = ' num2str(aa) num2str(bb) '*M '];
te = text(1,.25e01,stri) ;
set(te,'FontSize',14);
stri = [' Minimum Magnitude = ' num2str(min_backg)];
te = text(1,1e00, stri) ;
set(te,'FontSize',14);

uicontrol('Units','normal','Position',[.9 .01 .10 .05],'String','Postsc  ', 'Callback','print bval.ps -dpsc')
% plo4 = plot(faults(:,1),faults(:,2),'w');


