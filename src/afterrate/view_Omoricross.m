function view_Omoricross(lab1, re3)
% Script: view_Omoriparams.m
% Plot Modified Omori law / nested MOL parameters calculated with calc_Omoricross.m.
%
% j.woessner@sed.ethz.ch
% last update: 20.10.04

if isempty(name)
    name = '  '
end

think
report_this_filefun(mfilename('fullpath'));

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
% Find out of figure already exists
%
[existFlag,figNumber]=figure_exists('Omoricros-section',1);
newhOmoricrossWindowFlag=~existFlag;

if newhOmoricrossWindowFlag
    oldfig_button = 0
end

if oldfig_button == 0
    hOmoricross = figure_w_normalized_uicontrolunits( ...
        'Name','Omoricros-section',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','new', ...
        'backingstore','on',...
        'Visible','off', ...
        'Position',[ (fipo(3:4) - [600 400]) ZmapGlobal.Data.map_len]);
    % make menu bar
    matdraw

    %lab1 = 'p-value:';
    add_symbol_menu('eq_plot');

    % Menus
    options = uimenu('Label',' Analyze ');
    uimenu(options,'Label','Refresh ', 'Callback','view_Omoricross(lab1,re3)')
    %    uimenu(options,'Label','Select EQ in Circle',...
    %        'Callback','h1 = gca;met = ''ni''; ZG=ZmapGlobal.Data; ZG.hold_state=false;cirpva;watchoff(hOmoricross)')
    uimenu(options,'Label','Select EQ in Circle - Constant R',...
         'Callback','h1 = gca;met = ''ra''; ZG=ZmapGlobal.Data; ZG.hold_state=false;plot_circbootfit_a2;watchoff(hOmoricross)')
    uimenu(options,'Label','Select EQ with const. number',...
         'Callback','h1 = gca;ZG=ZmapGlobal.Data; ZG.hold_state2=true;ZG=ZmapGlobal.Data; ZG.hold_state=true;plot_constnrbootfit_a2;watchoff(hOmoricross)')


    op1 = uimenu('Label',' Maps ');

    %Meniu for adjusting several parameters.
    adjmenu =  uimenu(op1,'Label','Adjust Map Display Parameters'),...
        uimenu(adjmenu,'Label','Adjust Mmin cut',...
         'Callback','asel = ''mag''; adju2; view_Omoricross(lab1,re3)')
    uimenu(adjmenu,'Label','Adjust Rmax cut',...
         'Callback','asel = ''rmax''; adju2; view_Omoricross(lab1,re3)')
    uimenu(adjmenu,'Label','Adjust goodness of fit cut',...
         'Callback','asel = ''gofi''; adju2; view_Omoricross(lab1,re3)')
    uimenu(adjmenu,'Label','Adjust p-value st. dev. cut',...
         'Callback','asel = ''pstdc''; adju2; view_Omoricross(lab1,re3)')

    % Maps
    uimenu(op1,'Label','Model',...
         'Callback',' lab1=''Model'';re3 = mMod; view_Omoricross(lab1,re3)')
    uimenu(op1,'Label','KS-Test',...
         'Callback',' lab1=''Rejection'';re3 = mKstestH; view_Omoricross(lab1,re3)')
    uimenu(op1,'Label','KS-Test Statistic',...
         'Callback',' lab1=''KS distance'';re3 = mKsstat; view_Omoricross(lab1,re3)')
    uimenu(op1,'Label','KS-Test p-value',...
         'Callback',' lab1=''KS-Test p-value'';re3 = mKsp; view_Omoricross(lab1,re3)')
    uimenu(op1,'Label','RMS of fit',...
         'Callback',' lab1=''RMS'';re3 = mRMS; view_Omoricross(lab1,re3)')
    uimenu(op1,'Label','Resolution Map (Number of events)',...
         'Callback','lab1=''Number of events'';re3 = mNumevents; view_Omoricross(lab1,re3)')
    uimenu(op1,'Label','Resolution Map (Radii)',...
         'Callback','lab1=''Radius / [km]'';re3 = vRadiusRes; view_Omoricross(lab1,re3)')
    uimenu(op1,'Label','p-value',...
         'Callback',' lab1=''p-value'';re3 = mPval; view_Omoricross(lab1,re3)')
    uimenu(op1,'Label','p-value standard deviation',...
         'Callback',' lab1=''p-valstd'';re3 = mPvalstd; view_Omoricross(lab1,re3)')
    uimenu(op1,'Label','c-value',...
         'Callback','lab1=''c-value'';re3 = mCval; view_Omoricross(lab1,re3)')
    uimenu(op1,'Label','c-value standard deviation',...
         'Callback','lab1=''c-valuestd'';re3 = mCvalstd; view_Omoricross(lab1,re3)')
    uimenu(op1,'Label','k-value',...
         'Callback','lab1=''k-value'';re3 = mKval; view_Omoricross(lab1,re3)')
    uimenu(op1,'Label','k-value standard deviation',...
         'Callback','lab1=''k-valuestd'';re3 = mKvalstd; view_Omoricross(lab1,re3)')
    uimenu(op1,'Label','Magnitude of completness',...
         'Callback','lab1=''Mc'';re3 = mMc; view_Omoricross(lab1,re3)')
add_display_menu(1)

    %re3 = pvalg;
    tresh = nan;
    oldfig_button = 1;

    colormap(jet)
    tresh = nan; minpe = nan; Mmin = nan; minsd = nan;

end   % This is the end of the figure setup.

% Plot the cross section
figure_w_normalized_uicontrolunits(hOmoricross)
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

rect = [0.18,  0.10, 0.7, 0.75];
rect1 = rect;

% find max and min of data for automatic scaling
ZG.maxc = max(max(re3));
ZG.maxc = fix(ZG.maxc)+1;
ZG.minc = min(min(re3));
ZG.minc = fix(ZG.minc)-1;

% plot image
orient landscape

% Plot surface
axes('position',rect)
hold on
pco1 = pcolor(gx,gy,re3);

axis([ min(gx) max(gx) min(gy) max(gy)])
axis image
hold on

% Shading
if sha == 'fl'
    shading flat
else
    shading interp
end

%If the colorbar is freezed.
if fre == 1
    caxis([fix1 fix2])
end

% Labeling
title([name ';  '   num2str(t0b) ' to ' num2str(teb) ],'FontSize',ZmapGlobal.Data.fontsz.s,...
    'Color','r','FontWeight','bold')

xlabel('Distance [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
ylabel('Depth [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)

% Plot overlay
%
hold on
[nYnewa,nXnewa] = size(newa);
ploeq = plot(newa(:,nXnewa),-newa(:,7),'k.');
set(ploeq,'Tag','eq_plot','MarkerSize',ZG.ms6,'Marker',ty,'Color',co,'Visible',vi)
set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')
h1 = gca;
hzma = gca;

% Create a colorbar
h5 = colorbar('horiz');
set(h5,'Pos',[0.35 0.07 0.4 0.02],...
    'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s,'TickDir','out')
rect = [0.00,  0.0, 1 1];
axes('position',rect)
axis('off')
%  Text Object Creation
txt1 = text(...
    'Color',[ 0 0 0 ],...
    'EraseMode','normal',...
    'Units','normalized',...
    'Position',[ 0.33 0.075 0 ],...
    'HorizontalAlignment','right',...
    'Rotation',[ 0 ],...
    'FontSize',ZmapGlobal.Data.fontsz.s,....
    'FontWeight','bold',...
    'String',lab1);

% Make the figure visible
set(gca,'FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')
figure_w_normalized_uicontrolunits(hOmoricross);
axes(h1)
watchoff(hOmoricross)
done
