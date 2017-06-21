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
co = 'w';


% Find out of figure already exists
%
[existFlag,figNumber]=figure_exists('b-value-map',1);
newbmapWindowFlag=~existFlag;

% Set up the Seismicity Map window Enviroment
%
if newbmapWindowFlag
    bmap = figure_w_normalized_uicontrolunits( ...
        'Name','b-value-map',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','new', ...
        'backingstore','on',...
        'Visible','off', ...
        'Position',[ fipo(3)-600 fipo(4)-400 winx winy]);
    % make menu bar
    matdraw

    lab1 = 'b-value:';

    add_symbol_menu('eq_plot');

    %   uicontrol('Units','normal',...
    %      'Position',[.1 .23 .08 .06],'String','Info ',...
    %       'Callback',' web([''file:'' hodi ''/zmapwww/chp11.htm#996756'']) ');



    options = uimenu('Label',' Select ');
    uimenu(options,'Label','Refresh ', 'Callback','view_bva')
    uimenu(options,'Label','Select EQ in Circle',...
         'Callback','h1 = gca;met = ''ni''; ho=''noho'';cirbva;watchoff(bmap)')
    uimenu(options,'Label','Select EQ in Circle - Constant R',...
         'Callback','h1 = gca;met = ''ra''; ho=''noho'';cirbva;watchoff(bmap)')
    uimenu(options,'Label','Select EQ in Circle - Overlay existing plot',...
         'Callback','h1 = gca;ho = ''hold'';cirbva;watchoff(bmap)')

    uimenu(options,'Label','Select EQ in Polygon -new ',...
         'Callback','cufi = gcf;ho = ''noho'';selectp')
    uimenu(options,'Label','Select EQ in Polygon - hold ',...
         'Callback','cufi = gcf;ho = ''hold'';selectp')


    op1 = uimenu('Label',' Maps ');

    adjmenu =  uimenu(op1,'Label','Adjust Map Display Parameters'),...
        uimenu(adjmenu,'Label','Adjust Mmin cut',...
         'Callback','asel = ''mag''; adju; view_bva ')
    uimenu(adjmenu,'Label','Adjust Rmax cut',...
         'Callback','asel = ''rmax''; adju; view_bva')
    uimenu(adjmenu,'Label','Adjust goodness of fit cut',...
         'Callback','asel = ''gofi''; adju; view_bva ')


    uimenu(op1,'Label','b-value map (max likelihood)',...
         'Callback','lab1 =''b-value''; re3 = mBvalue; view_bva')
    uimenu(op1,'Label','Standard deviation of b-Value (max likelihood) map',...
         'Callback','lab1=''SdtDev b-Value''; re3 = mStdB; view_bva')
    uimenu(op1,'Label','Magnitude of completness map',...
         'Callback','lab1 = ''Mcomp''; re3 = mMc; view_bva')
    uimenu(op1,'Label','Standard deviation of magnitude of completness',...
         'Callback','lab1 = ''Mcomp''; re3 = mStdMc; view_bva')
    uimenu(op1,'Label','Goodness of fit to power law map',...
         'Callback','lab1 = '' % ''; re3 = Prmap; view_bva')
    uimenu(op1,'Label','Resolution map',...
         'Callback','lab1=''Radius in [km]'';re3 = r; view_bva')
    uimenu(op1,'Label','Earthquake density map',...
         'Callback','lab1=''log(EQ per km^2)'';re3 = log10(mNumEq./(r.^2*pi)); view_bva')
    uimenu(op1,'Label','a-value map',...
         'Callback','lab1=''a-value'';re3 = mAvalue; view_bva')


    if exist('mStdDevB')
        AverageStdDevMenu = uimenu(op1,'Label', 'Additional random simulation');
        uimenu(AverageStdDevMenu,'Label', 'Bootstrapped standard deviation of b-value',...
             'Callback','lab1=''standard deviation of b-value''; re3 = mStdDevB; view_bva')
        uimenu(AverageStdDevMenu,'Label', 'Bootstrapped standard deviation of Mc',...
             'Callback','lab1=''standard deviation of Mc''; re3 = mStdDevMc; view_bva')
        uimenu(AverageStdDevMenu,'Label', 'b-value map (max likelihood) with std. deviation',...
             'Callback','lab1=''b-value''; re3 = mBvalue; bOverlayTransparentStdDev = 1; view_bva')
    end

    recmenu =  uimenu(op1,'Label','recurrence time map '),...

uimenu(recmenu,'Label','recurrence time map ',...
     'Callback','def = {''6''};m = inputdlg(''Magnitude of projected mainshock?'',''Input'',1,def);m1 = m{:}; m = str2num(m1);lab1 = ''Tr (yrs) (sm. values only)'';re3 =(teb - t0b)./(10.^(mAvalue-m*mBvalue)); mrt = m; view_bva')

uimenu(recmenu,'Label','(1/Tr)/area map ',...
     'Callback','def = {''6''};m = inputdlg(''Magnitude of projected mainshock?'',''Input'',1,def);m1 = m{:}; m = str2num(m1);lab1 = ''1/Tr/area '';re3 =(teb - t0b)./(10.^(mAvalue-m*mBvalue)); re3 = 1./re3/(2*pi*ra*ra);  mrt = m; view_bva')

uimenu(recmenu,'Label','recurrence time percentage ',...
     'Callback','recperc')



uimenu(op1,'Label','Histogram ', 'Callback','zhist')
uimenu(op1,'Label','Reccurrence Time Histogram ', 'Callback','rechist')
uimenu(op1,'Label','Save map to ASCII file ', 'Callback','savemap')

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
figure_w_normalized_uicontrolunits(bmap)
delete(gca)
delete(gca)
delete(gca)
dele = 'delete(sizmap)';er = 'disp('' '')'; eval(dele,er);
reset(gca)
cla
hold off
watchon;
set(gca,'visible','off','FontSize',fontsz.s,'FontWeight','normal',...
    'FontWeight','normal','LineWidth',1.,...
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
%set(gcf,'PaperPosition', [0.5 1 9.0 4.0])

axes('position',rect)
hold on
pco1 = pcolor(gx,gy,re3);

axis([ min(gx) max(gx) min(gy) max(gy)])
set(gca,'dataaspect',[1 cos(pi/180*nanmean(a.Latitude)) 1]);
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
    'Color','r','FontWeight','normal')

xlabel('Longitude [deg]','FontWeight','normal','FontSize',fontsz.s)
ylabel('Latitude [deg]','FontWeight','normal','FontSize',fontsz.s)

% plot overlay
%
hold on
overlay_
ploeq = plot(a.Longitude,a.Latitude,'k.');
set(ploeq,'Tag','eq_plot','MarkerSize',ms6,'Marker',ty,'Color',co,'Visible',vi)


set(gca,'visible','on','FontSize',fontsz.s,'FontWeight','normal',...
    'FontWeight','normal','LineWidth',1.,...
    'Box','on','TickDir','out')

h1 = gca;
hzma = gca;

% Create a colorbar
%
h5 = colorbar('horiz');
set(h5,'Pos',[0.35 0.07 0.4 0.02],...
    'FontWeight','normal','FontSize',fontsz.s,'TickDir','out')

rect = [0.00,  0.0, 1 1];
axes('position',rect)
axis('off')
%  Text Object Creation
txt1 = text(...
    'Color',[ 0 0 0 ],...
    'EraseMode','normal',...
    'Units','normalized',...
    'Position',[ 0.2 0.06 0 ],...
    'HorizontalAlignment','right',...
    'Rotation',[ 0 ],...
    'FontSize',fontsz.s,....
    'FontWeight','normal',...
    'String',lab1);

% Make the figure visible
%
set(gca,'FontSize',fontsz.s,'FontWeight','normal',...
    'FontWeight','normal','LineWidth',1.,...
    'Box','on','TickDir','out')
figure_w_normalized_uicontrolunits(bmap);
%sizmap = signatur('ZMAP','',[0.01 0.04]);
%set(sizmap,'Color','k')
axes(h1)
set(gcf,'color','w');
watchoff(bmap)
%whitebg(gcf,[ 0 0 0 ])
done
