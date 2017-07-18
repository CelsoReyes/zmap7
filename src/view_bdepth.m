% This .m file "view_maxz.m" plots the maxz LTA values calculated
% with maxzlta.m or other similar values as a color map
% needs re3, gx, gy, stri
%
% define size of the plot etc.
%
if isempty(name)
    name = '  '
end
think
report_this_filefun(mfilename('fullpath'));
%co = 'w';


% Find out of figure already exists
%
%[existFlag,figNumber]=figure_exists('b-value-depth-ratio-map',1);
%newbmapWindowFlag=~existFlag;
if use_old_win == 1
    newbmapWindowFlag = 0;
    disp('using old window');
elseif use_old_win == 0
    newbmapWindowFlag = 1;
    disp('creating new window!!');
end
use_old_win = 0;
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
        'Name','b-value-depth-ratio-map',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','new', ...
        'backingstore','on',...
        'Visible','off', ...
        'Position',[ (fipo(3:4) - [600 400]) ZmapGlobal.Data.map_len]);
    % make menu bar
    matdraw

    %lab1 = 'b-value-depth-ratio:';

    add_symbol_menu('eq_plot');

    uicontrol('Units','normal',...
        'Position',[.0 .93 .08 .06],'String','Info ',...
         'Callback',' web([''file:'' hodi ''/zmapwww/chp11.htm#996756'']) ');



    options = uimenu('Label',' Select ');
    uimenu(options,'Label','Refresh ', 'Callback','use_old_win = 1; view_bdepth')
    uimenu(options,'Label','Select EQ in Circle',...
         'Callback','h1 = gca;met = ''rd''; ZG=ZmapGlobal.Data; ZG.hold_state=false;cirbva_bdepth2;watchoff(bmap)')


    op1 = uimenu('Label',' Maps ');

    adjmenu =  uimenu(op1,'Label','Adjust Map Display Parameters'),...
        uimenu(adjmenu,'Label','Adjust Rmax cut',...
         'Callback','asel = ''rmax''; adjub; view_bdepth')
    uimenu(adjmenu,'Label','Adjust goodness of fit cut',...
         'Callback','asel = ''gofi''; adjub; use_old_win = 1; view_bdepth')


    %  uimenu(op1,'Label','b-value map (WLS)',...
    %      'Callback','lab1 =''b-value''; re3 = old; view_bdepth')
    %  uimenu(op1,'Label','b(max likelihood) map',...
    %      'Callback','lab1=''b-value''; re3 = meg; view_bdepth')
    %  uimenu(op1,'Label','mag of completness map',...
    %      'Callback','lab1 = ''Mcomp''; re3 = old1; view_bdepth')
    %  uimenu(op1,'Label','Goodness of fit to power law map',...
    %      'Callback','lab1 = '' % ''; re3 = Prmap; view_bdepth')

    %  uimenu(op1,'Label','a-value map',...
    %      'Callback','lab1=''a-value'';re3 = avm; view_bdepth')
    %  uimenu(op1,'Label','standard error map',...
    %      'Callback',' lab1=''error in b'';re3 = stanm; view_bdepth')
    %  uimenu(op1,'Label','(WLS-Max like) map',...
    %      'Callback',' lab1=''differnce in b'';re3 = old-meg; view_bdepth')


    uimenu(op1,'Label','Depth Ratio Map',...
         'Callback','lab1=''b ratio'';re3 = old; view_bdepth')

    uimenu(op1,'Label','Utsu Probability Map',...
         'Callback','lab1=''Probability'';re3 = Prmap; view_bdepth')

    uimenu(op1,'Label','Top Zone b value Map',...
         'Callback','lab1=''Top Zone b value'';re3 = top_b; view_bdepth')

    uimenu(op1,'Label','Bottom Zone b value Map',...
         'Callback','lab1=''Bottom Zone b value'';re3 = bottom_b; view_bdepth')

    uimenu(op1,'Label','% of nodal EQs within top zone',...
         'Callback','lab1=''% of nodal EQs within top zone'';re3 = per_top; view_bdepth')

    uimenu(op1,'Label','% of nodal EQs within bottom zone',...
         'Callback','lab1=''% of nodal eqs within bottom zone'';re3 = per_bot; view_bdepth')

    uimenu(op1,'Label','resolution Map',...
         'Callback','lab1=''Radius in [km]'';re3 = r; view_bdepth')
    uimenu(op1,'Label','Histogram ', 'Callback','zhist')

    add_display_menu(1);

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
set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
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

% Find percentage above and below 1.0
disp('HELP!!!!!!');
under_1 = re3 < 1.0;
equal_1 = re3 == 1.0;
over_1 = re3 > 1.0;

total_num = length(re3);
p_under = under_1/total_num;
p_equal = equal_1/total_num;
p_over = over_1/total_num;

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

title([name ';  '   num2str(t0b) ' to ' num2str(teb) ],'FontSize',ZmapGlobal.Data.fontsz.s,...
    'Color','r','FontWeight','bold')

xlabel('Longitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
ylabel('Latitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)

% plot overlay
%
hold on
overlay_
ploeq = plot(ZG.a.Longitude,ZG.a.Latitude,'k.');
set(ploeq,'Tag','eq_plot','MarkerSize',ZG.ms6,'Marker',ty,'Color',co,'Visible',vi)



set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')
h1 = gca;
hzma = gca;

%lab1 = 'b-value-depth-ratio:';

% Create a colorbar
%
h5 = colorbar('horiz');
set(h5,'Pos',[0.35 0.05 0.4 0.02],...
    'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s,'TickDir','out')

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
    'FontWeight','bold',...
    'String',lab1);
ni_txt = text('Position', [.39 .12],'String',[num2str(ni_plot),' events per grid node.']);
bval_txt =  text('Position', [.34 .96],'String',['Overall b-value depth ratio = ' num2str(depth_ratio)]);
%bval2_txt =  text('Position', [.63 .95],'String',depth_ratio);

dbrange1 = num2str(top_zonet);
dbrange2 = num2str(top_zoneb);
dbrange3 = num2str(bot_zonet);
dbrange4 = num2str(bot_zoneb);
mid_txt = text('Position', [.20 .915],'String', ['Top and bottom zones for ratio calculation(km):' dbrange1,' to ',dbrange2 ,' and ' dbrange3,' to ',dbrange4]);
%mid2_txt = text('Position', [.685 .915],'String', [dbrange1,' to ',dbrange2 ,' and ' dbrange3,' to ',dbrange4]);


% Make the figure visible
%
set(gca,'FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')
figure_w_normalized_uicontrolunits(bmap);
%sizmap = signatur('ZMAP','',[0.01 0.04]);
%set(sizmap,'Color','k')
axes(h1)
watchoff(bmap)
%whitebg(gcf,[ 0 0 0 ])
done
