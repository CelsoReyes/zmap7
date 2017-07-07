function plot_tapera(fdkm,s1x,s1y,s2x,s2y,nodes,xvect,yvect)

    %normlap2= tapera';
    normlap2= fdkm;
    re3=reshape(normlap2,length(yvect),length(xvect));
    figure
    pcolor(xvect,yvect,re3)
    shading interp
    hold on
    plot(s1x,s1y,'k');
    plot(s2x,s2y,'k');
    plot(nodes(:,1),nodes(:,2),'+k');

    colorbar
