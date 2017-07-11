% This .m file "view_maxz.m" plots the maxz LTA values calculated
% with maxzlta.m or other similar values as a color map
% needs re3, gx, gy, stri
%
% define size of the plot etc.
%
if isempty(name) >  0
    name = '  '
end
think
report_this_filefun(mfilename('fullpath'));
co = 'w';
clear title;

% Find out of figure already exists
%
[existFlag,figNumber]=figure_exists('Z-Value-Map',1);
newzmapWindowFlag=~existFlag;

% This is the info window text
%


% Set up the Seismicity Map window Enviroment
%
if newzmapWindowFlag
    zmap = figure_w_normalized_uicontrolunits( ...
        'Name','Z-Value-Map',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','replace', ...
        'backingstore','on',...
        'Visible','off', ...
        'Position',[ (fipo(3:4) - [600 400]) ZmapGlobal.Data.map_len]);
    % make menu bar
    matdraw


    symbolmenu = uimenu('Label',' Symbol ');
    SizeMenu = uimenu(symbolmenu,'Label',' Symbol Size ');
    TypeMenu = uimenu(symbolmenu,'Label',' Symbol Type ');
    ColorMenu = uimenu(symbolmenu,'Label',' Symbol Color ');

    uimenu(SizeMenu,'Label','3','Callback','ZG.ms6 =3;eval(cal7)');
    uimenu(SizeMenu,'Label','6','Callback','ZG.ms6 =6;eval(cal7)');
    uimenu(SizeMenu,'Label','9','Callback','ZG.ms6 =9;eval(cal7)');
    uimenu(SizeMenu,'Label','12','Callback','ZG.ms6 =12;eval(cal7)');
    uimenu(SizeMenu,'Label','14','Callback','ZG.ms6 =14;eval(cal7)');
    uimenu(SizeMenu,'Label','18','Callback','ZG.ms6 =18;eval(cal7)');
    uimenu(SizeMenu,'Label','24','Callback','ZG.ms6 =24;eval(cal7)');

    uimenu(TypeMenu,'Label','dot','Callback','ty =''.'';eval(cal7)');
    uimenu(TypeMenu,'Label','+','Callback','ty=''+'';eval(cal7)');
    uimenu(TypeMenu,'Label','o','Callback','ty=''o'';eval(cal7)');
    uimenu(TypeMenu,'Label','x','Callback','ty=''x'';eval(cal7)');
    uimenu(TypeMenu,'Label','*','Callback','ty=''*'';eval(cal7)');
    uimenu(TypeMenu,'Label','none','Callback','vi=''off'';set(ploeq,''visible'',''off''); ');

    uimenu(ColorMenu,'Label','black','Callback','co=''k'';eval(cal7)');
    uimenu(ColorMenu,'Label','white','Callback','co=''w'';eval(cal7)');
    uimenu(ColorMenu,'Label','white','Callback','co=''r'';eval(cal7)');
    uimenu(ColorMenu,'Label','yellow','Callback','co=''y'';eval(cal7)');

    cal7 = ...
        [ 'vi=''on'';set(ploeq,''MarkerSize'',ZG.ms6,''LineStyle'',ty,''Color'',co,''visible'',''on'')'];


    options = uimenu('Label',' Select ');
    uimenu(options,'Label','Refresh ', 'Callback','delete(gca);delete(gca);delete(gca);delete(gca); view_ratecomp')
    uimenu(options,'Label','Select EQ in Circle - const Ni', 'Callback','nosort = ''on''; h1 = gca;circle;watchoff(zmap)')
    uimenu(options,'Label','Select EQ in Circle - const R2', 'Callback','nosort = ''on''; h1 = gca;circle_constR;watchoff(zmap)')

    uimenu(options,'Label','Select EQ in Polygon ', 'Callback',' nosort = ''on'';stri = ''Polygon'';h1 = gca;cufi = gcf;selectp')


    op1 = uimenu('Label',' Maps ');


    uimenu(op1,'Label','z-value map ',...
         'Callback','det =''ast''; re3 = old; view_ratecomp')
    uimenu(op1,'Label','Percent change map',...
         'Callback','det=''per''; re3 = per; view_ratecomp')
    uimenu(op1,'Label','Beta value map',...
         'Callback','det=''bet''; re3 = beta_map; view_ratecomp')

    uimenu(op1,'Label','Significance based on beta map',...
         'Callback','det=''bet''; re3 = betamap; view_ratecomp')

    uimenu(op1,'Label','Resolution Map',...
         'Callback','lab1=''Radius in [km]'';re3 = reso; view_ratecomp')

    op1 = uimenu('Label','  Display ');
    uimenu(op1,'Label','Plot Map in Lambert projection using m_map ', 'Callback','re4 = re3; plotmap ')
    uimenu(op1,'Label','Fix color (z) scale', 'Callback','fixax2 ')
    uimenu(op1,'Label','Plot map on top of topography (white background)',...
         'Callback','colback = 1; dramap_z')
    uimenu(op1,'Label','Plot map on top of topography (black background)',...
         'Callback','colback = 2; dramap_z')
    uimenu(op1,'Label','Histogram of map-values', 'Callback','zhist')
    uimenu(op1,'Label','Colormap InvertGray', 'Callback','g=gray; g = g(64:-1:1,:);colormap(g);brighten(.4)')
    uimenu(op1,'Label','Colormap Invertjet',...
         'Callback','g=jet; g = g(64:-1:1,:);colormap(g)')

    uimenu(op1,'Label','Show Grid ',...
         'Callback',' plot(newgri(:,1),newgri(:,2),''+k'')')
    uimenu(op1,'Label','shading flat', 'Callback','sha=''fl'';axes(hzma); shading flat')
    uimenu(op1,'Label','shading interpolated',...
         'Callback','sha=''in'';axes(hzma); shading interp')
    uimenu(op1,'Label','Brigten +0.4',...
         'Callback','axes(hzma); brighten(0.4)')
    uimenu(op1,'Label','Brigten -0.4',...
         'Callback','axes(hzma); brighten(-0.4)')

    uimenu(op1,'Label','Redraw overlay',...
         'Callback','hold on;overlay_')


    colormap(jet)

end   % This is the end of the figure setup

% Now lets plot the color-map of the z-value
%
figure_w_normalized_uicontrolunits(zmap)
delete(gca)
delete(gca)
delete(gca)
dele = 'delete(sizmap)';er = 'disp('' '')'; eval(dele,er);
reset(gca)
cla
hold off
watchon;
set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','normal',...
    'FontWeight','bold','LineWidth',1.,...
    'Box','on','SortMethod','childorder')

rect = [0.18,  0.10, 0.7, 0.75];
rect1 = rect;

% find max and min of data for automatic scaling
%
maxc = max(max(re3));
maxc = fix(maxc)+1;
minc = min(min(re3));
minc = fix(minc)-1;


% plot image
%
orient landscape
set(gcf,'PaperPosition',[ 0.1 0.1 8 6])
axes('position',rect)
hold on
pco1 = pcolor(gx,gy,re3);
axis([ s2 s1 s4 s3])
if sha == 'fl'
    shading flat
else
    shading interp
end

if fre == 1
    caxis([fix1 fix2])
end

if  det == 'per'
    coma = jet;
    coma = coma(64:-1:1,:);
    colormap(coma)
end

title([  num2str(t1,6) ' - ' num2str(t2,6) ' - compared with ' num2str(t3,6) ' - ' num2str(t4,6) ],'FontSize',ZmapGlobal.Data.fontsz.m,...
    'Color','k','FontWeight','normal')

xlabel('Longitude [deg]','FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.m)
ylabel('Latitude [deg]','FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.m)

% plot overlay
%
overlay_
%set(ploeq,'MarkerSize',ZG.ms6,'Marker',ty,'Color',co,'visible',vi);

set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')
h1 = gca;
hzma = gca;

% Create a colobar
%
h5 = colorbar('horiz');
set(h5,'Pos',[0.35 0.05 0.4 0.02],...
    'FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.m,'TickDir','out')

%  Text Object Creation
txt1 = text(...
    'Color',[ 0 0 0 ],...
    'EraseMode','normal',...
    'Units','normalized',...
    'Position',[ 0.05 -0.27 0 ],...
    'Rotation',[ 0 ],...
    'FontSize',ZmapGlobal.Data.fontsz.m,....
    'FontWeight','normal',...
    'String','z-value ');
if det =='per'
    set(txt1,'String','% change')
end
if det =='pro'
    set(txt1,'String','Probability')
end
if det =='res'
    set(txt1,'String','Radius  [km]')
end
if det =='bet'
    set(txt1,'String','beta ')
end
% Make the figure visible
%
set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','normal',...
    'LineWidth',1.0,'Color','w',...
    'Box','on','TickDir','out','Ticklength',[0.02 0.02])
set(gcf,'color','w');

figure_w_normalized_uicontrolunits(zmap);
%sizmap = signatur('ZMAP','',[0.01 0.04]);
%set(sizmap,'Color','k')
axes(h1)
watchoff(zmap)
done
