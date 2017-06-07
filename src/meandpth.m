%  meandpth  finds the average depth for a predefined running
%  window in terms of number of events, and a selected step
%  and plots the results.
%                                                     R.Z. 6/94
%                          Operates on newcat
%
report_this_filefun(mfilename('fullpath'));


if ic == 1 | ic == 0
    if isempty(newcat) newcat = a; end
    newcat = a;
    iwln = 100;
    step = 28;
    iwl = 2;

    figure_w_normalized_uicontrolunits(...
        'Name','MeanDepth Input Parameters',...
        'visible','off',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','new', ...
        'Units','Pixel',  'Position',[wex wey 550 200'])
    axis off
    set(gca,'visible','off');

    % creates a dialog box to input some parameters
    %
    if term == 1 ; set(gcf,'Color',[1 1 1 ]);end
    freq_field=uicontrol('Style','edit',...
        'Position',[.70 .60 .17 .10],...
        'Units','normalized','String',num2str(iwln),...
        'Callback','iwln=str2double(get(freq_field,''String'')); set(freq_field,''String'',num2str(iwln));');

    inp2_field=uicontrol('Style','edit',...
        'Position',[.70 .40 .17 .10],...
        'Units','normalized','String',num2str(step),...
        'Callback','step=str2double(get(inp2_field,''String'')); set(inp2_field,''String'',num2str(step));');

    close_button=uicontrol('Style','Pushbutton',...
        'Position', [.60 .05 .15 .15 ],...
        'Units','normalized','Callback','close;done','String','Cancel');

    go_button=uicontrol('Style','Pushbutton',...
        'Position',[.25 .05 .15 .15 ],...
        'Units','normalized',...
        'Callback','ic = 2;close;clear meandpth; meandpth',...
        'String','Go');

    txt1 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.65 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.m ,...
        'FontWeight','bold' ,...
        'String','Number of events in averaging window:');

    txt2 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[0. 0.40 0 ],...
        'Rotation',0 ,...
        'FontSize',fontsz.m ,...
        'FontWeight','bold' ,...
        'String','Time-step in days:');

    set(gcf,'visible','on')

elseif ic == 2

    step = step/365;
    if isempty(newcat) newcat = a; end
    %iwl = round(iwln* 365/par1);    % window length in years is converted to bins
    len = length(newcat(:,3));
    xt2  = [ ];
    meand = [ ];
    er = [];
    t0b = newcat(1,3);
    teb = newcat(len,3);
    ind = 0;

    me = [];
    b = a;

    sta = a(iwln+1,3);
    sto = max(a(:,3));
    for it=sta+step:step:sto
        ind = ind + 1;
        t = find( abs(b(:,3)-it)  == min(abs(b(:,3)-it)));
        if t <= iwln ; t = iwln+1; end
        meand(ind) =  mean(newcat(t-iwln:t,7)) ;
        er(ind) =  std(newcat(t-iwln:t,7)) ;
        xt2(ind) = it;        % time is end of window
    end    % for it

    % for it=1:step:len-iwln;
    %ind = ind + 1;
    %waitbar(it/(len-iwln));
    %%        l = newcat(:,3) >= it & newcat(:,3) < it+iwln;  % for time window
    %%        meand(ind) = mean(newcat(l,7));
    %%        xt2(ind) = it + iwln/2.;
    %meand(ind) = mean(newcat(it:it+iwln-1,7)) ;
    %me = [me  newcat(it:it+iwln-1,7)];
    %[m,n] = size(a);
    %er(ind) = std(newcat(it:it+iwln-1,7)) ;
    %xt2(ind) = newcat(it+iwln,3);        % time is end of window
    %
    %end    % for it
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
            'Units','Pixel',  'Position',[wex wey 550 400'])
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
            'Callback','iwl=str2num(get(new,''String''));''String'',num2str(iwl);medispas1',...
            'units','norm','pos',[.90 .30 .10 .06],'min',0.1,'max',100);

        newlabel = uicontrol('style','text','units','norm','pos',[.85 .30 .05 .06]);
        set(newlabel,'string','iwl:','background',[c1 c2 c3]);

        uicontrol('Units','normal',...
            'Position',[.90 .25 .08 .06],'String','Go',...
             'Callback','medispas1')

    end  % if figure exist

    figure_w_normalized_uicontrolunits(depfg)
    delete(gca);delete(gca);delete(gca);
    set(gca,'visible','off');

    %orient tall
    set(gcf,'Units','centimeter','PaperPosition',[1 1 7 8])
    rect = [0.15, 0.15, 0.65, 0.30];
    axes('position',rect)
    p5 = gca;

    % plot errbar
    errorbar(xt2,meand,er)
    hold on
    plot(xt2,meand,'co')
    pl = plot(xt2,meand,'-r')
    hold on
    set(pl,'LineWidth',1.0)
    if isempty(maepi) == 0
        pl =   plot(maepi(:,3),maepi(:,3)*0+mean(meand),'xm');
        set(pl,'LineWidth',2.0)
    end

    axis([min(newcat(:,3)) max(newcat(:,3)+0.1) min(meand*1.1)  max(meand*0.9)])
    v = axis;
    xlabel('Time (years)','FontWeight','bold','FontSize',fontsz.m,'Color','k')
    ylabel('Mean Depth (km)','FontWeight','bold','FontSize',fontsz.m,'Color','k')
    stri = ['Mean Depths and standard deviation ( ' file1 ')'];
    %title2(' Mean depths and mean depth error ',...
    %        'FontWeight','bold','FontSize',fontsz.m,'Color','k')
    set(gca,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',fontsz.m,'Linewidth',1.2)

    grid
    hold off

    rect = [0.15,  0.45, 0.65, 0.30];
    axes('position',rect)
    pl =plot(newcat(:,3),-newcat(:,7),'.b')
    set(pl,'MarkerSize',3')
    set(pl,'LineWidth',1.0)
    hold on
    if isempty(maepi) == 0
        pl =  plot(maepi(:,3),-maepi(:,7),'xm');
        set(pl,'LineWidth',2.0)
    end
    axis([ v(1) v(2) -max(newcat(:,7))  -min(newcat(:,7))])
    %xlabel('Time (years)','FontWeight','bold','FontSize',fontsz.m,'Color','k')
    ylabel('Depth (km)','FontWeight','bold','FontSize',fontsz.m,'Color','k')
    set(gca,'XTicklabels',[])
    stro = [' ' file1 '; wl = ' num2str(iwln) ' events, inc = ' num2str(step)];
    title2(stro,'FontWeight','bold','FontSize',fontsz.m,'Color','k')
    grid

    set(gca,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',fontsz.m,'Linewidth',1.2)

    set(gca,'visible','on');
    set(gcf,'visible','on');


    ic = 1;


end    % if ic

