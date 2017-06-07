function [mNewcatalog]=fmagstretch(mCatalog,dStartmag,dEndmag,dMagstretch,dMaggadd)
% function [mNewcatalog]=fmagstretch(mCatalog,dStartmag,dEndmag,dMagstretch,dMagadd);
%-----------------------------------------------------------------------------------
% Function to alter the magnitudes in a catalog for a specific magnitude range
% Author: J. Woessner
% woessner@seismo.ifg.ethz.ch
% last update: 25.06.02
%
% Incoming variables:
% mCatalog: earthquake catalog
% dStartmag   : Minimum magnitude to add dMagadd
% dEndmag     : Maximum magnitude to add dMagadd
% dMagstrech  : magnitude stretch factor
% dMagadd     : magnitude increment to be added

% Outgoing variable: mNewcatalog

mNewcatalog=mCatalog;
l=(mCatalog(:,6) >= dStartmag & mCatalog(:,6) <= dEndmag); % l : logical variable
mNewcatalog(l,6)=mCatalog(l,6)*dMagstretch+dMagadd;

return
