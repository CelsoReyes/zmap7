% This is  the m file lammap.m. It will display a map view of the
% seismicity in Lambert projection and ask for two input
% points select with the cursor. These input points are
% the endpoints of the crossection.
%
% Stefan Wiemer 2/95
global mapl
report_this_filefun(mfilename('fullpath'));
%
% Find out of figure already exists
%
[existFlag,figNumber]=figure_exists('Seismicity Map (Lambert)',1);
newMapLaWindowFlag=~existFlag;

global h2 xsec_fig newa
% Set up the Seismicity Map window Enviroment
%
if newMapLaWindowFlag
    mapl = figure_w_normalized_uicontrolunits( ...
        'Name','Seismicity Map (Lambert)',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'backingstore','on',...
        'Visible','off', ...
        'Position',[ (fipo(3:4) - [600 400]) ZmapGlobal.Data.map_len]);
    
    matdraw
    drawnow
end % if figure exist

figure_w_normalized_uicontrolunits(mapl)
delete(gca)
delete(gca)
delete(gca)
delete(gca)
if isempty(coastline)
    coastline = [a(1,1) a(1,2)]
end
hold on
if length(coastline) > 1
    lc_map(coastline(:,2),coastline(:,1),s3,s4,s1,s2)
    g = get(gca,'Children');
    set(g,'Color','k')
end
hold on
if length(faults) > 10
    lc_map(faults(:,2),faults(:,1),s3,s4,s1,s2)
end
hold on
if ~isempty(mainfault)
    lc_map(mainfault(:,2),mainfault(:,1),s3,s4,s1,s2)
end
lc_event(ZG.a.Latitude,ZG.a.Longitude,'.k')
if ~isempty(maepi)
    lc_event(maepi(:,2),maepi(:,1),'xm')
end
if ~isempty(main)
    lc_event(main(:,2),main(:,1),'+b')
end
%title2(strib,'FontWeight','bold',...
%'FontSize',ZmapGlobal.Data.fontsz.m,'Color','k')

uic = uicontrol('Units','normal',...
    'Position',[.05 .00 .40 .06],'String','Select Endpoints with cursor');

titStr ='Create Crossection                      ';

messtext= ...
    ['                                                '
    '  Please use the LEFT mouse button              '
    ' to select the two endpoints of the             '
    ' crossection                                    '
    ];

zmap_message_center.set_message(titStr,messtext);


[xsecx xsecy,  inde] = mysect(ZG.a.Latitude',ZG.a.Longitude',ZG.a.Depth,wi);

%if ~isempty(maepi)
% [maex, maey] = lc_xsec2(maepi(:,2)',maepi(:,1)',maepi(:,7),wi,leng,lat1,lon1,lat2,lon2);
%end

if ~isempty(main)
    [maix, maiy] = lc_xsec2(main(:,2)',main(:,1)',main(:,3),wi,leng,lat1,lon1,lat2,lon2);
    maiy = -maiy;
end
delete(uic)

uic3 = uicontrol('Units','normal',...
    'Position',[.80 .88 .20 .10],'String','Make Grid',...
     'Callback','sel = ''in'';magrcros');

uic4 = uicontrol('Units','normal',...
    'Position',[.80 .68 .20 .10],'String','Make b cross ',...
     'Callback','sel = ''in'';bcross');
uic5 = uicontrol('Units','normal',...
    'position',[.8 .48 .2 .1],'String','Select Eqs',...
     'Callback','crosssel;ZG.newcat=newa ;ZG.a=newa;update(mainmap());');

figure_w_normalized_uicontrolunits(mapl)
uic2 = uicontrol('Units','normal',...
    'Position',[.70 .92 .30 .06],'String','New selection ?',...
     'Callback','delete(uic2),lammap');
set_width = uicontrol('style','edit','value',wi,...
    'string',num2str(wi), 'background','y',...
    'units','norm','pos',[.90 .00 .08 .06],'min',0,'max',10000,...
     'Callback','wi=str2double(get(set_width,''String''));');

wilabel = uicontrol('style','text','units','norm','pos',[.60 .00 .30 .06]);
set(wilabel,'string','Width in km:','background','y');

% create the selected catalog
%
newa  = ZG.a.subset(inde);
newa = [newa xsecx'];
% call the m script that produces a grid
sel = 'in';
%magrcros
