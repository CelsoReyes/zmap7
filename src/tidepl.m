%  tidpl  plots a time depth plot of the seismicity
%  Stefan Wiemer 5/95
%
report_this_filefun(mfilename('fullpath'));


newcat = a;
xt2  = [ ];
meand = [ ];
er = [];
ind = 0;

% Find out of figure already exists
%
[existFlag,figNumber]=figure_exists('Time Depth',1);
newDepWindowFlag=~existFlag;

% Set up the Seismicity Map window Enviroment
%
if newDepWindowFlag

    figure_w_normalized_uicontrolunits(...
        'Name','Time Depth',...
        'visible','off',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','new', ...
        'Units','Pixel',  'Position',[wex wey 550 400'])
    tifg = gcf;
    hold on
    axis off
    matdraw
    
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
    cal6 = ...
        [ 'set(deplo1,''MarkerSize'',ms6,''LineStyle'',ty1,''visible'',''on'');',...
        'set(deplo2,''MarkerSize'',ms6,''LineStyle'',ty2,''visible'',''on'');',...
        'set(deplo3,''MarkerSize'',ms6,''LineStyle'',ty3,''visible'',''on'');' ];



end  % if figure exist

figure_w_normalized_uicontrolunits(tifg)

delete(gca);delete(gca);delete(gca);
set(gca,'visible','off');

orient tall
rect = [0.15, 0.15, 0.75, 0.65];
axes('position',rect)
p5 = gca;

deplo1 =plot(newt2(newt2(:,7)<=dep1,3),-newt2(newt2(:,7)<=dep1,7),'.b');
set(deplo1,'MarkerSize',ms6,'Marker',ty1,'era','normal')
hold on
deplo2 =plot(newt2(newt2(:,7)<=dep2&newt2(:,7)>dep1,3),-newt2(newt2(:,7)<=dep2&newt2(:,7)>dep1,7),'.g');
set(deplo2,'MarkerSize',ms6,'Marker',ty2,'era','normal');
deplo3 =plot(newt2(newt2(:,7)<=dep3&newt2(:,7)>dep2,3),-newt2(newt2(:,7)<=dep3&newt2(:,7)>dep2,7),'.r');
set(deplo3,'MarkerSize',ms6,'Marker',ty3,'era','normal')

hold on
if isempty(maepi) == 0
    pl =   plot(maepi(:,3),-maepi(:,7),'xm');
    set(pl,'LineWidth',2.0)
end

xlabel('Time in Years ]','FontWeight','bold','FontSize',fontsz.m)
ylabel('Depth in [km] ','FontWeight','bold','FontSize',fontsz.m)

set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',fontsz.m,'Linewidth',1.2)

grid
hold off
done
