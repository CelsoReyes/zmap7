N = size(E,1);				% N= # of events in the catalogue; E= Earthquake catalogue
pairtime = []; 			% pairdist= Vector of interevent distances
j = nchoosek(N,2);			% j= # of interevent distances calculated
pairtime = zeros(j,1);
k = 0;

for i = 1:(N-1)

    time1 = repmat(E(i,3), [(N-i),1]);
    time2 = E((i+1):end, 3);

    pairtime(k+1:k + size(time1, 1)) = abs(time1-time2);

end


HSTS = figure;
plot(pairtime, log2(pairdist), 'k.');
axis([0 0.1 -8 6])
