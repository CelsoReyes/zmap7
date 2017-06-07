%  This is the .m file "csubcat.m". It plots the eqs of the original catalog
%  related with the loaded cluster. Most routines work similar like in the
%  name map window
%

global newccat mapp decc par1 typele dep1 dep2 dep3 ms6 ty1 ty2 ty3 fontsz
global name term cb1 cb2 cb3 minde maxde maxma2 minma2


report_this_filefun(mfilename('fullpath'));
welcome('Message','Plotting Seismicity Map(Cluster) ....');
org2=original;
%set catalog to the original catalog used at declustering
if isempty(newccat)
    a=original;
    newccat=original;
else
    a=newccat;
end

% For time and magnitude cut window
minma2=min(a(:,6));
maxma2=max(a(:,6));
minde=min(a(:,7));
maxde=max(a(:,7));

% Find out of figure already exists
%
[existFlag,figNumber]=figure_exists('Seismicity Map (Cluster)',1);
newMapWindowFlag=~existFlag;

% Set up the Seismicity Map window Enviroment
%
if newMapWindowFlag
    mapp = figure_w_normalized_uicontrolunits( ...
        'Name','Seismicity Map (Cluster)',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'backingstore','on',...
        'NextPlot','add', ...
        'Visible','off', ...
        'Position',[ fipo(3)-600 fipo(4)-500 winx winy]);

    if term  > 1;   whitebg([c1 c2 c3]); end
    stri1 = [file1];


    %  call supplementary program to make menus at the top of the plot
    matdraw

    %
    % show buttons  for various analyses programs:

    


    % Make the menu to change symbol size and type
    %
    symbolmenu = uimenu('Label',' Symbol ');
    SizeMenu = uimenu(symbolmenu,'Label',' Symbol Size ');
    TypeMenu = uimenu(symbolmenu,'Label',' Symbol Type ');
    uimenu(SizeMenu,'Label','3','Callback','ms6 =3;eval(cal6)');
    uimenu(SizeMenu,'Label','6','Callback','ms6 =6;eval(cal6)');
    uimenu(SizeMenu,'Label','9','Callback','ms6 =9;eval(cal6)');
    uimenu(SizeMenu,'Label','12','Callback','ms6 =12;eval(cal6)');
    uimenu(SizeMenu,'Label','14','Callback','ms6 =14;eval(cal6)');
    uimenu(SizeMenu,'Label','18','Callback','ms6 =18;eval(cal6)');
    uimenu(SizeMenu,'Label','24','Callback','ms6 =24;eval(cal6)');

    uimenu(TypeMenu,'Label','dot',...
        'Callback','ty1=''.'';ty2=''.'';ty3=''.'';eval(cal6)');
    uimenu(TypeMenu,'Label','red+ blue o green x',...
        'Callback','ty1=''+'';ty2=''o'';ty3=''x'';eval(cal6)');
    uimenu(TypeMenu,'Label','o','Callback',...
        'ty1=''o'';ty2=''o'';ty3=''o'';eval(cal6)');
    uimenu(TypeMenu,'Label','x','Callback',...
        'ty1=''x'';ty2=''x'';ty3=''x'';eval(cal6)');
    uimenu(TypeMenu,'Label','*',...
        'Callback','ty1=''*'';ty2=''*'';ty3=''*'';eval(cal6)');
    uimenu(TypeMenu,'Label','none','Callback','set(deplo1,''visible'',''off'');set(deplo2,''visible'',''off'');set(deplo3,''visible'',''off''); ');
    TypeMenu = uimenu(symbolmenu,'Label',' Legend by Time ',...
        'Callback','typele = ''tim'';setleg');
    TypeMenu = uimenu(symbolmenu,'Label',' Legend by Depth ',...
        'Callback','typele = ''dep'';csubcat');

    cal6 = ...
        [ 'set(deplo1,''MarkerSize'',ms6,''LineStyle'',ty1,''visible'',''on'');',...
        'set(deplo2,''MarkerSize'',ms6,''LineStyle'',ty2,''visible'',''on'');',...
        'set(deplo3,''MarkerSize'',ms6,''LineStyle'',ty3,''visible'',''on'');' ];

    cufi = gcf;
    options = uimenu('Label',' Select ');
    uimenu(options,'Label','Cluster Window Values',...
        'Callback','selclus(1);csubcat;');
    uimenu(options,'Label','Expanded Cluster Values ',...
        'Callback','selclus(2);csubcat;');
    uimenu(options,'Label','Select new parameters',...
        'Callback','cpara(1);');
    uimenu(options,'Label','Select EQ in Polygon (Menu) ',...
        'Callback','h1 = gca;newt2 = a; stri = ''Polygon'';decc=0;clkeysel');

    uimenu(options,'Label','Select EQ in Polygon ',...
        'Callback','h1 = gca;stri = ''Polygon'';cufi = gcf;decc=0;clpickp(4)');

    %    uimenu(options,'Label','Select EQ in Circle (Menu) ',...
    %          'Callback','h1 = gca;set(gcf,''Pointer'',''watch''); stri = ['' '']; stri1 = ['' ''];decc=0;incircle');

    op2 = uimenu('Label','Catalog');
    uimenu(op2,'Label','Refresh Window ',...
        'Callback','delete(gca);delete(gca);delete(gca);delete(gca);csubcat');

    uimenu(op2,'Label','Reset Catalog ',...
        'Callback','think;clear plos1 mark1 ; a = original; newccat = original; newt2= original;csubcat');
    uimenu(op2,'label','Declustered catalog',...
         'Callback','newccat=buildcat(2);csubcat');
    catSave =...
        [ 'welcome(''Save Data'',''  '');think;',...
        '[file1,path1] = uigetfile(fullfile(hodi, ''eq_data'', ''*.mat''), ''Earthquake Datafile'');',...
        'if length(file1) > 1 , sapa2 = [''save '' path1 file1 '' a faults main mainfault coastline infstri ''],',...
        'eval(sapa2) ,end, done'];




    op3 = uimenu('Label','Tools');
    uimenu(op3,'Label','Plot Cumulative Number ',...
        'Callback','stri = ''Polygon''; newt2 = a; newcat = a; ctimeplot');

    uimenu(op3,'Label','Create Cross-section ',...
        'Callback','lammap');
    uimenu(op3,'Label','3 D view ',...
        'Callback','plot3d');
    uimenu(op3,'Label','Time Depth Plot ',...
        'Callback',' tidepl');
    uimenu(op3,'Label','Time magnitude Plot ',...
        'Callback',' timmag');
    uimenu(op3,'Label','Decluster the catalog',...
        'Callback','inpude;');
    uimenu(op3,'Label','get coordinates with Cursor',...
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
end
%end;    if figure exist

% show the figure
%
figure_w_normalized_uicontrolunits(mapp)
reset(gca)
cla
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
set(gcf,'PaperPosition',[ 0.1 0.1 8 6])
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

% plot earthquakes (differnt colors for varous depth layers) as
% defined in "startzmap"
%
hold on

%plot earthquakes according to depth
if typele == 'dep'
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
le =legend('+b',ls1,'og',ls2,'xr',ls3);
set(le,'position',[ 0.65 0.02 0.32 0.12])
axis([ s2 s1 s4 s3])
xlabel('Longitude [deg]','FontWeight','bold','FontSize',fontsz.m)
ylabel('Latitude [deg]','FontWeight','bold','FontSize',fontsz.m)
strib = [  ' Map of   '  name '; '  num2str(t0b) ' to ' num2str(teb) ];
title2(strib,'FontWeight','bold',...
    'FontSize',fontsz.m,'Color','k')

%make depth legend
%

h1 = gca;
if term > 1; set(gca,'Color',[cb1 cb2 cb3]); end
set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',fontsz.m,'Linewidth',1.2)
if term > 1;set(le,'Color','w'); end
%axis('image')
%  h1 is the graphic handle to the main figure in window 1
%

%
%  Plots epicenters  and faults
overlay_

% Make the figure visible
%
figure_w_normalized_uicontrolunits(mapp);
if term == 1; whitebg; whitebg;end
%si = signatur('ZMAP','',[0.02 0.04]);
%set(si,'Color','k','FontWeight','bold')
axes(h1);
watchoff(mapp)
set(mapp,'Visible','on');
done
welcome('Message','   ');
