% This plot a DEM map plus eq on top... for an area that overlaps
% two DEM files.
import zmaptopo.TopoToFlag

report_this_filefun(mfilename('fullpath'));

figure_w_normalized_uicontrolunits(map)
l  = get(h1,'XLim');
s1_east = l(2); s2_west = l(1);
l  = get(h1,'YLim');
s3_north = l(2); s4_south = l(1);
fac = 1;
if abs(s4_south-s3_north) > 0.4 || abs(s1_east-s2_west) > 0.4
    def = {'3'};
    ni2 = inputdlg('Decimation factor for DEM data?','Input',1,def);
    l = ni2{:};
    fac = str2double(l);
end
try
    cd(fullfile(hodi, 'dem', 'usgsdem3'));
catch err
    rethrow(err);
end



% which usgs dem 3 arc sec files do we need?

[fname, qname] = usgsdems([s4_south s3_north],[s2_west s1_east])
er = 0;
for i = 1:length(fname)
    l = fname{i};
    disp(['Checking for existence of file  ' l '  .... ']);
    if ~exist(l)
        disp(['Please get the file  ' l '  via ftp from ftp://edcftp.cr.usgs.gov/pub/data/DEM/250 and copy it into usgsdem3']);
        er = 1;
    else
        disp(['File  ' l '  OK!. ']);
    end
end

if er == 1; return; end


l = fname{1};
disp(['Trying to read file  ' l '  .... ']);
[tmap1, tmapleg1 ] =  usgsdem(l,fac,[ s4_south ceil(s4_south)],[s2_west ceil(s2_west)]);

l = fname{3};
disp(['Trying to read file  ' l '  .... ']);
[tmap2, tmapleg2 ] =  usgsdem(l,fac,[ ceil(s4_south) s3_north],[s2_west ceil(s2_west)]) ;

l = fname{2};
disp(['Trying to read file  ' l '  .... ']);
[tmap3, tmapleg3 ] =  usgsdem(l,fac,[ s4_south ceil(s4_south)],[ ceil(s2_west) s1_east]);

l = fname{4};
disp(['Trying to read file  ' l '  .... ']);
[tmap4, tmapleg4 ] =  usgsdem(l,fac,[ ceil(s4_south) s3_north],[ceil(s2_west) s1_east]);



tmapa = [tmap1 ; tmap2, ];

tmapb = [tmap3 ; tmap4];

tmap = [tmapa tmapb];
tmapleg = [tmapleg1(1) tmapleg4(2) tmapleg1(3)];


clear tmap1 tmap2 tmap3 tmap4 tmapa tmapb

mx = s2_west:1/(tmapleg1(1)+1):s1_east;
my = s4_south:1/(tmapleg1(1)+1):s3_north;
l = tmap == 0 ;
tmap(l) = nan;

toflag = TopoToFlag.Five;
plt = 'plo'; % pltopo;


[m,n] = size(tmap);

[existFlag,figNumber]=figure_exists('Topographic Map',1);

if existFlag == 0;  ac3 = 'new'; overtopo;   end
if existFlag == 1
    figure_w_normalized_uicontrolunits(to1)
    delete(gca); delete(gca);delete(gca)
end

hold on; axis off


axes('position',[0.1,  0.10, 0.75, 0.8]);
pcolor(mx(1:n),my(1:m),tmap); shading flat
demcmap(tmap);
hold on

whitebg(gcf,[0 0 0]);

set(gca,'FontSize',12,'FontWeight','bold','TickDir','out')
set(gcf,'Color','k','InvertHardcopy','off')
disp('END OF USA_TOPO');


