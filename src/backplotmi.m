function plotmi(var1)

    global a mi fontsz term cb1 cb2 cb3 mif2 mif1

    report_this_filefun(mfilename('fullpath'));

    newcat2 = a;
    [existFlag,figNumber]=figure_exists('Misfit ',1);
    figure_w_normalized_uicontrolunits(figNumber)

    delete(gca);delete(gca);
    delete(gca);delete(gca);

    rect = [0.15,  0.15, 0.75, 0.65];
    axes('position',rect)

    if var1 == 1

        [s,is] = sort(newcat2(:,1));
        newcat2 = newcat2(is(:,1),:) ;
        mi2 = mi(is(:,1),:) ;
        pl = plot(newcat2(:,1),cumsum(mi2(:,2)),'b')
        set(pl,'LineWidth',2.0)
        grid
        if term > 1; set(gca,'Color',[cb1 cb2 cb3]); end
        set(gca,'box','on',...
            'SortMethod','childorder','TickDir','out','FontWeight',...
            'bold','FontSize',fontsz.m,'Linewidth',1.2)
        xlabel('Longitude ','FontWeight','bold','FontSize',fontsz.m)
        ylabel('Cumulative Misfit ','FontWeight','bold','FontSize',fontsz.m)

    elseif var1 == 3
        [s,is] = sort(newcat2(:,3));
        newcat2 = newcat2(is(:,1),:) ;
        mi2 = mi(is(:,1),:) ;
        pl = plot(newcat2(:,3),cumsum(mi2(:,2)),'b')
        set(pl,'LineWidth',2.0)
        grid
        if term > 1; set(gca,'Color',[cb1 cb2 cb3]); end
        set(gca,'box','on',...
            'SortMethod','childorder','TickDir','out','FontWeight',...
            'bold','FontSize',fontsz.m,'Linewidth',1.2)

        xlabel('Time in [Years]','FontWeight','bold','FontSize',fontsz.m)
        ylabel('Cumulative Misfit ','FontWeight','bold','FontSize',fontsz.m)

    elseif var1 == 2
        [s,is] = sort(newcat2(:,var1));
        newcat2 = newcat2(is(:,1),:) ;
        mi2 = mi(is(:,1),:) ;
        pl = plot(newcat2(:,var1),cumsum(mi2(:,2)),'b')
        set(pl,'LineWidth',2.0)
        grid
        if term > 1; set(gca,'Color',[cb1 cb2 cb3]); end
        set(gca,'box','on',...
            'SortMethod','childorder','TickDir','out','FontWeight',...
            'bold','FontSize',fontsz.m,'Linewidth',1.2)

        xlabel('Latitude ','FontWeight','bold','FontSize',fontsz.m)
        ylabel('Cumulative Misfit ','FontWeight','bold','FontSize',fontsz.m)

    elseif var1 == 4
        [s,is] = sort(newcat2(:,6));
        newcat2 = newcat2(is(:,1),:) ;
        mi2 = mi(is(:,1),:) ;
        pl = plot(newcat2(:,6),cumsum(mi2(:,2)),'b')
        set(pl,'LineWidth',2.0)
        grid
        if term > 1; set(gca,'Color',[cb1 cb2 cb3]); end
        set(gca,'box','on',...
            'SortMethod','childorder','TickDir','out','FontWeight',...
            'bold','FontSize',fontsz.m,'Linewidth',1.2)

        xlabel('Magnitude ','FontWeight','bold','FontSize',fontsz.m)
        ylabel('Cumulative Misfit ','FontWeight','bold','FontSize',fontsz.m)

    elseif var1 == 5
        [s,is] = sort(newcat2(:,7));
        newcat2 = newcat2(is(:,1),:) ;
        mi2 = mi(is(:,1),:) ;
        pl = plot(newcat2(:,7),cumsum(mi2(:,2)),'b')
        set(pl,'LineWidth',2.0)
        grid
        if term > 1; set(gca,'Color',[cb1 cb2 cb3]); end
        set(gca,'box','on',...
            'SortMethod','childorder','TickDir','out','FontWeight',...
            'bold','FontSize',fontsz.m,'Linewidth',1.2)

        xlabel('Depth in [km] ','FontWeight','bold','FontSize',fontsz.m)
        ylabel('Cumulative Misfit ','FontWeight','bold','FontSize',fontsz.m)


    end   % if var1

