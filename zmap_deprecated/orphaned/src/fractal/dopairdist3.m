% This code calculates the 3D distances between all possible pairs
% (combination of n epicenters taken 2 at a time) of earthquakes of
% a given dataset.
%
%disp('fractal/codes/dopairdist3.m');
%
% Variables
%
N = size(E,1);	% N= # of events in the catalogue; E= Earthquake catalogue
pairdist = []; 			% pairdist= Vector of interevent distances
j = nchoosek(N,2);			% j= # of interevent distances calculated
pairdist = zeros(j,1);
depth = zeros(j,1);
k = 0;
%E.Latitude= (max(Da(:,2))+min(Da(:,2)))/2;
Ho_Wb = waitbar(0,'Calculating the interevent distances');
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

    waitbar((1/(N-1))*i, Ho_Wb);

end

clear i j k;
%
% Converts the interevent distances from degrees to kilometers and calculates
% the interevent distances in three dimensions.
%
close(Ho_Wb);
str4 = 'Calculating';
msg2 = msgbox(str4,'Message');

if dtokm == 1
    pairdist = pairdist.*111;
end

pairdist = (pairdist.^2 + depth.^2).^0.5;
clear depth;
%
% Compute the correlation integral
%
d = 3;			%the embedding dimension
docorint;
