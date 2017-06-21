%
% Calculates the interevent distances for points that are within a volume (a sphere) that is smaller
% than the volume of the entire distribution. The points outside the smaller volume are considered for
% the calculation of the distances.
% Francesco Pacchiani 1/2000
%
%disp('fractal/codes/fdsphere.m');
%
%
%  Variables
%
slon1 = min(E.Longitude);
slon2 = max(E.Longitude);
slat1 = min(E.Latitude);
slat2 = max(E.Latitude);
sdep1 = min(abs(E.Depth));
sdep2 = max(abs(E.Depth));
%
%
% Calculates the distances from the center point to all the other of the given catalog
%
%
ctr = [(slon1 + slon2)/2, (slat1 + slat2)/2, (sdep1 + sdep2)/2];		% Center point of the volume
%ctr = [-152.4, (slat1 + slat2)/2, (sdep1 + sdep2)/2];

%Ein = find(E.Depth>-15 & E.Depth<0);
%E1 = E(Ein,:);
E1 = E;
N1 = size(E1,1);			% N= # of events in the earthquake catalogue, or random catalog

ctrlon = repmat(ctr(1,1), [N1,1]);
ctrlat = repmat(ctr(1,2), [N1,1]);
ctrdep = repmat(ctr(1,3), [N1,1]);

%ctrdist1 = distance(ctrlat, ctrlon, E.Latitude, E.Longitude);
londif = ctrlon - E1(:,1);
latdif = ctrlat - E1(:,2);
ctrdepth = ctrdep - E1(:,7);

dist = (londif.^2 + latdif.^2).^0.5;
ctrdist1 = dist.*111;
ctrdist = (ctrdist1.^2 + ctrdepth.^2).^0.5;
[ctrd, ctri] = sort(ctrdist);


clear ctrdepth ctrlon ctrlat ctrdep ctrd N1 londif latdif ctrdist ctrdist1 dist
%
%
% Calculates the largest radius possible, so that the sphere is inscribed in the volume, and
% has no 'data gaps'.
%
%

%radi1 = [abs(ctr(1,1) - slon1); abs(ctr(1,2) - slat1); abs(ctr(1,3) - sdep1)/111];
%radi = min(radi1)*111;
%radi = max(radi1)*111;
%radi = 3;

%sph = find(ctrdist<=radi);
%nevents = size(E1,1);
sph = ctri(1:nevents);

sphere = E1(sph,:);

%clear ctri sph;
%clear sph;


figure;
hold on;
cla;
sphere(:,7) = [-sphere(:,7)];
E1(:,7) = [-E1(:,7)];
%rpts = plot3 (E1(:,1), E1(:,2), E1(:,7),'r.', 'Markersize', 10);
bpts = plot3 (sphere(:,1), sphere(:,2), sphere(:,7),'k.', 'Markersize', 4);
set(bpts, 'Xdata', sphere(:,1), 'Ydata', sphere(:,2), 'Zdata', sphere(:,7), 'k*', 'Markersize', 4);
%pause(0.25);

E = sphere;

%clear sphere;

%org = [9];
org = [1];
startfd;
