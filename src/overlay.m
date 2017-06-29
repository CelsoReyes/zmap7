% This subroutine "overlay.m" is called from varios
% program (view_*.m, subcata.m). It plots an overlay
% of coastlines, faults, earthquakes etc on a map.
% This file should be customized for each region

%  Stefan Wiemer   11/94



report_this_filefun(mfilename('fullpath'));

global main mainfault faults coastline vo
%plot earthquakes
%
hold on
ploeq = plot(a.Longitude,a.Latitude,'.k');
set(ploeq,'Markersize',2);
hold on
set(gca,'Clipping','on')
hold on
if isempty(faults) == 0
    plo4 = plot(faults(:,1),faults(:,2),'w');
    set(plo4,'LineWidth',0.2,'Clipping','on')
end  % if exist faults


if isempty(coastline) ==  0
    mapplot = plot(coastline(:,1),coastline(:,2),'w');
end

%
% plot big earthquake epicenters with a 'x' and the data/magnitude
%
if ~isempty(maepi)
    epimax = plot(maepi(:,1),maepi(:,2),'hm');
    set(epimax,'LineWidth',1.5,'MarkerSize',12,...
        'MarkerFaceColor','w','MarkerEdgeColor','k')
end

if exist('vo') >0
    if isempty(vo) ==  0
        plovo = plot(vo.Longitude,vo.Latitude,'^r');
        set(plovo,'LineWidth',1.5,'MarkerSize',6,...
            'MarkerFaceColor','w','MarkerEdgeColor','r');
    end
end


%plot mainshock(s)
%
if isempty(main) == 0
    plo1 = plot(main(:,1),main(:,2),'hm');
    set(plo1,'LineWidth',1.5,'MarkerSize',12,...
        'MarkerFaceColor','w','MarkerEdgeColor','k')

end  % if main

%plot main faultline

if isempty(mainfault) == 0
    plo3 = plot(mainfault(:,1),mainfault(:,2),'k');
    set(plo3,'LineWidth',1.0,'Clipping','on')
end  % if exist mainfault

