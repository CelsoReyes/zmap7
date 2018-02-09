% Generate detail for events on tiny scale (Lab)
n=1000000;
b=1.9; a=-4;

mmX =randi(10000,n,1) / 100; 
mmX=mmX.*cosd(mmX) /2;
mmY = 50 + 6.*randn(n,1);
mmZ = ( 20 + 5.*randn(n,1)) .* mmY/20;
dt = 0.5+ randn(n,1) /10;
dt = dt+abs(min(dt));

%log10(N) = a - bM
% bM = a - log10(N)
% M = (a - log10(N)) / b
mags=@(a,b,N) (a - log10(N) / b); 
magadjust=randn(n,1).* 0.2;
mag = mags(a, b, randperm(n));
mag=mag(:) + magadjust;
mag = round(mag,2) ; 
figure(3);
subplot(3,1,1);plot3(mmX,mmY,mmZ,'.')
xlabel('x')
ylabel('y')
zlabel('z')
grid on
box on
axis equal
dates= datetime(2010,1,1,12,0,0)+seconds(cumsum(abs(dt)));
subplot(3,1,2);plot(dates , 1:n); xlabel('Day'); ylabel('n');

subplot(3,1,3);
scatter(dates , mag);
title(sprintf('Mags [min:%.2f  max:%.2f]', min(mag),max(mag)));
C=ZmapCatalog;
C.Latitude=km2deg(mmY/1000);C.Longitude=km2deg(mmX/1000);C.Depth=km2deg(mmZ/1000);
C.Date=dates;
C.Magnitude=mag;
C.Name='lab_event_synth';
C.MagnitudeType=repmat({'Mw'},C.Count,1)
C.Dip=nan(C.Count,1);
C.DipDirection=nan(C.Count,1);
C.Rake=nan(C.Count,1);

clear dates mmX mmY mmZ dt mag mags magadjust
disp('now, replace a catalog with C. for example ZG.primeCatalog=C');

%% TOFIX
% To get this working properly, there appears to be a couple things needed:

% TOFIX size of markers is ridiculously large for large negative events.
%  marker size should perhaps be relative to smallest events.  Additionally, for many-many events
% perhaps default to a simple dot marker.
%
% TOFIX Short time scales don't look nice on the plots.
% TOFIX building a new catalog might not change ZG.maepi.