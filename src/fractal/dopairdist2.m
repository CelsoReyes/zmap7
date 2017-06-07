% This code calculates the 2D distances between all possible pairs
% (combination of n epicenters taken 2 at a time) of earthquakes of
% a given dataset.
%
%disp('fractal/codes/dopairdist2.m');
%
% Variables
%
N = size(E,1);				% N= # of events in the catalogue; E= Earthquake catalogue
pairdist = []; 			% pairdist= Vector of interevent distances
j = nchoosek(N,2);			% j= # of interevent distances calculated
pairdist = zeros(j,1);
k = 0;


Ho_Wb = waitbar(0,'Calculating the interevent distances');
Hf_Cfig = gcf;
Ha_Cax = gca;
Hf_child = get(groot,'children');
set(Hf_child,'pointer','watch');
%
% Calculation of the interevent distances.
%
for i = 1:(N-1)

    lon1 = repmat(E(i,1),[(N-i),1]);
    lat1 = repmat(E(i,2),[(N-i),1]);

    lon2 = E((i+1):end,1);
    lat2 = E((i+1):end,2);

    pairdist(k+1:k + size(lon1,1)) = distance(lat1,lon1,lat2,lon2);

    k = k + size(lon1,1);

    waitbar((1/(N-1))*i, Ho_Wb);

end

clear i j k;
%
% Converts the interevent distances from degrees to kilometers.
%
close(Ho_Wb);
str4 = 'Calculating';
msg2 = msgbox(str4,'Message');

if dtokm == 1
    pairdist = pairdist.*111;
end
%
% Compute the correlation integral
%
d = 2;			%the embedding dimension
docorint;
