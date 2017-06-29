% This code calculates the 3D distances between all possible pairs
% (combination of n epicenters taken 2 at a time) of earthquakes of
% a given dataset.
%
%
% Attributing the corresponding catalog to E
%
if ~exist('index', 'var')
    index = 1;
end

if index == 1
    E = newt2;
elseif index == 2
    E = ran;
elseif index == 3
    E = rann;
end
%
% Variables
%
N = size(E,1);				% N= # of events in the catalogue; E= Earthquake catalogue
pairdist = []; 			% pairdist= Vector of interevent distances
j = nchoosek(N,2)			% j= # of interevent distances calculated
pairdist = zeros(j,1);
depth = zeros(j,1);
k = 0;

Ho_Wb = waitbar(0,'Calculating the fractal dimension');
Hf_Cfig = gcf;
Hf_child = get(groot,'children');
set(Hf_child,'pointer','watch','papertype','A4');
%
% Calculation of the interevent distances in 2D plus the depths differences.
%
for i = 1:(N-1)

    lon1 = repmat(E(i,1), [(N-i),1]);
    lat1 = repmat(E(i,2), [(N-i),1]);
    depth1 = repmat(E(i,7), [(N-i),1]);
    lon2 = E((i+1):end, 1);
    lat2 = E((i+1):end, 2);
    depth2 = E((i+1):end, 7);
    pairdist(k+1:k + size(lon1, 1)) = distance(lat1,lon1,lat2,lon2);
    depth(k+1:k + size(lon1, 1)) = depth1-depth2;
    k = k + size(lon1,1);
    waitbar((0.5/(N-1))*i, Ho_Wb);

end
%
% Converts the interevent distances from degrees to kilometers and calculates
% the interevent distances in three dimensions.
%
pairdist = pairdist.*111;
pairdist = (pairdist.^2 + depth.^2).^0.5;
clear depth;
%
% Compute the correlation integral
%
d = 3;			%the embedding dimension
docorint;
