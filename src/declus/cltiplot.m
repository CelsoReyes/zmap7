function cltiplot(var1)
    % cltiplot.m                           A.Allmann
    % function to create a cumulative number curve of a selected area
    % valid for all catalog types in Cluster Menu or Cluster
    % cumulative number versus time
    % Time of events with a Magnitude greater than minmag will
    % be shown on the curve.
    %Last modification 8/95

    global action_button freq_field freq_slider
    global mess ccum bgevent equi file1 clust original cluslength newclcat
    global backcat ttcat cluscat
    global winx winy sys minmag clu te1 fontsz
    global clu1 pyy stri tiplo2 statime
    global xt par1 cumu cumu2 newt2 iwl3
    global close_ti_button mtpl
    global freq_field1 freq_field2 freq_field3 freq_field4 freq_field5
    global tmp1 tmp2 tmp3 tmp4 tmm magn hpndl1 ctiplo


    if ~isempty(pyy)
        delete(ccum);
    end
    % Find out of figure already exists
    %

    [existFlag,figNumber]=figure_exists('Cumulative Number Plot (Cluster)',1);
    newCumWindowFlag=~existFlag;

    % Set up the Seismicity Map window

    if newCumWindowFlag
        ccum = figure_w_normalized_uicontrolunits( ...
            'Name','Cumulative Number Plot (Cluster)',...
            'NumberTitle','off', ...
            'MenuBar','none', ...
            'NextPlot','new', ...
            'Visible','off', ...
            'Position',[ 100 100 winx-60 winy-40]);

        set(ccum,'visible','off');
        matdraw

        op1=uimenu('Label','Tools');
        uimenu(op1,'label','AS',...
            'Callback','set(gcf,''Pointer'',''watch'');clas;')

        uimenu(op1,'label','LTA',...
            'Callback','cllta(1);')

        uimenu(op1,'label','Timecut',...
            'Callback','timeselect(1);cltiplot(3) ;')

        uimenu(op1,'label','Back',...
            'Callback', 'if ~isempty(pyy),cltiplot(3);pyy=[];end');

        op2=uimenu(op1,'label','P-Value');
        uimenu(op2,'label','manual',...
             'Callback','ttcat=newt2;clpval(1);');
        uimenu(op2,'label','automatic',...
             'Callback','ttcat=newt2;clpval(3);');
        uimenu(op2,'label','with time', 'Callback','cltipval(2);');
        uimenu(op2,'label','with magnitude', 'Callback','cltipval(1);');

        uicontrol('Units','normal',...
            'Position',[.0 .85 .08 .06],'String','Info ',...
             'Callback','clinfo(4);')

        uicontrol('Units','normal',...
            'Position',[.0 .75 .08 .06],'String','Close ',...
             'Callback','xt=[];cumu=[];cumu2=[];if isempty(pyy),set(ccum,''visible'',''off'');else,;delete(ccum);pyy=[];end;');

        uicontrol('Units','normal',...
            'Position',[.0 .93 .08 .06],'String','Print ',...
             'Callback','myprint')



    else
        figure_w_normalized_uicontrolunits(ccum);
    end

    hold off
    cla
    watchon;

    set(gca,'visible','off','FontSize',fontsz.m,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on')

    if var1==1
        if ~isempty(newclcat)
            if ~isempty(backcat)
                if length(newclcat(:,1))>=length(backcat(:,1))
                    newt2=cluscat;
                else
                    newt2=newclcat;
                end
            else
                newt2=newclcat;
            end
        else
            newt2=cluscat;
        end
    elseif var1==2
        newt2=ttcat;
    end
    [ii,i]=sort(newt2.Date);
    newt2=newt2(i,:);
    statime=[];
    bigmag=max(newt2.Magnitude);
    % select big events ( > bigmag)
    %
    l = newt2.Magnitude == bigmag;
    big = newt2(l,:);
    %calculate start -end time of overall catalog
    t0b = newt2(1,3);
    n = newt2.Count;
    teb = newt2(n,3);
    tdiff = (teb - t0b)*365;
    par5=tdiff/100;         %bin length is 1/100 of timedifference(in days)
    if par5>1
        par5=round(par5);
    elseif par5>=.1  &&  par5 <= 1
        par5=.1;
    else
        par5=.02;
    end
    % set arrays to zero
    %
    %cumu = 0:par5:tdiff+2*par5;
    %cumu2 = 0:par5:tdiff-1;
    %cumu = cumu * 0;
    %cumu2 = cumu2 * 0;

    %
    % calculate cumulative number versus time and bin it
    %
    n = newt2.Count;
    if par5 >=1
        [cumu, xt] = hist(newt2.Date,(t0b-par5/365:par5/365:teb+par5/365));
    else
        [cumu, xt] = hist((newt2.Date-newt2(1,3)+par5/365)*365,(0:par5:(tdiff+2*par5)));
    end
    cumu2=cumsum(cumu);

    % plot time series
    %
    orient tall
    rect = [0.2,  0.15, 0.55, 0.75];
    axes('position',rect)
    hold on
    tiplo = plot(xt,cumu2,'ob');
    set(gca,'visible','off')
    tiplo2 = plot(xt,cumu2,'r');


    % plot big events on curve
    %
    if length(big) < 4
        f = cumu2(ceil((big(:,3) -t0b)*365/par5));
        bigplo = plot(big(:,3),f,'xr');
        set(bigplo,'MarkerSize',10,'LineWidth',2.5)
        stri4 = [];
        [le1,le2] = size(big);
        for i = 1:le1
            s = sprintf('  M=%3.1f',big(i,6));
            stri4 = [stri4 ; s];
        end   % for i

        te1 = text(big(:,3),f,stri4);
        set(te1,'FontWeight','bold','Color','m','FontSize',fontsz.s)


        %option to plot the location of big events in the map
        %
        %if var1==1
        % figure_w_normalized_uicontrolunits(clu)
        %else
        % figure_w_normalized_uicontrolunits(clu1);
        %end
        % plog = plot(big(:,1),big(:,2),'or','EraseMode','xor');
        %set(plog,'MarkerSize',ms10,'LineWidth',2.0)
        %figure_w_normalized_uicontrolunits(ccum)

    end %if big

    if exist('stri', 'var')
        v = axis;
        tea = text(v(1)+0.5,v(4)*0.9,stri) ;
        set(tea,'FontSize',fontsz.m,'Color','k','FontWeight','bold')
    end %% if stri

    strib = [file1];

    title2(strib,'FontWeight','bold',...
        'FontSize',fontsz.l,...
        'Color','r')

    grid
    if par5>=1
        xlabel('Time in years ','FontWeight','bold','FontSize',fontsz.m)
    else
        statime=newt2(1,3)-par5/365;
        xlabel(['Time in days relative to ',num2str(statime)],'FontWeight','bold','FontSize',fontsz.m)
    end
    ylabel('Cumulative Number ','FontWeight','bold','FontSize',fontsz.m)

    % Make the figure visible
    %
    set(gca,'visible','on','FontSize',fontsz.m,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on')
    set(ccum,'Visible','on');
    figure_w_normalized_uicontrolunits(ccum);
    watchoff(ccum)
    watchoff
    watchoff

