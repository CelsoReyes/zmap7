function aux_grdpntinfo(params, hParentFigure)
% function aux_grdpntinfo(params, hParentFigure);
%-------------------------------------------
%
% Incoming variables:
% params        : all variables
% hParentFigure : Handle of the parent figure
%
% Th. van Stiphout vanstiphout@sed.ethz.ch
% last update: 22.12.05



% Get the axes handle of the plotwindow
axes(sr_result('GetAxesHandle', hParentFigure, [], guidata(hParentFigure)));
hold on;
% Select a point in the plot window with the mouse
[fX, fY] = ginput(1);
disp(['X: ' num2str(fX) ' Y: ' num2str(fY)]);
% Plot a small circle at the chosen place
% figure_w_normalized_uicontrolunits('Name','Z-Value Gridpoint Info')
figure
[fXGridNode_ fYGridNode_,  nNodeGridPoint_] = calc_ClosestGridNode(params.mPolygon, fX, fY);
% plot(fXGridNode, fYGridNode, '*r');
% params.mPolygon(nNodeGridPoint_,:)

subplot(2,2,[1 3]);
mCatalog_=params.mCatalog(params.mNumDeclus(:,params.nSimul)==1,:);
vNodeCatalog_=mCatalog_(params.caNodeIndices{nNodeGridPoint_},3);
vNodeCatalog_=sort(vNodeCatalog_);
vSel1=(vNodeCatalog_(:) <= params.fTimeCut);
vSel2=(vNodeCatalog_(:) > params.fTimeCut);
plot(vNodeCatalog_(:),1:length(vNodeCatalog_(:)),'b','LineWidth',2);
% plot(vNodeCatalog_,1:length(vNodeCatalog_),'b');
hold on
plot(vNodeCatalog_(vSel2),length(vNodeCatalog_(vSel1))+1:length(vNodeCatalog_(vSel1))+length(vNodeCatalog_(vSel2)),'r','LineWidth',2);
set(get(gca,'XLabel'),'FontSize',14)
set(get(gca,'Ylabel'),'FontSize',14)
set(get(gca,'XLabel'),'String','Time [yrs]');
set(get(gca,'YLabel'),'String','Cumulative No. []');
hold on
subplot(2,2,2);
cdfplot(params.mZDeclus(nNodeGridPoint_,2,:));
set(gca,'XLim',[-1 1]);
set(get(gca,'XLabel'),'FontSize',14)
set(get(gca,'Ylabel'),'FontSize',14)
set(gca,'YAxisLocation','right');
set(get(gca,'XLabel'),'String',texlabel('\beta'));
set(get(gca,'YLabel'),'String','cdf(\beta)');
hold on
subplot(2,2,4);
cdfplot(params.mZDeclus(nNodeGridPoint_,4,:));
set(gca,'XLim',[0 1]);
set(get(gca,'XLabel'),'FontSize',14)
set(get(gca,'Ylabel'),'FontSize',14)
set(gca,'YAxisLocation','right');
set(get(gca,'XLabel'),'String','p(beta)');
set(get(gca,'YLabel'),'String','cdf(beta)');
% subplot(2,2,4);
% cdfplot(params.mZDeclus(nNodeGridPoint_,7,:));
disp('End aux_grdpntinfo')
