% This subroutine "overlay.m" is called from varios
% program (view_*.m, subcata.m). It plots an overlay
% of coastlines, faults, earthquakes etc on a map.
% This file should be customized for each region

%  Stefan Wiemer   11/94

report_this_filefun(mfilename('fullpath'));

global main mainfault faults coastline vo

figure_w_normalized_uicontrolunits(map)
ax = axis;
if ax(1) < min(coastline(:,1)) | ax(2) > min(coastline(:,1))
    disp([' Regetting coastline ... ']);
    struc = gshhs2('gshhs_h.b',[s4 s3],[s2 s1] );
    s2 = ax(1);s1 = ax(2);s3 = ax(4);s4 = ax(3);
end
%delete(mapplot);delete(plovo);delete(epimax);


[i,j ] = size(struc);
lat = [];
lon = [];
lat2 = [];
lon2 = [];
figure_w_normalized_uicontrolunits(map)
hold on
for i = 1:j
    if struc(i).tag(1:4) == 'land' | struc(i).tag(1:4) == 'isla' 
        lat = [lat ; struc(i).lat ];
        lon = [lon ; struc(i).long];
        l1 = [  struc(i).lat ];
        l2 =   [  struc(i).long];
        l = isnan(l1); l1(l) = [];
        l = isnan(l2); l2(l) = [];
        fill(l2,l1,[0.9 0.9 0.9]);
        hold on
    end

    if struc(i).tag(1:4) == 'lake'
        lat2 = [struc(i).lat ];
        lon2 = [struc(i).long];
        l1 = [  struc(i).lat ];
        l2 =   [  struc(i).long];
        l = isnan(l1); l1(l) = [];
        l = isnan(l2); l2(l) = [];
        fill(l2,l1,[0.85 0.85 1]);
        hold on
    end
end

coastline = [lon lat];

hold on
if exist('coastline', 'var')
    if isempty(coastline) ==  0
        mapplot = plot(coastline(:,1),coastline(:,2));
        set(mapplot,'LineWidth',1.0,'Color',[0  0      0 ])
    end
end
if exist('vo', 'var')
    if isempty(vo) ==  0
        plovo = plot(vo.Longitude,vo.Latitude,'^r');
        set(plovo,'LineWidth',1.5,'MarkerSize',6,...
            'MarkerFaceColor','w','MarkerEdgeColor','r');
    end
end

% plot the well location
if exist('well', 'var')
    if isempty(well) ==  0
        i = find(well(:,1) == inf);
        plowe = plot(well(i+1,1),well(i+1,2),'d');
        set(plowe,'LineWidth',1.5,'MarkerSize',6,...
            'MarkerFaceColor','k','MarkerEdgeColor','k');
    end
end

%plot main faultline

if exist('mainfault', 'var')
    if isempty(mainfault) == 0
        plo3 = plot(mainfault(:,1),mainfault(:,2),'b');
        set(plo3,'LineWidth',3.0)
    end  % if exist mainfault
end

%
% plot big earthquake epicenters with a 'x' and the data/magnitude
%
if exist('maepi', 'var')
    if isempty(maepi) == 0
        epimax = plot(maepi(:,1),maepi(:,2),'hm');
        set(epimax,'LineWidth',1.5,'MarkerSize',12,...
            'MarkerFaceColor','y','MarkerEdgeColor','k')

        stri2 = [];
        for i = 1:length(maepi(:,1));
            s = sprintf('   %3.1f M=%3.1f',maepi(i,3),maepi(i,6));
            stri2 = [stri2 ; s];
        end   % for i
        te1 = text(maepi(:,1),maepi(:,2),stri2);
        set(te1,'FontWeight','normal','Color','k','FontSize',9,'Clipping','on')
    end  %  if length(maepi)
end  %  if length(maepi)


%plot mainshock(s)
%
if exist('main', 'var')
    if isempty(main) == 0
        plo1 = plot(main(:,1),main(:,2),'*k');
        set(plo1,'MarkerSize',12,'LineWidth',2.0)
    end  % if main
end


if exist('faults', 'var')
    if isempty(faults) == 0
        plo4 = plot(faults(:,1),faults(:,2),'k');
        set(plo4,'LineWidth',0.2)
    end  % if exist faults
end
%axis([ s2 s1 s4 s3])
