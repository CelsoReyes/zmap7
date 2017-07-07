% This .m file plots the differential b values calculated
% with bvalmapt.m or other similar values as a color map
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
[existFlag,figNumber]=figure_exists('differential b-value-map',1);
newbmapWindowFlag=~existFlag;


% Set up the Seismicity Map window Enviroment
%
if newbmapWindowFlag
    bmap = figure_w_normalized_uicontrolunits( ...
        'Name','differential b-value-map',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','new', ...
        'backingstore','on',...
        'Visible','off', ...
        'Position',[ (fipo(3:4) - [600 400]) ZmapGlobal.Data.map_len]);
    % make menu bar
    matdraw

    lab1 = 'Db';

    add_symbol_menu('eq_plot');

    uicontrol('Units','normal',...
        'Position',[.0 .93 .08 .06],'String','Info ',...
         'Callback',' web([''file:'' hodi ''/zmapwww/chp11.htm#996756'']) ');



    options = uimenu('Label',' Select ');
    uimenu(options,'Label','Refresh ', 'Callback','view_bvtmap')
    uimenu(options,'Label','Select EQ in Circle',...
         'Callback','h1 = gca;met = ''ni''; ZG=ZmapGlobal.Data; ZG.hold_state=false;cirbva;watchoff(bmap)')
    uimenu(options,'Label','Select EQ in Circle - Constant R',...
         'Callback','h1 = gca;met = ''ra''; ZG=ZmapGlobal.Data; ZG.hold_state=false;cirbva;watchoff(bmap)')
    uimenu(options,'Label','Select EQ in Circle - Time split',...
         'Callback','h1 = gca;met = ''ti''; ZG=ZmapGlobal.Data; ZG.hold_state=false;cirbvat;watchoff(bmap)')
    uimenu(options,'Label','Select EQ in Circle - Overlay existing plot',...
         'Callback','h1 = gca;ZG=ZmapGlobal.Data; ZG.hold_state=true;cirbva;watchoff(bmap)')

    uimenu(options,'Label','Select EQ in Polygon -new ',...
         'Callback','cufi = gcf;ZG=ZmapGlobal.Data; ZG.hold_state=false;selectp')
    uimenu(options,'Label','Select EQ in Polygon - hold ',...
         'Callback','cufi = gcf;ZG=ZmapGlobal.Data; ZG.hold_state=true;selectp')


    op1 = uimenu('Label',' Maps ');
    uimenu(op1,'Label','Differential b-value map ',...
         'Callback','lab1 =''b-value''; re3 = db12; view_bvtmap')
    uimenu(op1,'Label','b change in percent map  ',...
         'Callback','lab1 =''b-value change''; re3 = dbperc; view_bvtmap')
    uimenu(op1,'Label','b-value map first period',...
         'Callback','lab1 =''b-value''; re3 = bm1; view_bvtmap')
    uimenu(op1,'Label','b-value map second period',...
         'Callback','lab1 =''b-value''; re3 = bm2; view_bvtmap')
    uimenu(op1,'Label','Probability Map (Utsus test for b1 and b2) ',...
         'Callback','lab1 =''P''; re3 = pro; view_bvtmap')
    uimenu(op1,'Label','Earthquake probability change map (M5) ',...
         'Callback','lab1 =''dP''; re3 = log10(maxm); view_bvtmap')
    uimenu(op1,'Label','standard error map',...
         'Callback',' lab1=''error in b'';re3 = stanm; view_bvtmap')

    uimenu(op1,'Label','mag of completeness map - period 1',...
         'Callback','lab1 = ''Mcomp1''; re3 = magco1; view_bvtmap')
    uimenu(op1,'Label','mag of completeness map - period 2',...
         'Callback','lab1 = ''Mcomp2''; re3 = magco2; view_bvtmap')
    uimenu(op1,'Label','differential completeness map ',...
         'Callback','lab1 = ''DMc''; re3 = dmag; view_bvtmap')
    uimenu(op1,'Label','resolution Map - number of events ',...
         'Callback','lab1=''# of events'';re3 = r; view_bvtmap')
    uimenu(op1,'Label','Histogram ', 'Callback','zhist')

    add_display_menu(1)


    tresh = nan; re4 = re3;
    nilabel2 = uicontrol('style','text','units','norm','pos',[.60 .92 .25 .04],'backgroundcolor','w');
    set(nilabel2,'string','Min Probability:');
    set_ni2 = uicontrol('style','edit','value',tresh,'string',num2str(tresh),...
        'background','y');
    set(set_ni2,'Callback','tresh=str2double(get(set_ni2,''String'')); set(set_ni2,''String'',num2str(tresh))');
    set(set_ni2,'units','norm','pos',[.85 .92 .08 .04],'min',0.01,'max',10000);

    uicontrol('Units','normal',...
        'Position',[.95 .93 .05 .05],'String','Go ',...
         'Callback','think;pause(1);re4 =re3; view_bvtmap')

    colormap(jet)

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
set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','normal',...
    'LineWidth',1.,...
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
l = pro < tresh;
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
    'Color','k','FontWeight','normal')

xlabel('Longitude [deg]','FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s)
ylabel('Latitude [deg]','FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s)

% plot overlay
%
hold on
overlay_
ploeq = plot(a.Longitude,a.Latitude,'k.');
set(ploeq,'Tag','eq_plot','MarkerSize',ms6,'Marker',ty,'Color',co,'Visible',vi)



set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','normal',...
    'LineWidth',1.,...
    'Box','on','TickDir','out')
h1 = gca;
hzma = gca;

% Create a colorbar
%
h5 = colorbar('horiz');
set(h5,'Pos',[0.35 0.05 0.4 0.02],...
    'TickDir','out','FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s)

rect = [0.00,  0.0, 1 1];
axes('position',rect)
axis('off')
%  Text Object Creation
txt1 = text(...
    'Color',[ 0 0 0 ],...
    'EraseMode','normal',...
    'Units','normalized',...
    'Position',[ 0.33 0.07 0 ],...
    'HorizontalAlignment','right',...
    'Rotation',[ 0 ],...
    'FontSize',ZmapGlobal.Data.fontsz.s,....
    'FontWeight','normal',...
    'String',lab1);

%RZ make  reset button
%    uicontrol('Units','normal','Position',...
%  [.85 .10 .15 .05],'String','Reset Catalog', 'Callback','think;clear plos1 mark1 conca ; a=storedcat; newcat=storedcat; newt2=storedcat; stri = ['' '']; stri1 = ['' '']');

%resets catalog  (useful for the random b map)
%clear plos1 mark1 conca ; a=storedcat; newcat=storedcat; newt2=storedcat; stri = ['' '']; stri1 = ['' ''];

% Make the figure visible
%
set(gca,'FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','normal',...
    'FontWeight','normal','LineWidth',1.,...
    'Box','on','TickDir','out','Ticklength',[0.02 0.02])
figure_w_normalized_uicontrolunits(bmap);
%sizmap = signatur('ZMAP','',[0.01 0.04]);
%set(sizmap,'Color','k')
axes(h1)
watchoff(bmap)
%whitebg(gcf,[ 0 0 0 ])
set(gcf,'Color','w')
done
