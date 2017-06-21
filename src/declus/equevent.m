function equi=equevent()
    %  equevent.m                                       A.Allmann
    % calculates equivalent event to a cluster
    % weight according to seismic moment
    % time for equivalent event is time of first biggest event
    %
    % Last change 11/95
     report_this_filefun(mfilename('fullpath'));
   
    global clus newcat  cluslength bg clustnumbers

    if ~any(clus)
        equi = [nan,nan,nan,nan,nan,nan,nan,nan,nan,nan];
        return
    end
    j=0;
    eqmoment=10.^(newcat.Magnitude.*1.2);

    for n=1:max(clus)
        l = clus == n;
        if max(l) > 0
            j = j + 1;
            emoment=sum(eqmoment(l));         %moment

            weight=eqmoment(l)./emoment;      %weightfactor
            elat(j)=sum(newcat.Latitude(l).*weight);
            elon(j)=sum(newcat.Longitude(l).*weight); %longitude
            edep(j)=sum(newcat.Depth(l).*weight); %depth
            emag(j)=(log10(emoment))/1.2;
        end

    end


    %equivalent events for each cluster
    %TODO put this in a ZmapCatalog
    equi=[elat' elon' decyear(newcat.Date(bg)) newcat.Month(bg) newcat.Day(bg),...
        emag' edep' newcat.Hour(bg) newcat.Minute(bg) newcat.Second(bg)];


