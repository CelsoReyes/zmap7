%  meandpth  finds the average depth for a predefined running
%  window in terms of number of events, and a selected step
%  and plots the results.
%                                                     R.Z. 6/94
%                          Operates on ZG.newcat
%
report_this_filefun(mfilename('fullpath'));


if ic == 1 | ic == 0
    if isempty(ZG.newcat) ZG.newcat = a; end
    ZG.newcat = a;
    iwln = 100;
    step = 10;
    iwl = 2;

    figure_w_normalized_uicontrolunits(...
        'Name','MeanDepth Input Parameters',...
        'visible','off',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','new', ...
        'Units','Pixel',  'Position',[ZG.welcome_pos 550 200'])
    axis off
    set(gca,'visible','off');

    % creates a dialog box to input some parameters
    %

    freq_field=uicontrol('Style','edit',...
        'Position',[.70 .60 .17 .10],...
        'Units','normalized','String',num2str(iwln),...
        'Callback','iwln=str2double(freq_field.String); freq_field.String=num2str(iwln);');

    inp2_field=uicontrol('Style','edit',...
        'Position',[.70 .40 .17 .10],...
        'Units','normalized','String',num2str(step),...
        'Callback','step=str2double(inp2_field.String); inp2_field.String=num2str(step);');

    close_button=uicontrol('Style','Pushbutton',...
        'Position', [.60 .05 .15 .15 ],...
        'Units','normalized','Callback','close;done','String','Cancel');

    go_button=uicontrol('Style','Pushbutton',...
        'Position',[.25 .05 .15 .15 ],...
        'Units','normalized',...
        'Callback','ic = 2;close:  meant',...
        'String','Go');

    txt1 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.65 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold' ,...
        'String','Number of events in averaging window:');

    txt2 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.40 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold' ,...
        'String','Step in number of events:');

    set(gcf,'visible','on')

elseif ic == 2

    if isempty(ZG.newcat) ZG.newcat = a; end
    %iwl = round(iwln* 365/par1);    % window length in years is converted to bins
    len = ZG.newcat.Count;
    xt2  = [ ];
    meand = [ ];
    er = [];
    t0b = ZG.newcat.Date(1);
    teb = ZG.newcat.Date(len);

    wai = waitbar(0,'Please wait...');
    set(wai,'NumberTitle','off','Name','Percent completed');
    me = [];
    S = [];
    clear xt2 meand
    ind = 0;

    for it=1:step:len-iwln
        ind = ind + 1;
        waitbar(it/(len-iwln));
        meand(ind) = mean(ZG.newcat(it:it+iwln-1,7)) ;
        [h, si] = ttest2(ZG.newcat.Depth,ZG.newcat(it:it+iwln-1,7),0.05,-1);
        S = [S ; h si];
        me = [me  ZG.newcat(it:it+iwln-1,7)];
        [m,n] = size(a);
        er(ind) = std(ZG.newcat(it:it+iwln-1,7)) ;
        xt2(ind) = ZG.newcat(it+iwln,3);        % time is end of window

    end    % for it
    meand = -meand;

    % Find out of figure already exists
    %
    [existFlag,figNumber]=figure_exists('Mean Depth',1);
    newDepWindowFlag=~existFlag;

    % Set up the Seismicity Map window Enviroment
    %
    if newDepWindowFlag

        figure_w_normalized_uicontrolunits(...
            'Name','Mean Depth',...
            'visible','off',...
            'NumberTitle','off', ...
            'MenuBar','none', ...
            'NextPlot','new', ...
            'Units','Pixel',  'Position',[ZG.welcome_pos 550 400'])
        depfg = gcf;
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
            'Callback','iwl=str2num(new.String);''String'',num2str(iwl);medispas1',...
            'units','norm','pos',[.90 .30 .10 .06],'min',0.1,'max',100);

        newlabel = uicontrol('style','text','units','norm','pos',[.85 .30 .05 .06]);
        set(newlabel,'string','iwl:','background',color_fbg);

        uicontrol('Units','normal',...
            'Position',[.90 .25 .08 .06],'String','Go',...
             'Callback','medispas1')

    end  % if figure exist

    figure_w_normalized_uicontrolunits(depfg)
    delete(gca);delete(gca);delete(gca);
    set(gca,'visible','off');

    %orient tall
    set(gcf,'Units','centimeter','PaperPosition',[1 1 5 6])
    rect = [0.15, 0.15, 0.65, 0.30];
    axes('position',rect)
    p5 = gca;

    % plot errbar
    %errorbar(xt2,meand,er)
    %plot(xt2,meand,'co')
    for i = 1:length(xt2)
        boxutil(-me(:,i),1,xt2(i),0.5, 'r.',1,1.5);
        hold on
    end

    pl = plot(xt2,meand,'-r')
    hold on
    set(pl,'LineWidth',3.0)
    if isempty(ZG.maepi) == 0
        pl =   plot(ZG.maepi.Date,ZG.maepi.Date*0+mean(meand),'xm');
        set(pl,'LineWidth',2.0)
    end

    axis([min(ZG.newcat.Date) max(ZG.newcat.Date+1) min(meand*1.1)  max(meand*0.9)])
    v = axis;
    xlabel('Time (years)','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m,'Color','k')
    ylabel('Mean Depth (km)','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m,'Color','k')
    stri = ['Mean Depths and standard deviation ( ' file1 ')'];
    %title(' Mean depths and mean depth error ',...
    %        'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m,'Color','k')
    set(gca,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)

    grid
    hold off

    rect = [0.15,  0.45, 0.65, 0.30];
    axes('position',rect)
    pl =plot(ZG.newcat.Date,-ZG.newcat.Depth,'ob')
    set(pl,'MarkerSize',3')
    set(pl,'LineWidth',1.0)
    hold on
    if isempty(ZG.maepi) == 0
        pl =  plot(ZG.maepi.Date,-ZG.maepi.Depth,'xm');
        set(pl,'LineWidth',2.0)
    end
    axis([ v(1) v(2) -max(ZG.newcat.Depth)  -min(ZG.newcat.Depth)])
    %xlabel('Time (years)','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m,'Color','k')
    ylabel('Depth (km)','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m,'Color','k')
    set(gca,'XTicklabels',[])
    stro = [' ' file1 '; wl = ' num2str(iwln) ' events, inc = ' num2str(step)];
    title(stro,'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m,'Color','k')
    grid

    set(gca,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)

    set(gca,'visible','on');
    set(gcf,'visible','on');

    figure
    plot(xt2,S(:,2),'b')
    hold on
    plot(xt2,S(:,1),'or')

    ic = 1;


    close(wai)

end    % if ic

