function plot_coastline(params, hParentFigure)
% function plot_coastline(params, hParentFigure);
%-------------------------------------------
% Plot coastline
%
% Incoming variables:
% params        : all variables
% hParentFigure : Handle of the parent figure
%
% J.Woessner, woessner@seismo.ifg.ethz.ch
% last update: 21.08.02
global coastline
% Track of changes:

% Get the axes handle of the plotwindow
axes(pf_result('GetAxesHandle', hParentFigure, [], guidata(hParentFigure)));
hold on;
plot(coastline(:,1),coastline(:,2),'k');
ylabel('Latitude');
xlabel('Longitude');

if exist(params.faults)
    plot(params.faults(:,1),params.faults(:,2),'k');
end
