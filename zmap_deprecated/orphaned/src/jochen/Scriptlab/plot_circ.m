function plot_circ(params, hParentFigure)
% function plot_circ(params, hParentFigure);
% ------------------------------------------
% Plot a circle around a point
%
% J. Woessner
% last update: 02.10.02

% Get the axes handle of the plotwindow
axes(sv_result('GetAxesHandle', hParentFigure, [], guidata(hParentFigure)));
hold on;
% Select a point in the plot window with the mouse
[fX, fY] = ginput(1);
disp(['X: ' num2str(fX) ' Y: ' num2str(fY)]);
% Plot a small circle at the chosen place
plot(fX,fY,'ok','MarkerSize',2);

report_this_filefun(mfilename('fullpath'));
%fPosY = 47.54;
%fPosX = 7.583;
fPosY = fY;
fPosX = fX;
r = km2deg(params.fRadius);
t = 0:pi/20:2*pi;
[x,y]=meshgrid(t);
plot(fPosX+r*sin(t),fPosY+r*cos(t),'Color',[0 0 0],'Linewidth',2,'Linestyle','--')

