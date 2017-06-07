% This is  the m file lammap2.m. It will display a map view of the
% seismicity in Lambert projection and ask for two input
% points select with the cursor. These input points are
% the endpoints of the crossection.
%
% Stefan Wiemer 2/95

report_this_filefun(mfilename('fullpath'));

xpos = get(gca,'pos');
set(gca,'pos',[0.15 0.3 0.8 0.4]);
figure_w_normalized_uicontrolunits(xsec_fig)

try

    if ~isempty(vo)
        [vox, voy] = lc_xsec2(vo(:,2)',vo(:,1)',vo(:,1)*0,wi,leng,lat1,lon1,lat2,lon2);
    end

    if ~isempty(maepi)
        [maex, maey] = lc_xsec2(maepi(:,2)',maepi(:,1)',maepi(:,7),wi,leng,lat1,lon1,lat2,lon2);
    end

    if ~isempty(well)
        i = find(well(:,1) == inf);wellx = []; welly = [];
        for k = 1:length(i)-1
            [wx, wy] = lc_xsec2(well(i(k):i(k+1),2)',well(i(k):i(k+1),1)',well(i(k):i(k+1),3),wi,leng,lat1,lon1,lat2,lon2);
            [m1,m2] = size(wy) ; if m1 > m2 ; wy = wy', end
            wellx = [wellx  inf  wx];
            welly = [welly  inf  wy];
        end
    end

    if ~isempty(main)
        [maix, maiy] = lc_xsec2(main(:,2)',main(:,1)',main(:,1)*0,wi,leng,lat1,lon1,lat2,lon2);
        maiy = -maiy;
    end


    if exist('maix') > 0
        hold on
        pl = plot(maix,maiy,'*k')
        set(pl,'MarkerSize',12,'LineWidth',2)
    end

    if exist('maex') > 0
        hold on
        pl = plot(maex,-maey,'hk')
        set(pl,'LineWidth',1.5,'MarkerSize',12,...
            'MarkerFaceColor','y','MarkerEdgeColor','k')

    end

    if exist('vox') > 0
        hold on
        plovo = plot(vox,-voy,'^r')
        set(plovo,'LineWidth',1.5,'MarkerSize',6,...
            'MarkerFaceColor','w','MarkerEdgeColor','r');
    end

    if exist('wellx') > 0
        hold on
        plwe = plot(wellx,-welly,'k')
        set(plwe,'LineWidth',2);
    end

catch
end


options = uimenu('Label','Select');
uimenu(options,'Label','Select EQ inside Polygon ',...
    'Callback','h1 = gca;stri = ''Polygon''; selectp');
uimenu(options,'Label','Refresh ',...
     'Callback','[xsecx xsecy,  inde] =mysect(tmp1,tmp2,a(:,7),wi,0,lat1,lon1,lat2,lon2);');

options = uimenu('Label','Ztool');


uimenu(options,'Label', 'differential b ',...
     'Callback','sel = ''in''; h1=gca; bcrossVt2');

uimenu(options,'Label','Fractal Dimension',...
     'Callback','sel = ''in'';Dcross');

uimenu(options,'Label','Mean Depth',...
     'Callback','meandepx');

uimenu(options,'Label','z-value grid',...
     'Callback','sel = ''in'';magrcros');

uimenu(options,'Label','b and Mc grid ',...
     'Callback','sel = ''in'';bcross');

uimenu(options,'Label','Prob. forecast test',...
     'Callback','rContainer.fXSWidth = wi; rContainer.Lon1 = lon1; rContainer.Lat1 = lat1; rContainer.Lon2 = lon2; rContainer.Lat2 = lat2;pt_start(newa, xsec_fig, 0, rContainer, name);');

uimenu(options,'Label','beCubed',...
     'Callback','rContainer.fXSWidth = wi; rContainer.Lon1 = lon1; rContainer.Lat1 = lat1; rContainer.Lon2 = lon2; rContainer.Lat2 = lat2;bc_start(newa, xsec_fig, 0, rContainer);');

uimenu(options,'Label','b diff (bootstrap)',...
     'Callback','rContainer.fXSWidth = wi; rContainer.Lon1 = lon1; rContainer.Lat1 = lat1; rContainer.Lon2 = lon2; rContainer.Lat2 = lat2;st_start(newa, xsec_fig, 0, rContainer);');

uimenu(options,'Label','Stress Varianz',...
     'Callback','sel = ''in''; cross_stress');


uimenu(options,'Label','Time Plot ',...
     'Callback','timcplo;');

uimenu(options,'Label',' X + topo ',...
     'Callback',' xsectopo;');

uimenu(options,'Label','Vert. Exaggeration',...
     'Callback','vexa');

uimenu(options,'Label','Rate change grid',...
     'Callback','sel = ''in'';rc_cross_a2');

uimenu(options,'Label','Omori parameter grid',...
     'Callback','sel = ''in'';calc_Omoricross;'); % formerly pcross

figure_w_normalized_uicontrolunits(mapl)
uic2 = uicontrol('BackGroundColor',[0.9 0.9 0.9],'Units','normal',...
    'Position',[.8 .92 .20 .06],'String','Refresh ',...
     'Callback','delete(uic2),delete(gca),delete(gca),delete(gca),nlammap2');
if term == 1 ; whitebg([0 0 0 ]);end

% create the selected catalog
%
newa  = a(inde,:);
% Check size of catalog, then decide where to put the xsex values
[nY,nX] = size(a);
% if nX < 11
newa = [newa xsecx'];
%     disp('xsecx values stored in last column!');
% else
%     newa(:,11) = xsecx';
%     disp('xsecx values stored in column 11!');
% end
sel = 'in';

