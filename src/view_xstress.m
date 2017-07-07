% Script: view_xstress.m
% Script to display results creates with cross_stress.m
%
% Needs re3, gx, gy, stri
%
% last modified: J. Woessner, 02.2004

if isempty(name) >  0
    name = '  '
end
think
report_this_filefun(mfilename('fullpath'));
% Color shortcut
co = 'w';

% Find out if figure already exists
[existFlag,figNumber]=figure_exists('Stress-section',1);
newstressmapWindowFlag=~existFlag;

% Set up the Seismicity Map window Enviroment
if newstressmapWindowFlag
    stressmap = figure_w_normalized_uicontrolunits( ...
        'Name','Stress-section',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','new', ...
        'backingstore','on',...
        'Visible','off', ...
        'Position',[ (fipo(3:4) - [600 400]) ZmapGlobal.Data.map_len]);
    % make menu bar
    matdraw
    
    add_symbol_menu('eqc_plot');

    % Menu Select
    options = uimenu('Label',' Select ');
    uimenu(options,'Label','Refresh ', 'Callback','re3 = r;view_xstress')
    uimenu(options,'Label','Select N closest EQs',...
        'Callback','h1 = gca;ic=1; ZG=ZmapGlobal.Data; ZG.hold_state=false;cicros;watchon;doinvers_michael;watchoff')
    uimenu(options,'Label','Select EQ in Circle - Constant R',...
        'Callback','h1 = gca;ic=2; ZG=ZmapGlobal.Data; ZG.hold_state=false;cicros;watchon;doinvers_michael;watchoff')
    uimenu(options,'Label','Select EQ in Polygon',...
        'Callback','h1=gca;ic=3;ZG=ZmapGlobal.Data; ZG.hold_state=false;cicros;watchon;doinvers_michael;watchoff')
    
    % Menu Maps
    op1 = uimenu('Label',' Maps ');
    uimenu(op1,'Label','Variance',...
        'Callback','lab1=''\sigma'';re3 = mVariance; view_xstress')
    uimenu(op1,'Label','Phi',...
        'Callback','lab1=''\Phi'';re3 = mPhi; view_xstress')
    uimenu(op1,'Label','Trend S1',...
        'Callback','lab1=''S1 trend [deg]'';re3 = mTS1; view_xstress')
    uimenu(op1,'Label','Plunge S1',...
        'Callback','lab1=''S1 plunge [deg]'';re3 = mPS1; view_xstress')
    uimenu(op1,'Label','Trend S2',...
        'Callback','lab1=''S2 trend [deg]'';re3 = mTS2; view_xstress')
    uimenu(op1,'Label','Plunge S2',...
        'Callback','lab1=''S2 plunge [deg]'';re3 = mPS2; view_xstress')
    uimenu(op1,'Label','Trend S3',...
        'Callback','lab1=''S3 trend [deg]'';re3 = mTS3; view_xstress')
    uimenu(op1,'Label','Plunge S3',...
        'Callback','lab1=''S3 plunge [deg]'';re3 = mPS3; view_xstress')
    uimenu(op1,'Label','Angular misfit',...
        'Callback','lab1=''\beta [deg]'';re3 = mBeta; view_xstress')
    uimenu(op1,'Label','\tau spread',...
        'Callback','lab1=''\tau [deg]'';re3 = mTau; view_xstress')
    uimenu(op1,'Label','Resolution map (const. Radius)',...
        'Callback','lab1=''Radius in [km]'';re3 = mResolution; view_xstress')
    uimenu(op1,'Label','Resolution map',...
        'Callback','lab1=''Number of events'';re3 = mNumber; view_xstress')
    uimenu(op1,'Label','Trend S1 relative to fault strike',...
        'Callback','lab1=''S1 trend to strike [deg]'';re3 = mTS1Rel; view_xstress')
    %uimenu(op1,'Label','Histogram ', 'Callback','zhist')
    
    % Menu Display
    add_display_menu(1);
    
    tresh = nan; re4 = re3;
    
    colormap(jet)
    tresh = nan; minpe = nan; Mmin = nan;
    
end   % This is the end of the figure setup

% Now lets plot the color-maps
figure_w_normalized_uicontrolunits(stressmap)
delete(gca)
delete(gca)
delete(gca)
dele = 'delete(sizmap)';er = 'disp('' '')'; eval(dele,er);
reset(gca)
cla
hold off
watchon;
set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','SortMethod','childorder')

% Figure position
rect = [0.18,  0.10, 0.7, 0.75];

% Find max and min of data for automatic scaling
maxc = max(max(re3));
maxc = fix(maxc)+1;
minc = min(min(re3));
minc = fix(minc)-1;

% Plot image
orient landscape

axes('position',rect)
hold on
pco1 = pcolor(gx,gy,re3);

axis([ min(gx) max(gx) min(gy) max(gy)])
axis image
hold on
if sha == 'fl'
    shading flat
else
    shading interp
end

if fre == 1
    caxis([fix1 fix2])
end


% title2([name ';  '   num2str(t0b) ' to ' num2str(teb) ],'FontSize',ZmapGlobal.Data.fontsz.s,...
%     'Color','r','FontWeight','bold')

xlabel('Distance in [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
ylabel('Depth in [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)

% plot overlay
%
ploeqc = plot(newa(:,length(newa(1,:))),-newa(:,7),'.k');
set(ploeqc,'Tag','eqc_plot','MarkerSize',ms6,'Marker',ty,'Color',co,'Visible',vi)

if exist('vox', 'var')
    plovo = plot(vox,voy,'*b');
    set(plovo,'MarkerSize',6,'LineWidth',1)
end

if exist('maix', 'var')
    pl = plot(maix,maiy,'*k');
    set(pl,'MarkerSize',12,'LineWidth',2)
end

if exist('maex', 'var')
    pl = plot(maex,-maey,'hm');
    set(pl,'LineWidth',1.5,'MarkerSize',12,...
        'MarkerFaceColor','w','MarkerEdgeColor','k')
    
end


set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')
h1 = gca;
hzma = gca;

% Create a colorbar
%
h5 = colorbar('horiz');
set(h5,'Pos',[0.35 0.2 0.4 0.02],...
    'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s,'TickDir','out')

rect = [0.00,  0.0, 1 1];
axes('position',rect)
axis('off')
%  Text Object Creation
txt1 = text(...
    'Color',[ 0 0 0 ],...
    'EraseMode','normal',...
    'Units','normalized',...
    'Position',[ 0.33 0.21 0 ],...
    'HorizontalAlignment','right',...
    'Rotation',[ 0 ],...
    'FontSize',ZmapGlobal.Data.fontsz.s,....
    'FontWeight','bold',...
    'String',lab1);

% Make the figure visible
set(gca,'FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')
% Print orientation
orient portrait
figure_w_normalized_uicontrolunits(stressmap);
axes(h1)
watchoff(stressmap)
done
