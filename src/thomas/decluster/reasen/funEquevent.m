function equi=equevent
%  equevent.m                                       A.Allmann
% calculats equivalent event to a cluster
% weight according to seismic moment
% time for equivalent event is time of first biggest event
%
% Last change 11/95
global clus ZG.newcat  cluslength bg clustnumbers

j=0;
eqmoment=10.^(ZG.newcat.Magnitude.*1.2);

for n=1:max(clus)
   l = clus == n;
   if max(l) >0
      j = j + 1;
      emoment=sum(eqmoment(l));         %moment

      weight=eqmoment(l)./emoment;      %weightfactor
      elat(j)=sum(ZG.newcat(l,1).*weight); %latitude
      elon(j)=sum(ZG.newcat(l,2).*weight); %longitude
      edep(j)=sum(ZG.newcat(l,7).*weight); %depth
      emag(j)=(log10(emoment))/1.2;
   end

end


%equivalent events for each cluster
equi=[elat' elon' ZG.newcat(bg,3) ZG.newcat(bg,4) ZG.newcat(bg,5) emag' edep' ZG.newcat(bg,8) ZG.newcat(bg,9)];


