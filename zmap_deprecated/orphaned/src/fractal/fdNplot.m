%
% Calculates and plots the relationship between the fractal dimension and the size of the
% random catalog. This calculated iteratively x (=nevents) times.
%
%
long1 = -120.732;
lati1 = 35.832;
dept1 = 0;

radm = [0.3];
rasm = [0.6];
dim = 3;
numran = 3482;

% Create random catalog


fdnumplot=[];
fdnumplot = zeros(40,25);
k3 = 1;
%fign = 200;
tic;

%for
%kd = 4;kd*0.0225

long2 = long1 + 0.351;
lati2 = lati1 + 0.335;
dept2 = dept1 + 33;
long = long2 - long1;
lati = lati2 - lati1;
long3 = (long1 + long2)/2;
lati3 = (lati1 + lati2)/2;

clear long1 lati1 long2 lati2

%rand(numran,1).*(long/2);
%rand(numran,1).*(lati/2);

%rcosx = rand(size(E,1),1).*180;
%rcosy = rand(size(E,1),1).*180;
%rcosz = rand(size(E,1),1).*180;
%factx = cos(rcosx).*(0.43/111);
%facty = cos(rcosy).*(0.43/111);
%factz = cos(rcosz).*1.52;

for k1 = 0:24

    ran = [];
    ran1 = [];
    E = [];
    rnlong = random('Normal',0,5,numran,1);%rand(numran,1).*(long/2);
    rnlat = random('Normal',0,5,numran,1);%rand(numran,1).*(lati/2);
    rlong = ((random('Normal',0,5,numran,1))./max(rnlong)).*long;
    rlat = ((random('Normal',0,5,numran,1))./max(rnlat)).*lati;
    rdep = rand(numran,1).*dept2/2;
    phi = rand(numran,1).*180;
    teta = rand(numran,1).*360;


    %ran1 = [E1(:,1)+ factx, E1(:,2) + facty,rand(size(E1,1),1),rand(size(E1,1),1),rand(size(E1,1),1),rand(size(E1,1),1), (E1(:,7) + factz)];
    %ran2 = find(ran1(:,7)>0);
    %ran = ran1(ran2,:);


    %ran = [((rand(numran,1).*long)+ long1), ((rand(numran,1).*lati)+ lati1), rand(numran,1),rand(numran,1),rand(numran,1),rand(numran,1), (rand(numran,1).*dept)];
    ran = [(rlong.*sin(phi).*cos(teta)+long3), (rlat.*sin(phi).*sin(teta))+lati3,rand(numran,1),rand(numran,1),rand(numran,1),rand(numran,1), rdep.*cos(phi)-(dept2/2)];

    E = ran;
    clear rlong rlat rdep phi teta rnlong rnlat
    %clear ran2 ran1 rcosx rcosy rcosz factx facty factz

    k2 = 1;

    for nevents = 50:50:2000

        fdsphere;
        %fdnumplot(k2,[(2*k1+1) (2*k1+2)], (k3+1)) = [nevents coef(1,1)];
        fdnumplot(k2,k1+1) = [coef(1,1)];
        k2 = k2+1;
        %D = coef(1,1);
        %fdallfig;
        %drawnow;
        E = ran;

    end % for num

    %fign = fign + 1;

end %for k1

%k3 = k3+1;

%end %for kdi
ti=toc;
%
%
% Plots the fractal dimension versus the number of events considered for the
% ten iterations. Creates 8 plots corresponding to the 8 different cubic volumes.
%
%
% for k5 = 1:8;
%   for k4 = 0:9;
%
%      Hfig1 = figure_w_normalized_uicontrolunits(100+k5);
%      hold on;
%      plot(fdnumfr(:,(2*k4+1),k5), fdnumfr(:,(2*k4+2),k5),'ko');
%      axis([0 1050 0.5 4]);
%
%   end
%end

Hfig4 = figure_w_normalized_uicontrolunits('numbertitle', 'off', 'name', 'D-value in function of # of events for 25 iterations');
plot(fdnpkfrrg,'kx');
axis([0 44 1.5 3.5]);
set(gca, 'Xtick', [1:4:41],'Xticklabel', [50:200:2050],  'Fontweight', 'bold');
title('D-value versus Number of Events Simulated in a Real Geometry');
xlabel('Number of Events');
ylabel('D-value');
