% function to create a cross-section consisting of multiple segments
%
% stefan wiemer 1/97

report_this_filefun(mfilename('fullpath'));

global rbox  sw

messtext=...
    ['To select the multiple segments:      '
    'Please use the LEFT mouse button      '
    'To select each corner. Use the RIGHT- '
    'the RIGTH mouse button for            '
    'the final point.                      '
    'Mac Users: Use the keyboard "p" more  '
    'point to select, "l" last point.      '
    '                                      '];

zmap_message_center.set_message('Select Mutiple segments for x-section',messtext);

% first lets input the endpoints
but = 1;x=[];y=[];
while but == 1 | but == 112
    [xi,yi,but] = ginput(1);
    [lat1, lon1] = lc_froca(xi,yi);
    lc_event(lat1,lon1,'rx',6,2)
    x = [x; lon1];
    y = [y; lat1];
end

% now feed the endpoints one by one to mysectm
newa=[];
po = length(a(1,:))+1;
for i=1:length(x)-1
    lat1 = y(i);lat2 = y(i+1);lon1 = x(i);lon2=x(i+1);
    [xsecx xsecy,  inde] =mysect(tmp1,tmp2,ZG.a.Depth,wi,0,lat1,lon1,lat2,lon2);
    if sw =='on' ; xsecx = -xsecx +max(xsecx);end
    if i==1; ma = 0; else ; ma = max(newa(:,po));end
    newa  = [newa ; a(inde,:) xsecx'+ma];
end

l = newa(:,6) >= minmag;
maex = newa(l,po);
maey = newa(l,7);
if isempty(maex)==1 ; maex = 0; maey = 0;end
if length(maex)>1 ; maex = maex(1); maey = maey(1);end
newa(:,po) = newa(:,po) - maex;
maex = 0*maex;

[st,ist] = sort(newa);   % re-sort wrt time for cumulative count
newa = newa(ist(:,3),:);
xsecx = newa(:,po)';
xsecy = newa(:,7);

% now lets plot the combined x-section
% with origin at the larget event

[existFlag,figNumber]=figure_exists('Cross -Section',1);
newCrSeWindowFlag=~existFlag;


if newCrSeWindowFlag
    xsec_fig = figure_w_normalized_uicontrolunits( ...
        'Name','Cross -Section',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'backingstore','on',...
        'Visible','on');
    matdraw
    

end

figure_w_normalized_uicontrolunits(xsec_fig)
hold on
delete(gca);delete(gca);
set(xsec_fig,'PaperPosition',[1 .5 9 6.9545])

pl =plot(newa(:,po),-newa(:,7),'rx');
set(pl,'Linewidth',1.5,'MarkerSize',6)

if exist('maex', 'var')
    hold on
    pl = plot(maex,-maey,'xm')
    set(pl,'MarkerSize',10,'LineWidth',2)
end

axis('equal')
axis([min(newa(:,po))*1.1 max(newa(:,po))*1.1 min(-newa(:,7))*1.1 max(-newa(:,7))*1.1]);


set(gca,'Color',color_bg)
set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',12,'Linewidth',1.2)

xlabel('Distance in [km]')
ylabel('Depth in [km]')
matdraw


xpos = get(gca,'pos');
set(gca,'pos',[0.15 0.15 xpos(3) xpos(4)]);

uicontrol('BackGroundColor',[0.9 0.9 0.9],'Units','normal',...
    'Position',[.40 .95 .20 .05],'String','differential b ',...
     'Callback','sel = ''in'';bcrossVt2');

uicontrol('BackGroundColor',[0.9 0.9 0.9],'Units','normal',...
    'Position',[.60 .95 .20 .05],'String','Fractal Dimension',...
     'Callback','sel = ''in'';Dcross');


%uicontrol('BackGroundColor',[0.8 0.8 0.8],'Units','normal',...
%   'Position',[.6 .9 .20 .05],'String','Refresh ',...
%    'Callback','[xsecx xsecy,  inde] =mysect(tmp1,tmp2,ZG.a.Depth,wi,0,lat1,lon1,lat2,lon2);');

uic3 = uicontrol('BackGroundColor',[0.9 0.9 0.9],'Units','normal',...
    'Position',[.20 .95 .20 .05],'String','z-value grid',...
     'Callback','sel = ''in'';magrcros');

uic4 = uicontrol('BackGroundColor',[0.9 0.9 0.9],'Units','normal',...
    'Position',[.0 .95 .20 .05],'String','b and Mc grid ',...
     'Callback','sel = ''in'';bcross');

% uicontrol('Units','normal',...
%   'Position',[.80 .58 .20 .10],'String','b-grid (const R) ',...
%    'Callback','sel = ''in'';bcrossV2');

uic5 = uicontrol('BackGroundColor',[0.8 0.8 0.8],'Units','normal',...
    'position',[0.0 .9 .2 .05],'String','Select Eqs',...
     'Callback','crosssel;ZG.newt2=newa2;ZG.newcat=newa2;timeplot;');

uicontrol('BackGroundColor',[0.8 0.8 0.8],'Units','normal',...
    'position',[.2 .9 .2 .05],'String','Time Plot ',...
     'Callback','timcplo;');

%uicontrol('BackGroundColor',[0.8 0.8 0.8],'Units','normal',...
%   'position',[.4 .9 .2 .05],'String',' X + topo ',...
%    'Callback','plt = ''lo2''; pltopo; xsectopo;');

%uicontrol('BackGroundColor',[0.8 0.8 0.8],'Units','normal',...
%  'position',[.8 .9 .2 .05],'String','Vertical Exageration ',...
%   'Callback','vexa');

%uicontrol('Units','normal',...
%  'position',[.8 .10 .2 .1],'String','p-value grid ',...
%   'Callback','sel = ''in'';pcross;');

figure_w_normalized_uicontrolunits(mapl)
uic2 = uicontrol('BackGroundColor',[0.9 0.9 0.9],'Units','normal',...
    'Position',[.80 .92 .20 .06],'String','Refresh ',...
     'Callback','delete(uic2),delete(gca),delete(gca),delete(gca),nlammap');


% create the selected catalog
%
sel = 'in';


