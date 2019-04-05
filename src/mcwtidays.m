function mcwtidays(catalog) 
    % plot Mc with time (days)
    
    % turned into function by Celso G Reyes 2017
    
    report_this_filefun();
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    bv3 = [] ;
    me = [];
    def = {'150'};
    ni2 = inputdlg('Number of events in each window?','Input',1,def);
    l = ni2{:};
    ni = str2double(l);
    
    
    itervector=1:ni/5:catalog.Count - ni;
    nIter=numel(itervector);
    % expect trouble elsewhere if bv2 or BV are reused... they've changed from matrices to structs
    % to handle dates better.
    bv2.magco(1:nIter,1) = double(missing);
    bv2.date(1:nIter,1)  = datetime(missing);

    bV.magco(1:nIter*3,1) = double(missing);
    bv.date(1:nIter*3,1)  = datetime(missing);
    
    for n = 1:numel(itervector)
        i=itervector(n);
        magco =  bvalca2(catalog.subset(i:i+ni));
        bv2.magco(n) = magco;
        bv2.date(n) = catalog.Date(i+ni/2);
        BV.magco(n*3-2:n*3-1) = magco;
        BV.date(n*3-2 : n*3-1) = [catalog.Date(i); catalog.Date(i+ni)];
        
    end
    
    % Find out if figure already exists
    %
    Mcfig=findobj('Type','Figure','-and','Name','Mc with time');
    
    % Set up the window
    
    if isempty(Mcfig)
        Mcfig = figure_w_normalized_uicontrolunits( ...
            'Name','Mc with time',...
            'NumberTitle','off', ...
            'NextPlot','replace', ...
            'backingstore','on',...
            'Visible','on');
        
        
    end
    figure(Mcfig);
    %TODO instead of completely recreating plots, just edit the existing ones
    delete(findobj(Mcfig,'Type','axes'));
    axis off
    
    i  = find(catalog.Magnitude ==  max(catalog.Magnitude), 1 );
    ZG.maepi = catalog.subset(i); % guaranteed to be only one event
    
    rect = [0.15 0.30 0.7 0.45];
    ax = axes('position',rect);
    plot(ax, days(bv2.date-ZG.maepi.Date),bv2.magco,'^r', 'LineWidth',1.5,'MarkerSize',10,...
        'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'r');
    ax.NextPlot = 'add';
    plot(ax, days(bv2.date-ZG.maepi.Date), bv2.magco, 'b', 'LineWidth', 1.0)
    plot(days(BV.date-ZG.maepi.Date), BV.magco, 'color', [0.5 0.5 0.5]);
    
    %grid
    ax.Color = ZG.color_bg;
    set(ax, 'box', 'on',...
        'SortMethod', 'childorder',...
        'TickDir', 'out',...
        'FontWeight','bold',...
        'FontSize', ZmapGlobal.Data.fontsz.m,...
        'Linewidth', 1.2)
    %
    ax.YLabel.String = 'Mc';
    %set(gca,'Xlim',[t0b teb]);
    
    xlabel('Days relative to mainshock')
    tist = [  catalog.Name ' - b(t), ni = ' num2str(ni) ];
    title(tist,'interpreter','none')
    
    
    
    %% what is the purpose of following code? Donno? Skipping.
    return
    
    
    
    nt = [];
    con = 0;
    
    ms = round(bv2.magco,1);
    for  m = max(bv2.magco):-0.1:min(bv2.magco)
        
        % find comp level and times.
        i = find(abs(m-ms) < 0.01, 1, 'last' );
        if ~isempty(i)
            con = con+1;
            nt = [nt ; m decyear(bv2.date(i))];
            
            if con > 1 &&  nt(con,2) < nt(con-1,2)
                nt(con,:) = []; 
                con = con-1; 
            end
        end
    end
    
    nt(1,2) = min(decyear(catalog.Date));
    % i = find((ms-min(ms) > 0.01), 1, 'last' );
    % nt(con,2) = bv2(i+1,2);
    
    
    
    
end
