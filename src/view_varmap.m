% This .m file "view_maxz.m" plots the maxz LTA values calculated
% with maxzlta.m or other similar values as a color map
% needs re3, gx, gy, stri
%
% define size of the plot etc.
%

if ~exist('Prmap','var')
    Prmap = re3*nan;
end
if isempty(Prmap) >  0
    Prmap = re3*nan;
end

if isempty(name) >  0
    name = '  ';
end
think
report_this_filefun(mfilename('fullpath'));
%co = 'w';


% Find out of figure already exists
%
[existFlag,figNumber]=figure_exists('variance-value-map',1);
newbmapWindowFlag=~existFlag;

% Set up the Seismicity Map window Enviroment
%
if newbmapWindowFlag
    bmap = figure_w_normalized_uicontrolunits( ...
        'Name','variance-value-map',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','new', ...
        'backingstore','on',...
        'Visible','off', ...
        'Position',[ (fipo(3:4) - [600 400]) ZmapGlobal.Data.map_len]);
    % make menu bar
    matdraw

    lab1 = 'b-value:';


    options = uimenu('Label',' Select ');
    uimenu(options,'Label','Refresh ', 'Callback','view_varmap')
    uimenu(options,'Label','Select EQ in Circle',...
         'Callback','h1 = gca;met = ''ni''; ZG=ZmapGlobal.Data; ZG.hold_state=false;circle;watchon;doinvers_michael;watchoff')
    uimenu(options,'Label','Select EQ in Circle - Constant R',...
         'Callback','h1 = gca;met = ''ra''; ZG=ZmapGlobal.Data; ZG.hold_state=false;circle;watchon;doinvers_michael;watchoff')

    uimenu(options,'Label','Select EQ in Polygon -new ',...
         'Callback','cufi = gcf;ZG=ZmapGlobal.Data; ZG.hold_state=false;selectp;watchon;doinvers_michael;watchoff')

    op1 = uimenu('Label',' Maps ');

    uimenu(op1,'Label','Variance map',...
         'Callback','lab1 =''b-value''; re3 = r; view_varmap')
    uimenu(op1,'Label','Resolution map',...
         'Callback','lab1 =''Radius''; re3 = rama; view_varmap')
    uimenu(op1,'Label','Plot map on top of topography ',...
         'Callback','colback = 1; dramap_stress2')


    uimenu(op1,'Label','Histogram ', 'Callback','zhist')


    add_display_menu(1)

    re4 = re3;

    colormap(jet)
    tresh = nan; minpe = nan; Mmin = nan;

end   % This is the end of the figure setup

% Now lets plot the color-map of the z-value
%
figure_w_normalized_uicontrolunits(bmap)
delete(gca)
delete(gca)
delete(gca)
dele = 'delete(sizmap)';er = 'disp('' '')'; eval(dele,er);
reset(gca)
cla
hold off
watchon;
set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','normal',...
    'LineWidth',1.,...
    'Box','on','SortMethod','childorder')

rect = [0.12,  0.10, 0.8, 0.8];
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

if fre == 1
    caxis([fix1 fix2])
end


title([name ';  '   num2str(t0b) ' to ' num2str(teb) ],'FontSize',ZmapGlobal.Data.fontsz.s,...
    'Color','k','FontWeight','normal')

xlabel('Longitude [deg]','FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s)
ylabel('Latitude [deg]','FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s)

% plot overlay
%
hold on
overlay_

hold on
plq = quiver(newgri(:,1),newgri(:,2),-cos(sor(:,SA*2)*pi/180),sin(sor(:,SA*2)*pi/180),0.8,'.');
set(plq,'LineWidth',1,'Color','k')
hold on

set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','normal',...
    'FontWeight','normal','LineWidth',1.,...
    'Box','on','TickDir','out');

h1 = gca;
hzma = gca;

% Create a colorbar
%
h5 = colorbar('horiz');
set(h5,'Pos',[0.35 0.06 0.4 0.02],...
    'FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s,'TickDir','out')

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
    'FontSize',ZmapGlobal.Data.fontsz.s,....
    'FontWeight','normal',...
    'String','Variance');

% Make the figure visible
%
set(gca,'FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','normal',...
    'FontWeight','normal','LineWidth',1.,...
    'Box','on','TickDir','out');
set(gcf,'color','w');
figure_w_normalized_uicontrolunits(bmap);
axes(h1)
watchoff(bmap)
%whitebg(gcf,[ 0 0 0 ])
done
