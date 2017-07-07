function aux_NodeStat(vResults)
% function aux_NodeStat(vResults);
%-------------------------------------------
% Function to create grid point statistics on magnitude ranges, actual radii and time periods
%
% Incoming variables:
% vResults        : all variables of a calculation
%
% J.Woessner, woessner@seismo.ifg.ethz.ch
% last update: 04.04.03

% Initialize
vNumEvents = [];
vTimeDiff = [];
vMagRange = [];
vMeanRadius = [];

% Create Indices to catalog
[vResults.caNodeIndices] = ex_CreateIndexCatalog(vResults.mCatalog, vResults.mPolygon, vResults.bMap, vResults.nGriddingMode, ...
    vResults.nNumberEvents, vResults.fRadius, vResults.fSizeRectHorizontal, vResults.fSizeRectDepth);

%[nX, nY] = size(vResults.caNodeIndices);
% Loop over grid nodes
for nNode = 1:length(vResults.mPolygon(:,1))
    % Get the data for the grid node
    mNodeCatalog_ = vResults.mCatalog(vResults.caNodeIndices{nNode}, :);
    if (vResults.nGriddingMode == 0)
        [mNodeCatalog_] = ex_MaxRadius(vResults.mCatalog, vResults.mPolygon, nNode, vResults.caNodeIndices, vResults.fMaxRadius, vResults.nNumberEvents, vResults.bMap);
    end
    fStartTime = vResults.fTstart;
    vSel = (fStartTime <= mNodeCatalog_(:,3) &  mNodeCatalog_(:,3) < fStartTime+vResults.fTimePeriod/365);
    mNodeCatalog_ = mNodeCatalog_(vSel,:);
    if (isempty(mNodeCatalog_) | length(mNodeCatalog_(:,1)) < vResults.nMinimumNumber)
        fNumEvents = nan;
        fMinTime = nan;
        fMaxTime = nan;
        fMinmag = nan;
        fMaxmag = nan;
        fMeanRadius = nan;
    else
        fNumEvents = length(mNodeCatalog_(:,1));
        % Time difference
        fMinTime = min(mNodeCatalog_(:,3));
        fMaxTime = max(mNodeCatalog_(:,3));
        % Magnitude range
        fMinmag = min(mNodeCatalog_(:,6));
        fMaxmag = max(mNodeCatalog_(:,6));
        % Radii
        mPos = [vResults.mPolygon(nNode, 1) vResults.mPolygon(nNode,2)];
        vDistances_ = sqrt(((mNodeCatalog_(:,1)-mPos(:,1))*cos(pi/180*mPos(:,2))*111).^2 + ((mNodeCatalog_(:,2)-mPos(:,2))*111).^2);
        fMeanRadius = mean(vDistances_);
    end
    vNumEvents = [vNumEvents; fNumEvents];
    vTimeDiff = [vTimeDiff; (fMaxTime-fMinTime)];
    vMagRange = [vMagRange; fMaxmag-fMinmag];
    vMeanRadius = [vMeanRadius; fMeanRadius];
end
% Select only nodes with quakes
vSel = (vNumEvents > 0);
vNodewEvents = vNumEvents(vSel,:);
vNodeNoEvents = vNumEvents(~vSel,:);
% Output definition
sTitlestr = ['Grid node information'];
sMsg1 = [' There are ' num2str(length(vResults.mPolygon(:,1))) ' used grid nodes. The mean number of events per grid node is '...
        num2str(mean(vNodewEvents)) ' (nodes with 0 events are not counted). Nodes with zero events are ' num2str(length(vNodeNoEvents(:,1))) '.'];
% Message window
zmaphelp(sTitlestr,sMsg1);

%% Plots
if exist('rad_fig','var') &  ishandle(rad_fig)
    set(0,'Currentfigure',rad_fig);
    disp('Figure exists');
else
    rad_fig=figure_w_normalized_uicontrolunits('tag','rad','Name','Mean radii','Units','normalized','Nextplot','add','Numbertitle','off');
    rad_axs=axes('tag','ax_rad','Nextplot','add','box','on');
end
set(gca,'tag','ax_rad','Nextplot','replace','box','on');
axs5=findobj('tag','ax_rad');
axes(axs5(1));
histogram(vMeanRadius,min(vMeanRadius):(max(vMeanRadius)-min(vMeanRadius))/10:max(vMeanRadius));
xlabel('Distance / [km]');
ylabel('Frequency');
vSel = (~isnan(vMeanRadius));
sTitlestr = ['Mean radius: ' num2str(mean(vMeanRadius(vSel,:))) 'km'];
title(sTitlestr);

% Magnitude range distribution
if exist('mag_fig','var') &  ishandle(mag_fig)
    set(0,'Currentfigure',mag_fig);
    disp('Figure exists');
else
    mag_fig=figure_w_normalized_uicontrolunits('tag','mag','Name','Magnitude ranges','Units','normalized','Nextplot','add','Numbertitle','off');
    mag_axs=axes('tag','ax_mag','Nextplot','add','box','on');
end
set(gca,'tag','ax_mag','Nextplot','replace','box','on');
axs5=findobj('tag','ax_mag');
axes(axs5(1));
histogram(vMagRange,min(vMagRange):0.2:max(vMagRange));
xlabel('Magnitude range');
ylabel('Frequency');
vSel = (~isnan(vMagRange));
sTitlestr = ['Mean magnitude range: ' num2str(mean(vMagRange(vSel,:)))];
title(sTitlestr);

% Time distribution
if exist('time_fig','var') &  ishandle(time_fig)
    set(0,'Currentfigure',time_fig);
    disp('Figure exists');
else
    time_fig=figure_w_normalized_uicontrolunits('tag','time','Name','Time range distribution','Units','normalized','Nextplot','add','Numbertitle','off');
    time_axs=axes('tag','ax_time','Nextplot','add','box','on');
end
set(gca,'tag','ax_time','Nextplot','replace','box','on');
axs5=findobj('tag','ax_time');
axes(axs5(1));
histogram(vTimeDiff,min(vTimeDiff):(max(vTimeDiff)-min(vTimeDiff))/10:max(vTimeDiff));
xlabel('Time range / [dec. year]');
ylabel('Frequency');
vSel = (~isnan(vTimeDiff));
sTitlestr = ['Mean time range: ' num2str(mean(vTimeDiff(vSel,:)))];
title(sTitlestr);

% Number of events distribution
if exist('num_fig','var') &  ishandle(num_fig)
    set(0,'Currentfigure',num_fig);
    disp('Figure exists');
else
    num_fig=figure_w_normalized_uicontrolunits('tag','num','Name','Number of events distribution','Units','normalized','Nextplot','add','Numbertitle','off');
    num_axs=axes('tag','ax_num','Nextplot','add','box','on');
end
set(gca,'tag','ax_num','Nextplot','replace','box','on');
axs5=findobj('tag','ax_num');
axes(axs5(1));
histogram(vNumEvents,min(vNumEvents):round((max(vNumEvents)-min(vNumEvents))/100):max(vNumEvents));
xlabel('Number of events');
ylabel('Frequency');
vSel = (~isnan(vNumEvents));
sTitlestr = ['Mean number of events: ' num2str(mean(vNumEvents(vSel,:)))];
title(sTitlestr);
