% This .m file, "view_rcva.m", plots ratechanges and p values calculated
% with rcvalgrid.m or other similar values as a color map.
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
        'Position',[ fipo(3)-600 fipo(4)-400 winx+50 winy+50]);
    % make menu bar
    matdraw

    %lab1 = 'p-value:';
    add_symbol_menu('eq_plot');


    %    uicontrol('Units','normal',...
    %       'Position',[.0 .93 .08 .06],'String','Info ',...
    %        'Callback',' web([''file:'' hodi ''/zmapwww/chp11.htm#996756'']) ');

    options = uimenu('Label',' Analyze ');
    uimenu(options,'Label','Refresh ', 'Callback','view_rcva_a2')
    %    uimenu(options,'Label','Select EQ in Circle',...
    %        'Callback','h1 = gca;met = ''ni''; ho=''noho'';cirpva;watchoff(rcmap)')
    uimenu(options,'Label','Select EQ in Circle - Constant R',...
         'Callback','h1 = gca;met = ''ra''; ho=''noho'';plot_circbootfit_a2;watchoff(rcmap)')
    uimenu(options,'Label','Select EQ with const. number',...
         'Callback','h1 = gca;ho2=''hold'';ho = ''hold'';plot_constnrbootfit_a2;watchoff(rcmap)')


    op1 = uimenu('Label',' Maps ');

    %Meniu for adjusting several parameters.
    adjmenu =  uimenu(op1,'Label','Adjust Map Display Parameters'),...
        uimenu(adjmenu,'Label','Adjust Mmin cut',...
         'Callback','asel = ''mag''; adju2; view_rcva_a2 ')
    uimenu(adjmenu,'Label','Adjust Rmax cut',...
         'Callback','asel = ''rmax''; adju2; view_rcva_a2')
    uimenu(adjmenu,'Label','Adjust goodness of fit cut',...
         'Callback','asel = ''gofi''; adju2; view_rcva_a2 ')
    uimenu(adjmenu,'Label','Adjust p-value st. dev. cut',...
         'Callback','asel = ''pstdc''; adju2; view_rcva_a2 ')


    uimenu(op1,'Label','Relative rate change (bootstrap)',...
         'Callback',' lab1=''Sigma'';re3 = mRelchange; view_rcva_a2')
    uimenu(op1,'Label','Model',...
         'Callback',' lab1=''Model'';re3 = mMod; view_rcva_a2')
    uimenu(op1,'Label','KS-Test',...
         'Callback',' lab1=''Rejection'';re3 = mKstestH; view_rcva_a2')
    uimenu(op1,'Label','KS-Test Statistic',...
         'Callback',' lab1=''KS distance'';re3 = mKsstat; view_rcva_a2')
    uimenu(op1,'Label','KS-Test p-value',...
         'Callback',' lab1=''KS-Test p-value'';re3 = mKsp; view_rcva_a2')
    uimenu(op1,'Label','RMS of fit',...
         'Callback',' lab1=''RMS'';re3 = mRMS; view_rcva_a2')
    uimenu(op1,'Label','Resolution Map (Number of events)',...
         'Callback','lab1=''Number of events'';re3 = mNumevents; view_rcva_a2')
    uimenu(op1,'Label','Resolution Map (Radii)',...
         'Callback','lab1=''Radius / [km]'';re3 = vRadiusRes; view_rcva_a2')
    uimenu(op1,'Label','p-value',...
         'Callback',' lab1=''p-value'';re3 = mPval; view_rcva_a2')
    uimenu(op1,'Label','p-value standard deviation',...
         'Callback',' lab1=''p-valstd'';re3 = mPvalstd; view_rcva_a2')
    uimenu(op1,'Label','c-value',...
         'Callback','lab1=''c-value'';re3 = mCval; view_rcva_a2')
    uimenu(op1,'Label','c-value standard deviation',...
         'Callback','lab1=''c-valuestd'';re3 = mCvalstd; view_rcva_a2')
    uimenu(op1,'Label','k-value',...
         'Callback','lab1=''k-value'';re3 = mKval; view_rcva_a2')
    uimenu(op1,'Label','k-value standard deviation',...
         'Callback','lab1=''k-valuestd'';re3 = mKvalstd; view_rcva_a2')
    uimenu(op1,'Label','p2-value',...
         'Callback',' lab1=''p2-value'';re3 = mPval2; view_rcva_a2')
    uimenu(op1,'Label','p-value standard deviation',...
         'Callback',' lab1=''p-valstd'';re3 = mPvalstd2; view_rcva_a2')
    uimenu(op1,'Label','c2-value',...
         'Callback','lab1=''c-value'';re3 = mCval2; view_rcva_a2')
    uimenu(op1,'Label','c2-value standard deviation',...
         'Callback','lab1=''c-valuestd'';re3 = mCvalstd2; view_rcva_a2')
    uimenu(op1,'Label','k2-value',...
         'Callback','lab1=''k-value'';re3 = mKval2; view_rcva_a2')
    uimenu(op1,'Label','k2-value standard deviation',...
         'Callback','lab1=''k-valuestd'';re3 = mKvalstd2; view_rcva_a2')
    %    uimenu(op1,'Label','Histogram ', 'Callback','zhist')

    op2e = uimenu('Label',' Display ');
    uimenu(op2e,'Label','Fix color (z) scale', 'Callback','fixax_vertical')
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
re4 = re3;%mRelchange;%re3;
% l = r > tresh;
% re4(l) = NaN(1,length(find(l)));
% l = Prmap < minpe;
% re4(l) = NaN(1,length(find(l)));
% l = old1 <  Mmin;
% re4(l) = NaN(1,length(find(l)));
% l = pvstd >  minsd;
% re4(l) = NaN(1,length(find(l)));


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


% title2([name ';  '   num2str(t0b) ' to ' num2str(teb) ],'FontSize',fontsz.s,...
%     'Color','r','FontWeight','bold')

xlabel('Longitude [deg]','FontWeight','bold','FontSize',fontsz.s)
ylabel('Latitude [deg]','FontWeight','bold','FontSize',fontsz.s)

% plot overlay
%
hold on
overlay_
ploeq = plot(a.Longitude,a.Latitude,'k.');
set(ploeq,'Tag','eq_plot''MarkerSize',ms6,'Marker',ty,'Color',co,'Visible',vi)



set(gca,'visible','on','FontSize',fontsz.s,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')
h1 = gca;
hzma = gca;

% Create a colorbar
%
% h5 = colorbar('horiz');
% set(h5,'Pos',[0.3 0.1 0.4 0.02],...
%     'FontWeight','bold','FontSize',fontsz.s,'TickDir','out')
h5 = colorbar;
chl = get(h5,'Ylabel');
set(chl,'String',lab1,'FontS',10,'Rot',270);

rect = [0.00,  0.0, 1 1];
axes('position',rect)
axis('off')
% %  Text Object Creation
% txt1 = text(...
%     'Color',[ 0 0 0 ],...
%     'EraseMode','normal',...
%     'Units','normalized',...
%     'Position',[ 0.33 0.06 0 ],...
%     'HorizontalAlignment','right',...
%     'Rotation',[ 0 ],...
%     'FontSize',fontsz.s,....
%     'FontWeight','bold',...
%     'String',lab1);
%
% Make the figure visible
%
set(gca,'FontSize',fontsz.s,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')
%figure_w_normalized_uicontrolunits(rcmap);
%sizmap = signatur('ZMAP','',[0.01 0.04]);
%set(sizmap,'Color','k')
axes(h1)
watchoff(rcmap)
%whitebg(gcf,[ 0 0 0 ])
done
