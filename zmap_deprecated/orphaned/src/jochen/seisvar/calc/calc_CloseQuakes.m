function [mCatClose] = calc_CloseQuakes(mCatalog, fX, fY, nNumberEvents)
% function [mCatClose] = calc_CloseQuakes(mCatalog, fX, fY, nNumberEvents);
% ----------------------------------------------------------------------------------
% Determines N = Number of closest events from chosen point fX / fY
%
% Incoming variables:
% mCatalog       : Current EQ catalog in ZMAP format
% fX             : Latitude / [dec. degree]
% fY             : Longitude / [dec. degree]
% nNumberEvents  : Number of N closest events
%
% J. Woessner, woessner@seismo.ifg.ethz.ch
% last update: 27.08.02

mCatClose = [];
vRadDist = sqrt(((mCatalog(:,1)-fX)*cos(pi/180*fY)*111).^2 + ((mCatalog(:,2)-fY)*111).^2);
[s,is] = sort(vRadDist);
mCatClose = mCatalog(is(:,1),:);
mCatClose = mCatClose(1:nNumberEvents,:)
