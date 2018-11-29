% This plot a DEM map plus eq on top... for an area that overlaps
% two DEM files.
import zmaptopo.TopoToFlag
report_this_filefun(mfilename('fullpath'));

l  = get(h1,'XLim');
s1 = l(2); s2 = l(1);
l  = get(h1,'YLim');
s3 = l(2); s4 = l(1);
fac = 1;
if abs(s4-s3) > 10 | abs(s1-s2) > 10 
    def = {'3'};
    ni2 = inputdlg('Decimation factor for DEM data?','Input',1,def);
    l = ni2{:};
    fac = str2double(l);
end
try
    cd(fullfile(hodi, 'dem','gtopo30'));
    [tmap, tmapleg] = gtopo30('test',fac,[s4 s3],[ s2 s1]);
    [tmap2, tmapleg2] = gtopo30('test',fac,[s4 s3],[ s2 s1]);
catch
    disp('failed to load gtopo30');
end

my = s4:1/tmapleg(1):s3+0.1;
mx = s2:1/tmapleg(1):s1+0.1;
toflag = TopoToFlag.five;
plt = 'plo'; % pltopo;

[ro1,co1] = size(tmap);
[ro2,co2] = size(tmap2);
total_map(1:ro1,1:co1) = tmap(1:ro1,1:co1);
total_map(ro1+1:ro1+ro2,1:co2) = tmap2(1:ro2,1:co2);
total_legend = tmapleg;
tdiff1 = s3 - tmapleg(2);
tdiff2 = s3 - tmapleg2(2);
if abs(tdiff2) < abs(tdiff1)
    total_legend(2) = tmapleg2(2);
end

[m,n] = size(total_map);

[existFlag,figNumber]=figure_exists('Topographic Map',1);

if existFlag == 0;  ac3 = 'new'; overtopo;   end
if existFlag == 1
    figure_w_normalized_uicontrolunits(to1)
    delete(gca); delete(gca);delete(gca)
end

hold on; axis off

smx = (mx <= -117.5 & mx >= -125); %% added to limit a particular map
smy = (my >= 36  & my <= 41); %% added to limit a particular map
ssmx = mx(smx);
ssmy = my(smy);

axes('position',[0.1,  0.10, 0.75, 0.8]);
pcolor(mx(1:n),my(1:m),total_map); shading flat
%   pcolor(ssmx,ssmy,total_map); shading flat
demcmap(total_map);
hold on

whitebg(gcf,[0 0 0]);

set(gca,'FontSize',12,'FontWeight','bold','TickDir','out')
set(gcf,'Color','k','InvertHardcopy','off')
display ('END OF CAL_TOPO');


