%[lat1 lon1 lat2,  lon2] =posinpu
% function posinpu.m               Alexander Allmann
% Position input of two coordinates to build a crossection
%
%
% last update: 20.10.2004
% j.woessner@sed.ethz.ch

report_this_filefun(mfilename('fullpath'));

global a mess
%'MenuBar','none', ...

hInpuCoord = figure_w_normalized_uicontrolunits( ...
    'Name','Cross-section Input Coordinates',...
    'tag','InpuCoordX','Position',[260 504 300 300],...
    'NumberTitle','off', ...
    'backingstore','on',...
    'Visible','on');
set(gca,'Box','off','visible','off')
% figure_w_normalized_uicontrolunits(mess)
% set(gcf,'visible','off')
% clf;
% cla;
% set(gca,'visible','off');
% set(gcf, 'Name','Crossection Input Coordinates');

txt1 = text(...
    'Color',[0 0 0 ],...
    'EraseMode','normal',...
    'Position',[0. 0.65 0 ],...
    'Rotation',0,...
    'FontSize',12,...
    'String','Point 1: ');
txt2 = text(...
    'Color',[0 0 0],...
    'EraseMode','normal',...
    'Position',[0. 0.45 0 ],...
    'Rotation',0,...
    'FontSize',12,...
    'String','Point 2: ');

txt3 = text(...
    'Color',[0 0 0 ],...
    'EraseMode','normal',...
    'Position',[0.35 0.8 0 ],...
    'Rotation',0,...
    'FontSize',12,...
    'String','Longitude:');
txt4 = text(...
    'Color',[0 0 0],...
    'EraseMode','normal',...
    'Position',[0.75 0.8 0 ],...
    'Rotation',0,...
    'FontSize',12,...
    'String','Latitude:');

inp1_field=uicontrol('Style','edit',...
    'Position',[.70 .60 .25 .10],...
    'Units','normalized','String',num2str(lat1,5),...
    'Callback','lat1=str2double(inp1_field.String);inp1_field.String=num2str(lat1);');

inp2_field=uicontrol('Style','edit',...
    'Position',[.70 .40 .25 .10],...
    'Units','normalized','String',num2str(lat2,5),...
    'Callback','lat2=str2double(inp2_field.String);inp2_field.String=num2str(lat2);');

inp3_field=uicontrol('Style','edit',...
    'Position',[.40 .60 .25 .10],...
    'Units','normalized','String',num2str(lon1,6),...
    'Callback','lon1=str2double(inp3_field.String);inp3_field.String=num2str(lon1);');

inp4_field=uicontrol('Style','edit',...
    'Position',[.40 .40 .25 .10],...
    'Units','normalized','String',num2str(lon2,6),...
    'Callback','lon2=str2double(inp4_field.String);inp4_field.String=num2str(lon2);');
go_button=uicontrol('Style','Pushbutton',...
    'Position',[.40 .05 .15 .15],...
    'Units','normalized',...
    'Callback','[xsecx xsecy,  inde] =mysect(tmp1,tmp2,ZG.a.Depth,wi,0,lat1,lon1,lat2,lon2);nlammap2;welcome;close(hInpuCoord)',...
    'String','Go');

cancel_button=uicontrol('Style','Pushbutton',...
    'Position',[.20 .05 .15 .15],...
    'Units','normalized',...
    'Callback','figure_w_normalized_uicontrolunits(mapl);',...
    'String','Cancel');

%    load_button=uicontrol('Style','Pushbutton',...
%                'Position', [.60 .05 .15 .15],...
%                'Units','normalized',...
%                'Callback','clpickp(3);',...
%                'String','load');
% set(mess,'visible','on')
