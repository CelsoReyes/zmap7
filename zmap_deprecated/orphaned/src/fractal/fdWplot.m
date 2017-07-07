%
% Study of the relationship between the fractal dimension and the width of the chosen volume.
%
%
numran = 800;
longi = -151.3;
latit1 = min(a.Latitude);
latit2 = 62.24;
latit = latit2 - latit1;
depti = -50;
k1 = 1;

fdwrel1 = zeros(20,1:2);

for g = 0.05:0.05:1

    fd = []; longit = [];
    rann = []; rannorm = [];
    longi2 = longi + g;
    longi1 = longi - g;
    longit = longi2 - longi1;
    rann = [((rand(numran,1).*longit)+ longi1), ((rand(numran,1).*latit)+ latit1), zeros(numran,1),zeros(numran,1),zeros(numran,1),zeros(numran,1),(rand(numran,1).*depti)];

    %rann = [((random('Normal',0,0.25,numran,1)./10)+(longi/2)), ((random('Normal',0,0.25,numran,1)./10)+(latit1+latit2)/2), zeros(numran,1),zeros(numran,1),zeros(numran,1),zeros(numran,1),  (random('Poisson',13,numran,1)-20)];
    %rann1 = rann(:,7) < 0;
    %rann2 = rann(:,7).*rann1;
    %rann(:,7) = rann2;

    %rann = [rand(numran,1), rand(numran,1), zeros(numran,1),zeros(numran,1),zeros(numran,1),zeros(numran,1), rand(numran,1)];
    %nordepti = max(rann(:,7));
    %rannorm = [((rann(:,1).*longit)+ longi1), ((rann(:,2).*latit)+ latit1), zeros(numran,1),zeros(numran,1),zeros(numran,1),zeros(numran,1), (rann(:,7).*depti)];

    index = 3;
    dopairdist3;
    %HF = gcf;
    %close(HF);
    fdwrel1(k1,[1 2]) = [fd(1,1) longit];
    k1 = k1 + 1;

end

figure%(1);
hold on;
plot((fdwrel1(:,2)/2),fdwrel1(:,1),'ko');
axis([0.1 0.9 2.1 3.1]);


figure_w_normalized_uicontrolunits('Numbertitle','off','Name','Random Catalog','toolbar','figure');
plot3 (rann(:,1), rann(:,2), rann(:,7),'r*');
set(gca,'pos',[0.15 0.11 0.76 0.76]);
axis([min(a.Longitude) -150.53 min(a.Latitude) 62.24 -50 -abs(min(a.Depth))]);
xlabel('Longitude');
ylabel('Latitude');
zlabel('Depth');
tit = sprintf('%.0f Randomly Generated Point Catalog', numran);
title(tit);
box on;
