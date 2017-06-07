function plotmima(var1)

    report_this_filefun(mfilename('fullpath'));

    global a mi fontsz term cb1 cb2 cb3 mif2 mif1 hndl3

    sc = get(hndl3,'Value');
    mi(:,2) = mi(:,2)+1;
    figure_w_normalized_uicontrolunits(mif1)

    delete(gca);delete(gca);
    rect = [0.15,  0.20, 0.75, 0.65];
    axes('position',rect)
    watchon


    if var1 == 1

        for i = 1:length(a(:,6))
            pl =  plot(a(i,1),a(i,2),'ro');
            hold on
            set(pl,'MarkerSize',mi(i,2)/sc)
        end

    elseif var1 == 2

        for i = 1:length(a(:,6))
            pl =  plot(a(i,1),a(i,2),'bx');
            hold on
            set(pl,'MarkerSize',mi(i,2)/sc,'LineWidth',mi(i,2)/sc)
        end

    elseif var1 == 3

        for i = 1:length(a(:,6))
            pl =  plot(a(i,1),a(i,2),'bx');
            hold on
            c = mi(i,2)/max(mi(:,2));
            set(pl,'MarkerSize',mi(i,2)/sc,'LineWidth',mi(i,2)/sc,'Color',[ c c c ] )
        end

    elseif var1 == 4
        pl =  plot(a(:,1),a(:,2),'bx');
    end

    hold on
    %axis([ s2 s1 s4 s3])
    %overlay_

    xlabel('Longitude [deg]','FontWeight','bold','FontSize',fontsz.m)
    ylabel('Latitude [deg]','FontWeight','bold','FontSize',fontsz.m)
    strib = [  'Misfit Map '];
    title2(strib,'FontWeight','bold',...
        'FontSize',fontsz.m,'Color','k')

    if term > 1
        set(gca,'Color',[cb1 cb2 cb3]);
    end
    set(gca,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',fontsz.m,'Linewidth',1.2)
    mi(:,2) = mi(:,2)-1;
    watchoff
