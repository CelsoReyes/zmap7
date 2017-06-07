% This .m file "view_x
% maxz.m" plots the maxz LTA values calculated
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
[existFlag,figNumber]=figure_exists('b and p -value cross-section',1);
newbpmapcsWindowFlag=~existFlag;

% This is the info window text
%
ttlStr='The b and p -Value Map Window                 ';
hlpStr1zmap= ...
    ['                                                '
    ' This window displays the b and p maps by       '
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
if newbpmapcsWindowFlag
    bpmapcs = figure_w_normalized_uicontrolunits( ...
        'Name','b and p -value cross-section',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'backingstore','on',...
        'Visible','off', ...
        'Position',[ fipo(3)-600 fipo(4)-400 winx winy]);
    % make menu bar
    matdraw
    lab1 = 'b-value';

    add_symbol_menu('eqc_plot');


    uicontrol('Units','normal',...
        'Position',[.0 .93 .08 .06],'String','Print ',...
         'Callback','myprint')

    callbackStr= ...
        ['f1=gcf; f2=gpf; set(f1,''Visible'',''off'');close(bpmapc);', ...
        'if f1~=f2, figure_w_normalized_uicontrolunits(map);done; end'];

    uicontrol('Units','normal',...
        'Position',[.0 .75 .08 .06],'String','Close ',...
         'Callback','eval(callbackStr)')

    uicontrol('Units','normal',...
        'Position',[.0 .85 .08 .06],'String','Info ',...
         'Callback','zmaphelp(ttlStr,hlpStr1zmap,hlpStr2zmap)')

    uicontrol('Units','normal',...
        'Position',[.0 .02 .08 .06],'String','zoom ',...
         'Callback','zoomrb')


    options = uimenu('Label',' Select ');
    uimenu(options,'Label','Refresh ', 'Callback','view_bpvs')
    uimenu(options,'Label','Select EQ in Circle (const N)',...
         'Callback',' h1 = gca;ho = ''noho'';ic = 1;cicros;')
    uimenu(options,'Label','Select EQ in Circle (const R)',...
         'Callback',' h1 = gca;ho = ''noho'';ic = 2;cicros;')
    uimenu(options,'Label','Select EQ in Circle - Overlay existing plot',...
         'Callback','h1 = gca;ho = ''hold'';cicros;')
    uimenu(options,'Label','Select Eqs in Polygon - new',...
         'Callback','ho = ''noho'';polyb;');
    uimenu(options,'Label','Select Eqs in Polygon - hold',...
         'Callback','ho = ''hold'';polyb;');

    op1 = uimenu('Label',' Maps ');

    %Meniu for adjusting several parameters.
    adjmenu =  uimenu(op1,'Label','Adjust Map Display Parameters'),...
        uimenu(adjmenu,'Label','Adjust Mmin cut',...
         'Callback','asel = ''mag''; adju2; view_bpvs ')
    uimenu(adjmenu,'Label','Adjust Rmax cut',...
         'Callback','asel = ''rmax''; adju2; view_bpvs')
    uimenu(adjmenu,'Label','Adjust goodness of fit cut',...
         'Callback','asel = ''gofi''; adju2; view_bpvs ')
    uimenu(adjmenu,'Label','Adjust p-value st. dev. cut',...
         'Callback','asel = ''pstdc''; adju2; view_bpvs ')

    uimenu(op1,'Label','b-value map (WLS)',...
         'Callback','lab1 =''b-value''; re3 = old; view_bpvs')
    uimenu(op1,'Label','b(max likelihood) map',...
         'Callback','lab1=''b-value''; re3 = meg; view_bpvs')
    uimenu(op1,'Label','mag of completness map',...
         'Callback','lab1 = ''Mcomp''; re3 = old1; view_bpvs')
    uimenu(op1,'Label','max magnitude map',...
         'Callback',' lab1=''Mmax'';re3 = maxm; view_bpvs')
    uimenu(op1,'Label','magnitude range map (Mmax - Mcomp)',...
         'Callback',' lab1=''dM '';re3 = maxm-magco; view_bpvs')

    uimenu(op1,'Label','p-value',...
         'Callback',' lab1=''p-value'';re3 = pvalg; view_bpvs')
    uimenu(op1,'Label','p-value standard deviation',...
         'Callback',' lab1=''p-valstd'';re3 = pvstd; view_bpvs')


    uimenu(op1,'Label','Goodness of fit to power law map',...
         'Callback','lab1 = '' % ''; re3 = Prmap; view_bpvs')

    uimenu(op1,'Label','a-value map',...
         'Callback','lab1=''a-value'';re3 = avm; view_bpvs')
    uimenu(op1,'Label','standard error map',...
         'Callback',' lab1=''error in b'';re3 = pro; view_bpvs')
    uimenu(op1,'Label','(WLS-Max like) map',...
         'Callback',' lab1=''difference in b'';re3 = old-meg; view_bpvs')


    uimenu(op1,'Label','resolution Map',...
         'Callback','lab1=''Radius in [km]'';re3 = r; view_bpvs')
    uimenu(op1,'Label','Histogram ', 'Callback','zhist')

    op2e = uimenu('Label',' Display ');
    uimenu(op2e,'Label','Fix color (z) scale', 'Callback','fixax2 ')
    uimenu(op2e,'Label','Show Grid ',...
         'Callback','hold on;plot(newgri(:,1),newgri(:,2),''+k'')')
    uimenu(op2e,'Label','Show Circles ', 'Callback','plotci3')
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
         'Callback','hold on;overlay_')

    uicontrol('Units','normal',...
        'Position',[.92 .80 .08 .05],'String','set ni',...
         'Callback','ni=str2num(get(set_nia,''String''));''String'',num2str(ni);')


    set_nia = uicontrol('style','edit','value',ni,'string',num2str(ni));
    set(set_nia,'Callback',' ');
    set(set_nia,'units','norm','pos',[.94 .85 .06 .05],'min',10,'max',10000);
    nilabel = uicontrol('style','text','units','norm','pos',[.90 .85 .04 .05]);
    set(nilabel,'string','ni:','background',[.7 .7 .7]);

    %tx = text(0.07,0.95,[name],'Units','Norm','FontSize',18,'Color','k','FontWeight','bold');

    tresh = max(max(r)); re4 = re3;

    colormap(jet)

end   % This is the end of the figure setup

% Now lets plot the color-map of the b and p -value.
%
figure_w_normalized_uicontrolunits(bpmapcs)
delete(gca)
delete(gca)
delete(gca)
dele = 'delete(sizmap)';er = 'disp('' '')'; eval(dele,er);
reset(gca)
cla
hold off
watchon;
set(gca,'visible','off','FontSize',fontsz.m,'FontWeight','bold',...
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
l = r > tresh;
re4(l) = NaN(1,length(find(l)));
l = Prmap < minpe;
re4(l) = NaN(1,length(find(l)));
l = old1 <  Mmin;
re4(l) = NaN(1,length(find(l)));
l = pvstd >  minsd;
re4(l) = NaN(1,length(find(l)));


% plot image
%
orient landscape
%set(gcf,'PaperPosition', [2. 1 7.0 5.0])

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


%If the colorbar is freezed
if fre == 1
    caxis([fix1 fix2])
end

title2([name ';  '   num2str(t0b,4) ' to ' num2str(teb,4) ],'FontSize',fontsz.m,...
    'Color','w','FontWeight','bold')

xlabel('Distance in [km]','FontWeight','bold','FontSize',fontsz.m)
ylabel('Depth in [km]','FontWeight','bold','FontSize',fontsz.m)

% plot overlay
%
hold on
ploeqc = plot(newa(:,length(newa(1,:))),-newa(:,7),'.k');
set(ploeqc,'Tag','eqc_plot','MarkerSize',ms6,'Marker',ty,'Color',co,'Visible',vi)

if exist('vox') > 0
    plovo = plot(vox,voy,'*b');
    set(plovo,'MarkerSize',6,'LineWidth',1)
end

if exist('maix') > 0
    pl = plot(maix,maiy,'*k');
    set(pl,'MarkerSize',12,'LineWidth',2)
end

if exist('maex') > 0
    pl = plot(maex,-maey,'hm');
    set(pl,'LineWidth',1.5,'MarkerSize',12,...
        'MarkerFaceColor','w','MarkerEdgeColor','k')
end

if exist('wellx') > 0
    hold on
    plwe = plot(wellx,-welly,'w')
    set(plwe,'LineWidth',2);
end

set(gca,'visible','on','FontSize',fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')
h1 = gca;
hzma = gca;

% Create a colorbar
%

h5 = colorbar('horiz');
%apo = get(h1,'pos');
set(h5,'Pos',[0.35 0.05 0.4 0.02],...
    'FontWeight','bold','FontSize',fontsz.m,'TickDir','out')

rect = [0.00,  0.0, 1 1];
axes('position',rect)
axis('off')
%  Text Object Creation
txt1 = text(...
    'Color',[ 0 0 0 ],...
    'EraseMode','normal',...
    'Position',[ 0.33 0.06 0 ],...
    'HorizontalAlignment','right',...
    'Rotation',[ 0 ],...
    'FontSize',fontsz.m,....
    'FontWeight','bold',...
    'String',lab1);

% Make the figure visible
%
axes(h1)
set(gca,'visible','on','FontSize',fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')
%whitebg(gcf,[0 0 0])
%set(gcf,'Color',[ 0 0 0 ])
figure_w_normalized_uicontrolunits(bpmapcs);
%axes(h1);
watchoff(bpmapcs);
done
