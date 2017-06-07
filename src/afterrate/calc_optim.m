function [opt_radius,opt_interval,result,r,alldt,nummod,numreal,sigma] = calc_optim(a,rmin,rstep,rmax,tmin,tstep,Nmin,bootloops,maepi,choice)

    % function [opt_radius,opt_interval,result,r,alldt,nummod,numreal,sigma] = calc_optim(a,rmin,rstep,rmax,tmin,tstep,Nmin,bootloops,maepi,choice);
    % -------------------------------------------------------------------------
    %
    % optimisation of free parameters looking for seismic quiescences preceding large aftershocks
    %
    % Input parameters:
    %   a               Earthquake catalog (has to be complete in magnitude!)
    %   rmin,rstep,rmax Radius [degrees]
    %   tmin,tstep      Time [days]
    %   Nmin            minimum earthquake number in catalog
    %   bootloops       number of bootstrap loops
    %   maepi           mainshock (->ZMAP)
    %   choice          Nr. of M5+ aftershock
    %
    % Output parameters:
    %   opt_radius      radius around large aftershock
    %   opt_interval    time interval before large aftershock
    %   result          matrix containing relative seismic quiescences
    %   r, alldt        vectors with radii, forecast intervals
    %   numreal,nummod  observed/modeled nr. of aftershocks in interval
    %   sigma           uncertainty of forecast
    %
    % Samuel Neukomm
    % last update 25.02.2004

report_this_filefun(mfilename('fullpath'));
    % get mainshock / calculate delay times / cut catalogue at mainshock
    [m_main, main] = max(a(:,6));
    if size(a,2) == 9
        date_matlab = datenum(floor(a(:,3)),a(:,4),a(:,5),a(:,8),a(:,9),zeros(size(a,1),1));
    else
        date_matlab = datenum(floor(a(:,3)),a(:,4),a(:,5),a(:,8),a(:,9),a(:,10));
    end
    date_main = date_matlab(main);
    time_aftershock = date_matlab-date_main;
    l = time_aftershock(:) > 0;
    tas = time_aftershock(l);
    eqcatalogue = a(l,:);

    % choose one of large aftershocks
    l = eqcatalogue(:,6) >= 5;
    largeas = eqcatalogue(l,:);
    largetime = tas(l);
    eq = largeas(choice,:);
    eqt = largetime(choice);

    % get optimum parameters
    dist_lon = eqcatalogue(:,1)-eq(1);
    dist_lat = eqcatalogue(:,2)-eq(2);
    dist_dep = km2deg(eqcatalogue(:,7)-eq(7),6371);
    result = []; i = 1;
    numreal = []; nummod = []; sigma = [];
    for r = rmin:rstep:rmax % range of collection radius
        disp(num2str(r/rmax))
        l = (dist_lon.^2+dist_lat.^2+dist_dep.^2).^0.5 <= r;
        gpi = eqcatalogue(l,:);
        time_as = tas(l);
        l = time_as < eqt;
        gpi = gpi(l,:); % sub-catalogue to be analysed
        time_as = time_as(l); % corresponding delay times

        if length(time_as) >= Nmin
            dt = tmin; % interval before large aftershock
            j = 1; alldt = [];
            while dt < eqt % Changed eqt/2 to eqt
                [rc,realnum,modnum,sig] = calc_optrc(gpi,time_as,eqt-dt,eqt,bootloops,maepi); % determine significance
                if isnan(rc)==0
                    result(i,j) = rc;
                    numreal(i,j) = realnum;
                    nummod(i,j) = modnum;
                    sigma(i,j) = sig;
                else
                    result(i,j) = 0;
                    numreal(i,j) = 0;
                    nummod(i,j) = 0;
                    sigma(i,j) = 0;
                end
                alldt = [alldt; dt];
                dt = dt+tstep;
                j = j+1;
            end
        end
        i = i+1;
    end
    r = (rmin:rstep:rmax)';

    if isempty(result) == 0  &&  max(max(result)) > 0
        % find minimum
        [dum, j] = min(min(result));
        [dum, i] = min(result(:,j));
        opt_radius = r(i);
        opt_interval = alldt(j);

        % contourplot of results
        figure_w_normalized_uicontrolunits('Numbertitle','off','Name','Optimum quiescence')
        lim = ceil(abs(dum));
        pcolor(alldt,r,result)
        set(gca,'pos',[0.15 0.15 0.7 0.7])
        shading interp
        caxis([-lim lim]);
        load fourcolors
        j = [j(256:-1:1,:) ];
        colormap(j)
        set(gcf,'renderer','zbuffer');
        set(gca,'TickDir','out')
        h5 = colorbar;
        set(h5,'Tickdir','out','pos',[0.8 0.3 0.02 0.4]);
        hold on
        plot(opt_interval,opt_radius','*','Markersize',8,'linewidth',2,'color','k');
        string =['Radius = ' num2str(opt_radius) ' deg; Interval = ' num2str(opt_interval) ' days; RC = ' num2str(dum,3) ];
        title(string)
        string = ['Time interval before t1 = ' num2str(round(100*eqt)/100) ' [days]'];
        xlabel(string)
        ylabel('Radius [deg]');
        set(gcf,'color','w');

        l = (dist_lon.^2+dist_lat.^2+dist_dep.^2).^0.5 <= opt_radius;
        optcat = eqcatalogue(l,:);
        time_as = tas(l);
        l = time_as < eqt;
        optcat = optcat(l,:);
        plot_optfit(optcat,eqt-opt_interval,opt_interval,bootloops,maepi);
    else
        opt_radius = NaN;
        opt_interval = NaN;
        alldt = NaN;
    end
