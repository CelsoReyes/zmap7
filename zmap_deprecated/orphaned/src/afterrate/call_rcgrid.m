% Script: call_rcgrid.m
% Script to determine rate changes in aftershock sequences on a grid with calc_rcgrid.m.
% Plots the first time slice at the end.
% The function works on the catalog newt2!!!
%
% Output variables:
% RCREL : Relative rate change matrix
%
% J.Woessner
% last update: 03.07.03

% Get input parameters
prompt  = {'Enter forecast period (number of events):','Enter maximum time of learning period (days):',...
    'Enter timesteps (days):','Longitude spacing / [deg]:','Latitude spacing / [deg]:','Radius / [deg]:'};
title   = 'Parameters ';
lines= 1;
def     = {'50','100','5','0.1','0.1','0.15'};
answer  = inputdlg(prompt,title,lines,def);
step = str2double(answer{1});
maxtime = str2double(answer{2});
timestep = str2double(answer{3});
dx = str2double(answer{4});
dy = str2double(answer{5});
r = str2double(answer{6});

% Calculate rate changes on grid
[RCREL,xx,yy] = calc_rcgrid(newt2,dx,dy,r,step,maxtime,timestep);

[existFlag,figNumber]=figure_exists('Rate change time slice',1);
newRCMapFlag=~existFlag;

% Set up figure for time slice plots
if newRCMapFlag
    rctfig = figure_w_normalized_uicontrolunits('tag','rtslice',...
        'Name','Rate change time slice',...
        'NumberTitle','off', ...
        'NextPlot','replace', ...
        'backingstore','on',...
        'Visible','on');
    rctax = axes('tag','axrctfig','NextPlot','replace','box','on');

    matdraw
    %
    uimenu('Label','Choose time slice', 'Callback','plot_timeslice')
end

% Other colormap
% cc = colormap;
% for i = 25:40
%     cc(i,:) = [1 1 1];
% end
% colormap(cc)

% get longitude / latitude
lon = a.Longitude; lat = a.Latitude;
% define grid
xmax = round(10*max(lon))/10+dx;
xmin = round(10*min(lon))/10-dx;
ymax = round(10*max(lat))/10+dy;
ymin = round(10*min(lat))/10-dy;

figure_w_normalized_uicontrolunits(rctfig)
%gcf=findobj('tag','rtslice')
%set(gcf,'Name','Rate change time slice');
set(gca,'tag','axrctfig');
hold on
xx = xmin-dx/2:dx:xmax-dx/2;
yy = ymax+dy/2:-dy:ymin+dy/2; yy = yy';
pcolor(xx,yy,RCREL(:,:,1))
shading flat
axis equal
caxis([-4 4])
colorbar

% plot_tslice=uicontrol('Style', 'pushbutton', 'String', 'Choose time slice','Units','normalized',...
%     'Position',[0.02 0.02 0.3 0.06],'Callback','plot_timeslice');
%hold off;
