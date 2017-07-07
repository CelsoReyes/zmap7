function [params] = sv_calcMcNodes_2methods(params,nNodeStart, nNodeEnd)
% function [params] = sv_calcMcNodes_2methods(params,nNodeStart, nNodeEnd);
% ----------------------------------------------------------------
% Calculation of magnitude of completeness specifying the nodes to be calculated for distributing on different CPUs
% Same as sv_calcMcNodes but just using McEMR and MAXC
%
% Input parameters:
%   params.mCatalog           Earthquake catalog
%   params.mPolygon           Polygon (defined by ex_selectgrid)
%   params.vX                 X-vector (defined by ex_selectgrid)
%   params.vY                 Y-vector (defined by ex_selectgrid)
%   params.vUsedNodes         Used nodes vX * vY defining the mPolygon (defined by ex_selectgrid)
%   params.bRandom            Perform random simulation (=1) or real calculation (=0)
%   params.nCalculation       Number of random simulations
%   params.bMap               Calculate a map (=1) or a cross-section (=0)
%   params.bNumber            Use constant number (=1) or constant radius (=0)
%   params.nNumberEvents      Number of earthquakes if bNumber == 1
%   params.fMaxRadius         Maximum Radius using a constant number of events; works only with bNumber == 1
%   params.fRadius            Radius of gridnode if bNumber == 0
%   params.nMinimumNumber     Minimum number of earthquakes per node for determining a b-value
%   params.fMinMag            Lower limit of magnitude range for testing
%   params.fMaxMag            Upper limit of magnitude range for testing
%   params.bTimePeriod        Calculate seismicity difference for 2 periods (0) until start and end of catalog or
%                             a specific time period before and after fSplitTime (1)
%   params.fTimePeriod        Length of time periods
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
%   Check sv_NodeCalcMc.m for a list of variables!!
%
% J. Woessner; j.woessner@sed.ethz.ch
% last update: 27.07.04

global bDebug;
if bDebug
    report_this_filefun(mfilename('fullpath'));
end

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
params.fTminCat = min(params.mCatalog(:,3));
params.fTmaxCat = max(params.mCatalog(:,3));
% Adjust to decimal years
fTimePeriod =params.fTimePeriod/365;

% Init result matrix
mValueGrid_ = [];

% Temporary saving the original catalog
mCatalog = params.mCatalog;

% Force saving all 500 nodes
fDivide = length(params.mPolygon(:,1))/500
fForceSave = length(params.mPolygon(:,1))/fDivide;
% Check for bootstrapping or not
% ------------------------------
% Case of calculations with bootstrapping
if (params.bBstnum == 1)
    % Loop over time
    fTstart = params.fTstart;
    while fTstart < params.fTmaxCat
        mValueGrid_ = [];
        params.mCatalog = mCatalog;
        % Create Indices to catalog and select quakes in time period
        vSel = (fTstart <= params.mCatalog(:,3) & params.mCatalog(:,3) < fTstart+fTimePeriod);
        params.mCatalog = params.mCatalog(vSel,:);
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
                mValueGrid_= [mValueGrid_; NaN NaN NaN NaN NaN NaN NaN NaN nX NaN NaN NaN NaN];
            else
                [rCalcNodeResult_] = sv_NodeCalcMc_2method(params,mNodeCatalog_);
                % Store the results
                mValueGrid_= [mValueGrid_; rCalcNodeResult_.fMc_max rCalcNodeResult_.fMc_EMR rCalcNodeResult_.fMc_Bst...
                        rCalcNodeResult_.fStd_Mc rCalcNodeResult_.fBvalue_Bst rCalcNodeResult_.fStd_B...
                        rCalcNodeResult_.fAvalue_Bst rCalcNodeResult_.fStd_A nX...
                        rCalcNodeResult_.bH_EMR rCalcNodeResult_.fPval rCalcNodeResult_.bH_Bst rCalcNodeResult_.fPval_Bst];
            end; % End of if on nNode_
            if rem(nNode_,floor(fForceSave)) == 0
                waitbar(nNode_/length(params.mPolygon(:,1)))
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Temporary saving
                params.vcsGridNames = cellstr(char('Mc max. curvature', 'Mc EMR-method', 'Mc(Bst-mean)', 'Mc(Bst-2nd-moment)',...
                    'Mc(Bst-b)', 'Mc(b_2nd-moment)','Mc(Bst-a)', 'Mc(a_2nd-moment)','Number of events',...
                    'H(KST)','P(KST)','H(KST_Bst)','P(KST_Bst)'));
                params.mValueGrid = mValueGrid_;
                % Add parameter to params.sComment
                if  params.nGriddingMode == 0;   % Constant number
                    params.sComment = ['Starttime ' num2str(fTstart) ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
                            ' Time period ' num2str(params.fTimePeriod) ' d, Constant number: ' num2str(params.nNumberEvents) ', MaxRadius: '...
                            num2str(params.fMaxRadius) ' km'];
                    vResults = params;
                    save(['tmp_result_Time' num2str(fTstart) '_Constnum_' num2str(params.nNumberEvents) '_MaxRad_' num2str(params.fMaxRadius)...
                            '_Nmin_' num2str(params.nMinimumNumber) '.mat'], 'vResults');
                elseif params.nGriddingMode == 1;   % Constant radius
                    params.sComment = ['Starttime ' num2str(fTstart) ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
                            ' Time period ' num2str(params.fTimePeriod) ' d, Radius: ' num2str(params.fRadius) ' km, Nmin: ' num2str(params.nMinimumNumber)];
                    vResults = params;
                    save(['tmp_result_Time' num2str(fTstart) '_Rad_' num2str(params.fRadius) '_Nmin_' num2str(params.nMinimumNumber) '.mat'], 'vResults');
                else  % Rectangle mode
                    params.sComment = ['Starttime ' num2str(fTstart) ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
                            ' Time period ' num2str(params.fTimePeriod) ' d, Rect. X: ' num2str(params.fSizeRectHorizontal) ' km, Rect. Y: ' num2str(params.fSizeRectDepth)...
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
        params.vcsGridNames = cellstr(char('Mc max. curvature', 'Mc EMR-method', 'Mc(Bst-mean)', 'Mc(Bst-2nd-moment)',...
            'Mc(Bst-b)', 'Mc(b_2nd-moment)','Mc(Bst-a)', 'Mc(a_2nd-moment)','Number of events',...
                    'H(KST)','P(KST)','H(KST_Bst)','P(KST_Bst)'));
        params.mValueGrid = mValueGrid_;
        % Add parameter to params.sComment
        if  params.nGriddingMode == 0;   % Constant number
            params.sComment = ['Starttime ' num2str(fTstart) ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
                    ' Time period ' num2str(params.fTimePeriod) ' d, Constant number: ' num2str(params.nNumberEvents) ', MaxRadius: '...
                    num2str(params.fMaxRadius) ' km'];
            vResults = params;
            save(['result_Time' num2str(fTstart) '_Constnum_' num2str(params.nNumberEvents) '_MaxRad_' num2str(params.fMaxRadius)...
                    '_Nmin_' num2str(params.nMinimumNumber) '_Nodes_' num2str(nNodeStart) '.mat'], 'vResults');
        elseif params.nGriddingMode == 1;   % Constant radius
            params.sComment = ['Starttime ' num2str(fTstart) ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
                    ' Time period ' num2str(params.fTimePeriod) ' d, Radius: ' num2str(params.fRadius) ' km, Nmin: ' num2str(params.nMinimumNumber)];
            vResults = params;
            save(['result_Time' num2str(fTstart) '_Rad_' num2str(params.fRadius) '_Nmin_' num2str(params.nMinimumNumber)...
                '_Nodes_' num2str(nNodeStart) '.mat'], 'vResults');
        else  % Rectangle mode
            params.sComment = ['Starttime ' num2str(fTstart) ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
                    ' Time period ' num2str(params.fTimePeriod) ' d, Rect. X: ' num2str(params.fSizeRectHorizontal) ' km, Rect. Y: ' num2str(params.fSizeRectDepth)...
                    ' km, Nmin: ' num2str(params.nMinimumNumber)];
            vResults = params;
            save(['result_Time' num2str(fTstart) '_RectX_' num2str(params.fSizeRectHorizontal) '_RectY_' num2str(params.fSizeRectDepth)...
                    '_Nmin_' num2str(params.nMinimumNumber) '_Nodes_' num2str(nNodeStart) '.mat'], 'vResults');
        end
        vResults =[];
        fTstart = fTstart+fTimePeriod;
    end; % End of while fTstart

    % Case of no bootstrapping
else
    % Loop over time
    fTstart = params.fTstart;
    while fTstart < params.fTmaxCat
        mValueGrid_ = [];
        params.mCatalog = mCatalog;
        % Create Indices to catalog and select quakes in time period
        vSel = (fTstart <= params.mCatalog(:,3) & params.mCatalog(:,3) < fTstart+fTimePeriod);
        params.mCatalog = params.mCatalog(vSel,:);
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
                mValueGrid_= [mValueGrid_; NaN NaN NaN NaN NaN NaN nX];
            else
                [rCalcNodeResult_] = sv_NodeCalcMc(params,mNodeCatalog_);
                mValueGrid_= [mValueGrid_; rCalcNodeResult_.fMc_max rCalcNodeResult_.fMc_90 rCalcNodeResult_.fMc_95 rCalcNodeResult_.fMc_com...
                        rCalcNodeResult_.fMc_EMR rCalcNodeResult_.fMc_shi nX];
            end; % End of if on nX
            if rem(nNode_,500) == 0
                waitbar(nNode_/length(params.mPolygon(:,1)))
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Temporary saving
                params.vcsGridNames = cellstr(char('Mc max. curvature' , 'Mc 90% goodness of fit' , 'Mc 95% goodness of fit',...
                    'Mc best combination', 'Mc EMR-method', 'Mc(Shi-b-uncertainty)','Number of events'));
                params.mValueGrid = mValueGrid_;
                % Add parameter to params.sComment
                if  params.nGriddingMode == 0;   % Constant number
                    params.sComment = ['Starttime ' num2str(fTstart) ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
                            ' Time period ' num2str(params.fTimePeriod) ' d, Constant number: ' num2str(params.nNumberEvents) ', MaxRadius: '...
                            num2str(params.fMaxRadius) ' km'];
                    vResults = params;
                    save(['tmp_result_Time' num2str(fTstart) '_Constnum_' num2str(params.nNumberEvents) '_MaxRad_' num2str(params.fMaxRadius)...
                            '_Nmin_' num2str(params.nMinimumNumber) '_Node' num2str(nNode_) '.mat'], 'vResults');
                elseif params.nGriddingMode == 1;   % Constant radius
                    params.sComment = ['Starttime ' num2str(fTstart) ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
                            ' Time period ' num2str(params.fTimePeriod) ' d, Radius: ' num2str(params.fRadius) ' km, Nmin: ' num2str(params.nMinimumNumber)];
                    vResults = params;
                    save(['tmp_result_Time' num2str(fTstart) '_Rad_' num2str(params.fRadius) '_Nmin_' num2str(params.nMinimumNumber)  '_Node' num2str(nNode_) '.mat'], 'vResults');
                else  % Rectangle mode
                    params.sComment = ['Starttime ' num2str(fTstart) ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
                            ' Time period ' num2str(params.fTimePeriod) ' d, Rect. X: ' num2str(params.fSizeRectHorizontal) ' km, Rect. Y: ' num2str(params.fSizeRectDepth)...
                            ' km, Nmin: ' num2str(params.nMinimumNumber)];
                    vResults = params;
                    save(['tmp_result_Time' num2str(fTstart) '_RectX_' num2str(params.fSizeRectHorizontal) '_RectY_' num2str(params.fSizeRectDepth)...
                            '_Nmin_' num2str(params.nMinimumNumber)  '_Node' num2str(nNode_) '.mat'], 'vResults');
                end; % END of params.nGriddingmode
                vResults =[];
            end; % End updating waitbar
        end; % for nNode
        close(hWaitbar1);
        % Parameter description
        params.vcsGridNames = cellstr(char('Mc max. curvature' , 'Mc 90% goodness of fit' , 'Mc 95% goodness of fit',...
            'Mc best combination', 'Mc EMR-method', 'Mc(Shi-b-uncertainty)'));
        params.mValueGrid = mValueGrid_;
        % Add parameter to params.sComment
        if  params.nGriddingMode == 0;   % Constant number
            params.sComment = ['Starttime ' num2str(fTstart) ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
                    ' Time period ' num2str(params.fTimePeriod) ' d, Constant number: ' num2str(params.nNumberEvents) ', MaxRadius: '...
                    num2str(params.fMaxRadius) ' km'];
            vResults = params;
            save(['result_Time' num2str(fTstart) '_Constnum_' num2str(params.nNumberEvents) '_MaxRad_' num2str(params.fMaxRadius)...
                    '_Nmin_' num2str(params.nMinimumNumber) '_Nodes_' num2str(nNodeStart) '_' num2str(nNodeEnd) '.mat'], 'vResults');
        elseif params.nGriddingMode == 1;   % Constant radius
            params.sComment = ['Starttime ' num2str(fTstart) ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
                    ' Time period ' num2str(params.fTimePeriod) ' d, Radius: ' num2str(params.fRadius) ' km, Nmin: ' num2str(params.nMinimumNumber)];
            vResults = params;
            save(['result_Time' num2str(fTstart) '_Rad_' num2str(params.fRadius) '_Nmin_' num2str(params.nMinimumNumber)...
                '_Nodes_' num2str(nNodeStart) '_' num2str(nNodeEnd) '.mat'], 'vResults');
        else  % Rectangle mode
            params.sComment = ['Starttime ' num2str(fTstart) ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
                    ' Time period ' num2str(params.fTimePeriod) ' d, Rect. X: ' num2str(params.fSizeRectHorizontal) ' km, Rect. Y: ' num2str(params.fSizeRectDepth)...
                    ' km, Nmin: ' num2str(params.nMinimumNumber)];
            vResults = params;
            save(['result_Time' num2str(fTstart) '_RectX_' num2str(params.fSizeRectHorizontal) '_RectY_' num2str(params.fSizeRectDepth)...
                    '_Nmin_' num2str(params.nMinimumNumber) '_Nodes_' num2str(nNodeStart) '_' num2str(nNodeEnd) '.mat'], 'vResults');
        end
        vResults =[];
        fTstart = fTstart+fTimePeriod;
    end; % End of while fTstart
end; % END of if params.bBst
