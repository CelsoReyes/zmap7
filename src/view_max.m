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

if det == 'pro'
    re3 = old;
    l = re3 < 2.57;
    re3(l) = ones(1,length(find(l)))*2.57;
    pr = 0.0024 + 0.03*(re3 - 2.57).^2;
    pr = (1-1./(exp(pr)));
    re3 = pr;
end   % if det = pro

% Find out of figure already exists
%
[existFlag,figNumber]=figure_exists('Z-Value-Map',1);
newzmapWindowFlag=~existFlag;

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



    uicontrol('Units','normal',...
        'Position',[.0 .93 .08 .06],'String','Print ',...
         'Callback','myprint')

    callbackStr= ...
        ['f1=gcf; f2=gpf; set(f1,''Visible'',''off'');close(zmap);', ...
        'if f1~=f2, figure_w_normalized_uicontrolunits(map);done; end'];

    uicontrol('Units','normal',...
        'Position',[.0 .75 .08 .06],'String','Close ',...
         'Callback','eval(callbackStr)')

    uicontrol('Units','normal',...
        'Position',[.0 .85 .08 .06],'String','Info ',...
         'Callback','zmaphelp(ttlStr,hlpStr1zmap,hlpStr2zmap)')


    options = uimenu('Label',' Select ');
    uimenu(options,'Label','Refresh ', 'Callback','delete(gca);delete(gca);delete(gca);delete(gca); view_max')
    uimenu(options,'Label','Select EQ in Circle', 'Callback','h1 = gca;circle;watchoff(zmap)')
    uimenu(options,'Label','Select EQ in Polygon ', 'Callback',' stri = ''Polygon'';h1 = gca;cufi = gcf;selectp')

    op1 = uimenu('Label',' Tools ');
    uimenu(op1,'Label','ZMAP Menu', 'Callback','zmapmenu ')
    uimenu(op1,'Label','Plot Map in Lambert projection using m_map ', 'Callback','plotmap ')
    uimenu(op1,'Label','Fix color (z) scale', 'Callback','fixax2 ')
    uimenu(op1,'Label','Histogram of z-values', 'Callback','zhist')
    uimenu(op1,'Label','Probability Map', 'Callback','det = ''pro'';fre = 0; view_max')
    uimenu(op1,'Label','Back to z-value Map', 'Callback','det = ''nop''; fre = 0;re3 = old; view_max')
    uimenu(op1,'Label','Colormap InvertGray', 'Callback','g=gray; g = g(64:-1:1,:);colormap(g);brighten(.4)')
    uimenu(op1,'Label','Colormap Invertjet',...
         'Callback','g=jet; g = g(64:-1:1,:);colormap(g)')

    uimenu(op1,'Label','Resolution Map', 'Callback','re3 = r;fre = 0;det = ''res''; view_max')
    uimenu(op1,'Label','Show Grid ',...
         'Callback',' plot(newgri(:,1),newgri(:,2),''+k'')')
    uimenu(op1,'Label','Show Circles ', 'Callback','plotci2')
    uimenu(op1,'Label','shading flat', 'Callback','sha=''fl'';axes(hzma); shading flat')
    uimenu(op1,'Label','shading interpolated',...
         'Callback','sha=''in'';axes(hzma); shading interp')
    uimenu(op1,'Label','Brigten +0.4',...
         'Callback','axes(hzma); brighten(0.4)')
    uimenu(op1,'Label','Brigten -0.4',...
         'Callback','axes(hzma); brighten(-0.4)')

    uimenu(op1,'Label','Redraw Overlay',...
         'Callback','hold on;overlay_')



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
         'Callback','think;pause(1);re4 =re3; view_max')

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
set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
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

% set values gretaer tresh = nan
%
re4 = re3;
[len, ncu] = size(cumuall);
%s = cumuall(len,:);
%
[n1, n2] = size(cumuall);
s = cumuall(n1,:);
normlap2(ll)= s(:);
%construct a matrix for the color plot
r=reshape(normlap2,length(yvect),length(xvect));



%r = reshape(cumuall(len,:),length(gy),length(gx));
l = r > tresh;
re4(l) = zeros(1,length(find(l)))*nan;

% plot image
%
orient landscape
set(gcf,'PaperPosition',[ 0.1 0.1 8 6])
axes('position',rect)
hold on
pco1 = pcolor(gx,gy,re4);
axis([ s2 s1 s4 s3])

if sha == 'fl'
    shading flat
else
    shading interp
end

if fre == 1
    caxis([fix1 fix2])
end

if  in == 'per'
    coma = jet;
    coma = coma(64:-1:1,:);
    colormap(coma)
end
set(gca,'dataaspect',[1 cosd(mean(ZG.a.Latitude)) 1]);

title([name ' (' in '); ' num2str(t0b) ' to ' num2str(teb) ' - cut at ' num2str(it) '; iwl = ' num2str(iwl2) ' yr'],'FontSize',ZmapGlobal.Data.fontsz.m,...
    'Color','k','FontWeight','bold')

xlabel('Longitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
ylabel('Latitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)

% plot overlay
%
overlay
set(ploeq,'MarkerSize',ZG.ms6,'Marker',ty,'Color',co,'visible',vi);

set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')
h1 = gca;
hzma = gca;

% Create a colobar
%
h5 = colorbar('horiz');
set(h5,'Pos',[0.25 0.09 0.5 0.05],'TickDir','out',...
    'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m','YTick',[]')

%  Text Object Creation
txt1 = text(...
    'Color',[ 0 0 0 ],...
    'EraseMode','normal',...
    'Units','normalized',...
    'Position',[ -0.20 -0.2 0 ],...
    'Rotation',[ 0 ],...
    'FontSize',ZmapGlobal.Data.fontsz.m,....
    'FontWeight','bold',...
    'String','z-value:');
if in =='per'
    set(txt1,'String','Change in %')
end
if det =='pro'
    set(txt1,'String','Probability')
end
if det =='res'
    set(txt1,'String','Radius in km')
end

% Make the figure visible
%
set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,'Color','k',...
    'Box','on','TickDir','out')
figure_w_normalized_uicontrolunits(zmap);
%sizmap = signatur('ZMAP','',[0.01 0.04]);
%set(sizmap,'Color','k')
axes(h1)
watchoff(zmap)
done
