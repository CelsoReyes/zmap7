function aux_NodeInfo(params, hParentFigure)
% function aux_NodeInfo(params, hParentFigure);
%-------------------------------------------
% Function to analyse a single grid point, giving hard information on the data
% Incoming variables:
% params        : all variables
% hParentFigure : Handle of the parent figure
%
% J.Woessner, woessner@seismo.ifg.ethz.ch
% last update: 17.01.03

%% Info on one picked node %%%%%%%%%%%%%%%%%%
% Get the axes handle of the plotwindow
axes(sv_result('GetAxesHandle', hParentFigure, [], guidata(hParentFigure)));
hold on;
% Select a point in the plot window with the mouse
[fX, fY] = ginput(1);
disp(['X: ' num2str(fX) ' Y: ' num2str(fY)]);
% Plot a small circle at the chosen place
plot(fX,fY,'ok');

% Get closest gridnode for the chosen point on the map
[fXGridNode fYGridNode,  nNodeGridPoint] = calc_ClosestGridNode(params.mPolygon, fX, fY);
disp(['Node  X : ' num2str(fXGridNode) ' Y : ' num2str(fYGridNode)]);
plot(fXGridNode, fYGridNode, '*r');
hold off;


% Get the data for the grid node
mNodeCatalog_ = params.mCatalog(params.caNodeIndices{nNodeGridPoint}, :);
% Check for constant number of events calculations
if (params.nGriddingMode == 0)
    [mNodeCatalog_] = ex_CheckMaxRadius(params.mCatalog, params.mPolygon, nNodeGridPoint, params.caNodeIndices, params.fMaxRadius, params.nNumberEvents, params.bMap);
end
% Select time period for mNodeCatalog_
% vSel = (params.fTstart <= mNodeCatalog_(:,3) & mNodeCatalog_(:,3) < params.fTstart+params.fTimePeriod/365);
% mNodeCatalog_ = mNodeCatalog_(vSel,:);
% Select magnitude range for probability calculations
if exist('params.fStartMag')
    vSel1 = (mNodeCatalog_(:,6) >= params.fStartMag);
    mNodeCatalog_ = mNodeCatalog_(vSel1,:);
end
% Amount of events
fNumQuake = length(mNodeCatalog_(:,1));
fMinTime = min(mNodeCatalog_(:,3));
fMaxTime = max(mNodeCatalog_(:,3));
fMinmag = min(mNodeCatalog_(:,6));
fMaxmag = max(mNodeCatalog_(:,6));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% Info on all grid nodes
vNumEvents = [];
%[nX, nY] = size(params.caNodeIndices);
% Calculate number of events per grid node
for nNode = 1:length(params.mPolygon(:,1))
    [fNumEvents, fDummy] = size(params.mCatalog(params.caNodeIndices{nNode}, :));
    vNumEvents = [vNumEvents; fNumEvents];
end
% Select only nodes with quakes
vSel = (vNumEvents > 0);
vNodewEvents = vNumEvents(vSel,:);
vNodeNoEvents = vNumEvents(~vSel,:);
% Output definition
sTitlestr = ['Grid node information'];
sMsg1 = [' There are ' num2str(length(params.vUsedNodes(:,1))) ' grid nodes. The mean number of events per grid node is '...
         num2str(mean(vNodewEvents)) '. You have picked grid node ' num2str(nNodeGridPoint) ' at' num2str(fXGridNode) ' / '  num2str(fYGridNode)...
        ' deg. Number of events: ' num2str(fNumQuake) '. First event: ' num2str(fMinTime)...
        ' Last event: ' num2str(fMaxTime) ' Minimum Magnitude: ' num2str(fMinmag)...
        ' Max. magnitude: ' num2str(fMaxmag)];
% Message window
zmaphelp(sTitlestr,sMsg1);

% Specific Node
params.mValueGrid(nNodeGridPoint,:)
