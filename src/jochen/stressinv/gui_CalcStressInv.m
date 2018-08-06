function [params] = gui_CalcStressInv(params,nNodeStart, nNodeEnd)
% function [params] = gui_CalcStressInv(params,nNodeStart, nNodeEnd);
% ----------------------------------------------------------------
% Calculate stress tensor inversion parameters
%
% Input parameters:
%   params.mCatalog           Earthquake catalog
%   params.mPolygon           Polygon (defined by ex_selectgrid)
%   params.vX                 X-vector (defined by ex_selectgrid)
%   params.vY                 Y-vector (defined by ex_selectgrid)
%   params.vUsedNodes         Used nodes vX * vY defining the mPolygon (defined by ex_selectgrid)
%   params.nCalculation       Number of random simulations
%   params.bMap               Calculate a map (true) or a cross-section (false)
%   params.bNumber            Use constant number (true) or constant radius (false)
%   params.nNumberEvents      Number of earthquakes if bNumber is true
%   params.fMaxRadius         Maximum Radius using a constant number of events; works only when bNumber is true
%   params.fRadius            Radius of gridnode if bNumber is false
%   params.nMinimumNumber     Minimum number of earthquakes per node for determining a b-value
%   params.fMinMag            Lower limit of magnitude range for testing
%   params.fMaxMag            Upper limit of magnitude range for testing
%   params.bTimePeriod        Calculate seismicity difference for 2 periods (0) until start and end of catalog or
%                             a specific time period before and after fSplitTime (1)
%   params.fTimePeriodDays        Length of time periods
%   params.bTstart            Check for starting time of temporal mapping
%   params.fTstart            Starting time for temporal mapping
%   params.bBstnum            Check for boostrap sampling
%   params.fBstnum            Number of bootstrap samples
%   params.fBinning           Bin size for magnitude binning
%   params.sComment           Comment on calculation

% Output parameters:
%   Same as input parameters including
%   params.mValueGrid         Matrix of calculated values
%   params.vcsGridNames       Names of parameters calculated
%   Check gui_NodeCalcStressInv.m for a list of variables!!
%
% J. Woessner; j.woessner@sed.ethz.ch
% updated: 16.02.2006

report_this_filefun();

% Check calculation for splitting of nodes
if nargin < 2
    nNodeStart = 1;
    nNodeEnd = length(params.mPolygon(:,1));
end

% Initialize
vResults = [];
params.sComment = [];
if isempty(params.fBinning)
    params.fBinning = 0.1;
end

% Determine time period of catalog
params.fTminCat = min(params.mCatalog.Date);
params.fTmaxCat = max(params.mCatalog.Date);

% Init result matrix
mValueGrid_ = [];

% Temporary saving the original catalog
mCatalog = params.mCatalog;

% Force saving all 100 nodes
fDivide = length(params.mPolygon(:,1))/100;
fForceSave = length(params.mPolygon(:,1))/fDivide;

% Loop over time
fTstart = params.fTstart;
while fTstart < params.fTmaxCat
    mValueGrid_ = [];
    params.mCatalog = mCatalog;
    % Create Indices to catalog and select quakes in time period
    vSel = (fTstart <= params.mCatalog.Date & params.mCatalog.Date < fTstart+params.fTimePeriodDays);
    params.mCatalog = params.mCatalog.subset(vSel);
    [params.caNodeIndices] = ex_CreateIndexCatalog(params.mCatalog, params.mPolygon, params.bMap, params.nGriddingMode, ...
        params.nNumberEvents, params.fRadius, params.fSizeRectHorizontal, params.fSizeRectDepth);
    % Loop over all grid nodes
    hWaitbar1 = waitbar(0,'Calculating nodes...');
    set(hWaitbar1,'Numbertitle','off','Name','Node percentage');
    for nNode_ = nNodeStart:nNodeEnd
        % Create node catalog
        mNodeCatalog_ = params.mCatalog(params.caNodeIndices{nNode_}, :);
        % Check for constant number of events calculations
        if (params.nGriddingMode == 0)
            [mNodeCatalog_] = ex_CheckMaxRadius(mNodeCatalog_, params.mPolygon, nNode_, params.caNodeIndices, params.fMaxRadius, params.nNumberEvents, params.bMap);
        end
        [nX,nY] = size(mNodeCatalog_);
        if (nX < params.nMinimumNumber)
            mValueGrid_= [mValueGrid_; NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN nX NaN NaN];
        else
            [rCalcNodeResult_] = gui_NodeCalcStressInv(params,mNodeCatalog_);
            % Store the results
            mValueGrid_= [mValueGrid_; rCalcNodeResult_.fVariance rCalcNodeResult_.fBeta ...
                rCalcNodeResult_.fStdBeta rCalcNodeResult_.fS11 rCalcNodeResult_.fS12...
                rCalcNodeResult_.fS13 rCalcNodeResult_.fS22 rCalcNodeResult_.fS23 rCalcNodeResult_.fS33...
                rCalcNodeResult_.fPhi rCalcNodeResult_.fS1Trend rCalcNodeResult_.fS1Plunge rCalcNodeResult_.fS2Trend ...
                rCalcNodeResult_.fS2Plunge rCalcNodeResult_.fS3Trend rCalcNodeResult_.fS3Plunge...
                rCalcNodeResult_.nNumEvents rCalcNodeResult_.fRms rCalcNodeResult_.fAphi];
        end; % End of if on nNode_
        if rem(nNode_,floor(fForceSave)) == 0
            waitbar(nNode_/length(params.mPolygon(:,1)))
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Temporary saving
            params.vcsGridNames = cellstr(char('Variance', '\beta', '\Sigma \beta', 'S11', 'S12', 'S13',...
                'S22', 'S23','S33', 'Phi','S1 Trend','S1 Plunge','S2 Trend','S2 Plunge',...
                'S3 Trend','S3 Plunge','Number of events','FM RMS diversity','A_{\phi}'));
            params.mValueGrid = mValueGrid_;
            % Add parameter to params.sComment
            if  params.nGriddingMode == 0;   % Constant number
                params.sComment = ['Starttime ' num2str(fTstart) ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
                    ' Time period (days) ' num2str(params.fTimePeriodDays) ' d, Constant number: ' num2str(params.nNumberEvents) ', MaxRadius: '...
                    num2str(params.fMaxRadius) ' km'];
                vResults = params;
                save(['tmp_result_Time' num2str(fTstart) '_Constnum_' num2str(params.nNumberEvents) '_MaxRad_' num2str(params.fMaxRadius)...
                    '_Nmin_' num2str(params.nMinimumNumber) '.mat'], 'vResults');
            elseif params.nGriddingMode == 1;   % Constant radius
                params.sComment = ['Starttime ' num2str(fTstart) ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
                    ' Time period (days) ' num2str(params.fTimePeriodDays) ' d, Radius: ' num2str(params.fRadius) ' km, Nmin: ' num2str(params.nMinimumNumber)];
                vResults = params;
                save(['tmp_result_Time' num2str(fTstart) '_Rad_' num2str(params.fRadius) '_Nmin_' num2str(params.nMinimumNumber)  '.mat'], 'vResults');
            else  % Rectangle mode
                params.sComment = ['Starttime ' num2str(fTstart) ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
                    ' Time period (days) ' num2str(params.fTimePeriodDays) ' d, Rect. X: ' num2str(params.fSizeRectHorizontal) ' km, Rect. Y: ' num2str(params.fSizeRectDepth)...
                    ' km, Nmin: ' num2str(params.nMinimumNumber)];
                vResults = params;
                save(['tmp_result_Time' num2str(fTstart) '_RectX_' num2str(params.fSizeRectHorizontal) '_RectY_' num2str(params.fSizeRectDepth)...
                    '_Nmin_' num2str(params.nMinimumNumber) '.mat'], 'vResults');
            end; % END of params.nGriddingmode
            vResults =[];
        end; % End updating waitbar
    end; % for nNode
    close(hWaitbar1);
    % Parameter description
    params.vcsGridNames = cellstr(char('Variance', '\beta', '\Sigma \beta', 'S11', 'S12', 'S13',...
                'S22', 'S23','S33', 'Phi','S1 Trend','S1 Plunge','S2 Trend','S2 Plunge',...
                'S3 Trend','S3 Plunge','Number of events','FM RMS diversity','A_{\phi}'));
    params.mValueGrid = mValueGrid_;
    % Add parameter to params.sComment
    if  params.nGriddingMode == 0;   % Constant number
        params.sComment = ['Starttime ' num2str(fTstart) ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
            ' Time period (days) ' num2str(params.fTimePeriodDays) ' d, Constant number: ' num2str(params.nNumberEvents) ', MaxRadius: '...
            num2str(params.fMaxRadius) ' km'];
        vResults = params;
        save(['result_Time' num2str(fTstart) '_Constnum_' num2str(params.nNumberEvents) '_MaxRad_' num2str(params.fMaxRadius)...
            '_Nmin_' num2str(params.nMinimumNumber) '_Nodes_' num2str(nNodeStart) '_' num2str(nNodeEnd) '.mat'], 'vResults');
    elseif params.nGriddingMode == 1;   % Constant radius
        params.sComment = ['Starttime ' num2str(fTstart) ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
            ' Time period (days) ' num2str(params.fTimePeriodDays) ' d, Radius: ' num2str(params.fRadius) ' km, Nmin: ' num2str(params.nMinimumNumber)];
        vResults = params;
        save(['result_Time' num2str(fTstart) '_Rad_' num2str(params.fRadius) '_Nmin_' num2str(params.nMinimumNumber)...
            '_Nodes_' num2str(nNodeStart) '_' num2str(nNodeEnd) '.mat'], 'vResults');
    else  % Rectangle mode
        params.sComment = ['Starttime ' num2str(fTstart) ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
            ' Time period (days) ' num2str(params.fTimePeriodDays) ' d, Rect. X: ' num2str(params.fSizeRectHorizontal) ' km, Rect. Y: ' num2str(params.fSizeRectDepth)...
            ' km, Nmin: ' num2str(params.nMinimumNumber)];
        vResults = params;
        save(['result_Time' num2str(fTstart) '_RectX_' num2str(params.fSizeRectHorizontal) '_RectY_' num2str(params.fSizeRectDepth)...
            '_Nmin_' num2str(params.nMinimumNumber) '_Nodes_' num2str(nNodeStart) '_' num2str(nNodeEnd) '.mat'], 'vResults');
    end
    vResults =[];
    fTstart = fTstart+params.fTimePeriodDays;
end; % End of while fTstart

