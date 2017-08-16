function view_rcva(lab1,re3)
% This .m file, "view_rcva.m", plots ratechanges and p values calculated
% with rcvalgrid.m or other similar values as a color map.
% needs re3, gx, gy
%
% define size of the plot etc.
%
if isempty(name)
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
        'NextPlot','new', ...
        'backingstore','on',...
        'Visible','off', ...
        'Position',[ (fipo(3:4) - [600 400]) ZmapGlobal.Data.map_len]);

    %lab1 = 'p-value:';
    add_symbol_menu('eq_plot');

    options = uimenu('Label',' Analyze ');
    uimenu(options,'Label','Refresh ', 'callback',@callbackfun_001)
    uimenu(options,'Label','Select EQ in Circle - Constant R',...
         'callback',@callbackfun_002)
    uimenu(options,'Label','Select EQ with const. number',...
         'callback',@callbackfun_003)


    op1 = uimenu('Label',' Maps ');

    %Meniu for adjusting several parameters.
    adjmenu =  uimenu(op1,'Label','Adjust Map Display Parameters'),...
        uimenu(adjmenu,'Label','Adjust Mmin cut',...
         'callback',@callbackfun_004)
    uimenu(adjmenu,'Label','Adjust Rmax cut',...
         'callback',@callbackfun_005)
    uimenu(adjmenu,'Label','Adjust goodness of fit cut',...
         'callback',@callbackfun_006)
    uimenu(adjmenu,'Label','Adjust p-value st. dev. cut',...
         'callback',@callbackfun_007)


    %    uimenu(op1,'Label','b-value map (WLS)',...
    %        'callback',@callbackfun_008)
    %    uimenu(op1,'Label','b(max likelihood) map',...
    %        'callback',@callbackfun_009)
    %    uimenu(op1,'Label','Mag of completness map',...
    %        'callback',@callbackfun_010)
    %    uimenu(op1,'Label','max magnitude map',...
    %           'callback',@callbackfun_011)
    %    uimenu(op1,'Label','Magnitude range map (Mmax - Mcomp)',...
    %           'callback',@callbackfun_012)
    %
    uimenu(op1,'Label','Relative rate change',...
         'callback',@callbackfun_013)
    uimenu(op1,'Label','Relative rate change by boostrap',...
         'callback',@callbackfun_014)
    uimenu(op1,'Label','Resolution Map (Number of events)',...
         'callback',@callbackfun_015)
    uimenu(op1,'Label','Resolution Map (Radii)',...
         'callback',@callbackfun_016)
    uimenu(op1,'Label','p-value',...
         'callback',@callbackfun_017)
    uimenu(op1,'Label','p-value standard deviation',...
         'callback',@callbackfun_018)
    uimenu(op1,'Label','c-value',...
         'callback',@callbackfun_019)
    uimenu(op1,'Label','c-value standard deviation',...
         'callback',@callbackfun_020)
    uimenu(op1,'Label','k-value',...
         'callback',@callbackfun_021)
    uimenu(op1,'Label','k-value standard deviation',...
         'callback',@callbackfun_022)
    %    uimenu(op1,'Label','Histogram ', 'callback',@callbackfun_023)

    add_display_menu(1);

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

% Make the figure visible
%
set(gca,'FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')
figure_w_normalized_uicontrolunits(rcmap);
%sizmap = signatur('ZMAP','',[0.01 0.04]);
%set(sizmap,'Color','k')
axes(h1)
watchoff(rcmap)
%whitebg(gcf,[ 0 0 0 ])
done

function callbackfun_001(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_001');
  view_rcva(lab1,re3);
end
 
function callbackfun_002(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_002');
  h1 = gca;
  met = 'ra';
   ZG=ZmapGlobal.Data;
   ZG.hold_state=false;
  plot_circbootfitF;
  watchoff(rcmap);
end
 
function callbackfun_003(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_003');
  h1 = gca;
  ZG=ZmapGlobal.Data;
   ZG.hold_state2=true;
  ZG=ZmapGlobal.Data;
   ZG.hold_state=true;
  plot_constnrbootfitF;
  watchoff(rcmap);
end
 
function callbackfun_004(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_004');
  asel = 'mag';
   adju2;
   view_rcva(lab1,re3);
end
 
function callbackfun_005(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_005');
  asel = 'rmax';
   adju2;
   view_rcva(lab1,re3);
end
 
function callbackfun_006(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_006');
  asel = 'gofi';
   adju2;
   view_rcva(lab1,re3);
end
 
function callbackfun_007(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_007');
  asel = 'pstdc';
   adju2;
   view_rcva(lab1,re3);
end
 
function callbackfun_008(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_008');
  lab1 ='b-value';
   re3 = old;
   view_rcva(lab1,re3);
end
 
function callbackfun_009(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_009');
  lab1='b-value';
   re3 = meg;
   view_rcva(lab1,re3);
end
 
function callbackfun_010(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_010');
  lab1 = 'Mcomp';
   re3 = old1;
   view_rcva(lab1,re3);
end
 
function callbackfun_011(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_011');
   lab1='Mmax';
  re3 = maxm;
   view_rcva(lab1,re3);
end
 
function callbackfun_012(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_012');
   lab1='dM ';
  re3 = maxm-magco;
   view_rcva(lab1,re3);
end
 
function callbackfun_013(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_013');
   lab1='Sigma';
  re3 = mRelchange;
   view_rcva(lab1,re3);
end
 
function callbackfun_014(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_014');
   lab1='Sigma';
  re3 = vRcBst;
   view_rcva(lab1,re3);
end
 
function callbackfun_015(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_015');
  lab1='Number of events';
  re3 = mNumevents;
   view_rcva(lab1,re3);
end
 
function callbackfun_016(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_016');
  lab1='Radius / [km]';
  re3 = vRadiusRes;
   view_rcva(lab1,re3);
end
 
function callbackfun_017(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_017');
   lab1='p-value';
  re3 = mPval;
   view_rcva(lab1,re3);
end
 
function callbackfun_018(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_018');
   lab1='p-valstd';
  re3 = mPvalstd;
   view_rcva(lab1,re3);
end
 
function callbackfun_019(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_019');
  lab1='c-value';
  re3 = mCval;
   view_rcva(lab1,re3);
end
 
function callbackfun_020(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_020');
  lab1='c-valuestd';
  re3 = mCvalstd;
   view_rcva(lab1,re3);
end
 
function callbackfun_021(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_021');
  lab1='k-value';
  re3 = mKval;
   view_rcva(lab1,re3);
end
 
function callbackfun_022(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_022');
  lab1='k-valuestd';
  re3 = mKvalstd;
   view_rcva(lab1,re3);
end
 
function callbackfun_023(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_023');
  zhist;
end
 
