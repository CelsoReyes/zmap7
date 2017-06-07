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
%co = 'w';


% Find out of figure already exists
%
[existFlag,figNumber]=figure_exists('b-value-map',1);
newbmapWindowFlag=~existFlag;

% This is the info window text
%
ttlStr='The Z-Value Map Window                        ';
hlpStr1zmap= ...
    ['                                                '
    ' This window displays seismicity rate changes   '
    ' as z-values using a color code. Negative       '
    ' z-values indicate an increase in the seismicity'
    ' rate, positive values a decrease.              '
    ' Some of the menu-bar options are               '
    ' described below:                               '
    '                                                '
    ' Threshold: You can set the maximum size that   '
    '   a volume is allowed to have in order to be   '
    '   displayed in the map. Therefore, areas with  '
    '   a low seismicity rate are not displayed.     '
    '   edit the size (in km) and click the mouse    '
    '   outside the edit window.                     '
    'FixAx: You can chose the minimum and maximum    '
    '        values of the color-legend used.        '
    'Polygon: You can select earthquakes in a        '
    ' polygon either by entering the coordinates or  '
    ' defining the corners with the mouse            '];
hlpStr2zmap= ...
    ['                                                '
    'Circle: Select earthquakes in a circular volume:'
    '      Ni, the number of selected earthquakes can'
    '      be edited in the upper right corner of the'
    '      window.                                   '
    ' Refresh Window: Redraws the figure, erases     '
    '       selected events.                         '

    ' zoom: Selecting Axis -> zoom on allows you to  '
    '       zoom into a region. Click and drag with  '
    '       the left mouse button. type <help zoom>  '
    '       for details.                             '
    ' Aspect: select one of the aspect ratio options '
    ' Text: You can select text items by clicking.The'
    '       selected text can be rotated, moved, you '
    '       can change the font size etc.            '
    '       Double click on text allows editing it.  '
    '                                                '
    '                                                '];

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

    uicontrol('Units','normal',...
        'Position',[.0 .93 .08 .06],'String','Info ',...
         'Callback',' web([''file:'' hodi ''/zmapwww/chp11.htm#996756'']) ');



    options = uimenu('Label',' Select ');
    uimenu(options,'Label','Refresh ', 'Callback','view_bva')
    uimenu(options,'Label','Select EQ in Circle',...
         'Callback','h1 = gca;met = ''ni''; ho=''noho'';cirbva;watchoff(bmap)')
    uimenu(options,'Label','Select EQ in Circle - Constant R',...
         'Callback','h1 = gca;met = ''ra''; ho=''noho'';cirbva;watchoff(bmap)')
    uimenu(options,'Label','Select EQ in Circle - Overlay existing plot',...
         'Callback','h1 = gca;ho = ''hold'';cirbva;watchoff(bmap)')

    uimenu(options,'Label','Select EQ in Polygon -new ',...
         'Callback','cufi = gcf;ho = ''noho'';selectp2')
    uimenu(options,'Label','Select EQ in Polygon - hold ',...
         'Callback','cufi = gcf;ho = ''hold'';selectp2')


    op1 = uimenu('Label',' Maps ');

    adjmenu =  uimenu(op1,'Label','Adjust Map Display Parameters'),...
        uimenu(adjmenu,'Label','Adjust Mmin cut',...
         'Callback','asel = ''mag''; adju; view_bva ')
    uimenu(adjmenu,'Label','Adjust Rmax cut',...
         'Callback','asel = ''rmax''; adju; view_bva')
    uimenu(adjmenu,'Label','Adjust goodness of fit cut',...
         'Callback','asel = ''gofi''; adju; view_bva ')


    uimenu(op1,'Label','b-value map (WLS)',...
         'Callback','lab1 =''b-value''; re3 = old; view_bva')
    uimenu(op1,'Label','b(max likelihood) map',...
         'Callback','lab1=''b-value''; re3 = meg; view_bva')
    uimenu(op1,'Label','mag of completness map',...
         'Callback','lab1 = ''Mcomp''; re3 = old1; view_bva')
    uimenu(op1,'Label','Goodness of fit to power law map',...
         'Callback','lab1 = '' % ''; re3 = Prmap; view_bva')

    uimenu(op1,'Label','a-value map',...
         'Callback','lab1=''a-value'';re3 = avm; view_bva')
    uimenu(op1,'Label','standard error map',...
         'Callback',' lab1=''error in b'';re3 = stanm; view_bva')
    uimenu(op1,'Label','(WLS-Max like) map',...
         'Callback',' lab1=''differnce in b'';re3 = old-meg; view_bva')

    recmenu =  uimenu(op1,'Label','recurrence time map '),...

uimenu(recmenu,'Label','recurrence time map ',...
     'Callback','def = {''6''};m = inputdlg(''Magnitude of projected mainshock?'',''Input'',1,def);m1 = m{:}; m = str2num(m1);lab1 = ''Tr (yrs) (sm. values only)'';re3 =(teb - t0b)./(10.^(avm-m*old)); mrt = m; view_bva')

uimenu(recmenu,'Label','(1/Tr)/area map ',...
     'Callback','def = {''6''};m = inputdlg(''Magnitude of projected mainshock?'',''Input'',1,def);m1 = m{:}; m = str2num(m1);lab1 = ''1/Tr/area '';re3 =(teb - t0b)./(10.^(avm-m*old)); re3 = 1./re3/(2*pi*ra*ra);  mrt = m; view_bva')

uimenu(recmenu,'Label','recurrence time percentage ',...
     'Callback','recperc')


uimenu(op1,'Label','resolution Map',...
     'Callback','lab1=''Radius in [km]'';re3 = r; view_bva')
uimenu(op1,'Label','Histogram ', 'Callback','zhist')
uimenu(op1,'Label','Reccurrence Time Histogram ', 'Callback','rechist')

op2e = uimenu('Label',' Display ');
uimenu(op2e,'Label','Fix color (z) scale', 'Callback','fixax2 ')
uimenu(op2e,'Label','Plot Map in lambert projection using m_map ', 'Callback','plotmap ')
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

%tresh = nan; re4 = re3;

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
set(gca,'visible','off','FontSize',fontsz.s,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','SortMethod','childorder')

rect = [0.18,  0.10, 0.7, 0.75];
rect1 = rect;



def = {'4'};
ni2 = inputdlg('Which depth level ','Input',1,def);
l = ni2{:};
dez = str2double(l);

re3 = testhypo(:,:,dez);
re3 = re3';
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
ploeq = plot(a(:,1),a(:,2),'k.');
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
figure_w_normalized_uicontrolunits(bmap);
%sizmap = signatur('ZMAP','',[0.01 0.04]);
%set(sizmap,'Color','k')
axes(h1)
watchoff(bmap)
%whitebg(gcf,[ 0 0 0 ])
done

figure

[m,n] = size(re3);
ro = reshape(re3,m*n,1);
l = isnan(ro);

ro(l) = [];
mean(ro)

histogram(ro,30);


