% This .m file "vi_cucroz.m" plots the maxz LTA values calculated
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
co = 'k';

if det == 'pro'
    re3 = old;
    l = re3 < 2.57;
    re3(l) = ones(1,length(find(l)))*2.65;
    pr = 0.0024 + 0.03*(re3 - 2.57).^2;
    pr = (1-1./(exp(pr)));
    re3 = pr;
end   % if det = pro

% Find out of figure already exists
%
[existFlag,figNumber]=figure_exists('Z-Value-Cross-section',1);
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
    zmapc = figure_w_normalized_uicontrolunits( ...
        'Name','Z-Value-Cross-section',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','new', ...
        'backingstore','on',...
        'Visible','off', ...
        'Position',[ fipo(3)-600 fipo(4)-400 winx winy]);
    % make menu bar
    matdraw


    symbolmenu = uimenu('Label',' Symbol ');
    SizeMenu = uimenu(symbolmenu,'Label',' Symbol Size ');
    TypeMenu = uimenu(symbolmenu,'Label',' Symbol Type ');
    ColorMenu = uimenu(symbolmenu,'Label',' Symbol Color ');

    uimenu(SizeMenu,'Label','3','Callback','ms6 =3;eval(cal8)');
    uimenu(SizeMenu,'Label','6','Callback','ms6 =6;eval(cal8)');
    uimenu(SizeMenu,'Label','9','Callback','ms6 =9;eval(cal8)');
    uimenu(SizeMenu,'Label','12','Callback','ms6 =12;eval(cal8)');
    uimenu(SizeMenu,'Label','14','Callback','ms6 =14;eval(cal8)');
    uimenu(SizeMenu,'Label','18','Callback','ms6 =18;eval(cal8)');
    uimenu(SizeMenu,'Label','24','Callback','ms6 =24;eval(cal8)');

    uimenu(TypeMenu,'Label','dot','Callback','ty =''.'';eval(cal8)');
    uimenu(TypeMenu,'Label','+','Callback','ty=''+'';eval(cal8)');
    uimenu(TypeMenu,'Label','o','Callback','ty=''o'';eval(cal8)');
    uimenu(TypeMenu,'Label','x','Callback','ty=''x'';eval(cal8)');
    uimenu(TypeMenu,'Label','*','Callback','ty=''*'';eval(cal8)');
    uimenu(TypeMenu,'Label','none','Callback','vi=''off'';set(ploeqc,''visible'',''off''); ');

    uimenu(ColorMenu,'Label','black','Callback','co=''k'';eval(cal8)');
    uimenu(ColorMenu,'Label','white','Callback','co=''w'';eval(cal8)');
    uimenu(ColorMenu,'Label','red','Callback','co=''r'';eval(cal8)');
    uimenu(ColorMenu,'Label','blue','Callback','co=''b'';eval(cal8)');
    uimenu(ColorMenu,'Label','yellow','Callback','co=''y'';eval(cal8)');

    cal8 = ...
        [ 'vi=''on'';set(ploeqc,''MarkerSize'',ms6,''LineStyle'',ty,''Color'',co,''visible'',''on'')'];

    %


    options = uimenu('Label',' Select ');
    uimenu(options,'Label','Refresh ', 'Callback','vi_cucro')
    uimenu(options,'Label','Select EQ in Circle (fixed ni)', 'Callback','h1 = gca;met = ''ni''; cicros2;watchoff(zmapc)');
    uimenu(options,'Label','Select EQ in Circle (fixed radius)', 'Callback','h1 = gca;met = ''ra''; cicros2;watchoff(zmapc)')

    uimenu(options,'Label','Select EQ in Polygon ', 'Callback','polycz ')

    op1 = uimenu('Label',' Tools ');
    uimenu(op1,'Label','ZMAP Menu', 'Callback','menucros ')
    uimenu(op1,'Label','Fix color (z) scale', 'Callback','fixax3 ')
    uimenu(op1,'Label','Histogram of z-values', 'Callback','zhist')
    uimenu(op1,'Label','Probability Map', 'Callback','det = ''pro''; vi_cucro')
    uimenu(op1,'Label','Back to z-value Map', 'Callback','det = ''nop''; re3 = old; vi_cucro')
    uimenu(op1,'Label','Colormap Invertjet',...
         'Callback','g=jet; g = g(64:-1:1,:);colormap(g)')

    uimenu(op1,'Label','Colormap InvertGray', 'Callback','g=gray; g = g(64:-1:1,:);colormap(g);brighten(.4)')
    uimenu(op1,'Label','Resolution Map', 'Callback','re3 = r;det = ''res''; vi_cucro')
    uimenu(op1,'Label','Show Grid ',...
         'Callback',' plot(newgri(:,1),newgri(:,2),''+k'')')
    uimenu(op1,'Label','Show Circles ', 'Callback','plotcirc')
    uimenu(op1,'Label','shading flat', 'Callback','sha=''fl'';axes(hzma); shading flat')
    uimenu(op1,'Label','shading interpolated',...
         'Callback','sha=''in'';axes(hzma); shading interp')
    uimenu(op1,'Label','Brigten +0.4',...
         'Callback','axes(hzma); brighten(0.4)')
    uimenu(op1,'Label','Brigten -0.4',...
         'Callback','axes(hzma); brighten(-0.4)')



    uicontrol('Units','normal',...
        'Position',[.92 .80 .08 .05],'String','set ni',...
         'Callback','ni=str2num(get(set_nia,''String''));''String'',num2str(ni);')


    set_nia = uicontrol('style','edit','value',ni,'string',num2str(ni));
    set(set_nia,'Callback',' ');
    set(set_nia,'units','norm','pos',[.94 .85 .06 .05],'min',10,'max',10000);
    nilabel = uicontrol('style','text','units','norm','pos',[.90 .85 .04 .05]);
    set(nilabel,'string','ni:','background',[.7 .7 .7]);

    % tx = text(0.07,0.95,[name],'Units','Norm','FontSize',18,'Color','k','FontWeight','bold');

    tresh = max(max(r)); re4 = re3;
    nilabel2 = uicontrol('style','text','units','norm','pos',[.60 .92 .25 .06]);
    set(nilabel2,'string','MinRad (in km):','background',[c1 c2 c3]);
    set_ni2 = uicontrol('style','edit','value',tresh,'string',num2str(tresh),...
        'background','y');
    set(set_ni2,'Callback','tresh=str2double(get(set_ni2,''String'')); set(set_ni2,''String'',num2str(tresh))');
    set(set_ni2,'units','norm','pos',[.85 .92 .08 .06],'min',0.01,'max',10000);

    uicontrol('Units','normal',...
        'Position',[.95 .93 .05 .05],'String','Go ',...
         'Callback','think;pause(1);re4 =re3; vi_cucro')
    sha = 'in';
    if term == 1
        colormap(gray)
    else
        colormap(jet)
    end


end   % This is the end of the figure setup

% Now lets plot the color-map of the z-value
%
[existFlag,figNumber]=figure_exists('Z-Value-Cross-section',1);
figure_w_normalized_uicontrolunits(figNumber)
zmapc = figNumber;
delete(gca)
delete(gca)
delete(gca)

watchon;
rect = [0.22  0.20, 0.8, 0.65];
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
[n1, n2] = size(cumuall);
s = cumuall(n1,:);
normlap2(ll)= s(:);
%construct a matrix for the color plot
r=reshape(normlap2,length(yvect),length(xvect));
l = r > tresh;
re4(l) = zeros(1,length(find(l)))*nan;

% plot image
%
orient landscape
axes('position',pos)
hold on
pco1 = pcolor(gx,gy,re4);
hold on

if sha == 'fl'
    shading flat
else
    shading interp
end

axis equal
if fre == 1
    caxis([fix1 fix2])
end
if  in == 'per'
    coma = jet;
    coma = coma(64:-1:1,:);
    colormap(coma)
end

title([name ' (' in '); ' num2str(t0b,6) ' to ' num2str(teb,6) ' - cut at ' num2str(it,6) '; iwl = ' num2str(iwl2) ' yr'],'FontSize',fontsz.s,...
    'Color','k','FontWeight','normal')

ylabel('Depth in  [km]','FontWeight','normal','FontSize',fontsz.s)
xlabel('Distance along projection in [km]','FontWeight','normal','FontSize',fontsz.s)

% plot overlay
%
ploeqc = plot(newa(:,length(newa(1,:))),-newa(:,7),'.k');
set(ploeqc,'MarkerSize',ms6,'Marker',ty,'Color',co,'visible', vi);

if ~exist('maex', 'var'); maex =[];maey = [];end
if ~isempty(maex)
    pl = plot(maex,-maey,'hm');
    %set(pl,'MarkerSize',12,'LineWidth',1)
    set(pl,'LineWidth',1.,'MarkerSize',12,...^M
        'MarkerFaceColor','w','MarkerEdgeColor','k')

end
if ~exist('maix', 'var'); maex =[];maey = [];end
if ~isempty(maix)
    pl = plot(maix,maiy,'*k');
    set(pl,'MarkerSize',10,'LineWidth',2)
end

set(gca,'visible','on','FontSize',fontsz.s,'FontWeight','normal',...
    'FontWeight','normal','LineWidth',1.,...
    'Box','on','TickDir','out','Ticklength',[0.015 0.015])
h1 = gca;
hzma = gca;

% Create a colobar
%
h5 = colorbar('vert');
apo = get(h1,'Position');
set(h5,'Pos',[apo(1)+apo(3)+0.14 apo(2) 0.01 apo(4)-0.05],...
    'FontWeight','normal','FontSize',fontsz.s, 'Box','on','TickDir','out','Ticklength',[0.02 0.02])

%Text Object Creation
txt1 = text(...
    'Color',[ 0 0 0 ],...
    'EraseMode','normal',...
    'Units','normalized',...
    'Position',[ 1.40 0.4 0 ],...
    'Rotation',[ 90 ],...
    'FontSize',fontsz.m,....
    'FontWeight','normal',...
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
set(gcf,'color','w');
figure_w_normalized_uicontrolunits(zmapc);
%sizmap = signatur('ZMAP','',[0.01 0.04]);
%set(sizmap,'Color','k')
axes(h1)
%whitebg(gcf,[ 0 0 0 ]);
watchoff(zmapc)
done
