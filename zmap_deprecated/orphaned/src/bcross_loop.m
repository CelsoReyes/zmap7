%function bvalgrid(dx,dy,ni)
% This subroutine assigns creates a grid with
% spacing dx,dy (in degreees). The size will
% be selected interactiVELY. The bvalue in each
% volume around a grid point containing ni earthquakes
% will be calculated as well as the magnitude
% of completness
%   Stefan Wiemer 1/95

report_this_filefun(mfilename('fullpath'));

miret = [];
n = newa.Count;
teb = newa(n,3) ;
tdiff = round((teb - t0b)*365/par1);
loc = zeros(3, length(gx)*length(gy));

for ni = 50:10:150
    % loop over  all points
    %
    i2 = 0.;
    i1 = 0.;
    bvg = [];
    allcount = 0.;
    wai = waitbar(0,[' Please Wait ...  ni =  ' num2str(ni)] );
    set(wai,'NumberTitle','off','Name','b-value grid - percent done');;
    drawnow
    %
    % longitude  loop
    %
    for x =  x0:dd:x1
        i1 = i1+ 1;

        % latitude loop
        %
        for  y = y0:dx:y1
            allcount = allcount + 1.;
            i2 = i2+1;

            % calculate distance from center point and sort wrt distance
            l = sqrt(((xsecx' - x)).^2 + ((xsecy + y)).^2) ;
            [s,is] = sort(l);
            b = newa(is(:,1),:) ;       % re-orders matrix to agree row-wise

            % take first ni points
            b = b(1:ni,:);      % new data per grid point (b) is sorted in distance

            % call the b-value function
            [bv magco stan av me mer me2,  rt] =  bvalca2(b);
            l = sort(l);
            bvg = [bvg ; bv magco x y l(ni) mean(b(:,6)) rt ];
            waitbar(allcount/itotal)
        end  % for y0
        i2 = 0;
    end  % for x0

    close(wai)

    % plot the results
    %
    % old and re3 (initially ) is the b-value matrix
    re3 = reshape(bvg(:,1),length(gy),length(gx));
    meg = reshape(bvg(:,6),length(gy),length(gx));
    ret = reshape(bvg(:,7),length(gy),length(gx));
    r = reshape(bvg(:,5),length(gy),length(gx));
    old = re3;
    % old1 is the magnitude of completness matrx
    old1 = reshape(bvg(:,2),length(gy),length(gx));

    [i1,i2] = find(ret ==  min(min(ret)) );
    i1 = min(i1);
    i2 = min(i2);
    miret = [miret ; min(min(ret)) ni r(i1,i2) ]

end   % for ni
figure
pl =  plot(miret(:,2),miret(:,1),'x')
set(pl,'Linewidth',2.0,'MarkerSize',14)
hold on
pl =  plot(miret(:,2),miret(:,1),'-b')
set(pl,'Linewidth',2.0)
xlabel('Number of events in each volume','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
ylabel('Minimum recurrence time','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)


