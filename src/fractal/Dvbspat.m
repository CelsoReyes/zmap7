%
% This code creates the plot of the D-value versus the b-value.
% The code is called from view_Dv.
% Francesco Pacchiani 3/2000
%
%
[bvg5, ord] = sort(bvg(:,5));
bvg1 = bvg(ord,1);
bx = [bvg5(3):0.05: bvg5(end-1)]';
Dy = 2*bx;
clear ord;

Dvb=figure_w_normalized_uicontrolunits('Numbertitle','off','Name','D versus b');
plot(bvg(:,5),bvg(:,1),'ko', 'Markersize', 10);
hold on;
plot(bx, Dy, 'b-','linewidth', 1);
xlabel('b-value', 'fontsize',12);
ylabel('D-value', 'fontsize',12);
title('D-value versus b-value (blue line: D = 2b)', 'fontsize',14);


reg = [ones(size(bvg,1),1), bvg(:,5)];
[sl, cint, res, resint, stat] = regress(bvg(:,1), reg, 0.666);

sl
stat

rsl = [sl(2,1) sl(1,1)];
coef1 = [cint(2,1), cint(1,1)];
coef2 = [cint(2,2), cint(1,2)];
deltar = sl(2,1) - cint(2,1);
[line] = polyval(rsl,bx);
[line1] = polyval(coef1, bx);
[line2] = polyval(coef2, bx);

hold on;
plot(bx, line, 'r', 'Linewidth', 1.5);
plot(bx, line1, 'g:', 'Linewidth', 1);
plot(bx, line2, 'g:', 'Linewidth', 1);

str2 = ['D = xb: x =  ' sprintf('%.2f',sl(2,1)) '  +/- ' sprintf('%.2f', deltar)];
axes('pos',[0 0 1 1]); axis off; hold on;
te1 = text(0.15, 0.87, str2, 'fontsize', 12, 'fontweight', 'bold');
clear sl cint res resint stat rsl coef1 coef2 deltar line line1 line2 str2 te1
