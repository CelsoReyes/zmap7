%function clcross(a)
% plots current cluster catalog in a lambert-map and plots cross-sections
% postition input for cross-sections is interactive
%
% Alexander Allmann 8/95

report_this_filefun(mfilename('fullpath'));


global fipo  lclu winx winy wi

al=cluscat;

% Build figure lambert-map
%
[existFlag,figNumber]=figure_exists('Cluster Map (Lambert)',1);
newMapLaWindowFlag=~existFlag;

if newMapLaWindowFlag
    lclu = figure_w_normalized_uicontrolunits( ...
        'Name','Cluster Map (Lambert)',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'backingstore','on',...
        'Visible','off', ...
        'Position',[ fipo(3)-600 fipo(4)-400 winx winy]);
    
    matdraw
    drawnow
end % if figure exist

figure_w_normalized_uicontrolunits(lclu)
delete(gca);

lc_event(al(:,2),al(:,1),'.k');

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
%if term == 1 ; whitebg([0 0 0 ]);end

[xsecx xsecy,  inde] = mysect(al(:,2)',al(:,1)',al(:,7),wi);

delete(uic)

uic3 = uicontrol('Units','normal',...
    'Position',[.80 .88 .20 .10],'String','Make Grid',...
     'Callback','sel = ''in'';magrcros');

uic4 = uicontrol('Units','normal',...
    'Position',[.80 .68 .20 .10],'String','Make b cross ',...
     'Callback','sel = ''in'';bcross');

figure_w_normalized_uicontrolunits(lclu)
uic2 = uicontrol('Units','normal',...
    'Position',[.70 .92 .30 .06],'String','New selection ?',...
     'Callback','delete(uic2),lammap');
set_width = uicontrol('style','edit','value',wi,...
    'string',num2str(wi), 'background','y',...
    'units','norm','pos',[.90 .00 .08 .06],'min',0,'max',10000,...
     'Callback','wi=str2double(get(set_width,''String''));');

wilabel = uicontrol('style','text','units','norm','pos',[.60 .00 .30 .06]);
set(wilabel,'string','Width in km:','background','y');
if term == 1 ; whitebg([0 0 0 ]);end

% create the selected catalog
%
newa  = a.subset(inde);
newa = [newa xsecx'];
% call the m script that produces a grid
sel = 'in';
%magrcros
