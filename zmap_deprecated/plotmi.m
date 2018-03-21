function newcat2=plotmi(var1, newcat2, mi)
    %plot misfit (?)
    % TODO make this work with the new catalogs
    report_this_filefun(mfilename('fullpath'));
    
    global  mif2 mif1
    global tmp % REALLY? global tmp?  "tmp" is 1:nEvents
    % cumu2 mi2
    figNumber=findobj('Type','Figure','-and','Name','Misfit ');
    figure(figNumber);
    delete(findobj(figNumber,'Type','axes'));
    rect = [0.15,  0.15, 0.75, 0.65];
    axes('position',rect)
    ax=gca;
    nEvents=newcat2.Count;
    tmp=1:nEvents;
    sixSlices=round(0 : nEvents/5 : nEvents);
    sixSlices(1)=1;
    
    var2=var1;
    
    misfitAngle = mi(:,2);
    X = 1:nEvents;
    xtitle=sprintf('Number of Eqs (sorted by %s)',lower(var1));
    switch (var1)
        case {'Longitude','Latitude','Magnitude','Depth'}
            % plot_by_lon(); %by lon
            plot_by_field(var1);
        case 'Time'
            plot_by_time(); % by date
        case 'Strike'
            plot_by_strike(); % along strike
        case 'Default'
            option_7(); %unsorted
        otherwise
            error('unknown choice for plotmi');
    end
    
    grid('on')
    set(ax,'Color',color_bg);
    set(ax,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
    ylabel('Cumulative Misfit ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m);
    xlabel(xtitle,'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    
    if ~ strcmp(var1 ,'Default')
        hold on
        for i=1:6
            plot(ax,tmp(sixSlices(i)),cumu2(sixSlices(i)),'xr');
            str=['  ',num2str(newcat2(sixSlices(i),var2))];
            te=text(tmp(sixSlices(i)),cumu2(sixSlices(i)),str);
            set(te,'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
        end
    else
        
    end
    
    
    function plot_by_field(name)
        % assumes that misfit matrix (mi) has same number of rows as 
        % number of earthquakes in catalog
        [~,is] = sort(newcat2.(name));
        newcat2.sort(name); % sort the catalog itself by this field
        
        cumu2=cumsum(misfitAngle(is));
        plot(1:nEvents , cumu2 , 'o');
        xtitle=sprintf('Number of Eqs (sorted by %s)',lower(name));
    end
    
    
    function plot_by_time()
        [~,is] = sort(newcat2.Date);
        newcat2.sort(Date);
        cumu2=cumsum(misfitAngle(is));
        pl = plot(tmp,cumu2,'o');
        xtitle='Number of Eqs (sorted by time)';
    end
    
    function plot_by_strike()
        % [~,is] = sort(newcat2(:,15));
        [~,is] = sort(newcat2(:,end));
        newa2 = newcat2.subset(is) ;
        cumu2=cumsum(misfitAngle(is));
        pl = plot(newa2(:,16)-18.6,cumu2,'o');
        xtitle='Number of Eqs (sorted along strike)';
        var2=15;
    end
    
    function option_7()
        mi2 = mi ;
        cumu2=cumsum(mi2(:,2));
        pl = plot(tmp,cumu2,'o');
        xtitle='Number of Eqs ';
    end
end