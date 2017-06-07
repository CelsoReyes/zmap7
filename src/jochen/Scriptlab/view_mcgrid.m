% This .m file, "view_mcgrid.m", plots ratechanges calculated with mcgrid.m
% needs re3, gx, gy
%
% define size of the plot etc.
%
if isempty(name) >  0
    name = '  '
end
think
report_this_filefun(mfilename('fullpath'));
%co = 'w';



% This is the info window text
%
ttlStr='The b and p -Value Map Window                 ';
hlpStr1zmap= ...
    ['                                                '
    ' This window displays b-values and p-values     '
    ' using a color code.                            '
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

% Find out of figure already exists
%
[existFlag,figNumber]=figure_exists('rc-value-map',1);
newrcmapWindowFlag=~existFlag;

if newrcmapWindowFlag
    oldfig_button = 0
end

if oldfig_button == 0
    rcmap = figure_w_normalized_uicontrolunits( ...
        'Name','rc-value-map',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','new', ...
        'backingstore','on',...
        'Visible','off', ...
        'Position',[ fipo(3)-600 fipo(4)-400 winx winy]);
    % make menu bar
    matdraw

    %lab1 = 'p-value:';


    add_symbol_menu('eq_plot');

    %    uicontrol('Units','normal',...
    %       'Position',[.0 .93 .08 .06],'String','Info ',...
    %        'Callback',' web([''file:'' hodi ''/zmapwww/chp11.htm#996756'']) ');



    options = uimenu('Label',' Analyze ');
    uimenu(options,'Label','Refresh ', 'Callback','view_tcgrid')
    %    uimenu(options,'Label','Select EQ in Circle',...
    %        'Callback','h1 = gca;met = ''ni''; ho=''noho'';cirpva;watchoff(rcmap)')
    uimenu(options,'Label','Select EQ in Circle - Constant R',...
         'Callback','h1 = gca;met = ''ra''; ho=''noho'';plot_circ_FMD2Periods;watchoff(rcmap)')
    uimenu(options,'Label','Select EQ with const. number',...
         'Callback','h1 = gca;ho2=''hold'';ho = ''hold'';plot_constnrbootfit_a2;watchoff(rcmap)')

    %
    %    uimenu(options,'Label','Select EQ in Polygon -new ',...
    %        'Callback','cufi = gcf;ho = ''noho'';selectp2')
    %    uimenu(options,'Label','Select EQ in Polygon - hold ',...
    %        'Callback','cufi = gcf;ho = ''hold'';selectp2')
    %

    op1 = uimenu('Label',' Maps ');

    %Menu for adjusting several parameters.
    adjmenu =  uimenu(op1,'Label','Adjust Map Display Parameters'),...
        uimenu(adjmenu,'Label','Adjust Mmin cut',...
         'Callback','asel = ''mag''; adju2; view_mcgrid ')
    uimenu(adjmenu,'Label','Adjust Rmax cut',...
         'Callback','asel = ''rmax''; adju2; view_mcgrid')
    uimenu(adjmenu,'Label','Adjust goodness of fit cut',...
         'Callback','asel = ''gofi''; adju2; view_mcgrid ')
    uimenu(adjmenu,'Label','Adjust p-value st. dev. cut',...
         'Callback','asel = ''pstdc''; adju2; view_mcgrid ')
    % Menu MAPS
    uimenu(op1,'Label','Magnitude shift',...
         'Callback',' lab1=''dM'';re3 = mMagShift; view_mcgrid')
    uimenu(op1,'Label','KS-Test result',...
         'Callback','lab1=''H'';re3 = mHkstest; view_mcgrid')
    uimenu(op1,'Label','Magnitude shift validated',...
         'Callback',' lab1=''dM'';re3 = mMagShift_valid; view_mcgrid')
    uimenu(op1,'Label','Normalized \Delta_{FMD}',...
         'Callback','lab1=''\Delta_{FMD}'';re3 = mChFMD; view_mcgrid')
    uimenu(op1,'Label','Resolution Map (Number of events period 1)',...
         'Callback','lab1=''Number of events'';re3 = mNumevents1; view_mcgrid')
    uimenu(op1,'Label','Resolution Map (Number of events period 2)',...
         'Callback','lab1=''Number of events'';re3 = mNumevents2; view_mcgrid')
    uimenu(op1,'Label','Mc period 1',...
         'Callback','lab1=''Mc'';re3 = mMc1; view_mcgrid')
    uimenu(op1,'Label','Mc period 2',...
         'Callback','lab1=''Mc'';re3 = mMc2; view_mcgrid')
    uimenu(op1,'Label','Mc change',...
         'Callback','lab1=''dMc'';re3 = mdMc; view_mcgrid')
    uimenu(op1,'Label','Mc change validated',...
         'Callback','lab1=''dMc'';re3 = mdMc_val; view_mcgrid')
    uimenu(op1,'Label','AIC difference Utsu',...
         'Callback','lab1=''dAIC'';re3 = mdAIC_Utsu; view_mcgrid')
    uimenu(op1,'Label','Probability of stationarity (favoring stationarity)',...
         'Callback','lab1=''Mc'';re3 = mStationary1_Utsu; view_mcgrid')
    uimenu(op1,'Label','Probability of stationarity (favoring non-stationarity)',...
         'Callback','lab1=''Prob'';re3 = mStationary2_Utsu; view_mcgrid')

    % Menu DISPLAY
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

    %re3 = pvalg;
    tresh = nan; re4 = re3;
    oldfig_button = 1;

    colormap(jet)
    tresh = nan; minpe = nan; Mmin = nan; minsd = nan;

end   % This is the end of the figure setup.

% Now lets plot the color-map!
%
figure_w_normalized_uicontrolunits(rcmap)
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
maxc = max(max(re3));
maxc = fix(maxc)+1;
minc = min(min(re3));
minc = fix(minc)-1;

% set values greater tresh = nan
%
re4 = re3;

% plot image
%
orient landscape
%set(gcf,'PaperPosition', [0.5 1 9.0 4.0])

%Plots re4, which contains the filtered values.
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

%If the colorbar is freezed.
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
figure_w_normalized_uicontrolunits(rcmap);
%sizmap = signatur('ZMAP','',[0.01 0.04]);
%set(sizmap,'Color','k')
axes(h1)
watchoff(rcmap)
%whitebg(gcf,[ 0 0 0 ])
done
