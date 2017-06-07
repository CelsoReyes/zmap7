report_this_filefun(mfilename('fullpath'));

load worldlo;

switch domask

    case 'coast'

        wo = worldlo('POline');
        cos = [wo(2).long , wo(2).lat ];
        bo =  [ wo(1).long , wo(1).lat ];
        cos = [cos ; bo];
        hold on
        plot(cos(1),cos(2),'k');

    case 'cities'

        ci = worldlo('PPpoint');
        cx = ci(1).long;
        cy = ci(1).lat;
        hold on
        plot(cx,cy,'sr','Markersize',8,'Markerfacecolor',[0.9 0.9 0.9])

    case 'rivers'

        ri = worldlo('DNline');
        hold on

        rx = [ri(1).long ; ri(2).long];
        ry = [ri(1).lat ; ri(2).lat ];
        hold on
        plot(rx,ry,'b','Linewidth',2);

end

