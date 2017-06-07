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
        'backingstore','on',...
        'NextPlot','add', ...
        'Visible','on', ...
        'Position',[ fipo(3)-1000 fipo(4)-700 winx winy]);

    %if term  > 1;   whitebg2([c1 c2 c3]); end
    stri1 = [file1];

    %  call supplementary program to make menus at the top of the plot
    matdraw


    % Make the menu to change symbol size and type
    %
    symbolmenu = uimenu('Label',' --   Overlay ');

    %TODO use add_symbol_menu(...) instead of creating all these menus
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
        'Callback','ty1=''o'';ty2=''.'';ty3=''.'';eval(cal6)');
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
    ovmenu = uimenu(symbolmenu,'Label',' Volcanoes, Plate Boundaries etc.  ');

    TypeMenu = uimenu(ovmenu,'Label','Load/show volcanoes ',...
        'Callback','load volcano.mat; subcata');
    TypeMenu = uimenu(ovmenu,'Label',' Do not show volcanoes ',...
        'Callback','vo = [];subcata');
    TypeMenu = uimenu(ovmenu,'Label','Load/show plate boundaries ',...
        'Callback','load plates.mat ; fa_back = faults; faults = [faults ; plates]; subcata');
    TypeMenu = uimenu(ovmenu,'Label',' Do not show plates/faults boundaries ',...
        'Callback','faults = [];subcata');
    uimenu(ovmenu,'Label',' Load a coastline  from GSHHS database',...
        'Callback','selt = ''in'';  plotmymap;');
    uimenu(ovmenu,'Label','Add coastline/faults from existing *.mat file',...
        'Callback','think;addcoast');
    uimenu(ovmenu,'Label','Plot stations + station names',...
        'Callback','think;plotstations');

    lemenu = uimenu(symbolmenu,'Label',' Legend by ...  ');

    uimenu(lemenu,'Label',' Legend by time ',...
        'Callback','typele = ''tim'';setleg');
    uimenu(lemenu,'Label',' Legend by depth ',...
        'Callback','typele = ''dep'';subcata');
    uimenu(lemenu,'Label',' Legend by magnitude ',...
        'Callback','typele = ''mag'';setlegm');
    uimenu(lemenu,'Label',' Mag by size and depth by color (slow) ',...
        'Callback','typele = ''mad'';subcata');
    uimenu(lemenu,'Label',' Symbol color by faulting type (slow) ',...
        'Callback','typele = ''fau'';subcata');

    fosmenu = uimenu(symbolmenu,'Label',' Change font size ...  ');

    uimenu(fosmenu,'Label',' FontSize +2',...
        'Callback','fontsz=fontsz+2; subcata');
    uimenu(fosmenu,'Label',' FontSize +1',...
        'Callback','fontsz=fontsz+1; subcata');
    TypeMenu = uimenu(fosmenu,'Label',' FontSize -1',...
        'Callback','fontsz=fontsz-1; subcata');
    TypeMenu = uimenu(fosmenu,'Label',' FontSize -2',...
        'Callback','fontsz=fontsz-2; subcata');
    TypeMenu = uimenu(symbolmenu,'Label',' Change background colors ',...
        'Callback','setcol');

    TypeMenu = uimenu(symbolmenu,'Label',' Mark large event with M > ??',...
        'Callback','pl_large');

    uimenu(ColorMenu,'Label','black','Callback','co=''k'';eval(cal6B)');
    uimenu(ColorMenu,'Label','white','Callback','co=''w'';eval(cal6B)');
    uimenu(ColorMenu,'Label','red','Callback','co=''r'';eval(cal6B)');
    uimenu(ColorMenu,'Label','blue','Callback','co=''b'';eval(cal6B)');
    uimenu(ColorMenu,'Label','yellow','Callback','co=''y'';eval(cal6B)');


    cal6 = ...
        [ 'set(deplo1,''MarkerSize'',ms6,''Marker'',ty1,''visible'',''on'',''Color'',''b'');',...
        'set(deplo2,''MarkerSize'',ms6,''Marker'',ty2,''visible'',''on'',''Color'',''g'');',...
        'set(deplo3,''MarkerSize'',ms6,''Marker'',ty3,''visible'',''on'',''Color'',''r'');' ];

    cal6B = ...
        [ 'set(deplo1,''MarkerSize'',ms6,''Marker'',ty1,''Color'',co,''visible'',''on'');',...
        'set(deplo2,''MarkerSize'',ms6,''Marker'',ty2,''Color'',co,''visible'',''on'');',...
        'set(deplo3,''MarkerSize'',ms6,''Marker'',ty3,''Color'',co,''visible'',''on'');' ];


    cufi = gcf;
    options = uimenu('Label',' Select ');
    uimenu(options,'Label','Select EQ in Polygon (Menu) ',...
        'Callback','noh1 = gca;newt2 = a; stri = ''Polygon''; keysel');

    uimenu(options,'Label','Select EQ inside Polygon ',...
        'Callback','h1 = gca;stri = ''Polygon'';cufi = gcf; selectp');

    uimenu(options,'Label','Select EQ outside Polygon ',...
        'Callback','h1 = gca;stri = ''Polygon'';cufi = gcf; selectpo');

    uimenu(options,'Label','Select EQ in Circle (fixed ni)',...
        'Callback',' h1 = gca;set(gcf,''Pointer'',''watch''); stri = [''  '']; stri1 = ['' ''];circle');

    uimenu(options,'Label','Select EQ in Circle (Menu) ',...
        'Callback','h1 = gca;set(gcf,''Pointer'',''watch''); stri = ['' '']; stri1 = ['' '']; incircle');

    op2 = uimenu('Label','Catalog'); %...  fails
    uimenu(op2,'Label','Refresh map window ',...
        'Callback','delete(gca);delete(gca);delete(gca);delete(gca);subcata');

    uimenu(op2,'Label','Open new catalog ',...
        'Callback','think;hold off;startzma');

    uimenu(op2,'Label','Keep this catalog in memory (use reset below to recall)',...
        'Callback','org2 = a; ');

    uimenu(op2,'Label','Reset catalog to the one saved in memory previously',...
        'Callback','think;clear plos1 mark1 ; a = org2; newcat = org2; newt2= org2;subcata');

    uimenu(op2,'Label','Select new parameters (reload last catalog) ',...
        'Callback','think; load(lopa);if max(a(:,3)) < 100; a(:,3) = a(:,3)+1900; end, if length(a(1,:))== 7,a(:,3) = decyear(a(:,3:5));elseif length(a(1,:))>=9,a(:,3) = decyear(a(:,[3:5 8 9]));end;inpu');

    uimenu(op2,'Label','Combine two catalogs ',...
        'Callback','think;comcat');

    uimenu(op2,'Label','Compare two catalogs - find identical events',...
        'Callback','do = ''initial''; comp2cat');


    uimenu(op2,'Label','Save current catalog (ASCII format) ',...
        'Callback','save_ca;');

    uimenu(op2,'Label','Save current catalog (mat format) ',...
        'Callback','eval(catSave);');

    %Syntax change Matlab Version 7, no window positioning on macs
    %{
    % the following is the unrolled version of catSave
    welcome('Save Data', ' ');
    try
    think;
    [file1, path1] = uiputfile(fullfile(hodi, 'eq_data', '*.mat'), 'Earthquake Datafile');
    if length(file1) > 1
        wholePath=[path1 file1]
        save('WholePath', 'a', 'faults','main','mainfault','coastline','infstri','well');
    end
    done
    catch ME
        warning(ME)
    end
    %}
    
    catSave =...
        [ 'welcome(''Save Data'',''  '');think;',...
        '[file1,path1] = uiputfile(fullfile(hodi, ''eq_data'', ''*.mat''), ''Earthquake Datafile'');',...
        'if length(file1) > 1 , wholePath=[path1 file1],sapa2 = [''save('' ''wholePath'' '', ''''a'''', ''''faults'''', ''''main'''', ''''mainfault'''', ''''coastline'''', ''''infstri'''', ''''well'''')''],',...
        'eval(sapa2) ,end, done'];

    %sapa2 = [''save '' path1 file1 '' a faults main mainfault coastline infstri well'']
    seisstr=['global freq_field1 freq_field2 freq_field3 freq_field4 freq_field5 freq_field6 map h1 a ldx Mmin tlap stime dx dy,seisgrid(1);'];

    op3 = uimenu('Label','ZTools');%);

    uimenu(op3,'Label','Analyse time series ... ',...
        'Callback','stri = ''Polygon''; newt2 = a; newcat = a; timeplot');

    op1F   =  uimenu(op3,'Label','Plot topographic map  ');

    uimenu(op1F,'Label','Open DEM GUI',...
        'Callback',' prepinp ');

    uimenu(op1F,'Label','3 arc sec resolution (USGS DEM) ',...
        'Callback','plt = ''lo3'' ; pltopo;');

    uimenu(op1F,'Label','30 arc sec resolution (GLOBE DEM) ',...
        'Callback','plt = ''lo1'' ; pltopo;');

    uimenu(op1F,'Label','30 arc sec resolution (GTOPO30) ',...
        'Callback','plt = ''lo30'' ; pltopo;');

    uimenu(op1F,'Label','2 deg resolution (ETOPO 2) ',...
        'Callback','plt = ''lo2'' ; pltopo;');
    uimenu(op1F,'Label','5 deg resolution (ETOPO 5, Terrain Base) ',...
        'Callback','plt = ''lo5''; pltopo;');
    uimenu(op1F,'Label',' Your topography (mydem, mx, my must be defined)',...
        'Callback','plt = ''yourdem''; pltopo;');
    uimenu(op1F,'Label',' Help on plotting topography',...
        'Callback','plt = ''genhelp''; pltopo;');

   %  op2F   =  uimenu(op3,'Label','Plot map using m_map/Import coastline  ');
   % uimenu(op2F,'Label',' Select a projection ...','Callback','selt = ''in'';  plotmymap;');



  %  uimenu(op2F,'Label',' Help on plotting maps ','Callback','web([''file:///'' which(''plotm_map.htm'')]); ');
  %  uimenu(op2F,'Label',' Information on m_map','Callback','web http://www2.ocgy.ubc.ca/~rich/map.html ');

    % uimenu(op3,'Label','GenAS','Callback','ingenas');

    op4C  =   uimenu(op3,'Label','Random data simulations');
    uimenu(op4C,'label','Create permutated catalog (also new b-value)...', 'Callback',' org2 = a; [a] = syn_invoke_random_dialog(a); newt2 = a;timeplot; subcata; bdiff(a); revertcat');
    uimenu(op4C,'label','Create synthetic catalog...', 'Callback',' org2 = a; [a] = syn_invoke_dialog(a); newt2 = a; timeplot; subcata; bdiff(a); revertcat');

    uimenu(op4C,'Label','Evaluate significance of b- and a-values  ',...
        'Callback','brand');
    uimenu(op4C,'Label','Calculate a random b map and compare to observed data  ',...
        'Callback','brand2');
    uimenu(op4C,'Label','Info on synthetic catalogs ',...
        'Callback','web([''file:'' hodi ''/zmapwww/syntcat.htm''])');

    uimenu(op3,'Label','Create cross-section ',...
        'Callback','nlammap');

    uimenu(op3,'Label','3-D view ',...
        'Callback','plot3d');


    op4B  =   uimenu(op3,'Label','Mapping rate changes');
    uimenu(op4B,'Label','Compare two periods (z, beta, probabilty)',...
        'Callback','sel= ''in'';,comp2periodz')

    uimenu(op4B,'Label','Calculate a z-value map',...
        'Callback','sel= ''in'';,inmakegr')
    uimenu(op4B,'Label','Calculate a z-value cross-section ',...
        'Callback','nlammap');
    uimenu(op4B,'Label','Calculate a 3D  z-value distribution',...
        'Callback','sel = ''in''; zgrid3d');
    uimenu(op4B,'Label','Load a z-value grid (map-view)',...
        'Callback','sel= ''lo'';loadgrid')
    uimenu(op4B,'Label','Load a z-value grid (cross-section-view)',...
        'Callback','sel= ''lo'';magrcros')
    uimenu(op4B,'Label','Load a z-value movie (map-view)',...
        'Callback','loadmovz')

    op3B  =   uimenu(op3,'Label','Mapping a- and b-values');
    uimenu(op3B,'Label','Calculate a Mc, a- and b-value map ',...
        'Callback','sel= ''in'';,bvalgrid')
    uimenu(op3B,'Label','Calculate a differential b-value map (const R)',...
        'Callback','sel= ''in'';,bvalmapt')
    uimenu(op3B,'Label','Calculate a b-value cross-section ',...
        'Callback','nlammap');
    uimenu(op3B,'Label','Calculate a 3D  b-value distribution',...
        'Callback','sel = ''i1''; bgrid3dB');
    uimenu(op3B,'Label','Calculate a b-value depth ratio grid',...
        'Callback','sel= ''in'';,bdepth_ratio')
    uimenu(op3B,'Label','Load a b-value grid (map-view)',...
        'Callback','sel= ''lo'';bvalgrid')
    %RZ
    uimenu(op3B,'Label','Load a differential b-value grid',...
        'Callback','sel= ''lo'';bvalmapt')
    %RZ
    uimenu(op3B,'Label','Load a b-value grid (cross-section-view)',...
        'Callback','sel= ''lo'';bcross')
    uimenu(op3B,'Label','Load a 3D b-value grid ',...
        'Callback','sel= ''no'';ac2 = ''load''; myslicer')
    uimenu(op3B,'Label','Load a b-value depth ratio grid',...
        'Callback','sel= ''lo'';,bdepth_ratio')

    % op3C = uimenu(op3, 'Label', 'Probabilistic forecast test');
    % uimenu(op3C, 'Label', 'Probabilistic forecast test...','Callback','pt_start(a, gcf, 1, coastline, faults, [], name);');
    % uimenu(op3C, 'Label', 'Load probilistic forecast test results...', 'Callback', 'kj_load;');

    % op3D = uimenu(op3, 'label', 'b-cubed');
    % uimenu(op3D, 'label', 'b-cubed map...',  'Callback', 'bc_start(a, gcf, 1, coastline, faults, [], name);');

    op3E  =   uimenu(op3,'Label','Mapping p-values');
    uimenu(op3E,'Label','Calculate p and b-value map ',...
        'Callback','sel= ''in'';,bpvalgrid');
    uimenu(op3E,'Label','Load existing p and b-value map ',...
        'Callback','sel= ''lo'';,bpvalgrid');
    %   uimenu(op3E,'Label','Rate change, p-,c-,k-value map in aftershock sequence (RMS)',...
    %     'Callback','sel= ''in'';,rcvalgrid');
    %   uimenu(op3E,'Label','Load existing  Rate change, p-,c-,k-value map (RMS)',...
    %     'Callback','sel= ''lo'';rcvalgrid');
    uimenu(op3E,'Label','Rate change, p-,c-,k-value map in aftershock sequence (MLE) ',...
        'Callback','sel= ''in'';,rcvalgrid_a2');
    uimenu(op3E,'Label','Load existing  Rate change, p-,c-,k-value map (MLE)',...
        'Callback','sel= ''lo'';rcvalgrid_a2');

    op4D  = uimenu(op3,'Label','Detect quarry contamination');
    uimenu(op4D,'Label','Map day/nighttime ration of events ',...
        'Callback','sel = ''in'';findquar;');
    uimenu(op4D,'Label','Info on detecting quarries. ',...
        'Callback','web([''file:'' hodi ''/help/quarry.htm''])');


    uimenu(op3,'Label','Map stress tensor',...
        'Callback','sel = ''in''; stressgrid');

    op3G = uimenu(op3,'Label','Decluster the catalog');
    uimenu(op3G,'Label','Decluster using Reasenberg',...
        'Callback','inpudenew;');
    uimenu(op3G,'Label','Decluster using Gardner & Knopoff',...
        'Callback','declus_inp;');
    uimenu(op3,'Label','Misfit calculation',...
        'Callback','inmisfit;');
    uimenu(op3,'Label','Get coordinates with Cursor',...
         'Callback','ginput(1)');

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
    uimenu(op5,'Label','Stress tensor quality',...
        'Callback','global histo;hisgra(a(:,13),''Quality '');');
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

if s1 == s2; s2 = s2 +- 0.1 ; s1 = s1 - 0.1; end
if s3 == s4 ; s3 = s3 +0.1; s4 = s4 - 0.1; end
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
if typele == 'mad'
    symbol_magsize
end
if typele == 'fau'
    symbol_faulttype
end


%plot earthquakes according to depth
if typele == 'dep'

    dep1 = 0.3*max(a(:,7));
    dep2 = 0.6*max(a(:,7));
    dep3 = max(a(:,7));
    deplo1 =plot(a(a(:,7)<=dep1,1),a(a(:,7)<=dep1,2),'.b');
    set(deplo1,'MarkerSize',ms6,'Marker',ty1,'era','normal');
    deplo2 =plot(a(a(:,7)<=dep2&a(:,7)>dep1,1),a(a(:,7)<=dep2&a(:,7)>dep1,2),'.g');
    set(deplo2,'MarkerSize',ms6,'Marker',ty2,'era','normal');
    deplo3 =plot(a(a(:,7)<=dep3&a(:,7)>dep2,1),a(a(:,7)<=dep3&a(:,7)>dep2,2),'.r');
    set(deplo3,'MarkerSize',ms6,'Marker',ty3,'era','normal')
    ls1 = sprintf('z<%3.1f km',dep1);
    ls2 = sprintf('z<%3.1f km',dep2);
    ls3 = sprintf('z<%3.1f km',dep3);
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

if typele ~= 'mad'
    le = legend([deplo1 deplo2 deplo3],ls1,ls2,ls3);
    %le =legend('+b',ls1,'og',ls2,'xr',ls3);
    set(le,'position',[ 0.65 0.02 0.32 0.12],'FontSize',12,'color','w')
end

try
    %set(gca,'dataaspect',[1 cos(pi/180*mean(a(:,2))) 1]);
catch

end


set(gca,'FontSize',fontsz.s,'FontWeight','normal',...
    'Ticklength',[0.01 0.01],'LineWidth',1.0,...
    'Box','on','drawmode','normal','TickDir','out')

xlabel('Longitude [deg]','FontSize',fontsz.m)
ylabel('Latitude [deg]','FontSize',fontsz.m)
strib = [  ' Map of '  name '; '  num2str(t0b,5) ' to ' num2str(teb,5) ];
title2(strib,'FontWeight','normal',...
    'FontSize',fontsz.m,'Color','k')

%make depth legend
%

h1 = gca;
if term > 1; set(gca,'Color',[cb1 cb2 cb3]); end

%
%  Plots epicenters  and faults
overlay_
axis([ s2 s1 s4 s3])

% Make the figure visible

%set(gcf,'Color','w');
figure_w_normalized_uicontrolunits(map);
if term == 1; whitebg; whitebg;end

axes('pos',[ 0 0 1 1 ]); axis off
str = [ 'ZMAP ' date ];
text(0.02,0.02,str,'FontWeight','normal','FontSize',12);


%si = signature('ZMAP','',[0.02 0.04]);
%set(si,'Color','k','FontWeight','normal','FontSize',7)
do = 'axes(le) ;'; err = ' '; eval(do,err);
do = 'axes(h1) ;'; err = ' '; eval(do,err);
watchoff(map)
set(map,'Visible','on');
%set(gcf,'Color','w');
done
welcome('Message','   ');
