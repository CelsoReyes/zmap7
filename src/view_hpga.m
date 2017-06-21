% This .m file "view_maxz.m" plots the maxz LTA values calculated
% with maxzlta.m or other similar values as a color map
% needs re3, gx, gy, stri
%
% define size of the plot etc.
%

if exist('Prmap')  == 0
    Prmap = re3*nan;
end
if isempty(Prmap) >  0
    Prmap = re3*nan;
end

if isempty(name) >  0
    name = '  '
end
think
report_this_filefun(mfilename('fullpath'));
%co = 'w';


% Find out of figure already exists
%
[existFlag,figNumber]=figure_exists('Hazard-map',1);
newhazmapWindowFlag=~existFlag;


% Set up the Seismicity Map window Enviroment
%
if newhazmapWindowFlag
    hmap = figure_w_normalized_uicontrolunits( ...
        'Name','Hazard-map',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','new', ...
        'backingstore','on',...
        'Visible','off', ...
        'Position',[ fipo(3)-600 fipo(4)-400 winx winy]);
    % make menu bar
    matdraw

    lab1 = 'HPGA - value:';
    hmap = gcf;

    add_symbol_menu('eq_plot');

    options = uimenu('Label',' Select ');
    uimenu(options,'Label','Refresh ', 'Callback','view_hpga')
    uimenu(options,'Label','Compute hazard curve at one location',...
         'Callback','watchon ; newhazfig = 0; ;hazcurve;watchoff  ')
    uimenu(options,'Label','Compute hazard curve at one location (overlay existing graph)',...
         'Callback','watchon ; newhazfig = 1; ;hazcurve;watchoff  ')


    % Map menu
    op1 = uimenu('Label',' Maps ');

    uimenu(op1,'Label','Re-compute map with new parameters ',...
         'Callback','dohaz=''in1'';hazmap')



    % Display menu
    op2e = uimenu('Label',' Display ');
    uimenu(op2e,'Label','Fix color (z) scale', 'Callback','fixax2 ')
    uimenu(op2e,'Label','Plot Map in lambert projection using m_map ', 'Callback','plotmap ')
    uimenu(op2e,'Label','Plot map on top of topography (white background)',...
         'Callback','colback = 1; dramap2_z')
    uimenu(op2e,'Label','Plot map on top of topography (black background)',...
         'Callback','colback = 2; dramap2_z')
    uimenu(op2e,'Label','Show Grid ',...
         'Callback','hold on;plot(newgri(:,1),newgri(:,2),''+k'')')
    uimenu(op2e,'Label','Show Circles ', 'Callback','plotci2')
    uimenu(op2e,'Label','Colormap InvertGray',...
         'Callback','g=gray; g = g(64:-1:1,:);colormap(g);brighten(.4)')
    uimenu(op2e,'Label','Colormap Invertjet',...
         'Callback','g=jet; g = g(64:-1:1,:);colormap(g)')
    uimenu(op2e,'Label','shading flat',...
         'Callback','axes(hzma); shading flat;sha=''fl'';')
    uimenu(op2e,'Label','shading interpolated',...
         'Callback','axes(hzma); shading interp;sha=''in'';')
    uimenu(op2e,'Label','Brigten +0.4',...
         'Callback','axes(hzma); brighten(0.4)')
    uimenu(op2e,'Label','Brigten -0.4',...
         'Callback','axes(hzma); brighten(-0.4)')
    uimenu(op2e,'Label','Redraw Overlay',...
         'Callback','hold on;overlay')

    tresh = nan; re4 = re3;

    colormap(jet)
    tresh = nan; minpe = nan; Mmin = nan;

end   % This is the end of the figure setup

% Now lets plot the color-map of the z-value
%
figure_w_normalized_uicontrolunits(hmap)
delete(gca)
delete(gca)
delete(gca)
dele = 'delete(sizmap)';er = 'disp('' '')'; eval(dele,er);
reset(gca)
cla
hold off
watchon;
set(gca,'visible','off','FontSize',fontsz.s,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','SortMethod','childorder')

rect = [0.18,  0.10, 0.7, 0.75];
rect1 = rect;

% find max and min of data for automatic scaling
%
maxc = max(max(re3));
maxc = fix(maxc)+1;
minc = min(min(re3));
minc = fix(minc)-1;

% set values gretaer tresh = nan
%
re4 = re3;
l = r > tresh;
re4(l) = zeros(1,length(find(l)))*nan;
l = Prmap < minpe;
re4(l) = zeros(1,length(find(l)))*nan;
l = old1 <  Mmin;
re4(l) = zeros(1,length(find(l)))*nan;

% plot image
%
orient landscape
%set(gcf,'PaperPosition', [0.5 1 9.0 4.0])

axes('position',rect)
hold on
pco1 = pcolor(gx,gy,re4);

axis([ min(gx) max(gx) min(gy) max(gy)])
axis image
hold on
if sha == 'fl'
    shading flat
else
    shading interp
end
% make the scaling for the recurrence time map reasonable
if lab1(1) =='T'
    l = isnan(re3);
    re = re3;
    re(l) = [];
    caxis([min(re) 5*min(re)]);
end
if fre == 1
    caxis([fix1 fix2])
end


title2([name ';  '   num2str(t0b) ' to ' num2str(teb) ],'FontSize',fontsz.s,...
    'Color','r','FontWeight','bold')

xlabel('Longitude [deg]','FontWeight','bold','FontSize',fontsz.s)
ylabel('Latitude [deg]','FontWeight','bold','FontSize',fontsz.s)

% plot overlay
%
hold on
overlay_
ploeq = plot(a.Longitude,a.Latitude,'k.');
set(ploeq,'Tag','eq_plot','MarkerSize',ms6,'Marker',ty,'Color',co,'Visible',vi)

set(gca,'visible','on','FontSize',fontsz.s,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')
h1 = gca;
hzma = gca;

% Create a colorbar
%
h5 = colorbar('horiz');
set(h5,'Pos',[0.35 0.05 0.4 0.02],...
    'FontWeight','bold','FontSize',fontsz.s,'TickDir','out')

rect = [0.00,  0.0, 1 1];
axes('position',rect)
axis('off')
%  Text Object Creation
txt1 = text(...
    'Color',[ 0 0 0 ],...
    'EraseMode','normal',...
    'Units','normalized',...
    'Position',[ 0.33 0.06 0 ],...
    'HorizontalAlignment','right',...
    'Rotation',[ 0 ],...
    'FontSize',fontsz.s,....
    'FontWeight','bold',...
    'String',lab1);

% Make the figure visible
%
set(gca,'FontSize',fontsz.s,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')
figure_w_normalized_uicontrolunits(hmap);
%sizmap = signatur('ZMAP','',[0.01 0.04]);
%set(sizmap,'Color','k')
axes(h1)
watchoff(hmap)
%whitebg(gcf,[ 0 0 0 ])
done
