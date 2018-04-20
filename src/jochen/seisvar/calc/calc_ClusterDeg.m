function [fClusterDeg] = calc_ClusterDeg(mCatalog, vCluster)
% [fClusterDeg] = calc_ClusterDeg(mCatalog, vCluster);
%---------------------------------------------------
% Function to determine degree of clustering
%
% Incoming variables
% mCatalog : EQ catalog in ZMAP format
% vCluster : Vector of cluster numbers
%
% Outgiong variables:
% fClusterDeg : Percentage of clustering
%
% J. Woessner, woessner@seismo.ifg.ethz.ch
% updated: 19.08.02


report_this_filefun();

vSel = (vCluster(:,1) > 0);
mCatalogDecl = mCatalog.subset(vSel);
if isempty(mCatalogDecl) % This means no events in cluster!
    fClusterDeg = NaN;
else
    fClusterDeg = length(mCatalogDecl(:,1))/mCatalog.Count;
end
