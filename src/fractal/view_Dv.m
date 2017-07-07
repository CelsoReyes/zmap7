% This .m file "view_x
% maxz.m" plots the maxz LTA values calculated
% with maxzlta.m or other similar values as a color map
% needs re3, gx, gy, stri
% Called from Dcross.m
%
% define size of the plot etc.
%
if isempty(name) >  0
    name = '  '
end
think
report_this_filefun(mfilename('fullpath'));
co = 'w';


% Find out of figure already exists
%
[existFlag,figNumber]=figure_exists('D-value cross-section',1);
newbmapcWindowFlag=~existFlag;



% Set up the Seismicity Map window Enviroment
%
if newbmapcWindowFlag
    bmapc = figure_w_normalized_uicontrolunits( ...
        'Name','D-value cross-section',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'backingstore','on',...
        'Visible','off', ...
        'Position',[ (fipo(3:4) - [600 400]) ZmapGlobal.Data.map_len]);
    % make menu bar
    matdraw
    lab1 = 'D-value';
    add_symbol_menu('eqc_plot');

    uicontrol('Units','normal',...
        'Position',[.0 .95 .08 .06],'String','Info ',...
         'Callback','zmaphelp(ttlStr,hlpStr1zmap,hlpStr2zmap)')



    options = uimenu('Label',' Select ');
    uimenu(options,'Label','Refresh ', 'Callback','view_Dv')

    uimenu(options,'Label','Select EQ in Sphere (const N)',...
         'Callback',' h1 = gca;ZG=ZmapGlobal.Data;ZG.hold_state=false;ic = 1; org = [5]; startfd;')
    uimenu(options,'Label','Select EQ in Sphere (const R)',...
         'Callback',' h1 = gca;ZG=ZmapGlobal.Data;ZG.hold_state=false;icCircl = 2; org = [5]; startfd;')
    uimenu(options,'Label','Select EQ in Sphere (N) - Overlay existing plot',...
         'Callback','h1 = gca;ZG=ZmapGlobal.Data;ZG.hold_state=true;ic = 1; org = [5]; startfd;')
    %
    %

    op1 = uimenu('Label',' Maps ');

    uimenu(op1,'Label','D-value Map (weighted LS)',...
         'Callback','lab1=''D-value''; re3 = old; view_Dv');

    %  uimenu(op1,'Label','Goodness of fit  map',...
    %      'Callback','lab1=''%''; re3 = Prmap; view_Dv');

    uimenu(op1,'Label','b-value Map',...
         'Callback','lab1=''b-value'';re3 = BM; view_Dv');

    uimenu(op1,'Label','resolution Map',...
         'Callback','lab1=''Radius in [km]'';re3 = reso; view_Dv');

    uimenu(op1,'Label','Histogram ', 'Callback','zhist');

    uimenu(op1,'Label','D versus b',...
         'Callback','Dvbspat;');

    uimenu(op1,'Label','D versus Resolution',...
         'Callback','Dvresfig;')
    %
    %

    add_display_menu(3);

    %  uicontrol('Units','normal',...
    %      'Position',[.92 .80 .08 .05],'String','set ni',...
    %       'Callback','ni=str2num(get(set_nia,''String''));''String'',num2str(ni);')


    %  set_nia = uicontrol('style','edit','value',ni,'string',num2str(ni));
    %  set(set_nia,'Callback',' ');
    %  set(set_nia,'units','norm','pos',[.94 .85 .06 .05],'min',10,'max',10000);
    %  nilabel = uicontrol('style','text','units','norm','pos',[.90 .85 .04 .05]);
    %  set(nilabel,'string','ni:','background',[.7 .7 .7]);

    % tx = text(0.07,0.95,[name],'Units','Norm','FontSize',18,'Color','k','FontWeight','bold');

    % tresh = max(max(r)); re4 = re3;
    % nilabel2 = uicontrol('style','text','units','norm','pos',[.60 .92 .25 .06]);
    % set(nilabel2,'string','MinRad (in km):','background',color_fbg);
    % set_ni2 = uicontrol('style','edit','value',tresh,'string',num2str(tresh),...
    %     'background','y');
    % set(set_ni2,'Callback','tresh=str2double(get(set_ni2,''String'')); set(set_ni2,''String'',num2str(tresh))');
    % set(set_ni2,'units','norm','pos',[.85 .92 .08 .06],'min',0.01,'max',10000);

    %  uicontrol('Units','normal',...
    %      'Position',[.95 .93 .05 .05],'String','Go ',...
    %       'Callback','think;pause(1);re4 =re3; view_Dv')

    colormap(jet)
end   % This is the end of the figure setup

% Now lets plot the color-map of the D-value
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
set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.,...
    'Box','on','SortMethod','childorder')

rect = [0.10,  0.10, 0.8, 0.75];
rect1 = rect;

% set values greater tresh = nan
%
re4 = re3;
l = r > tresh;
re4(l) = zeros(1,length(find(l)))*nan;

% plot image
%
orient portrait
%set(gcf,'PaperPosition', [2. 1 7.0 5.0])

axes('position',rect)
hold on
% Here is the importnnt  line ...
pco1 = pcolor(gx,gy,re4);

axis([ min(gx) max(gx) min(gy) max(gy)])
axis image
hold on;

if sha == 'fl'
    shading flat
else
    shading interp
end

%end


if fre == 1
    caxis([fix1 fix2])
end

title2([name],'FontSize',12,...
    'Color','w','FontWeight','bold')
%num2str(t0b,4) ' to ' num2str(teb,4)
xlabel('Distance in [km]','FontWeight','bold','FontSize',12)
ylabel('Depth in [km]','FontWeight','bold','FontSize',12)

% plot overlay
%
ploeqc = plot(Da(:,1),-Da(:,7),'.k');
set(ploeq,'Tag','eqc_plot''MarkerSize',ms6,'Marker',ty,'Color',co,'Visible',vi)


set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')
h1 = gca;
hzma = gca;

% Create a colorbar
%
h5 = colorbar('horz');
apo = get(h1,'pos');
set(h5,'Pos',[0.3 0.1 0.4 0.02],...
    'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m,'TickDir','out')

rect = [0.00,  0.0, 1 1];
axes('position',rect)
axis('off')

%  Text Object Creation

txt1 = text(...
    'Color',[ 1 1 1 ],...
    'EraseMode','normal',...
    'Position',[0.55 0.03],...
    'HorizontalAlignment','right',...
    'Rotation',[ 0 ],...
    'FontSize',ZmapGlobal.Data.fontsz.m,....
    'FontWeight','bold',...
    'String',lab1);

% Make the figure visible

axes(h1)
set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')
whitebg(gcf,[0 0 0])
set(gcf,'Color',[ 0 0 0 ])
figure_w_normalized_uicontrolunits(bmapc);
watchoff(bmapc)
done
