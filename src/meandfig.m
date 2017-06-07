%  meandpth  finds the average depth for a predefined running
%  window in terms of number of events, and a selected step
%  and plots the results.
%                                                     R.Z. 6/94
%                          Operates on newcat
%
report_this_filefun(mfilename('fullpath'));



% Find out of figure already exists
%
[existFlag,figNumber]=figure_exists('Mean Depth2',1);
newDep2WindowFlag=~existFlag;

% Set up the Seismicity Map window Enviroment
%
if newDep2WindowFlag

    figure_w_normalized_uicontrolunits(...
        'Name','Mean Depth2',...
        'visible','off',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'Color',[ 1 1 1], ...
        'NextPlot','new', ...
        'Units','Pixel',  'Position',[wex wey 550 400'])
    depfg2 = gcf;
    hold on
    axis off
    matdraw
    

    uicontrol('Style','Pushbutton',...
        'Position',[.9 .80 .10 .05],...
        'Units','normalized',...
        'Callback','sta = ''ast'';medispas1','String','AS');
    uicontrol('Style','Pushbutton',...
        'Position',[.9 .70 .10 .05],...
        'Units','normalized',...
        'Callback','sta = ''lta'';medispas1','String','LTA');
    uicontrol('Style','Pushbutton',...
        'Position',[.9 .90 .10 .05],...
        'Units','normalized',...
        'Callback','dispma4','String','Com');

    new = uicontrol('style','edit','value',iwl,...
        'string',num2str(iwl), 'background','y',...
        'Callback','iwl=str2num(get(new,''String''));''String'',num2str(iwl);medispas1',...
        'units','norm','pos',[.90 .30 .10 .06],'min',0.1,'max',100);

    newlabel = uicontrol('style','text','units','norm','pos',[.85 .30 .05 .06]);
    set(newlabel,'string','iwl:','background',[c1 c2 c3]);

    uicontrol('Units','normal',...
        'Position',[.90 .25 .08 .06],'String','Go',...
         'Callback','medispas1')

end  % if figure exist

figure_w_normalized_uicontrolunits(depfg2)
delete(gca);delete(gca);delete(gca);
set(gca,'visible','off');

%orient tall
set(gcf,'Units','centimeter','PaperPosition',[1 1 8 7])
rect = [0.15, 0.15, 0.65, 0.30];
axes('position',rect)
p5 = gca;

% plot errbar
%errorbar(xt2,meand,er)
%plot(xt2,meand,'co')
%for i = 1:length(xt2)
%boxutil(-me(:,i),1,xt2(i),0.5, 'r.',1,1.5);
%hold on
%end

pl = plot(xt2,meand,'-k')
set(pl,'LineWidth',1.0)
hold on
pl = plot(xt2,meand,'ok')
set(pl,'LineWidth',1.0,'MarkerSize',6)
if isempty(maepi) == 0
    pl =   plot(maepi(:,3),-maepi(:,7),'xk');
    set(pl,'LineWidth',2.0)
end

axis([min(xt2) max(xt2+0.5) min([meand*1.1 ])  max([meand*0.9 ])])
v = axis;
grid
xlabel('Time (years)','FontWeight','bold','FontSize',fontsz.m,'Color','k')
ylabel('Mean Depth (km)','FontWeight','bold','FontSize',fontsz.m,'Color','k')
stro = [' ' file1 '; ' num2str(iwln) ' / ' num2str(step)];
title2(stro,'FontWeight','bold','FontSize',fontsz.m,'Color','k')

set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',fontsz.m,'Linewidth',1.2)

hold off

set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',fontsz.m,'Linewidth',1.2)

set(gca,'visible','on');
set(gcf,'visible','on');


ic = 1;



