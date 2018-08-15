function ran = dorand(obj, params) 
    % Calculates any desired number of random distributed points with different
    % random distributions and geometries.
    %
    % Francesco Pacchiani 1/2000
    
    long = long2 - long1;
    long3 = (long1 + long2)/2;
    
    if long == 0
        long1 = long1-0.1;
        long2 = long2+0.1;
        long = long2-long1;
    end
    
    lati = lati2 - lati1;
    lati3 = (lati1 + lati2)/2;
    
    if lati == 0
        lati1 = lati1-0.1;
        lati2 = lati2+0.1;
        lati = lati + 0.2;
    end
    
    dept = dept2 - dept1;
    dept3 = (dept1 + dept2)/2;
    ran = [];
    rannor = [];
    
    ratx = long*111/100;
    raty = lati*111/100;
    ratz = abs(dept)/100;
    %
    %
    % Creates the chosen random catalog
    %
    switch (distr)
        
        case 1 % Random catalog in a parallelepiped of similar volume as the real earthquake distribution.
            
            ran = [((rand(numran,1).*long)+ long1), ((rand(numran,1).*lati)+ lati1), rand(numran,1),rand(numran,1),rand(numran,1),rand(numran,1), (rand(numran,1).*dept)];
            ranp = ran(:,[1 2 7]);
            ranp(:,3) = [-ranp(:,3)];
            
            plot_it(distr);
            
            clear ranp
            butto = 'button';
            
            
        case 2  %Random 2-dimensional Sierpinski Gasket.
            
            siergas2d;
            
            plot_it(distr)
            clear ratx raty ratz ranp
            butto = 'button';
            
            
        case 3  %Random 3-dimensional Sierpinski Gasket.
            
            siergas3d;
            
            plot_it(distr)
            
            clear ratx raty ratz ranp
            butto = 'button';
            
            
        case 4  %Random points in the real complex volume distributed normally about the hypocenter.
            
            if stdx == 0
                nerrx = 0;
            else
                nerrx = normrnd(0,stdx/111, numran,1);  %Creates an error of normal distribution with mean = 0 and sigma = stdx chosen in the menu randomcat.m
                %nerrx = unifrnd(0,stdx/111, numran,1);	  %Creates an error of uniform distribution with values ranging from 0 to stdx.
            end
            
            if stdy == 0
                nerry = 0;
            else
                nerry = normrnd(0,stdy/111, numran,1);
                %nerry = unifrnd(0,stdy/111, numran,1);
            end
            
            if stdz == 0
                nerrz = 0;
            else
                nerrz = normrnd(0,stdz, numran,1);
                %nerrz = unifrnd(0,stdz, numran,1);
            end
            
            if numran < size(a,1)+1
                
                E = E(1:numran,:);
            else
                
                str5 = 'Not an appropriate input value: the number of random events must be equal or smaller than the numnber of events in the real distribution';
                msg3 = msgbox(str5, 'Input Error');
                waitforbuttonpress;
                close(msg3);
                obj.randomcat();
                
            end
            
            clear str5 msg3
            
            ran1 = [E.Longitude+ nerrx, E.Latitude + nerry, rand(size(E,1),1),rand(size(E,1),1),rand(size(E,1),1),rand(size(E,1),1), (E.Depth + nerrz)];
            %ran2 = find(ran1(:,7)>0.1);
            ran = ran1;%(ran2,:);
            ranp = ran(:,[1 2 7]);
            ranp(:,3) = [-ranp(:,3)];
            clear ran2 ran1
            
            
            plot_it(distr)
            
            clear ranp ratx raty ratz
            butto = 'button';
            
            
        case 5 % Same as one except that the points follow a normal distribution.
            
            rannor = [random('Normal',0,0.000001,numran,1), random('Normal',0,0.5,numran,1), zeros(numran,1),zeros(numran,1),zeros(numran,1),zeros(numran,1),random('Normal',0,0.05,numran,1)];
            
            norlon = max(abs(rannor(:,1)));
            norlat = max(abs(rannor(:,2)));
            nordept = max(abs(rannor(:,7)));
            ran = [(((rannor(:,1)./norlon).*long)+(long1+long2)/2), (((rannor(:,2)./norlat).*lati)+(lati1+lati2)/2), rand(numran,1),rand(numran,1),rand(numran,1),rand(numran,1), (((rannor(:,7)./nordept).*dept)+(-(dept1+dept2)/2))];
            elim = find(ran(:,7) < 0);
            ran = ran(elim,:);
            
            long1 = min(ran(:,1));
            long2 = max(ran(:,1));
            lati1 = min(ran(:,2));
            lati2 = max(ran(:,2));
            dept1 = min(abs(ran(:,7)));
            dept2 = max(abs(ran(:,7)));
            
            clear norlon norlat nordept elim;
            plot_it(distr)
            
            butto = 'button';
            
            
        case 6  % Random points in a sphere
            
            switch (params.rndsph)
                
                case 'distr3a'  % Selection of the spherical parameters. Input window.
                    
                    radiusx = 0.09;
                    radiusy = 0.09;
                    radiusz = 10;
                    centerx = long3;
                    centery = lati3;
                    centerz = -dept;
                    butto = 'buttoff';
                    
                case 'distr3b'	% Creation of the random catalog.
                    
                    radix = rand(numran,1).*radiusx;
                    radiy = rand(numran,1).*radiusy;
                    radiz = rand(numran,1).*radiusz;
                    phi = rand(numran,1).*360;
                    teta = rand(numran,1).*180;
                    rlong = (radix.*sin(phi).*cos(teta)) + centerx;
                    rlat = (radiy.*sin(phi).*sin(teta)) + centery;
                    rdep = (radiz.*cos(phi)) + centerz;
                    %rlong = (radiusx.*sin(phi).*cos(teta)) + centerx;  % The next three lines create a disc.
                    %rlat = (radiusy.*sin(phi).*cos(teta)) + centery;
                    %rdep = (radiusz.*cos(phi)) + centerz;
                    fi = find(rdep<0);
                    rdep = rdep(fi);
                    rlong = rlong(fi);
                    rlat = rlat(fi);
                    clear fi;
                    
                    ran = [rlong, rlat, rand(size(rdep,1),1),rand(size(rdep,1),1),rand(size(rdep,1),1),rand(size(rdep,1),1), rdep];
                    
                    %
                    %
                    % Construction of the plot.
                    %
                    ratx = (max(rlong)-min(rlong))*111/100; % Ratio parameters for the plot.
                    raty = (max(rlat)-min(rlat))*111/100;
                    ratz = (max(rdep)+min(rdep))/100;
                    
                    plot_it(distr)
                    clear rnlong rnlat rlong rlat rdep phi teta radix radiy radiz ratx raty ratz
                    butto = 'button';
                    
            end
            
            
    end %switch (distr)
    %
    %
    % Creation of buttons
    %
    switch(butto)
        
        case 'buttoff'
            
            rndsphparain;
            
        case 'button'
            
            uicontrol('Units','normal','Position',[.0 .94 .2 .06],...
                'String','Fractal Dimension', 'callback',@cb_fractal_dimension);
            
            uicontrol('Units','normal','Position',[.2 .94 .2 .06],...
                'String','Change Catalog', 'callback',@cb_change_catalog);
            
            uicontrol('Units','normal','Position',[.4 .94 .2 .06],...
                'String','Keep as Catalog', 'callback',@cb_keep_as_catalog);
            
            
    end  %switch (butto)
    
    function cb_fractal_dimension(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        E = ran;
        gobut = 1;
        org = 1;
        startfd(org,catalog,gobut);
    end
    
    function cb_change_catalog(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close;
        E = a;
        obj.randomcat();
    end
    
    function cb_keep_as_catalog(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        E = ran;
        ao=a;
        replaceMainCatalog(ran);
        zmap_update_displays();
    end
    
    function plot_it(n)
        Hfig = figure('NumberTitle','off','Name','Random Catalog','toolbar','figure');
        switch (n)
            case 1
                rpts = plot3 (ranp(:,1), ranp(:,2), ranp(:,3),'r.', 'MarkerSize', 4);
                axis([long1 long2  lati1  lati2  -dept2 -dept1]);
                titletext = sprintf('%.0f Randomly Distributed Points', numran);
            case 2
                rpts = plot3 (ranp(:,1), ranp(:,2), ranp(:,3),'r.', 'MarkerSize', 4);
                axis([long1 long2 lati1 lati2 -dept2 -dept1]);
                titletext = sprintf('%.0f Normally Distributed Points', numran);
            case 3
                rpts = plot3 (ranp(:,1), ranp(:,2), ranp(:,3),'r.', 'MarkerSize', 4);
                axis([long1 long2 lati1 lati2 -dept2 -dept1]);
                titletext = sprintf('%.0f Normally Distributed Points', numran);
                
            case 4
                plot3 (ranp(:,1), ranp(:,2), ranp(:,3),'r.', 'MarkerSize', 4);
                axis([long1 long2  lati1  lati2  -dept2 -dept1]);
                titletext = sprintf('%.0f Points Normally Distributed About the Hypocenters', size(ran,1));
            case 5
                rpts = plot3 (ran(:,1), ran(:,2), ran(:,7),'r.', 'MarkerSize', 4);
                axis([long1 long2 lati1 lati2 -dept2 -dept1]);
                titletext = sprintf('%.0f Normally Distributed Points', numran);
            case 6
                rndsph = plot3 (ran(:,1), ran(:,2), ran(:,7),'r.', 'MarkerSize', 4);
                axis([min(rlong) ,max(rlong) min(rlat) max(rlat) min(rdep) max(rdep)]);
                titletext = sprintf('%.0f Points Randomly Distributed in a Sphere', numran);
        end
        
        set(gca,'pos',[0.15 0.11 0.76 0.76], 'plotboxaspectratio', [ratx raty ratz]);
        xlabel('Longitude', 'fontsize', 12);
        ylabel('Latitude', 'fontsize', 12);
        zlabel('Depth', 'fontsize', 12);
        title(titletext, 'fontsize', 14);
        box on
        
    end
end

