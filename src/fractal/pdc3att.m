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
pairdist = zeros(j,1);
depth = zeros(j,1);
k = 0;
%E(:,2)= (max(Da(:,2))+min(Da(:,2)))/2;


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

    %lon1 = repmat(E(i,1), [(N-i),1]);
    %lat1 = repmat(E(i,2), [(N-i),1]);
    %depth1 = repmat(E(i,3), [(N-i),1]);
    one1 = repmat(E(i,1), [(N-i),1]);
    two1 = repmat(E(i,2), [(N-i),1]);
    three1 = repmat(E(i,3), [(N-i),1]);
    %four1 = repmat(E(i,4), [(N-i),1]);
    %five1 = repmat(E(i,5), [(N-i),1]);
    %six1 = repmat(E(i,6), [(N-i),1]);
    %seven1 = repmat(E(i,7), [(N-i),1]);
    %eight1 = repmat(E(i,8), [(N-i),1]);

    %lon2 = E((i+1):end, 1);
    %lat2 = E((i+1):end, 2);
    %depth2 = E((i+1):end, 3);
    one2 = E((i+1):end, 1);
    two2 = E((i+1):end, 2);
    three2 = E((i+1):end, 3);
    %four2 = E((i+1):end, 4);
    %five2 = E((i+1):end, 5);
    %six2 = E((i+1):end, 6);
    %seven2 = E((i+1) :end, 7);
    %eight2 = E((i+1) :end, 8);

    %pairdist(k+1:k + size(lon1, 1)) = distance(lat1,lon1,lat2,lon2);
    %depth(k+1:k + size(lon1, 1)) = depth1-depth2;
    %pairdist1(k+1:k + size(lon1, 1)) = lon2 - lon1;
    one(k+1:k + size(one1, 1)) = one1-one2;
    two(k+1:k + size(one1,1)) = two1-two2;
    three(k+1:k + size(one1,1)) = three1-three2;
    %four(k+1:k + size(one1, 1)) = four1-four2;
    %five(k+1:k + size(one1,1)) = five1-five2;
    %six(k+1:k + size(one1,1)) = six1-six2;
    %seven(k+1:k + size(one1,1)) = seven1-seven2;
    %eight(k+1:k + size(one1,1)) = eight1-eight2;
    k = k + size(one1,1);

    waitbar((0.75/(N-1))*i, Ho_Wb);

end

clear i j k%  one1 one2 two1 two2 three1 three2 four1 four2 five1 five2 six1 six2 seven1 seven2;
%
%
% Conversion of the interevent distances from degrees to kilometers and calculates
% the interevent distances in three dimensions.
%
%
%if dtokm == 1
%   pairdist = pairdist.*111;
%end

%pairdist = (pairdist.^2 + depth.^2 ).^0.5;		% pairdist = Interevent distances (vector).
%clear depth four;
pairdist = (one.^2 + two.^2+ three.^2).^0.5;%    + four.^2+ five.^2 + six.^2 + seven.^2 + eight.^2
%
% Calculation of the correlation integral using as input the
% pair distances computed above.
%
%
% Variables
%
d = 3;						%d = the dimension of the embedding volume.
rmax = max(pairdist);
rmin = min(pairdist);

if rmin == 0
    rmin = 0.01;
end

%rinc = round((rmax-rmin)/0.43);
lrmin = log10(rmin);
lrmax = log10(max(pairdist));

%u = (log10(rmin):0.15:log10(rmax))';
%
% Defining the distance vector r in order that on the
% log-log graph all the points plot at equal distances from one another.
%
r = (logspace(lrmin, lrmax, 50))';
r1 = rmin:0.5:rmax;
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
% Plotting of the correlation integral in function of the interevent
% distance r.
%
%
Hf_Fig = figure_w_normalized_uicontrolunits('Numbertitle','off','Name','Fractal Dimension');
Hl_gr1 = loglog(r, corint,'ko');
set(Hl_gr1,'MarkerSize',7);
title(sprintf('Correlation Integral versus %.0fD Interevent Distances', d));
%
%
dofd = 'fd';
dofdim;
