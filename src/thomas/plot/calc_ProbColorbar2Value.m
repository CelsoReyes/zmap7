function [mPlotValueOut]=plot_ProbColorbar2(mPlotValue)

% colormap(abs((gui_Colormap_ReadPovRay('ProbabilitySRC0-4sigma.pov'))))
% set(gca,'CLim',[pmin pmax]);
% colorbar('Location','EastOutside',...
%     'YLim',[pmin pmax],...
%     'YTick',      [0, 0.3010, 0.7995,  1.3010, 1.6430, 2.8697,  4],...
%     'YTickLabel',{'0', '0.5', '1s', '0.95', '2s', '3s', '0.9999'});

% testing colorbar
mPlotValueOut=mPlotValue*NaN;
vSel=(mPlotValue>=0.5);
mPlotValueOut(vSel)=log10(1-mPlotValue(vSel));
mPlotValueOut(~vSel)=-log10(mPlotValue(~vSel));

% % ProbValues=[0.0001 0.0013 0.0227 0.0500 0.1587 00.5     0.8413 0.9500 0.9772 0.9987 0.9999]'
%
%     0.0001    4.0000    1.0000
%     0.0013    2.8697    0.8587  3s
%     0.0227    1.6430    0.7054  2s
%     0.0500    1.3010    0.6626
%     0.1000    1.0000    0.6250
%     0.1587    0.7995    0.5999  1s
%     0.5000    0.3010    0.5376
%     0.5000   -0.3010    0.4624
%     0.8413   -0.7995    0.4001  1s
%     0.9000   -1.0000    0.3750
%     0.9500   -1.3010    0.3374
%     0.9772   -1.6430    0.2946  2s
%     0.9987   -2.8697    0.1413  3s
%     0.9999   -4.0000   -0.0000
