function [mCatClose] = calc_CloseQuakesRad(mCatalog, fX, fY, fRadius)
% function [mCatClose] = calc_CloseQuakesRad(mCatalog, fX, fY, fRadius);
% ----------------------------------------------------------------------------------
% Determines events in a radius (km) from chosen point fX / fY
%
% Incoming variables:
% mCatalog       : Current EQ catalog in ZMAP format
% fX             : Latitude / [dec. degree]
% fY             : Longitude / [dec. degree]
% fRadius        : Radius in km
%
% J. Woessner, woessner@seismo.ifg.ethz.ch
% last update: 16.09.02

% Initialize
mCatClose = [];

mPos = [fX fY]; % Position of point to choose events around
mPos = repmat(mPos,length(mCatalog(:,1)),1);
vRadDist = abs(distance(mCatalog(:,1), mCatalog(:,2), mPos(:,1), mPos(:,2)));
[s,is] = sort(vRadDist);
mCatClose = mCatalog(is(:,1),:);
vSkm = deg2km(s,almanac('earth','radius','km','grs80'));
vSel = (vSkm <= fRadius);
mCatClose = mCatClose(vSel,:);
