function plot_CatDecl(params, hParentFigure)
% function plot_CatDecl(params, hParentFigure);
%-------------------------------------------
% Plot events of declustered catalog
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
mCatalogDecl = params.mCatalog(~vSel,:);
plot(mCatalogDecl(:,1), mCatalogDecl(:,2),'ro');

newt2 = mCatalogDecl;
return
