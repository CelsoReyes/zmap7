function view_bvt(lab1,re3)
% This .m file "view_x
% maxz.m" plots the maxz LTA values calculated
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
co = 'k';


% Find out of figure already exists
%
[existFlag,figNumber]=figure_exists('b-value cross-section',1);
newbmapcWindowFlag=~existFlag;

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
if newbmapcWindowFlag
    bmapc = figure_w_normalized_uicontrolunits( ...
        'Name','b-value cross-section',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'backingstore','on',...
        'Visible','off', ...
        'Position',[ (fipo(3:4) - [600 400]) ZmapGlobal.Data.map_len]);
    % make menu bar
    matdraw
    lab1 = 'b-value';

    add_symbol_menu('eqc_plot');

    uicontrol('Units','normal',...
        'Position',[.0 .93 .08 .06],'String','Print ',...
         'Callback','myprint')

    callbackStr= ...
        ['f1=gcf; f2=gpf; set(f1,''Visible'',''off'');close(bmapc);', ...
        'if f1~=f2, figure_w_normalized_uicontrolunits(map);done; end'];

    uicontrol('Units','normal',...
        'Position',[.0 .75 .08 .06],'String','Close ',...
         'Callback','eval(callbackStr)')

    uicontrol('Units','normal',...
        'Position',[.0 .85 .08 .06],'String','Info ',...
         'Callback','zmaphelp(ttlStr,hlpStr1zmap,hlpStr2zmap)')


    options = uimenu('Label',' Select ');
    uimenu(options,'Label','Refresh ', 'Callback','view_bv2(lab1,re3)')
    uimenu(options,'Label','Select EQ in Circle (const N)',...
         'Callback',' h1 = gca;ZG=ZmapGlobal.Data; ZG.hold_state=false;cicros(1);')
    uimenu(options,'Label','Select EQ in Circle (const R)',...
         'Callback',' h1 = gca;ZG=ZmapGlobal.Data; ZG.hold_state=false;cicros(2);')
    uimenu(options,'Label','Select EQ in Circle - Overlay existing plot',...
         'Callback','h1 = gca;ZG=ZmapGlobal.Data; ZG.hold_state=true;cicros(0);')
    uimenu(options,'Label','Select EQ in Circle (const R - time split)',...
         'Callback',' h1 = gca;ZG=ZmapGlobal.Data; ZG.hold_state=false;cicros(3);')
    uimenu(options,'Label','Select Eqs in Polygon - new',...
         'Callback','ZG=ZmapGlobal.Data; ZG.hold_state=false;polyb;');
    uimenu(options,'Label','Select Eqs in Polygon - hold',...
         'Callback','ZG=ZmapGlobal.Data; ZG.hold_state=true;polyb;');

    op1 = uimenu('Label',' Maps ');
    uimenu(op1,'Label','b change in percent map  ',...
         'Callback','lab1 =''b-value change''; re3 = dbperc; view_bvt(lab1,re3)')
    uimenu(op1,'Label','b-value Map (weighted LS)',...
         'Callback','lab1=''b-value''; re3 = old; view_bvt(lab1,re3)')
    uimenu(op1,'Label','b(max likelihood) map',...
         'Callback',' lab1=''b-value'';re3 = meg; view_bvt(lab1,re3)')
    uimenu(op1,'Label','a-value map',...
         'Callback',' lab1=''a-value'';re3 = avm; view_bvt(lab1,re3)')
    uimenu(op1,'Label','standard error map',...
         'Callback',' lab1=''error in b'';re3 = stanm; view_bvt(lab1,re3)')
    uimenu(op1,'Label','(WLS-Maxlike) map ',...
         'Callback',' lab1=''difference in b'';re3 = old-meg; view_bvt(lab1,re3)')
    uimenu(op1,'Label','max magnitude map',...
         'Callback',' lab1=''Mmax'';re3 = maxm; view_bvt(lab1,re3)')
    uimenu(op1,'Label','magnitude range map (Mmax - Mcomp)',...
         'Callback',' lab1=''dM '';re3 = maxm-magco; view_bvt(lab1,re3)')

    uimenu(op1,'Label','recurrence time map ',...
         'Callback','def = {''6''};m = inputdlg(''Magnitude of projected mainshock?'',''Input'',1,def);m1 = m{:}; m = str2num(m1);lab1 = ''Tr in yrs. (only smallest values shown)'';re3 =(teb - t0b)./(10.^(avm-m*old)); view_bvt(lab1,re3)')


    uimenu(op1,'Label','probability Map',...
         'Callback','lab1=''Probability''; re3 = pro; view_bvt(lab1,re3)')
    uimenu(op1,'Label','mag of completness map',...
         'Callback','lab1=''Mcomp''; re3 = old1; view_bv2(lab1,re3)')
    uimenu(op1,'Label','resolution Map',...
         'Callback','lab1=''Radius in [km]'';re3 = r; view_bvt(lab1,re3)')
    uimenu(op1,'Label','Histogram ', 'Callback','zhist')

    add_display_menu(3);

    uicontrol('Units','normal',...
        'Position',[.92 .80 .08 .05],'String','set ni',...
         'Callback','ni=str2num(set_nia.String);''String'',num2str(ni);')


    set_nia = uicontrol('style','edit','value',ni,'string',num2str(ni));
    set(set_nia,'Callback',' ');
    set(set_nia,'units','norm','pos',[.94 .85 .06 .05],'min',10,'max',10000);
    nilabel = uicontrol('style','text','units','norm','pos',[.90 .85 .04 .05]);
    set(nilabel,'string','ni:','background',[.7 .7 .7]);

    % tx = text(0.07,0.95,[name],'Units','Norm','FontSize',18,'Color','k','FontWeight','bold');

    tresh = max(max(r)); re4 = re3;
    nilabel2 = uicontrol('style','text','units','norm','pos',[.60 .92 .25 .06]);
    set(nilabel2,'string','MinRad (in km):','background',color_fbg);
    set_ni2 = uicontrol('style','edit','value',tresh,'string',num2str(tresh),...
        'background','y');
    set(set_ni2,'Callback','tresh=str2double(set_ni2.String); set_ni2.String=num2str(tresh))';
    set(set_ni2,'units','norm','pos',[.85 .92 .08 .06],'min',0.01,'max',10000);

    uicontrol('Units','normal',...
        'Position',[.95 .93 .05 .05],'String','Go ',...
         'Callback','think;pause(1);re4 =re3; view_bv2(lab1,re3)')

    colormap(jet)
end   % This is the end of the figure setup

% Now lets plot the color-map of the z-value
%
figure_w_normalized_uicontrolunits(bmapc)
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


% set values greater tresh = nan
%
re4 = re3;
l = r > tresh;
re4(l) = NaN(1,length(find(l)));

%l = re4 > min(bvgr(:,1)) &  re4 < max(bvgr(:,1)) ;
%l = re4 > mean(bvgr(:,1))-2*std(bvgr(:,1)) &  re4 <  mean(bvgr(:,1))+2*std(bvgr(:,1));
%re4(l) = NaN(1,length(find(l)));
%re4(l) = zeros(1,length(find(l)))+ mean(bvgr(:,1));

% plot image
%
orient portrait
set(gcf,'PaperPosition', [2. 1 7.0 5.0])
%col = [hot(64) ; cool(64)];
%col = col(128:-1:1,:);
%load /home/2ken/stefan/after_figs/moslip.mat

hold on
pco1 = pcolor(gx,gy,db12);
axis([ min(gx) max(gx) min(gy) max(gy)])
hold on;  shading flat; axis image

hocm = hot;

hocm(33,:) = [0.4 0.4 0.4];
colormap(hocm)
%brighten(0.7)
caxis([-0.3 0.3])
set(gca,'Color',[1.0 1.0 1.0]  )
set(gca,'visible','on','FontSize',10,...
    'FontWeight','normal','LineWidth',1.5,...
    'Box','on','TickDir','out')
hold on
%  cs =contour(-gxd,gyd,sl/100,[0 0.2 0.4 0.6 0.8  1] ,'k');
%set(gca,'YTick',[ -10 -5 0 ])
%set(gca,'YTickLabels',[10 5 0 ])


% plot overlay
%
ploeqc = plot(newa(:,length(newa(1,:))),-newa(:,7),'.k');
set(ploeqc,'Tag','eqc_plot','MarkerSize',ZG.ms6,'Marker',ty,'Color',co,'Visible',vi)

if exist('vox', 'var')
    plovo = plot(vox,voy,'*b');
    set(plovo,'MarkerSize',6,'LineWidth',1)
end

if exist('maix', 'var')
    pl = plot(maix,maiy,'*k');
    set(pl,'MarkerSize',12,'LineWidth',2)
end

if exist('maex', 'var')
    pl = plot(maex,-maey,'*k');
    set(pl,'MarkerSize',8,'LineWidth',2)
end
%overlay


set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')
h1 = gca;
hzma = gca;

% Create a colorbar
%
h5 = colorbar('horz');
set(h5,'Pos',[0.35 0.05 0.4 0.04],...
    'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s,'TickDir','out')

rect = [0.00,  0.0, 1 1];
axes('position',rect)
axis('off')
%  Text Object Creation
txt1 = text(...
    'Color',[ 0 0 0 ],...
    'EraseMode','normal',...
    'Position',[ 0.33 0.07 0 ],...
    'HorizontalAlignment','right',...
    'Rotation',[ 0 ],...
    'FontSize',ZmapGlobal.Data.fontsz.s,....
    'FontWeight','bold',...
    'String',lab1);

% Make the figure visible
%
axes(h1)
set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')
figure_w_normalized_uicontrolunits(bmapc);
watchoff(bmapc)
done
