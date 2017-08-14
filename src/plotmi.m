function plotmi(var1)
%plot misfit (?)

    report_this_filefun(mfilename('fullpath'));

    global  a mi mif2 mif1 newcat2
    global tmp cumu2 mi2
    newcat2 = a;
    [existFlag,figNumber]=figure_exists('Misfit ',1);
    figure_w_normalized_uicontrolunits(figNumber)

    delete(gca);delete(gca);
    delete(gca);delete(gca);

    rect = [0.15,  0.15, 0.75, 0.65];
    axes('position',rect)

    tmp1=length(newcat2(:,1));
    tmp=1:tmp1;
    tmp2=round(0:tmp1/5:tmp1);
    tmp2(1)=1;
    var2=var1;

    if var1 == 1

        [s,is] = sort(newcat2(:,1));
        newcat2 = newcat2(is(:,1),:) ;
        mi2 = mi(is(:,1),:) ;
        cumu2=cumsum(mi2(:,2));
        % pl = plot(tmp,cumu2,'b');
        pl = plot(tmp,cumu2,'o');
        % set(pl,'LineWidth',2.0)
        grid
         set(gca,'Color',color_bg);
        set(gca,'box','on',...
            'SortMethod','childorder','TickDir','out','FontWeight',...
            'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
        xlabel('Number of Eqs (sorted by longitude) ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        ylabel('Cumulative Misfit ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)

    elseif var1 == 3
        [s,is] = sort(newcat2(:,3));
        newcat2 = newcat2(is(:,1),:) ;
        mi2 = mi(is(:,1),:) ;
        cumu2=cumsum(mi2(:,2));
        % pl = plot(tmp,cumu2,'b');
        pl = plot(tmp,cumu2,'o');
        % set(pl,'LineWidth',2.0)
        grid
         set(gca,'Color',color_bg);
        set(gca,'box','on',...
            'SortMethod','childorder','TickDir','out','FontWeight',...
            'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)

        xlabel('Number of Eqs (sorted by time)','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        ylabel('Cumulative Misfit ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)

    elseif var1 == 2
        [s,is] = sort(newcat2(:,var1));
        newcat2 = newcat2(is(:,1),:) ;
        mi2 = mi(is(:,1),:) ;
        cumu2=cumsum(mi2(:,2));
        % pl = plot(tmp,cumu2,'b');
        pl = plot(tmp,cumu2,'o');
        % set(pl,'LineWidth',2.0)
        grid
         set(gca,'Color',color_bg);
        set(gca,'box','on',...
            'SortMethod','childorder','TickDir','out','FontWeight',...
            'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)

        xlabel('Number of Eqs (sorted by latitude) ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        ylabel('Cumulative Misfit ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)

    elseif var1 == 4
        [s,is] = sort(newcat2(:,6));
        newcat2 = newcat2(is(:,1),:) ;
        mi2 = mi(is(:,1),:) ;
        cumu2=cumsum(mi2(:,2));
        % pl = plot(tmp,cumu2,'b');
        pl = plot(tmp,cumu2,'o');
        % set(pl,'LineWidth',2.0)
        grid
         set(gca,'Color',color_bg);
        set(gca,'box','on',...
            'SortMethod','childorder','TickDir','out','FontWeight',...
            'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)

        xlabel('Number of Eqs (sorted by magnitude)','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        ylabel('Cumulative Misfit ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        var2=6;
    elseif var1 == 5
        [s,is] = sort(newcat2(:,7));
        newcat2 = newcat2(is(:,1),:) ;
        mi2 = mi(is(:,1),:) ;
        cumu2=cumsum(mi2(:,2));
        % pl = plot(tmp,cumu2,'b');
        pl = plot(tmp,cumu2,'o');
        % set(pl,'LineWidth',2.0)
        grid
         set(gca,'Color',color_bg);
        set(gca,'box','on',...
            'SortMethod','childorder','TickDir','out','FontWeight',...
            'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)

        xlabel('Number of Eqs (sorted by depth)','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        ylabel('Cumulative Misfit ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        var2=7;
    elseif var1 == 6
        % [s,is] = sort(newcat2(:,15));
        [s,is] = sort(newa(:, length(newa(1,:)) ));
        newa2 = newa(is(:,1),:) ;
        mi2 = mi(is(:,1),:) ;
        cumu2=cumsum(mi2(:,2));
        % pl = plot(tmp,cumu2,'b');
        pl = plot(newa2(:,16)-18.6,cumu2,'o');
        % set(pl,'LineWidth',2.0)
        grid
         set(gca,'Color',color_bg);
        set(gca,'box','on',...
            'SortMethod','childorder','TickDir','out','FontWeight',...
            'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
        xlabel('Number of Eqs (sorted along strike)','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        ylabel('Cumulative Misfit ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        var2=15;

    elseif var1 == 7
        mi2 = mi ;
        cumu2=cumsum(mi2(:,2));
        % pl = plot(tmp,cumu2,'b');
        pl = plot(tmp,cumu2,'o');
        % set(pl,'LineWidth',2.0)
        grid
         set(gca,'Color',color_bg);
        set(gca,'box','on',...
            'SortMethod','childorder','TickDir','out','FontWeight',...
            'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
        xlabel('Number of Eqs ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        ylabel('Cumulative Misfit ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)



    end   % if var1
    if var1~=7
        hold on
        for i=1:6
            plot(tmp(tmp2(i)),cumu2(tmp2(i)),'xr');
            str=['  ',num2str(newcat2(tmp2(i),var2))];
            te=text(tmp(tmp2(i)),cumu2(tmp2(i)),str);
            set(te,'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
        end
    end

