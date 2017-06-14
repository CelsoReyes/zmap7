report_this_filefun(mfilename('fullpath'));

% first layer 0 - 1.5 km
l = org2(:,7) <=1.5 ;
a = org2(l,:);
mainmap_overview()
hetopo

dx = 0.001;
dy = 0.001;
ni = 100;

selgp
sel = 'ca'
bvalgrid


bmap = figure_w_normalized_uicontrolunits( ...
    'Name','b-value-map',...
    'NumberTitle','off', ...
    'MenuBar','none', ...
    'NextPlot','new', ...
    'backingstore','on',...
    'Visible','off', ...
    'Position',[ fipo(3)-600 fipo(4)-400 winx winx]);
% make menu bar
matdraw

% set values gretaer tresh = nan
%
re4 = re3;
l = r > tresh;
re4(l) = zeros(1,length(find(l)))*nan;

rect = [0.20,  0.70, 0.2, 0.2];
% plot image
%
orient landscape
set(gcf,'PaperPosition', [0.5 1 9.0 4.0])

axes('position',rect)
hold on
pco1 = pcolor(gx,gy,re4);
view([-37 30])
axis('off')

axis([ min(gx) max(gx) min(gy) max(gy)])
axis equal
hold on
shading interp
colormap(jet)
caxis([0.7 1.8])
hetopo
set(gca,'visible','on','FontSize',fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')
set(gca,'XTickLabels',[])
set(gca,'YTickLabels',[])

% second layer 1.5 - 3.0 km
l = org2(:,7) <=3.0 & org2(:,7) > 1.5 ;
a = org2(l,:);

sel = 'ca'
bvalgrid


figure_w_normalized_uicontrolunits(bmap)
% set values gretaer tresh = nan
%
re4 = re3; l = r > tresh; re4(l) = zeros(1,length(find(l)))*nan;

rect = [0.20,  0.50, 0.2, 0.2]; axes('position',rect)
hold on
pco1 = pcolor(gx,gy,re4);

axis([ min(gx) max(gx) min(gy) max(gy)])
axis equal
hold on
shading interp
colormap(jet)
caxis([0.7 1.8])
hetopo
set(gca,'visible','on','FontSize',fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')
set(gca,'XTickLabels',[])
set(gca,'YTickLabels',[])

% third layer 3.0 - 6.0 km
l = org2(:,7) <=6.0 & org2(:,7) > 3.0 ;
a = org2(l,:);

sel = 'ca'
bvalgrid


figure_w_normalized_uicontrolunits(bmap)
% set values gretaer tresh = nan
%
re4 = re3; l = r > tresh; re4(l) = zeros(1,length(find(l)))*nan;

rect = [0.20,  0.30, 0.2, 0.2]; axes('position',rect)
hold on
pco1 = pcolor(gx,gy,re4);

axis([ min(gx) max(gx) min(gy) max(gy)])
axis equal
hold on
shading interp
colormap(jet)
caxis([0.7 1.8])
hetopo
set(gca,'visible','on','FontSize',fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')
set(gca,'XTickLabels',[])
set(gca,'YTickLabels',[])

% fourth layer 9.0 - 6.0 km
l = org2(:,7) >6.0;
a = org2(l,:);

sel = 'ca'
bvalgrid

figure_w_normalized_uicontrolunits(bmap)
% set values gretaer tresh = nan
%
re4 = re3; l = r > tresh; re4(l) = zeros(1,length(find(l)))*nan;

rect = [0.20,  0.10  0.2, 0.2]; axes('position',rect)
hold on
pco1 = pcolor(gx,gy,re4);

axis([ min(gx) max(gx) min(gy) max(gy)])
axis equal
hold on
shading interp
colormap(jet)
caxis([0.7 1.8])
hetopo
set(gca,'visible','on','FontSize',fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')

h5 = colorbar('horiz');
set(h5,'Pos',[0.48 0.11 0.23 0.03],...
    'FontWeight','bold','FontSize',10)

if sel == 'ca'

    dx = 0.1; dy = 0.1; ni = 100;

    figure(xsec_fig)
    ax = gca;
    hold on

    messtext=...
        ['To select a polygon for a grid.       '
        'Please use the LEFT mouse button of   '
        'or the cursor to the select the poly- '
        'gon. Use the RIGTH mouse button for   '
        'the final point.                      '
        'Mac Users: Use the keyboard "p" more  '
        'point to select, "l" last point.      '
        '                                      '];

    welcome('Select Polygon for a grid',messtext);

    hold on
    % ax = findobj('Tag','main_map_ax');
    [x,y, mouse_points_overlay] = select_polygon(ax);
    welcome('Message',' Thank you .... ')

    plos2 = plot(x,y,'b-','era','xor');        % plot outline
    sum3 = 0.;
    pause(0.3)

    %create a rectangular grid
    xvect=[min(x):dx:max(x)];
    yvect=[min(y):dy:max(y)];
    gx = xvect;gy = yvect;
    tmpgri=zeros((length(xvect)*length(yvect)),2);
    n=0;
    for i=1:length(xvect)
        for j=1:length(yvect)
            n=n+1;
            tmpgri(n,:)=[xvect(i) yvect(j)];
        end
    end
    %extract all gridpoints in chosen polygon
    XI=tmpgri(:,1);
    YI=tmpgri(:,2);

    ll = polygon_filter(x,y, XI, YI, 'inside');
    %grid points in polygon
    newgri=tmpgri(ll,:);

    % Plot all grid points
    plot(newgri(:,1),newgri(:,2),'+k')

    if length(xvect) < 2  ||  length(yvect) < 2
        errordlg('Selection too small! (not a matrix)');
        return
    end

    itotal = length(newgri(:,1));

    welcome(' ','Running... ');think
    %  make grid, calculate start- endtime etc.  ...
    %
    t0b = newa(1,3)  ;
    n = length(newa(:,1));
    teb = newa(n,3) ;
    tdiff = round((teb - t0b)*365/par1);
    loc = zeros(3,length(gx)*length(gy));

    % loop over  all points
    %
    i2 = 0.;
    i1 = 0.;
    bvg = [];
    allcount = 0.;
    wai = waitbar(0,' Please Wait ...  ');
    set(wai,'NumberTitle','off','Name','b-value grid - percent done');;
    drawnow
    %
    % loop
    %
    for i= 1:length(newgri(:,1))
        x = newgri(i,1);y = newgri(i,2);
        allcount = allcount + 1.;
        i2 = i2+1;

        % calculate distance from center point and sort wrt distance
        l = sqrt(((xsecx' - x)).^2 + ((xsecy + y)).^2) ;
        [s,is] = sort(l);
        b = newa(is(:,1),:) ;       % re-orders matrix to agree row-wise

        % take first ni points
        b = b(1:ni,:);      % new data per grid point (b) is sorted in distance

        % call the b-value function
        [bv magco stan av me mer me2,  rt] =  bvalca2(b);
        l = sort(l);
        bvg = [bvg ; bv magco x y l(ni) mean(b(:,6)) rt ];
        waitbar(allcount/itotal)
    end  % for  newgri

    % save data
    %
    %  set(txt1,'String', 'Saving data...')
    drawnow
    gx = xvect;gy = yvect;

    close(wai)
    % reshape a few matrices
    %
    normlap2=ones(length(tmpgri(:,1)),1)*nan;
    normlap2(ll)= bvg(:,1);
    re3=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,5);
    r=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,6);
    meg=reshape(normlap2,length(yvect),length(xvect));

    old = re3;

    % View the b-value map
    %view_bv2

end   %  if sel = ca

figure_w_normalized_uicontrolunits(bmap)

rect = [0.30,  0.20, 0.6, 0.70];

% set values greater tresh = nan
%
re4 =  0.4343./(meg-min(newa(:,6)));
l = r > tresh;
re4(l) = zeros(1,length(find(l)))*nan;

% plot image
%
axes('position',rect)
hold on
pco1 = pcolor(gx,gy,re4);

axis([ min(gx) max(gx) min(gy) max(gy)])
axis image
shading interp
caxis([0.7 1.8])

set(gca,'visible','on','FontSize',fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')

