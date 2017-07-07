function[fdkm,s1x,s1y,s2x,s2y] = distofault(nodes,xvect,yvect)

    %function[fdkm, nodes] = distofault(nodex,nodey);
    %%
    % this calculates a guess at the fault length and direction
    % based on the early seismicity, for use in th Generic Cali
    % model forecast.  It also calulates the distance from each
    % grid node to the closest fault segment.
    %%

report_this_filefun(mfilename('fullpath'));
    global newt2 maepi

    %%
    % regrid the grid data into pairs
    %%
    %nodes = [];
    %ct = 1;
    %for i = 1:length(nodex)
    %    for j = 1:length(nodey)
    %        nodes(ct,:) = [nodex(i) nodey(j)];
    %        ct = ct + 1;
    %    end
    %end

    %%
    % find the extremes in the obs data to get est. fault length
    % take the 1% and 99% distance to avoid extreme eq locations
    %%
    [latsort,lasi] = sort(newt2.Latitude);
    [longsort, losi] = sort(newt2.Longitude);
    mila = round(length(latsort)*.01);
    mala = round(length(latsort)*.99);
    milo = round(length(longsort)*.01);
    malo = round(length(longsort)*.99);
    minlat = latsort(mila);
    maxlat = latsort(mala);
    minlong = longsort(milo);
    maxlong = longsort(malo);

    %[minlat,mila] = min(newt2.Latitude);
    %[maxlat,mala] = max(newt2.Latitude);
    %[minlong,milo] = min(newt2.Longitude);
    %[maxlong,malo] = max(newt2.Longitude);

    latl = maxlat-minlat;
    longl = maxlong-minlong;

    if latl > longl
        tope = newt2(lasi(mala),1:2);
        bote = newt2(lasi(mila),1:2);
    else
        tope = newt2(losi(malo),1:2);
        bote = newt2(losi(milo),1:2);
    end

    %%
    % break fault into two segments around the mainshock
    %%
    seg1 = [tope(:,1) tope(:,2) maepi(:,1) maepi(:,2)];
    seg2 = [maepi(:,1) maepi(:,2) bote(:,1) bote(:,2)];

    %%
    % interpolate the segments
    %%
    nint=100;
    s1x = linspace(seg1(:,1), seg1(:,3), nint);
    s1y = linspace(seg1(:,2), seg1(:,4), nint);
    s2x = linspace(seg2(:,1), seg2(:,3), nint);
    s2y = linspace(seg2(:,2), seg2(:,4), nint);

    %%
    % plot the fault segments
    %%

    %figure
    %plot(s1x,s1y)
    %hold on
    %plot(s2x,s2y)
    %plot(nodes(:,1),nodes(:,2),'+k');

    %%
    % now loop over all grid nodes to find the distance to fault
    %%

    geoid = [0, 0];

    for nloop = 1:length(nodes)
        %%
        % find the min to each interpolated segment
        %%
        for i =  1:nint
            d1(i) = distance(s1x(i),s1y(i),nodes(nloop,1),nodes(nloop,2));
            d2(i) = distance(s2x(i),s2y(i),nodes(nloop,1),nodes(nloop,2));
        end
        fd(nloop) = min(min(d1),min(d2));
    end

    %%
    % convert to km's
    %%
    fdkm = deg2km(fd);

    %plot_tapera(fdkm,s1x,s1y,s2x,s2y,nodes,xvect,yvect);
