function histogram_old_95(vari1,stri2)
    %histogram_old_95.m                               A.Allmann
    %plots histogram in cumulative number window
    %vari1 depends on input parameter
    %
    %Last modification 6/95
    global mess  ccum freq_field histo hisvar strii1 strii2
    stri1='Histogram';
    strii1=stri1;
    strii2=stri2;
    hisvar=vari1;
    tm1=[];
    % Find out of figure already exists
    %
    [existFlag,figNumber]=figure_exists('Histogram',1);
    newHistoFlag=existFlag;
    if newHistoFlag
        figure_w_normalized_uicontrolunits(histo)
        cla
        cla
        delete(gca)
    else
        histo= figure_w_normalized_uicontrolunits( ...
            'NumberTitle','off','Name',stri1,...
            'MenuBar','none', ...
            'NextPlot','new', ...
            'Visible','off')

        %Menuline for options
        %
        %matdraw

        op1 = uimenu('Label','Display');
        uimenu(op1,'Label','Bin Number','Callback','inpubin(1);');
        uimenu(op1,'Label','Bin Vector','Callback','inpubin(2);');
        uimenu(op1,'Label','Default','Callback','histogram(hisvar);');

        callbackStr= ...
            ['newcat=a;f1=gcf; f2=gpf; set(f1,''Visible'',''off'');', ...
            'if f1~=f2, figure_w_normalized_uicontrolunits(f2); end'];

        uicontrol('Units','normal',...
            'Position',[.0  .83 .08 .06],'String','Close ',...
             'Callback','close;done')

        uicontrol('Units','normal',...
            'Position',[.0  .93 .08 .06],'String','Print ',...
             'Callback','myprint')

    end

    orient tall
    rect = [0.25,  0.18, 0.60, 0.70];
    axes('position',rect)
    hold on

    histogram(vari1,50);
    title2([stri2,stri1],'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m,'Color','k')
    set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,'Box','on')

    xlabel(stri2,'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    ylabel('  Number ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    set(gcf,'Visible','on')
