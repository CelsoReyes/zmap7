function pvalcat()
    %This program is called from timeplot.m and displays the values
    % of p, c and k from Omori law, together with their errors.
    %Modified May: 2001. B. Enescu
    % sets newt2
    
    global valeg  % used for choosing some options in mypval2m.m.
    global valeg2 %  decides if c is fixed or not.
    global cua2a % axes associated with this  (should be persistent instead)
    global CO % c-value (initial?)
    global valm1 % min magnitude
    ZG=ZmapGlobal.Data;
    
    disp('This is pvalcat');
    valeg = 2; % signal for mypval2.m, telling it where it was called from and what to do
    nn2 = ZG.newt2;
    
    prompt = {'Minimum magnitude',...
        'Min. time after mainshock (in days)',...
        'Enter a negative value if you wish a fix c'};
    title = 'You can change the following parameters:';
    lines = 1;
    valm1 = min(ZG.newt2.Magnitude);
    minDaysAfterMainshock = 0;
    valeg2 = 0;
    
    
    def = {num2str(valm1), num2str(minDaysAfterMainshock) , num2str(valeg2)};
    answer = inputdlg(prompt,title,lines,def);
    
    valm1=str2double(answer{1});
    minDaysAfterMainshock = str2num(answer{2});
    valeg2 = str2num(answer{3});
    
    % cut catalog at mainshock time:
    l = ZG.newt2.Date > ZG.maepi.Date(1);
    ZG.newt2 = ZG.newt2.subset(l); %keep events AFTER mainshock
    
    % cat at selected magnitude threshold
    l = ZG.newt2.Magnitude >= valm1;
    ZG.newt2 = ZG.newt2.subset(l); %keep big-enough events
    
    ZG.hold_state2=true;
    timeplot(ZG.newt2)
    ZG.hold_state2=false;
    
    
    if (valeg2 < 0)
        prompt = {'c-value'}; % time delay before the onset of the power-law aftershock decay rate
        title = 'c-value:';
        lines = 1;
        CO = 0.01;
        def = {num2str(CO)};
        answer = inputdlg(prompt,title,lines,def);
        CO = str2double(answer{1});
    end
    
    paramc1 = ZG.newt2.Magnitude >= valm1;
    pcat = ZG.newt2.subset(paramc1);
    
    lt = pcat.Date >= minDaysAfterMainshock;
    bpcat = pcat.subset(lt);
    
    [timpa] = timabs(pcat);
    [timpar] = timabs(ZG.maepi);
    tmpar = timpar(1);
    pcat = (timpa-tmpar)/1440;
    paramc2 = (pcat >= minDaysAfterMainshock);
    pcat = pcat(paramc2,:);
    tmin = min(pcat); tmax = max(pcat);
    tint = [tmin tmax];
    
    [pv, pstd, cv, cstd, kv, kstd, rja, rjb] = mypval2m(pcat);
    
    if ~isnan(pv)
        dispStats(pv, pstd, cv, cstd, kv, kstd, rja, rjb,pcat,tmin,tmax,valm1);
    end
        dispGeneral(pcat,tmin,tmax,valm1);
    end
    
    %Find if the figure already exist.
    pgraph=findobj(0,'Tag','p-value graph');
    
    %Make figure
    if isempty(pgraph)
        pgraph = figure_w_normalized_uicontrolunits( ...
            'Name','p-value graph',...
            'NumberTitle','off', ...
            'NextPlot','new', ...
            'backingstore','on',...
            'Visible','off', ...
            'Position',[ (fipo(3:4) - [600 400]) ZmapGlobal.Data.map_len],...
            'Tag','p-value graph');
        %     'MenuBar','none', ...
    end
    
    %If a new graph is overlayed or not
    if hold_state
        axes(cua2a);
        disp('Hold');
        hold on
    else
        hold on
        figure_w_normalized_uicontrolunits(pgraph)
        hold on
        delete(gca)
        axis off
    end
    ax=gca;
    
    powers = -12:0.5:12;
    sir2 = 2 .^ (1:numel(powers));
    sir2(sir2<=tmin | sir2 >=tmax) = 0;
    
    limit1 = (sir2 > 0);
    sir2(~limit1)=[];
    
    lung = length(sir2);
    dursir = diff(sir2);
    tavg = (sir2(2:end).*sir2(1:end-1)).^(0.5);
    for j = 1 : numel(sir2)-1
        num = sum(sir2(j) < pcat) & (pcat <= sir2(j+1)); % count events between sir2's
        numv = [numv, num];
    end
    
    ratac = numv ./ dursir;
    
    frf = kv ./ ((tavg + cv).^pv);
    frf2 = kv ./ ((tint(1:2) + cv).^pv);
    
    frfr = [frf2(1) frf frf2(2)];
    tavgr = [tint(1) tavg tint(2)];
    
    
    llh1=loglog(tavg, ratac, '-k','LineStyle', 'none', 'Marker', '+','MarkerSize',9);
    hold on
    loglog(tavgr, frfr, '-k','LineWidth',2.0);
    
    if hold_state
        llh1.Marker='+';
    else
        llh1.Marker='o';
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
end

function labelPlot(ax, pv, pstd, cv, cstd, kv, kstd, show_cstd)
    
    text(ax,0.05, 0.2,['p = ' num2str(pv)  ' +/- ' num2str(pstd)],'FontWeight','Bold','FontSize',12,'units','norm');
    if show_cstd >= 0
        text(ax,0.05, 0.15,['c = ' num2str(cv)  ' +/- ' num2str(cstd)],'FontWeight','Bold','FontSize',12,'units','norm');
    else
        text(ax,0.05, 0.15,['c = ' num2str(cv)],'FontWeight','Bold','FontSize',12,'units','norm');
    end
    text(ax,0.05, 0.1,['k = ' num2str(kv)  ' +/- ' num2str(kstd)],'FontWeight','Bold','FontSize',12,'units','norm');
end

function dispStats(pv, pstd, cv, cstd, kv, kstd, rja, rjb, pcat,tmin,tmax,valm1)
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
    disp(['Number of Earthquakes = ' num2str(length(pcat))]);
    events_used = sum(ZG.newt2(paramc1,3) > ZG.maepi.Date + days(cv));
    disp(['Number of Earthquakes greater than c  = ' num2str(events_used)]);
    disp(['tmin = ' num2str(tmin)]);
    disp(['tmax = ' num2str(tmax)]);
    disp(['Mmin = ' num2str(valm1)]);
end

function dispGeneral(pcat,tmin,tmax,valm1)
    % dispGeneral shows parameters
    disp([]);
    disp('Parameters :');
    disp('No result');
    disp(['Number of Earthquakes = ' num2str(length(pcat))]);
    disp(['tmin = ' num2str(tmin)]);
    disp(['tmax = ' num2str(tmax)]);
    disp(['Mmin = ' num2str(valm1)]);
end