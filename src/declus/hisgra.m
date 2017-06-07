function hisgra(vari1,stri2)
    %histogram.m                               A.Allmann
    %plots histogram in cumulative number window
    %vari1 depends on input parameter
    %
    %Last modification 6/95
    global mess  ccum freq_field histo hisvar strii1 strii2 fontsz
    stri1='Histogram';
    strii1=stri1;
    strii2=stri2;
    stri3='Duration ';
    stri4='Foreshock Duration ';
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
            'Visible','off');

        %Menuline for options
        %
        matdraw

        op1 = uimenu('Label','Display');
        uimenu(op1,'Label','Bin Number','Callback',@(s,e)inpubin(1));
        uimenu(op1,'Label','Bin Vector','Callback',@(s,e)inpubin(2));
        uimenu(op1,'Label','Default','Callback',@(s,e)histogram(hisvar));


        axis('off')
        hold on
    end

    orient portrait
    rect = [0.25,  0.18, 0.60, 0.70];
    axes('position',rect)
    hold on

    if stri2(1:2) == 'Ma'
        histogram(vari1,floor(min(vari1)):0.1:ceil(max(vari1)));
    end
    if stri2(1:2) == 'De'
        histogram(vari1,50);
    end
    if stri2(1:2) == 'Ti'
        histogram(vari1,50);
    end
    if stri2(1:2) == 'Hr'
        histogram(vari1,-0.5:1:24.5);
    end

    if stri2(1:2) == 'Qu'
        histogram(vari1,-0.1:0.01:1.1);
    end

    title2([stri2,stri1],'FontWeight','bold','FontSize',fontsz.m,'Color','k')
    set(gca,'visible','on','FontSize',fontsz.m,'FontWeight','bold',...
        'FontWeight','bold','TickDir','out','Ticklength',[ 0.02 0.02],'LineWidth',1.,'Box','on')
    if strcmp(stri2,stri3)
        stri2='Duration in days';
    elseif strcmp(stri2,stri4)
        stri2='Foreshock Duration in days';
    end
    xlabel(stri2,'FontWeight','bold','FontSize',fontsz.m)
    ylabel('  Number ','FontWeight','bold','FontSize',fontsz.m)
    set(gcf,'Visible','on')
