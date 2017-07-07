function aux_grdpntinfo(params, hParentFigure)
% function aux_grdpntinfo(params, hParentFigure);
%-------------------------------------------
% Example:
% call it in gui_result as Auxiliary function with seismic rates result
% matrix
%
% Function to plot information on the gridpoint selected. It will open a
% window with 3 subplots: 1) cumulative no of earthquakes in the time
% calculated, 2) cdf(z(lta)), 3) cdf(p(z(lta)))
%
% Incoming variables:
% params        : all variables
% hParentFigure : Handle of the parent figure
%
% Th. van Stiphout vanstiphout@sed.ethz.ch
% created: 22.12.05
% updates:
% 24.8.2006 vst cum.no.eq.only btw. fStartTime and (fTimeCut+fTwLength)



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
% vst 24.8.2006
vSel_=((params.mCatalog(:,3) > params.fStartTime) & ...
    (params.mCatalog(:,3) < (params.fTimeCut+params.fTwLength)) & ...
    (params.mNumDeclus(:,params.nSimul)==1));
mCatalog_=params.mCatalog(vSel_,:);
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
cdfplot(params.mZDeclus(nNodeGridPoint_,5,:));
set(gca,'XLim',[-2 6]);
set(get(gca,'XLabel'),'FontSize',14)
set(get(gca,'Ylabel'),'FontSize',14)
set(gca,'YAxisLocation','right');
set(get(gca,'XLabel'),'String','z(lta)');
set(get(gca,'YLabel'),'String','cdf(z(lta))');
hold on
subplot(2,2,4);
cdfplot(log10(1-params.mZDeclus(nNodeGridPoint_,7,:)));
set(gca,'XLim',[-8 0]);
set(get(gca,'XLabel'),'FontSize',14)
set(get(gca,'Ylabel'),'FontSize',14)
set(gca,'YAxisLocation','right');
set(get(gca,'XLabel'),'String','p(z(lta))');
set(get(gca,'YLabel'),'String','cdf(p(z(lta)))');
% subplot(2,2,4);
% cdfplot(params.mZDeclus(nNodeGridPoint_,7,:));
disp('End aux_grdpntinfo')
