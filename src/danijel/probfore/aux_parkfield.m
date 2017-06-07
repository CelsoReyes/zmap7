function aux_parkfield(vResult, hParentFigure)

sComputer = computer;
if sComputer(1:3) == 'PCW'
  sFont = 'Verdana';
else
  sFont = 'Helvetica';
end

axes(pf_result('GetAxesHandle', hParentFigure, [], guidata(hParentFigure)));
shading flat;
set(gca, 'Color', [0 0 0]);

set(gcf, 'InvertHardcopy', 'off');

set(gca, 'XLim', [0 100]);
hXLabel = text('String', 'Distance [km]');
set(hXLabel, 'FontName', sFont);
set(hXLabel, 'FontSize', 18);
set(hXLabel, 'FontWeight', 'bold');
set(gca, 'XLabel', hXLabel);
set(gca, 'XTickMode', 'manual');
set(gca, 'XTick', [0 10 20 30 40 50 60 70 80 90 100]);
set(gca, 'XColor', [1 1 1]);

set(gca, 'YLim', [-15 0]);
hYLabel = text('String', 'Depth [km]');
set(hYLabel, 'FontName', sFont);
set(hYLabel, 'FontSize', 18);
set(hYLabel, 'FontWeight', 'bold');
set(gca, 'YLabel', hYLabel);
set(gca, 'YTickLabel', '15|10|5|0');
set(gca, 'YColor', [1 1 1]);

set(gca, 'FontName', sFont);
set(gca, 'FontSize', 14);
set(gca, 'FontWeight', 'bold');

set(gca, 'LineWidth', 3);

%set(gca, 'CLim', [0.6 1.4]);


hColorbar = pf_result('GetColorbarHandle', hParentFigure, [], guidata(hParentFigure));
delete(hColorbar);
% set(hColorbar, 'FontName', sFont);
% set(hColorbar, 'FontSize', 14);
% set(hColorbar, 'FontWeight', 'bold');
% set(hColorbar, 'XColor', [1 1 1]);
% set(hColorbar, 'YColor', [1 1 1]);
% %set(hColorbar, 'XLim', [0.6 1.4]);
% %set(hColorbar, 'CLim', [0.6 1.4]);
%
% set(hColorbar, 'LineWidth', 3);


hPlot = pf_result('GetFigureHandle', hParentFigure, [], guidata(hParentFigure));

vPos = get(hPlot, 'Position');
vPos(3) = 1000;
vPos(4) = 500;
set(hPlot, 'Position', vPos);
set(hPlot, 'Color', 'k');

hEQPlot = pf_result('GetEQPlotHandle', hParentFigure, [], guidata(hParentFigure));
set(hEQPlot, 'MarkerFaceColor', [1 1 1]);
set(hEQPlot, 'MarkerEdgeColor', [1 1 1]);
set(hEQPlot, 'MarkerSize', 3);
