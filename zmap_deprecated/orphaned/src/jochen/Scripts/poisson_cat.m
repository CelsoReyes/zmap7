% Matlab Script: poisson_cat.m
% -------------------------------
% Script to determine the Poissonianess of an entire catalog
%
% The script gives choices for the radius around a point, magnitude threshold and date.
%
% J. Woessner, woessner@seismo.ifg.ethz.ch
% last update: 16.09.02

% The script was used for a PEGASOS-Report on the poissonianess of the ECOS catalog.
storedcat=a;
mCatalog = a;

% Catalog selection
sPrompt  = {'Min. Time','Minimum Magnitude','Radius / [km]','Latitude','Longitude'};
sTitle   = 'Parameters for catalog selection';
nLines= 1;
sDef     = {'1975','2.5','200','47.54','7.583'};
sAnswer  = inputdlg(sPrompt,sTitle,nLines,sDef);
fMinTime = str2double(sAnswer(1));
fMinMag = str2double(sAnswer(2));
fRadius = str2double(sAnswer(3)); % km
fLat = str2double(sAnswer(4));    % degree
fLon = str2double(sAnswer(5));    % degree

vSel = (mCatalog(:,6) >= fMinMag & mCatalog(:,3) >= fMinTime);
mCatalog = mCatalog(vSel,:);
[mCatClose] = calc_CloseQuakesRad(mCatalog, fLon, fLat,fRadius);
nEv = length(mCatClose(:,1)) % Quantity of events

[fChi2] = plot_Chi2(mCatClose)

newt2 = mCatClose;
timeplot;

