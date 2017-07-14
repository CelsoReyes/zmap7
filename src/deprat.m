%

global p
report_this_filefun(mfilename('fullpath'));
ms3 = 5;

% This is the info window text
%
ttlStr='Comparing Seismicity rates ';
hlpStr1map= ...
    ['                                                '
    ' To be Implemented                              '
    '                                                '];
% Find out of figure already exists
%
[existFlag,figNumber]=figure_exists('Compare two rates',1);
newCompWindowFlag=~existFlag;

% Set up the Seismicity Map window Enviroment
%
if newCompWindowFlag
    bvfig= figure_w_normalized_uicontrolunits( ...
        'Name','Compare two rates',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'backingstore','on',...
        'NextPlot','new', ...
        'Visible','on', ...
        'Position',[ (fipo(3:4) - [600 500]) (ZmapGlobal.Data.map_len + [0 200]));


    uicontrol('Units','normal',...
        'Position',[.0 .93 .08 .06],'String','Print ',...
         'Callback','myprint')

    uicontrol('Units','normal',...
        'Position',[.0 .75 .08 .06],'String','Close ',...
         'Callback','f1=gcf; f2=gpf;set(f1,''Visible'',''off'');if f1~=f2, zmap_message_center();done; end')

    uicontrol('Units','normal',...
        'Position',[.0 .85 .08 .06],'String','Info ',...
         'Callback','zmaphelp(ttlStr,hlpStr1map,hlpStr2map,hlpStr3map)')
    axis off
    matdraw

end % if figure exits

figure_w_normalized_uicontrolunits(bvfig)
hold on
delete(gca)
delete(gca)
delete(gca)
delete(gca)
delete(gca)
delete(gca)
delete(gca)
delete(gca)
try
    delete(uic)
catch ME
    error_handler(ME,@do_nothing);
end
backg = [ ] ;
foreg = [ ] ;
format short;

if isempty(ZG.newcat)
    ZG.newcat = a;
end
t0b = min(ZG.newcat.Date);
teb = max(ZG.newcat.Date);
n = ZG.newcat.Count;
tdiff = round(teb - t0b);

td12 = t2p(1) - t1p(1);
td34 = t4p(1) - t3p(1);

l = ZG.newcat.Date > t1p(1) & ZG.newcat.Date < t2p(1) ;
backg =  ZG.newcat.subset(l);
[n1,x1] = hist(backg(:,7),(0:1.0:max(ZG.newcat.Depth)));
n1 = n1 *  td34/td12;                      % normalization

l = ZG.newcat.Date > t3p(1) & ZG.newcat.Date < t4p(1) ;
foreg = ZG.newcat.subset(l);
[n2,x2] = hist(foreg(:,7),(0:1.0:max(ZG.newcat.Depth)));

set(gcf,'PaperPosition',[2 1 5.5 7.5])
rect = [0.2 0.70 0.65 0.25];
axes('position',rect)
bar(x1,n1,'r')
grid
la1 = ['  Time: ' num2str(t1p(1)) ' to '  num2str(t2p(1))];
te = text(0.6,0.8,la1,'units','normalized','FontWeight','Bold');
set(gca,'XLim',[0 max(ZG.newcat.Depth)])
set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',ZmapGlobal.Data.fontsz.s,'Linewidth',1.0)
ylabel('Number (normalized)')

rect = [0.2 0.4 0.65 0.25];
axes('position',rect)
bar(x2,n2,'r')
grid
set(gca,'XLim',[0 max(ZG.newcat.Depth)])
set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',ZmapGlobal.Data.fontsz.s,'Linewidth',1.0)
la1 = ['  Time: ' num2str(t3p(1)) ' to '  num2str(t4p(1))];
te = text(0.6,0.8,la1,'units','normalized','FontWeight','Bold');
xlabel('Depth')
ylabel('Number')

rect = [0.2 0.1 0.65 0.2];
axes('position',rect)
%pl =plot(x1,n2./n1);
bar(x2,n1-n2)
%set(pl,'LineWidth',2)

set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',ZmapGlobal.Data.fontsz.s,'Linewidth',1.0)
set(gca,'XLim',[0 max(ZG.newcat.Depth)])
xlabel('Depth')
ylabel('Difference (t1-t2)')
grid
p1 = gca;

