function plotmi(var1)
    %plot misfit (?)
    % TODO make this work with the new catalogs
    report_this_filefun(mfilename('fullpath'));
    
    global  a mi mif2 mif1 newcat2
    global tmp cumu2 mi2
    newcat2 = a;
    figNumber=findobj('Type','Figure','-and','Name','Misfit ');
    figure(figNumber);
    delete(findobj(figNumber,'Type','axes'));
    rect = [0.15,  0.15, 0.75, 0.65];
    axes('position',rect)
    
    tmp1=length(newcat2(:,1));
    tmp=1:tmp1;
    tmp2=round(0:tmp1/5:tmp1);
    tmp2(1)=1;
    var2=var1;
    
    switch (var1)
        case 1
            plot_by_lon(); %by lon
        case 3
            plot_by_time(); % by lat
        case 2
            plot_by_lat(); % by time
        case 4
            plot_by_mag(); % by mag
        case 5
            plot_by_depth() %  by depth
        case 6
            plot_by_strike(); % along strike
        case 7
            option_7(); %unsorted
        otherwise
            error('unknown choice for plotmi');
    end
    
    grid
    set(gca,'Color',color_bg);
    set(gca,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
    ylabel('Cumulative Misfit ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m);
    xlabel(xtitle,'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    
    if var1~=7
        hold on
        for i=1:6
            plot(tmp(tmp2(i)),cumu2(tmp2(i)),'xr');
            str=['  ',num2str(newcat2(tmp2(i),var2))];
            te=text(tmp(tmp2(i)),cumu2(tmp2(i)),str);
            set(te,'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
        end
    end
    
    
    function plot_by_lon()
        [~,is] = sort(newcat2.Longitude);
        newcat2 = newcat2(is(:,1),:) ;
        mi2 = mi(is(:,1),:) ;
        cumu2=cumsum(mi2(:,2));
        pl = plot(tmp,cumu2,'o');
        xtitle='Number of Eqs (sorted by longitude) ';
    end
    
    function plot_by_lat()
        [~,is] = sort(newcat2.Latitude);
        newcat2 = newcat2(is(:,1),:) ;
        mi2 = mi(is(:,1),:) ;
        cumu2=cumsum(mi2(:,2));
        pl = plot(tmp,cumu2,'o');
        xtitle='Number of Eqs (sorted by latitude) ';
    end
    
    function plot_by_time()
        [~,is] = sort(newcat2.Date);
        newcat2 = newcat2(is(:,1),:) ;
        mi2 = mi(is(:,1),:) ;
        cumu2=cumsum(mi2(:,2));
        pl = plot(tmp,cumu2,'o');
        xtitle='Number of Eqs (sorted by time)';
    end
    
    function plot_by_mag()
        [~,is] = sort(newcat2.Magnitude);
        newcat2 = newcat2(is(:,1),:) ;
        mi2 = mi(is(:,1),:) ;
        cumu2=cumsum(mi2(:,2));
        pl = plot(tmp,cumu2,'o');
        xtitle='Number of Eqs (sorted by magnitude)';
        var2=6;
    end
    
    function plot_by_depth()
        [~,is] = sort(newcat2.Depth);
        newcat2 = newcat2(is(:,1),:) ;
        mi2 = mi(is(:,1),:) ;
        cumu2=cumsum(mi2(:,2));
        pl = plot(tmp,cumu2,'o');
        xtitle='Number of Eqs (sorted by depth)';
        var2=7;
    end
    
    function plot_by_strike()
        % [~,is] = sort(newcat2(:,15));
        [~,is] = sort(newa(:, length(newa(1,:)) ));
        newa2 = newa(is(:,1),:) ;
        mi2 = mi(is(:,1),:) ;
        cumu2=cumsum(mi2(:,2));
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