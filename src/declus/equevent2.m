function equi=equevent
    %  equevent.m                                       A.Allmann
    % calculats equivalent event to a cluster
    % weight according to seismic moment
    % time for equivalent event is time of first biggest event
    %

    global clust newcat  cluslength bg clustnumbers

    n=0;
    eqmoment=10.^(newcat.Magnitude.*1.2);

    for j=clustnumbers
        if clust(30,j)==1
            bsclu=clust(find(clust(:,j)),j);
        else
            bsclu=bcluster(j);
        end
        emoment=sum(eqmoment(bsclu));         %moment
        weight=eqmoment(bsclu)./emoment;      %weightfactor
        elat(n)=sum(newcat(bsclu,1).*weight); %latitude
        elon(n)=sum(newcat(bsclu,2).*weight); %longitude
        edep(n)=sum(newcat(bsclu,7).*weight); %depth
        emag(n)=(log10(emoment))/1.2;                            %magnitude
    end

    %equivalent events for each cluster
    equi=[elat' elon' newcat(bg,3) newcat(bg,4) newcat(bg,5) emag' edep' newcat(bg,8) newcat(bg,9)];


