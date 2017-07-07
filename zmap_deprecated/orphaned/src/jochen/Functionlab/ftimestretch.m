function [mNewcatalog]=ftimestretch(mCatalog,dStartyear,dEndyear,dMagstretch,dMagadd)
% function [mNewcatalog]=ftimestretch(mCatalog,dStartyear,dEndyear,dMagstretch,dMagadd);
% --------------------------------------------------------------------------------------
% Function to alter the magnitudes in a catalog for a specific time sequence by a stretch factor
% Author: J. Woessner
% woessner@seismo.ifg.ethz.ch
% last update: 21.06.02
% Incoming variables:
% mCatalog: earthquake catalog
% dStartyear   : decimal year, Start time
% dEndyear     : decimal year, End time
% dMagstretch  : magnitude stretch factor
% dMagadd     : magnitude increment to be added

mNewcatalog=mCatalog;
l=(mCatalog(:,3) >= dStartyear & mCatalog(:,3) <= dEndyear); % l : logical variable
mNewcatalog(l,6)=mCatalog(l,6)*dMagstretch;
mNewcatalog(l,6)=mNewcatalog(l,6)+dMagadd;

return
