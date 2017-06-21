%
% This code calculates the interevent distances and the correlation integral
% of a subset selected with the sampling sphere. The code is called from circlefd.m.
% Francesco Pacchiani 1/2000
%
% Calculation of the 3D distances between all possible pairs
% (combination of n epicenters taken 2 at a time) of earthquakes of
% the given dataset.
%
%
% Variables
%
N = size(E,1);				% N= # of events in the catalogue; E= Earthquake catalogue
pairdist = []; 			% pairdist= Vector of interevent distances
j = nchoosek(N,2);			% j= # of interevent distances calculated
pairdist = zeros(j,1);
k = 0;
%E.Latitude= (max(Da(:,2))+min(Da(:,2)))/2;


Ho_Wb = waitbar(0,'Calculating the fractal dimension D');
Hf_Cfig = gcf;
Hf_child = get(groot,'children');
set(Hf_child,'pointer','watch','papertype','A4');
%
%
% Calculation of the interevent distances in 2D plus the depths differences.
%
%
for i = 1:(N-1)

    lon1 = repmat(E(i,1), [(N-i),1]);
    lat1 = repmat(E(i,2), [(N-i),1]);

    lon2 = E((i+1):end, 1);
    lat2 = E((i+1):end, 2);

    pairdist(k+1:k + size(lon1, 1)) = distance(lat1,lon1,lat2,lon2);

    k = k + size(lon1,1);

    waitbar((0.75/(N-1))*i, Ho_Wb);

end

clear i j k;
%
%
% Conversion of the interevent distances from degrees to kilometers and calculates
% the interevent distances in three dimensions.
%
%
if dtokm == 1
    pairdist = pairdist.*111;
end
%
%
% Calculation of the correlation integral using as input the
% pair distances computed above.
%
%
% Variables
%
d = 2;						%d = the dimension of the embedding volume.
rmax = max(pairdist);
rmin = min(pairdist);

if rmin == 0
    rmin = 0.01;
end

lrmin = log10(rmin);
lrmax = log10(max(pairdist));

%u = (log10(rmin):0.15:log10(rmax))';
%
% Defining the distance vector r in order that on the
% log-log graph all the points plot at equal distances from one another.
%
r = (logspace(lrmin, lrmax, 50))';
%r = zeros(size(u,1),1);
%r = 10.^u;
%
%
corint = [];						% corint= Vector of ?cumulative? correlation integral values for increasing interevent radius
corint = zeros(size(r,1),1);
k = 1;

for i = 1:size(r,1)

    j = [];
    j = pairdist < r(i);
    corint (k,1) = (2/(N*(N-1)))*sum(j);
    k = k + 1;
    waitbar(0.75 + (0.25/size(r,1))*i,Ho_Wb);

end

clear i j k;
close(Ho_Wb);
Hf_child = get(groot,'children');
set(Hf_child,'pointer','arrow');
%
%
dofd = 'fd';
