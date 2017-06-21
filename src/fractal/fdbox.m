%
% Calculates the interevent distances for points that are within a volume (a rectangle) that is smaller
% than the volume of the entire distribution. The points outside the smaller volume are considered for
% the calculation of the distances.
%
%
%
% Attributing the corresponding catalog to E
%
if ~exist('index')
    index = 1;
end

if index == 1
    E = newt2;
elseif index == 2
    E = ran1;
elseif index == 3
    E = rann;
end
%
%  Variables
%
long1 = min(E.Longitude);
long2 = max(E.Longitude);
lati1 = min(E.Latitude);
lati2 = max(E.Latitude);
dept1 = min(abs(E.Depth));
dept2 = max(abs(E.Depth));

long = abs(long1 - long2)/2;
lati = abs(lati1 - lati2)/2;
dept = abs(dept1 - dept2)/2;


lo = long/9;
la = lati/9;
de = dept/9;

fdVboxplot = zeros(10,2);
Eboxsize = zeros(10,2);

%for w = 1:10;
w=1
lo1 = (long1 + long2)/2 + (w*lo);
lo2 = (long1 + long2)/2 - (w*lo);
la1 = (lati1 + lati2)/2 + (w*la);
la2 = (lati1 + lati2)/2 - (w*la);
de1 = (dept1 + dept2)/2 + (w*de);
de2 = (dept1 + dept2)/2 - (w*de);


Eb1 = find(E.Longitude<=lo1 & E.Longitude>=lo2);
Ebox = E(Eb1,:);
Eb2 = find(Ebox(:,2)<=la1 & Ebox(:,2)>=la2);
Ebox = Ebox(Eb2,:);
Eb3 = find(abs(Ebox(:,7))<=de1 & abs(Ebox(:,7))>=de2);
Ebox = Ebox(Eb3,:);
%E = setxor(E,Ebox,'rows');
Eboxsize(w,1:2) = [w, size(Ebox,1)];
%end

N = size(E,1);
pairdist = [];
j = numran*size(Ebox,1)
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
for i = 1:size(Ebox,1)

    lon1 = repmat(Ebox(i,1), [N,1]);
    lat1 = repmat(Ebox(i,2), [N,1]);
    depth1 = repmat(Ebox(i,7), [N,1]);

    lon2 = E.Longitude;
    lat2 = E.Latitude;
    depth2 = E.Depth;

    pairdist(k+1:k + size(lon1, 1)) = distance(lat1,lon1,lat2,lon2);
    depth(k+1:k + size(lon1, 1)) = depth1-depth2;

    k = k + size(lon1,1);

    waitbar((0.5/size(Ebox,1))*i, Ho_Wb);
end
%
% Converts the interevent distances from degrees to kilometers and calculates
% the interevent distances in three dimensions.
%
dep = find(depth(:,1)~=0);
pairdist = pairdist(dep);
depth = depth(dep);
pairdist = pairdist.*111;
pairdist = (pairdist.^2 + depth.^2).^0.5;
clear depth;
clear dep;
%
% Compute the correlation integral
%
d = 3;			%the embedding dimension
docorint;
HF1 = gcf;
close(HF1);

fdVboxplot(w,[1 2]) = [(w) fd(1,1)];

%end

figure_w_normalized_uicontrolunits(6);
plot(fdVboxplot(:,1), fdVboxplot(:,2),'ko');
axis([0 11 2.5 3.2]);
figure;
plot(Eboxsize(:,1), Eboxsize(:,2),'ko');
