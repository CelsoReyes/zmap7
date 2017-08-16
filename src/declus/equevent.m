function equi=equevent(mycat,clus)
% equevent calc equivalent event to cluster
% equi = equevent(catalog, cluster, bg)
%   catalog : earthquake catalog
%   cluster
%   bg : index of a big event (?)
    %  equevent.m                        A.Allmann
    % calculates equivalent event to a cluster
    % weight according to seismic moment
    % time for equivalent event is time of first biggest event
    %
     report_this_filefun(mfilename('fullpath'));
   
    global bg

    equi=ZmapCatalog;
    equi.Name='clusters';

    if ~any(clus)
        return
    end
    j=0;
    eqmoment=10.^(mycat.Magnitude.*1.2);

    for n=1:max(clus)
        l = clus == n;
        if max(l) > 0
            j = j + 1;
            emoment=sum(eqmoment(l));         %moment

            weight=eqmoment(l)./emoment;      %weightfactor
            elat(j)=sum(mycat.Latitude(l).*weight);
            elon(j)=sum(mycat.Longitude(l).*weight); %longitude
            edep(j)=sum(mycat.Depth(l).*weight); %depth
            emag(j)=(log10(emoment))/1.2;
        end

    end


    %equivalent events for each cluster
    %TODO put this in a ZmapCatalog
    equi.Latitude=elat(:);
    equi.Longitude=elon(:);
    equi.Date=mycat.Date(bg); % why is this dissimilar?
    assert(isequal(size(equi.Date),size(equi.Longitude)))
    equi.Magnitude=emag(:);
    equi.Depth=edep(:);



