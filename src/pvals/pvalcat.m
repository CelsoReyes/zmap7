function pvalcat()
    %This program is called from timeplot.m and displays the values
    % of p, c and k from Omori law, together with their errors.
    %
    %
    %Modified May: 2001. B. Enescu
    % sets newt2
    
    persistent cua2a % axes associated with this  (should be persistent instead)
    
    report_this_filefun();
    ZG=ZmapGlobal.Data;
    
    nn2 = ZG.newt2;
    
    prompt = {'Minimum magnitude',...
        'Min. time after mainshock (in days)',...
        'Enter a negative value if you wish to fix c'};
    title_str = 'You can change the following parameters:';
    lines = 1;
    minThreshMag = min(ZG.newt2.Magnitude);
    minDaysAfterMainshock = days(0); % 
    mainshockDate = ZG.maepi.Date(1);
    valeg2 = 0; %  decides if c is fixed or not.
    
    
    if ~ensure_mainshock()
        return
    end
    def = {num2str(minThreshMag), num2str(minDaysAfterMainshock/days()) , num2str(valeg2)};
    answer = inputdlg(prompt,title_str,lines,def);
    
    minThreshMag=str2double(answer{1});
    minDaysAfterMainshock = days(str2double(answer{2}));
    valeg2 = str2double(answer{3});
    
    % cut catalog at mainshock time:
    l = ZG.newt2.Date > mainshockDate;
    ZG.newt2 = ZG.newt2.subset(l); %keep events AFTER mainshock
    
    % cat at selected magnitude threshold
    l = ZG.newt2.Magnitude >= minThreshMag;
    ZG.newt2 = ZG.newt2.subset(l); %keep big-enough events
    
    ZG.hold_state2=true;
    CumTimePlot(ZG.newt2);
    ZG.hold_state2=false;
    
    CO = 0.01; % c-value (initial?)
    if (valeg2 < 0)
        prompt = {'c-value'}; % time delay before the onset of the power-law aftershock decay rate
        title_str = 'c-value:';
        lines = 1;
        def = {num2str(CO)};
        answer = inputdlg(prompt,title_str,lines,def);
        CO = str2double(answer{1});
    end
    
    eqDates = ZG.newt2.Date;
    timeSinceMainshock = eqDates - mainshockDate;
    assert(all(timeSinceMainshock>0));
    
    paramc2 = timeSinceMainshock >= minDaysAfterMainshock;
    eqDates = eqDates(paramc2);
    eqMags = ZG.newt2.Magnitude(paramc2);
    
    tmin = min(timeSinceMainshock);
    tmax = max(timeSinceMainshock);
    
    tint = [tmin tmax];
    
    [pv, pstd, cv, cstd, kv, kstd, rja, rjb] = mypval2m(eqDates,eqMags,'date',valeg2,CO,minThreshMag);
    
    if ~isnan(pv)
        dispStats(pv, pstd, cv, cstd, kv, kstd, rja, rjb,eqDates,tmin,tmax,minThreshMag);
    else
        dispGeneral(eqDates,tmin,tmax,minThreshMag);
    end
    
    %Find if the figure already exist.
    pgraph=findobj('Tag','p-value graph');
    
    %Make figure
    if isempty(pgraph)
        pgraph = figure_w_normalized_uicontrolunits( ...
            'Name','p-value graph',...
            'NumberTitle','off', ...
            'NextPlot','new', ...
            'backingstore','on',...
            'Visible','off', ...
            ...'Position',position_in_current_monitor(ZG.map_len(1), ZG.map_len(2)),...
            'Tag','p-value graph');
        %     ...
    end
    
    %If a new graph is overlayed or not
    if ZG.hold_state
        axes(cua2a);
        disp('Hold');
        set(gca,'NextPlot','add')
    else
        set(gca,'NextPlot','add')
        figure(pgraph);
        set(gca,'NextPlot','add')
        delete(gca)
        axis off
    end
    ax=gca;
    
    powers = -12:0.5:12;
    sir2 = 2 .^ (1:numel(powers)); % remarked out because it just didn't make sense if powers wasn't used anywhere else -CGR
    %sir2 = 2 .^ powers;
    sir2(sir2<=tmin | sir2 >=tmax) = 0;
    
    limit1 = (sir2 > 0);
    sir2(~limit1)=[];
    
    lung = length(sir2);
    dursir = diff(sir2);
    tavg = (sir2(2:end).*sir2(1:end-1)).^(0.5);
    numv=[];
    for j = 1 : numel(sir2)-1
        num = sum(sir2(j) < timeSinceMainshock) & (timeSinceMainshock <= sir2(j+1)); % count events between sir2's
        numv = [numv, num];
    end
    
    ratac = numv ./ dursir;
    
    frf = kv ./ ((tavg + cv).^pv);
    frf2 = kv ./ ((days(tint) + cv).^pv);
    
    frfr = [frf2(1) frf frf2(2)];
    tavgr = [tint(1) days(tavg) tint(2)];
    
    %TOFIX: this works, but seems to plot incorrectly
    
    llh1=loglog(tavg, ratac, '-k','LineStyle', 'none', 'Marker', '+','MarkerSize',9);
    set(gca,'NextPlot','add')
    loglog(days(tavgr), frfr, '-k','LineWidth',2.0);
    
    if ZG.hold_state
        set(llh1,'Marker','+');
    else
        set(llh1,'Marker','o');
        xlabel(ax,'Time from Mainshock (days)','FontWeight','bold','FontSize',14);
        ylabel(ax,'No. of Earthquakes / Day','FontWeight','bold','FontSize',14);
    end
    
    set(ax,'visible','on','FontSize',12,'FontWeight','normal',...
        'FontWeight','bold','LineWidth',1.0,'TickDir','out',...
        'Box','on','Tag','cufi')
    
    
    cua2a = ax;
    labelPlot(cua2a, pv, pstd, cv, cstd, kv, kstd, valeg2);
    
    % reset ZG.newt2;
    
    ZG.newt2 = nn2;
    
    function labelPlot(ax, pv, pstd, cv, cstd, kv, kstd, show_cstd)
        
        text(ax,0.05, 0.2,['p = ' num2str(pv)  ' +/- ' num2str(pstd)],'FontWeight','Bold','FontSize',12,'units','norm');
        if show_cstd >= 0
            text(ax,0.05, 0.15,['c = ' num2str(cv)  ' +/- ' num2str(cstd)],'FontWeight','Bold','FontSize',12,'units','norm');
        else
            text(ax,0.05, 0.15,['c = ' num2str(cv)],'FontWeight','Bold','FontSize',12,'units','norm');
        end
        text(ax,0.05, 0.1,['k = ' num2str(kv)  ' +/- ' num2str(kstd)],'FontWeight','Bold','FontSize',12,'units','norm');
    end
    
    function dispStats(pv, pstd, cv, cstd, kv, kstd, rja, rjb, eqDates,tmin,tmax,minThreshMag)
        ZG=ZmapGlobal.Data;
        disp('');
        disp('Parameters :');
        disp(['p = ' num2str(pv)  ' +/- ' num2str(pstd)]);
        disp(['a = ' num2str(min(rja))  ' +/- ' num2str(pstd)]);
        disp(['b = ' num2str(min(rjb))  ' +/- ' num2str(pstd)]);
        if valeg2 >= 0
            disp(['c = ' num2str(cv)  ' +/- ' num2str(cstd)]);
        else
            disp(['c = ' num2str(cv)]);
        end
        disp(['k = ' num2str(kv)  ' +/- ' num2str(kstd)]);
        disp(['Number of Earthquakes = ' num2str(length(eqDates))]);
        %events_used = sum(ZG.newt2.Date(paramc1) > ZG.maepi.Date(1) + days(cv));
        events_used = sum(eqDates > ZG.maepi.Date(1) + days(cv));
        disp(['Number of Earthquakes greater than c  = ' num2str(events_used)]);
        disp(['tmin = ' char(tmin)]);
        disp(['tmax = ' char(tmax)]);
        disp(['Mmin = ' num2str(minThreshMag)]);
    end
    
    function dispGeneral(eqDates,tmin,tmax,minThreshMag)
        % dispGeneral shows parameters
        disp([]);
        disp('Parameters :');
        disp('No result');
        disp(['Number of Earthquakes = ' num2str(length(eqDates))]);
        disp(['tmin = ' char(tmin)]);
        disp(['tmax = ' char(tmax)]);
        disp(['Mmin = ' num2str(minThreshMag)]);
    end
end
