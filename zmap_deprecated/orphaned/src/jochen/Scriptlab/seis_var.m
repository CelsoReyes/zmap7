% Master m-file: seis_var.m
%
% Masterscript for the study of seismicity rate changes and variations
%
% Author: J. Woessner, woessner@seismo.ifg.ethz.ch
% last update: 26.06.02
%
basfig=figure_w_normalized_uicontrolunits('tag','welcomefig','Units','normalized','Position',[0.05 0.5 0.4 0.4],'Name','Detecting seismicity variations',...
    'NumberTitle','off');

% Buttons
seis_shift=uicontrol('Style', 'pushbutton', 'String', 'Magnitude characteristics','Units','normalized',...
    'Position',[0.1 0.10 0.3 0.06],'Callback','seisshift');
timestretch=uicontrol('Style', 'pushbutton', 'String', 'Time stretch a catalog','Units','normalized',...
    'Position',[0.1 0.80 0.3 0.06],'Callback','ftimestretch');
exit=uicontrol('Style', 'pushbutton', 'String', 'Exit','Units','normalized',...
    'Position',[0.7 0.1 0.15 0.06],'Callback','delete(findobj(''tag'',''welcomefig'')); close all');

% Figures
%topofig=figure_w_normalized_uicontrolunits('tag','Topography','Name','Topography plot','Nextplot','add','Units', 'normalized',...
%    'Position',[0.5 0.5 0.4 0.4],'Numbertitle','off');
%axtopofig=axes('tag','axtopo','NextPlot','add','box','on');
