% This is  the .m file "subcata.m". It plots the earthquake data loaded
%  with "startmagsig" on a map and supplies the user with an
%  interface to do further analyses. This program operates in window 1.
%
%  Depending on the selection it resets newt2, newcat and a

think
report_this_filefun(mfilename('fullpath'));
welcome('Message','Plotting Seismicity Map ....');

% This is the info window text
%
ttlStr='The Map Window                                ';
hlpStr1map= ...
    ['                                                '
    ' This window displays the seismicity in the sel-'
    ' ected catalog. Some of the menu-bar options are'
    ' described below:                               '
    '                                                '
    ' zoom: Selecting Axis -> zoom on allows you to  '
    '       zoom into a region. Click and drag with  '
    '       the left mouse button. type <help zoom>  '
    '       for details.                             '
    'Rubberband zoom:                                '
    ' You can  zoom the current 2D figure            '
    ' by clicking with the LEFT mouse button, then   '
    ' dragging the box until you get the desired area'
    ' If you don t like that zoom, or want to retrace'
    ' your steps, click with the RIGHT mouse         '
    ' button and your previous axis will be restoed  '
    ' Exit zoom:  press <RETURN> in the figure.      '
    '                                                '
    ' Aspect: select one of the aspect ratio options '
    ' Text: You can select text items by clicking.The'
    '       selected text can be rotated, moved, you '
    '       can change the font size etc.            '
    '       Double click on text allows editing it.  '
    '                                                '
    ' You can select earthquakes in a polygon either '
    ' by entering the coordinates or defining the    '
    ' corners with the mouse                         '];
hlpStr2map= ...
    ['                                                '
    ' Select earthquakes in a circular volume:       '
    '      Ni, the number of selected earthquakes can'
    '      be edited in the upper right corner of the'
    '      window.                                   '
    ' Refresh Window: Redraws the figure, erases     '
    '       selected events.                         '
    ' Catalog: This options enables you to           '
    '       reset the selected catalog to the ori-   '
    '       ginal selection (AFTER General selection)'
    ' Select new Parameters: Opens the General       '
    '       Parameter window for a new selection.    '];


hlpStr3map= ...
    ['                                                '
    ' Several tools are activated from here:         '
    ' - Plot the cumulative number                   '
    ' - Start a GenAS analyses                       '
    ' - Make a grid for a                            '
    ' - Mean depth analyses                          '
    ' - Decluster a catalog                          '
    '                                                '
    ' Please refer to the users guide for details    '
    ' about these functions                          '
    '                                                '];



% Find out of figure already exists
%
[existFlag,figNumber]=figure_exists('Seismicity Map',1);
newMapWindowFlag=~existFlag;

% Set up the Seismicity Map window Enviroment
%
if newMapWindowFlag
    map = figure_w_normalized_uicontrolunits( ...
        'Name','Seismicity Map',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'backingstore','on',...
        'NextPlot','add', ...
        'Visible','off', ...
        'Position',[ fipo(3)-600 fipo(4)-500 winx winy]);

    %if term  > 1;   whitebg2([c1 c2 c3]); end
    stri1 = [file1];


    %  call supplementary program to make menus at the top of the plot
    matdraw

    %
    % show buttons  for various analyses programs:

    

    uicontrol('Units','normal',...
        'Position',[.0 .93 .08 .06],'String','Info ',...
         'Callback',' web([''file:'' hodi ''/zmapwww/chap4.htm#996775'']) ');



    %uicontrol('Units','normal',...
    %'Position',[.92 .87 .08 .05],'String','set ni',...
    % 'Callback','ni=str2num(get(set_ni3,''String''));''String'',num2str(ni);')

    %set_ni3 = uicontrol('style','edit','value',ni,...
    %'string',num2str(ni), 'background','y',...
    %'units','norm','pos',[.92 .92 .08 .06],'min',10,'max',10000);

    %nilabel = uicontrol('style','text','units','norm','pos',[.88 .92 .04 .06]);
    %set(nilabel,'string','ni:','background','y');

    % Make the menu to change symbol size and type
    %
    symbolmenu = uimenu('Label',' Symbol ');
    SizeMenu = uimenu(symbolmenu,'Label',' Symbol Size ');
    TypeMenu = uimenu(symbolmenu,'Label',' Symbol Type ');
    ColorMenu = uimenu(symbolmenu,'Label',' Symbol Color ');

    uimenu(SizeMenu,'Label','1','Callback','ms6 =1;eval(cal6)');
    uimenu(SizeMenu,'Label','3','Callback','ms6 =3;eval(cal6)');
    uimenu(SizeMenu,'Label','6','Callback','ms6 =6;eval(cal6)');
    uimenu(SizeMenu,'Label','9','Callback','ms6 =9;eval(cal6)');
    uimenu(SizeMenu,'Label','12','Callback','ms6 =12;eval(cal6)');
    uimenu(SizeMenu,'Label','14','Callback','ms6 =14;eval(cal6)');
    uimenu(SizeMenu,'Label','18','Callback','ms6 =18;eval(cal6)');
    uimenu(SizeMenu,'Label','24','Callback','ms6 =24;eval(cal6)');

    uimenu(TypeMenu,'Label','dot',...
        'Callback','ty1=''.'';ty2=''.'';ty3=''.'';eval(cal6)');
    uimenu(TypeMenu,'Label','o','Callback',...
        'ty1=''o'';ty2=''o'';ty3=''o'';eval(cal6)');
    uimenu(TypeMenu,'Label','x','Callback',...
        'ty1=''x'';ty2=''x'';ty3=''x'';eval(cal6)');
    uimenu(TypeMenu,'Label','*',...
        'Callback','ty1=''*'';ty2=''*'';ty3=''*'';eval(cal6)');
    uimenu(TypeMenu,'Label','red+ blue o green x',...
        'Callback','ty1=''+'';ty2=''o'';ty3=''x'';eval(cal6)');
    uimenu(TypeMenu,'Label','red^  blue h black o',...
        'Callback','ty1=''+'';ty2=''o'';ty3=''x'';eval(cal6)');
    uimenu(TypeMenu,'Label','none','Callback','set(deplo1,''visible'',''off'');set(deplo2,''visible'',''off'');set(deplo3,''visible'',''off''); ');
    TypeMenu = uimenu(symbolmenu,'Label',' Legend by Time ',...
        'Callback','typele = ''tim'';setleg');
    TypeMenu = uimenu(symbolmenu,'Label',' Legend by Depth ',...
        'Callback','typele = ''dep'';subcata');
    TypeMenu = uimenu(symbolmenu,'Label',' Legend by Magnitude ',...
        'Callback','typele = ''mag'';setlegm');
    TypeMenu = uimenu(symbolmenu,'Label',' Do not show volcanoes ',...
        'Callback','vo = [];subcata');
    TypeMenu = uimenu(symbolmenu,'Label',' Change Background Colors ',...
        'Callback','setcol');
    TypeMenu = uimenu(symbolmenu,'Label',' FontSize +2',...
        'Callback','fontsz=fontsz+2; subcata');
    TypeMenu = uimenu(symbolmenu,'Label',' FontSize -2',...
        'Callback','fontsz=fontsz-2; subcata');
    TypeMenu = uimenu(symbolmenu,'Label',' Mark large event with M > ??',...
        'Callback','pl_large');

    uimenu(ColorMenu,'Label','black','Callback','co=''k'';eval(cal6B)');
    uimenu(ColorMenu,'Label','white','Callback','co=''w'';eval(cal6B)');
    uimenu(ColorMenu,'Label','red','Callback','co=''r'';eval(cal6B)');
    uimenu(ColorMenu,'Label','blue','Callback','co=''b'';eval(cal6B)');
    uimenu(ColorMenu,'Label','yellow','Callback','co=''y'';eval(cal6B)');


    cal6 = ...
        [ 'set(deplo1,''MarkerSize'',ms6,''LineStyle'',ty1,''visible'',''on'',''Color'',''b'');',...
        'set(deplo2,''MarkerSize'',ms6,''LineStyle'',ty2,''visible'',''on'',''Color'',''g'');',...
        'set(deplo3,''MarkerSize'',ms6,''LineStyle'',ty3,''visible'',''on'',''Color'',''r'');' ];

    cal6B = ...
        [ 'set(deplo1,''MarkerSize'',ms6,''LineStyle'',ty1,''Color'',co,''visible'',''on'');',...
        'set(deplo2,''MarkerSize'',ms6,''LineStyle'',ty2,''Color'',co,''visible'',''on'');',...
        'set(deplo3,''MarkerSize'',ms6,''LineStyle'',ty3,''Color'',co,''visible'',''on'');' ];


    cufi = gcf;
    options = uimenu('Label',' Select ');
    uimenu(options,'Label','Select EQ in Polygon (Menu) ',...
        'Callback','h1 = gca;newt2 = a; stri = ''Polygon''; keysel');

    uimenu(options,'Label','Select EQ inside Polygon ',...
        'Callback','h1 = gca;stri = ''Polygon'';cufi = gcf; selectp');

    uimenu(options,'Label','Select EQ outside Polygon ',...
        'Callback','h1 = gca;stri = ''Polygon'';cufi = gcf; selectpo');

    uimenu(options,'Label','Select EQ in Circle (fixed ni)',...
        'Callback',' h1 = gca;set(gcf,''Pointer'',''watch''); stri = [''  '']; stri1 = ['' ''];circle');

    uimenu(options,'Label','Select EQ in Circle (Menu) ',...
        'Callback','h1 = gca;set(gcf,''Pointer'',''watch''); stri = ['' '']; stri1 = ['' '']; incircle');

    op2 = uimenu('Label','Catalog');
    uimenu(op2,'Label','Refresh Window ',...
        'Callback','delete(gca);delete(gca);delete(gca);delete(gca);subcata');

    uimenu(op2,'Label','Keep this catalog in memory ',...
        'Callback','org2 = a; ');

    uimenu(op2,'Label','Reset Catalog ',...
        'Callback','think;clear plos1 mark1 ; a = org2; newcat = org2; newt2= org2;subcata');
    ;
    uimenu(op2,'Label','Open new catalog ',...
        'Callback','think;hold off;startzma');

    uimenu(op2,'Label','Select new Parameters  ',...
        'Callback','think; load(lopa);if length(a(1,:))== 7,a(:,3) = decyear(a(:,3:5));elseif length(a(1,:))>=9,a(:,3) = decyear(a(:,[3:5 8 9]));end;inpu');

    uimenu(op2,'Label','Combine two catalogs ',...
        'Callback','think;comcat');

    uimenu(op2,'Label','Add coastline/faults fom existing *.mat file',...
        'Callback','think;addcoast');

    uimenu(op2,'Label','Save selected Catalog (ASCII) ',...
        'Callback','save_ca;');

    uimenu(op2,'Label','Save selected Catalog (mat) ',...
        'Callback','eval(catSave);');


    catSave =...
        [ 'welcome(''Save Data'',''  '');think;',...
        '[file1,path1] = uiputfile(fullfile(hodi, ''eq_data'', ''*.mat''), ''Earthquake Datafile'');',...
        'if length(file1) > 1 , sapa2 = [''save '' path1 file1 '' a faults main mainfault coastline infstri ''],',...
        'eval(sapa2) ,end, done'];


    seisstr=['global freq_field1 freq_field2 freq_field3 freq_field4 freq_field5 freq_field6 map h1 a ldx Mmin tlap stime dx dy,seisgrid(1);'];

    op3 = uimenu('Label','Tools');

    uimenu(op3,'Label','Plot Cumulative Number ',...
        'Callback','stri = ''Polygon''; newt2 = a; newcat = a; timeplot');

    op1F   =  uimenu(op3,'Label','Plot Topographic Map  ');
    uimenu(op1F,'Label','2 deg resolution (ETOPO 2) ',...
        'Callback','plt = ''lo2'' ; pltopo;');
    uimenu(op1F,'Label','5 deg resolution (ETOPO 5, Terrain Base) ',...
        'Callback','plt = ''lo5''; pltopo;');
    uimenu(op1F,'Label',' Your Topography (mydem, mx, my must be defined)',...
        'Callback','plt = ''yourdem''; pltopo;');
    uimenu(op1F,'Label',' Help on plotting Topography',...
        'Callback','plt = ''genhelp''; pltopo;');

    op2F   =  uimenu(op3,'Label','Plot  Map using m_map  ');
    uimenu(op2F,'Label','Lambert Projection - low resolution ',...
        'Callback','res = ''c'';  plotmymap;');
    uimenu(op2F,'Label','Lambert Projection - intermediate resolution (slow!)',...
        'Callback','res = ''i'';  plotmymap;');



    uimenu(op3,'Label','Run GenAS',...
        'Callback','ingenas');

    op4C  =   uimenu(op3,'Label','Monte Carlo ');
    uimenu(op4C,'Label','evaluate random z(windowlength) distribution  ',...
        'Callback','zrand4');
    uimenu(op4C,'Label','evaluate random z distribution (one windowlength) ',...
        'Callback','zrand3');
    uimenu(op4C,'Label','evaluate random z dist. (repeat maximum ) ',...
        'Callback','zramax3');
    uimenu(op4C,'Label','evaluate synthetic random z dist. (repeat maximum ) ',...
        'Callback','znormra');
    uimenu(op4C,'Label','evaluate random b distribution  ',...
        'Callback','brand');
    uimenu(op4C,'Label','Info on synthetic catalogs ',...
        'Callback','web([''file:'' hodi ''/zmapwww/syntcat.htm#996747''])');

    uimenu(op3,'Label','Create Cross-section ',...
        'Callback','nlammap');
    uimenu(op3,'Label','3-D view ',...
        'Callback','plot3d');


    op3C  =   uimenu(op3,'Label','Time Series ');
    uimenu(op3C,'Label','Mean Depth ',...
        'Callback','ic = 0; meandpth');
    uimenu(op3C,'Label','Time Depth Plot ',...
        'Callback',' newt2 = a;tidepl');
    uimenu(op3C,'Label','Time magnitude Plot ',...
        'Callback',' newt2 = a;timmag');

    uimenu(op3,'Label','Summary Plot ',...
        'Callback',' sumplot2');

    op4B  =   uimenu(op3,'Label','Mapping z-values');
    uimenu(op4B,'Label','Calculate a z-value Map',...
        'Callback','sel= ''in'';,inmakegr')
    uimenu(op4B,'Label','Calculate a z-value Cross-section ',...
        'Callback','nlammap');
    uimenu(op4B,'Label','Calculate a 3D  z-value distribution',...
        'Callback','sel = ''in''; zgrid3d');
    uimenu(op4B,'Label','Load a z-value grid (Map-view)',...
        'Callback','sel= ''lo'';loadgrid')
    uimenu(op4B,'Label','Load a z-value grid (Cross-section-view)',...
        'Callback','sel= ''lo'';magrcros')
    uimenu(op4B,'Label','Load a z-value Movie (Map-view)',...
        'Callback','loadmovz')

    op3B  =   uimenu(op3,'Label','Mapping b-values');
    uimenu(op3B,'Label','Calculate a b-value Map (const N)',...
        'Callback','sel= ''in'';,bvalgrid')
    uimenu(op3B,'Label','Calculate a b-value Map (const R)',...
        'Callback','sel= ''in'';,bvalgridr')
    uimenu(op3B,'Label','Calculate a b-value Cross-section ',...
        'Callback','nlammap');
    uimenu(op3B,'Label','Calculate a 3D  b-value distribution',...
        'Callback','sel = ''in''; bgrid3d');
    uimenu(op3B,'Label','Load a b-value grid (Map-view)',...
        'Callback','sel= ''lo'';bvalgrid')
    uimenu(op3B,'Label','Load a b-value grid (Cross-section-view)',...
        'Callback','sel= ''lo'';bcross')


    uimenu(op3,'Label','Decluster the catalog',...
        'Callback','inpude;');
    uimenu(op3,'Label','Misfit Calculation',...
        'Callback','inmisfit;');
    uimenu(op3,'Label','get coordinates with Cursor',...
         'Callback','ginput(1)');
    uimenu(op3,'Label','Zmapmenu',...
        'Callback','zmapmenu;');

    op4C  = uimenu(op3,'Label','SEISMOLAP');
    uimenu(op4C,'Label','News on  Seismo Lap ',...
        'Callback','help_lap ;');

    %op4C  = uimenu(op3,'Label','SEISMOLAP');
    %uimenu(op4C,'Label','Intro to Seismo Lap ',...
    %uimenu(op4C,'Label','Seismo Lap - one point',...
    %'Callback','quie=1;inlap;');
    %uimenu(op4C,'Label','Seismo Lap - Grid',...
    %'Callback','var1=1;probgrid;');
    %uimenu(op4C,'Label','Load existing grid ',...
    %'Callback','loadlagr;');
    %uimenu(op4C,'Label','Load existing movie ',...
    %'Callback','loadmovi;');


    %calculate several histogramms
    stt1='Magnitude ';stt2='Depth ';stt3='Duration ';st4='Foreshock Duration ';
    st5='Foreshock Percent ';

    op5 = uimenu(op3,'Label','Histograms');

    uimenu(op5,'Label','Magnitude',...
        'Callback','global histo;hisgra(a(:,6),stt1);');
    uimenu(op5,'Label','Depth',...
        'Callback','global histo;hisgra(a(:,7),stt2);');
    uimenu(op5,'Label','Time',...
        'Callback','global histo;hisgra(a(:,3),''Time '');');
    uimenu(op5,'Label','Hr of the day',...
        'Callback','global histo;hisgra(a(:,8),''Hr '');');
end
%end;    if figure exist

% show the figure
%
figure_w_normalized_uicontrolunits(map)
%reset(gca)
%cla
delete(gca),delete(gca),delete(gca);delete(gca);
delete(gca),delete(gca),delete(gca);delete(gca);
dele = 'delete(si),delete(le)';er = 'disp('' '')'; eval(dele,er);
watchon;
set(gca,'visible','off','SortMethod','childorder')
hold off

%set(set_ni3,'String',num2str(ni));
% find min and Maximum axes points
s1 = max(a(:,1));
s2 = min(a(:,1));
s3 = max(a(:,2));
s4 = min(a(:,2));
%ni = 100;
orient landscape
set(gcf,'PaperPosition',[ 1.0 1.0 8 6])
rect = [0.15,  0.20, 0.75, 0.65];
axes('position',rect)
%
% find start and end time of catalogue "a"
%
t0b = a(1,3);
n = length(a(:,1));
teb = a(n,3) ;
tdiff =round(teb - t0b)*365/par1;


n = length(a);

% plot earthquakes (different symbols for various parameters) as
% defined in "startzmap"
%
hold on

%plot earthquakes according to magnitude
if typele == 'mag'
    deplo1=plot(a(a(:,6)>=dep1&a(:,6)<dep2,1),a(a(:,6)>=dep1&a(:,6)<dep2,2),'ob');
    % set(deplo1,'MarkerSize',ms6,'Marker',ty1,'era','normal')
    set(deplo1,'MarkerSize',ms6,'era','normal')
    deplo2=plot(a(a(:,6)>=dep2&a(:,6)<dep3,1),a(a(:,6)>=dep2&a(:,6)<dep3,2),'ob');
    % set(deplo2,'MarkerSize',ms6*2,'Marker',ty2,'era','normal');
    set(deplo2,'MarkerSize',ms6*2,'era','normal');
    deplo3 =plot(a(a(:,6)>=dep3,1),a(a(:,6)>=dep3,2),'ob');
    % set(deplo3,'MarkerSize',ms6*3,'Marker',ty3,'era','normal')
    set(deplo3,'MarkerSize',ms6*3,'era','normal')

    ls1 = sprintf('M > %3.1f ',dep1);
    ls2 = sprintf('M > %3.1f ',dep2);
    ls3 = sprintf('M > %3.1f ',dep3);
end

%plot earthquakes according to depth
if typele == 'dep'

    dep1 = 0.3*max(a(:,7));
    dep2 = 0.6*max(a(:,7));
    dep3 = max(a(:,7));
    deplo1 =plot(a(a(:,7)<=dep1,1),a(a(:,7)<=dep1,2),'.b');
    set(deplo1,'MarkerSize',ms6,'Marker',ty1,'era','normal')
    deplo2 =plot(a(a(:,7)<=dep2&a(:,7)>dep1,1),a(a(:,7)<=dep2&a(:,7)>dep1,2),'.g');
    set(deplo2,'MarkerSize',ms6,'Marker',ty2,'era','normal');
    deplo3 =plot(a(a(:,7)<=dep3&a(:,7)>dep2,1),a(a(:,7)<=dep3&a(:,7)>dep2,2),'.r');
    set(deplo3,'MarkerSize',ms6,'Marker',ty3,'era','normal')
    ls1 = sprintf('Depth < %3.1f km',dep1);
    ls2 = sprintf('Depth < %3.1f km',dep2);
    ls3 = sprintf('Depth < %3.1f km',dep3);
end

%plot earthquakes according time
if typele == 'tim'
    deplo1 =plot(a(a(:,3)<=tim2&a(:,3)>=tim1,1),a(a(:,3)<=tim2&a(:,3)>=tim1,2),'.b');
    set(deplo1,'MarkerSize',ms6,'Marker',ty1,'era','normal')
    deplo2 =plot(a(a(:,3)<=tim3&a(:,3)>tim2,1),a(a(:,3)<=tim3&a(:,3)>tim2,2),'.g');
    set(deplo2,'MarkerSize',ms6,'Marker',ty2);
    deplo3 =plot(a(a(:,3)<=tim4&a(:,3)>tim3,1),a(a(:,3)<=tim4&a(:,3)>tim3,2),'.r');
    set(deplo3,'MarkerSize',ms6,'Marker',ty3)

    ls1 = sprintf('%3.1f < t < %3.1f ',tim1,tim2);
    ls2 = sprintf('%3.1f < t < %3.1f ',tim2,tim3);
    ls3 = sprintf('%3.1f < t < %3.1f ',tim3,tim4);


end
le = legend([deplo1 deplo2 deplo3],ls1,ls2,ls3);
%le =legend('+b',ls1,'og',ls2,'xr',ls3);
set(le,'position',[ 0.65 0.02 0.32 0.12])
axis image

set(gca,'FontSize',fontsz.m,'FontWeight','normal',...
    'FontWeight','bold','LineWidth',3.0,...
    'Box','on','SortMethod','childorder','TickDir','out')

xlabel('Longitude [deg]','FontWeight','bold','FontSize',fontsz.m)
ylabel('Latitude [deg]','FontWeight','bold','FontSize',fontsz.m)
strib = [  ' Map of   '  name '; '  num2str(t0b,5) ' to ' num2str(teb,5) ];
title2(strib,'FontWeight','bold',...
    'FontSize',fontsz.m,'Color','k')

%make depth legend
%

h1 = gca;
if term > 1; set(gca,'Color',[cb1 cb2 cb3]); end

%if term > 1;set(le,'Color','w'); end
%axis('image')
%  h1 is the graphic handle to the main figure in window 1
%

%
%  Plots epicenters  and faults
overlay_

% Make the figure visible
%
figure_w_normalized_uicontrolunits(map);
if term == 1; whitebg; whitebg;end
%si = signatur('ZMAP','',[0.02 0.04]);
%set(si,'Color','k','FontWeight','normal')
axes(h1);
watchoff(map)
set(map,'Visible','on');
done
welcome('Message','   ');
