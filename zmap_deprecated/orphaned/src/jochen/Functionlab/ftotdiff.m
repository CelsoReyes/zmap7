function [dNdiffsum, dNdiffsumYear] = ftotdiff(mCatalog1,mCatalog2)
% function [dNdiffsum, dNdiffsumYear]=ftotdiff(mCatalog1,mCatalog2)
% --------------------------------------------------------------------------------------
% Function to calculate absolute difference of number of events between
% to time periods of an earthquake catalog
% Author: J. Woessner
% woessner@seismo.ifg.ethz.ch
% last update: 27.06.02
%
% Incoming variables:
% mCatalog1: earthquake catalog 1
% mCatalog2: earthquake catalog 2
%
% Outgoing variable:
% dNdiffsum : total difference of number of events in the two time periods

[dEv_val dMags dEv_valsum dEv_valsum_rev,  dMags_rev] =fcumulsum(mCatalog1);
[dEv_val2 dMags2 dEv_valsum2 dEv_valsum_rev2,  dMags_rev2] =fcumulsum(mCatalog2);

dNdiff=dEv_val2-dEv_val;

dNdiffsum = cumsum(dNdiff);
dNdiffsum = dNdiffsum(length(dNdiffsum));
dNdiffsumYear = dNdiffsum/365;
dNdiffsumMonth = dNdiffsum/(365*12);
return
