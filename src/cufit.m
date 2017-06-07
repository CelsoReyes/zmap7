function ci =  cusum(cat)
% This function calculates the CUMSUm function (Page 1954).
%

report_this_filefun(mfilename('fullpath'));

[existFlag,figNumber]=figure_exists('CUFIT',1);
if existFlag
 cfig2 = figNumber;
else
 cfig2=figure_w_normalized_uicontrolunits(...                  %build figure for plot
          'Units','normalized','NumberTitle','off',...
          'Name','CUFIT',...
          'MenuBar','none',...
          'visible','off',...
          'pos',[ 0.300  0.3 0.4 0.6]);
  ho = 'noho';
  
  matdraw
end   % if fig exist

ci2 = [  ];

m  = cat(:,6);
me = mean(m);
i = (1:1:length(m));
ci = cumsum(m)' - i.*me;


 le = 20;

[p,s] = polyfit(i(1:le),ci(1:le),1);
f = polyval(p,i(1:le));
ci2 = ci(1:le) - f;

for j = 21:length(m)
 [p,s] = polyfit(i(1:j),ci(1:j),1);
 ci2 = [ci2 ci(j)-polyval(p,j)];
end



figure_w_normalized_uicontrolunits(cfig2)
delete(gca);delete(gca);
plot(cat(:,3),ci2,'o','MarkerSize',3)
%plot(i,ci,'o')
set(gca,'visible','on','FontSize',10,'FontWeight','normal',...
    'FontWeight','normal','LineWidth',1.0,...
    'Box','on')
xlabel('Time [yrs]')
ylabel('CUFIT ')
grid


