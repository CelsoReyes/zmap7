function equi=equevent()
    %  equevent.m                                       A.Allmann
    % calculates equivalent event to a cluster
    % weight according to seismic moment
    % time for equivalent event is time of first biggest event
    %
    % Last change 11/95
     report_this_filefun(mfilename('fullpath'));
   
    global clus ZG.newcat  cluslength bg clustnumbers

    if ~any(clus)
        equi = [nan,nan,nan,nan,nan,nan,nan,nan,nan,nan];
        return
    end
    j=0;
    eqmoment=10.^(ZG.newcat.Magnitude.*1.2);

    for n=1:max(clus)
        l = clus == n;
        if max(l) > 0
            j = j + 1;
            emoment=sum(eqmoment(l));         %moment

            weight=eqmoment(l)./emoment;      %weightfactor
            elat(j)=sum(ZG.newcat.Latitude(l).*weight);
            elon(j)=sum(ZG.newcat.Longitude(l).*weight); %longitude
            edep(j)=sum(ZG.newcat.Depth(l).*weight); %depth
            emag(j)=(log10(emoment))/1.2;
        end

    end


    %equivalent events for each cluster
    %TODO put this in a ZmapCatalog
    equi=[elat' elon' decyear(ZG.newcat.Date(bg)) ZG.newcat.Month(bg) ZG.newcat.Day(bg),...
        emag' edep' ZG.newcat.Hour(bg) ZG.newcat.Minute(bg) ZG.newcat.Second(bg)];


