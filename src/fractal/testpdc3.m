%
% This code calculates the interevent distances and the correlation integral
% of a given earthquake distribution.
% Calculation of the 3D distances between all possible pairs
% (combination of n epicenters taken 2 at a time) of earthquakes of
% the given dataset.
% Francesco Pacchiani 1/2000
%
%
% Variables
%
N = size(E,1);				% N= # of events in the catalogue; E= Earthquake catalogue
pairdist = []; 			% pairdist= Vector of interevent distances
j = nchoosek(N,2);			% j= # of interevent distances calculated
pairdist = zeros((N-1),N);
depth = zeros((N-1),N);
k = 1;
%E(:,2)= (max(Da(:,2))+min(Da(:,2)))/2;


%Ho_Wb = waitbar(0,'Calculating the fractal dimension D');
%Hf_Cfig = gcf;
%Hf_child = get(groot,'children');
%set(Hf_child,'pointer','watch','papertype','A4');
%
%
% Calculation of the interevent distances in 2D plus the depths differences.
%
%
for i = 1:(N-1)

    lon1 = repmat(E(i,1), [(N-1),1]);
    lat1 = repmat(E(i,2), [(N-1),1]);
    depth1 = repmat(E(i,7), [(N-1),1]);

    E(i,:) = [];

    lon2 = E(:,1);
    lat2 = E(:,2);
    depth2 = E(:,7);

    pairdist(1:(N-1),k) = distance(lat1,lon1,lat2,lon2);
    depth(1:(N-1),k) = depth1-depth2;

    k = k + 1;
    E = newt2;

    %Waitbar((0.75/(N-1))*i, Ho_Wb);

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

pairdist = (pairdist.^2 + depth.^2).^0.5;		% pairdist = Interevent distances (vector).
clear depth;
%
%
% Calculation of the correlation integral using as input the
% pair distances computed above.
%
%
% Variables
%
d = 3;						%d = the dimension of the embedding volume.
rmax1 = max(pairdist);
rmin1 = min(pairdist);
rmax = max(rmax1);
rmin = min(rmin1);

clear rmax1 rmin1;

if rmin == 0
    rmin = 0.01;
end

lrmin = log10(rmin);
lrmax = log10(rmax);

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
cor = zeros(size(r,1),N);
i = 1;

for k = 1:50

    l = [];
    l = pairdist < r(k);
    test(k,1) = sum(l);
    %cor(1:size(r,1),i) = (sum(l));
    %i=i+1;

    %Waitbar(0.75 + (0.25/size(r,1))*k,Ho_Wb);
end

sumcor = sum(cor,2);
sumcor1 = sumcor./N;

for j = 0:20

    corint1(1:50,1,(j+1)) = sumcor1(:,1,(j+1)).^(1/(j-1));
end

corint = corint1(1:50, 1:21);

clear i j j1 k l cor sumcor;
close(Ho_Wb);
Hf_child = get(groot,'children');
set(Hf_child,'pointer','arrow');
%
%
% Plotting of the correlation integral in function of the interevent
% distance r.
%
%
Hf_Fig = figure_w_normalized_uicontrolunits('Numbertitle','off','Name','Fractal Dimension');
Hl_gr1 = loglog(r, corint,'ko', 'MarkerSize',5);
set(Hl_gr1,'MarkerSize',5);
title(sprintf('Correlation Integral versus %.0fD Interevent Distances', d));

Hf_Fig = figure_w_normalized_uicontrolunits('Numbertitle','off','Name','Fractal Dimension');
Hl_gr1 = loglog(r, cor,'r+');
set(Hl_gr1,'MarkerSize',7);
title(sprintf('Correlation Integral versus %.0fD Interevent Distances', d));
%
%
dofd = 'fd';
dofdim;
