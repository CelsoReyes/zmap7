% This is  the m file lammap.m. It will display a map view of the
% seismicity in Lambert projection and ask for two input
% points select with the cursor. These input points are
% the endpoints of the crossection.
%
% Stefan Wiemer 2/95
% last update: 12.10.2004, jochen.woessner@sed.ethz.ch


global main mainfault faults coastline vo s1 s2 s3 s4
global mapl hoc
if ~exist('hoc')
    hoc = 'noho';
end
if isempty(hoc)
    hoc = 'noho';
end
report_this_filefun(mfilename('fullpath'));
%
% Find out of figure already exists
%
[existFlag,figNumber]=figure_exists('Seismicity Map (Lambert)',1);
newMapLaWindowFlag=~existFlag;

global h2 xsec_fig newa lat1 leng lon1 lon2 lat2 wi
rotationangle = 0;
% Set up the Seismicity Map window Enviroment
%
if newMapLaWindowFlag
    mapl = figure_w_normalized_uicontrolunits( ...
        'Name','Seismicity Map (Lambert)',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'backingstore','on',...
        'Visible','off', ...
        'Position',[ fipo(3)-600 fipo(4)-400 winx winy]);
    
    matdraw
    drawnow

    uicontrol('Units','normal',...
        'Position',[.0 .93 .08 .06],'String','Info ',...
         'Callback',' web([''file:'' hodi ''/zmapwww/chp11.htm#996756'']) ');


    uicontrol('Units','normal',...
        'Position',[.0 .93 .08 .06],'String','Info ',...
         'Callback',' web([''file:'' hodi ''/zmapwww/chap4.htm#997433'']) ');


end % if figure exist

figure_w_normalized_uicontrolunits(mapl)
if strcmp(hoc,'noho') ||  newMapLaWindowFlag == 1
    delete(gca)
    delete(gca)
    delete(gca)
    delete(gca)
    if isempty(coastline)
        coastline = [a.Longitude(1) a.Latitude(1)];
    end
    hold on
    % Added try-catch to prevent failure if no coastline is inside
    % cross-section box, JW
    %try
    if length(coastline) > 1
        lc_map(coastline(:,2),coastline(:,1),s3,s4,s1,s2)
        g = get(gca,'Children');
        set(g,'Color','k')

        %catch
    end
    hold on
    try
        if length(faults) > 10
            lc_map(faults(:,2),faults(:,1),s3,s4,s1,s2)
        end
    catch
    end
    hold on
    if ~isempty(mainfault)
        lc_map(mainfault(:,2),mainfault(:,1),s3,s4,s1,s2)
    end

    if a.Count > 5000;
        %lc_event(a.Latitude,a.Longitude,'.k')
        lc_event(a(a.Depth<=dep1,2),a(a.Depth<=dep1,1),'.b',1);
        lc_event(a(a.Depth<=dep2&a.Depth>dep1,2),a(a.Depth<=dep2&a.Depth>dep1,1),'.g',1);
        lc_event(a(a.Depth<=dep3&a.Depth>dep2,2),a(a.Depth<=dep3&a.Depth>dep2,1),'.r',1);
    else
        lc_event(a(a.Depth<=dep1,2),a(a.Depth<=dep1,1),'+b');
        lc_event(a(a.Depth<=dep2&a.Depth>dep1,2),a(a.Depth<=dep2&a.Depth>dep1,1),'og');
        lc_event(a(a.Depth<=dep3&a.Depth>dep2,2),a(a.Depth<=dep3&a.Depth>dep2,1),'xr');

    end

    if ~isempty(maepi)
        lc_event(maepi(:,2),maepi(:,1),'hy',10,2.0)
    end
    if ~isempty(main)
        lc_event(main(:,2),main(:,1),'hk',10,2.0)
    end
    if ~isempty(vo)
        lc_event(vo(:,2),vo(:,1),'^r')
    end
    if ~isempty(well)
        lc_event(well(:,2),well(:,1),'dk')
    end
end % if hol
%title2(strib,'FontWeight','bold',...
%'FontSize',fontsz.m,'Color','k')
labelList=['Select an option | Select Endpoints by Mouse | Coordinate Input | Multiple segments | Rotate X-Section'];
labelPos = [.05 .00 .40 .06];
tmp1=a.Latitude';tmp2=a.Longitude';

uic = uicontrol(...
    'Style','popup',...
    'Units','normalized',...
    'Position',labelPos,...
    'String',labelList,...
    'Backgroundcolor',[0.9 0.9 0.9],...
     'Callback','in2=get(uic,''Value'');if in2 ==2,[xsecx xsecy,  inde] = mysect(tmp1,tmp2,a.Depth,wi);nlammap2;elseif in2==3, posinpu; elseif in2==4; musec; elseif in2==5; rotateit; end');


set_width = uicontrol('style','edit','value',wi,...
    'string',num2str(wi), 'background',[0.9 0.9 0.9],...
    'units','norm','pos',[.90 .00 .08 .06],'min',0,'max',10000,...
     'Callback','wi=str2double(get(set_width,''String''));');

wilabel = uicontrol('style','text','units','norm',...
    'Backgroundcolor',[0.9 0.9 0.9],...
    'pos',[.70 .00 .20 .06]);
set(wilabel,'string','Width in km:');

set_rotationangle = uicontrol('style','edit','value',rotationangle,...
    'string',num2str(rotationangle), 'background',[0.9 0.9 0.9],...
    'units','norm','pos',[.60 .00 .08 .06],'min',0,'max',360,...
     'Callback','rotationangle=str2double(get(set_rotationangle,''String''));');

wilabel = uicontrol('style','text','units','norm',...
    'Backgroundcolor',[0.9 0.9 0.9],...
    'pos',[.50 .00 .10 .06], 'string', 'Angle [deg]:');


