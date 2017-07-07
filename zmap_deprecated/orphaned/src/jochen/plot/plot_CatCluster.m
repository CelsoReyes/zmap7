function plot_CatCluster(params, hParentFigure)
% function plot_CatCluster(params, hParentFigure);
%-------------------------------------------
% Plot events of clusters in the catalog
%
% Incoming variables:
% params        : all variables
% hParentFigure : Handle of the parent figure
%
% J.Woessner, woessner@seismo.ifg.ethz.ch
% last update: 21.08.02

% Track of changes:
global newt2

% Get the axes handle of the plotwindow
axes(pf_result('GetAxesHandle', hParentFigure, [], guidata(hParentFigure)));
hold on;

vSel = (params.vCluster(:,1) > 0);
mCatalogCluster = params.mCatalog(vSel,:);
plot(mCatalogCluster(:,1), mCatalogCluster(:,2),'m+');

newt2 = mCatalogCluster;
return
