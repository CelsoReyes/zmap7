function [params] = sv_calcSchuster(params)
% function [params] = sv_calcSchuster(params)
% -------------------------------------
% Calulate Schuster's test and it's uncertainty, as well as fast Mc
% estimates
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
%   Check sv_NodeCalcSchuster.m for a list of variables!!
%
% J. Woessner; woessner@seismo.ifg.ethz.ch
% last update: 17.04.03

global bDebug;
if bDebug
    report_this_filefun(mfilename('fullpath'));
end

% Initialize
vResults = [];
params.sComment = [];
if isempty(params.fBinning)
    params.fBinning = 0.1;
end

% Create Indices to catalog
[params.caNodeIndices] = ex_CreateIndexCatalog(params.mCatalog, params.mPolygon, params.bMap, params.nGriddingMode, ...
    params.nNumberEvents, params.fRadius, params.fSizeRectHorizontal, params.fSizeRectDepth);

% Determine time period of catalog
params.fTminCat = min(params.mCatalog(:,3));
params.fTmaxCat = max(params.mCatalog(:,3));
% Adjust to decimal years
fTimePeriod =params.fTimePeriod/365;

% Loop over time
fTstart = params.fTstart;
while fTstart < params.fTmaxCat
    % Init result matrix
    mValueGrid_ = [];
    for fStartMag = params.fStartMag:0.2:params.fEndMag
        hWaitbar1 = waitbar(0,'Calculating nodes...');
        set(hWaitbar1,'Numbertitle','off','Name','Node percentage');
        % Loop over all grid nodes
        for nNode_ = 1:length(params.mPolygon(:,1))
            % Create node catalog
            mNodeCatalog_ = params.mCatalog(params.caNodeIndices{nNode_}, :);

            % Check for constant number of events calculations
            if (params.nGriddingMode == 0)
                [mNodeCatalog_] = ex_MaxRadius(params.mCatalog, params.mPolygon, nNode_, params.caNodeIndices, params.fMaxRadius, params.nNumberEvents, params.bMap);
            end
            % Select time period for mNodeCatalog_
            vSel = (fTstart <= mNodeCatalog_(:,3) & mNodeCatalog_(:,3) < fTstart+fTimePeriod);
            mNodeCatalog_ = mNodeCatalog_(vSel,:);
            % Select magnitude range for probability calculations
            vSel1 = (mNodeCatalog_(:,6) >= fStartMag);
            mNodeCatalog_ = mNodeCatalog_(vSel1,:);
            [nX,nY] = size(mNodeCatalog_)
            if (nX < params.nMinimumNumber)
                mValueGrid_= [mValueGrid_; NaN NaN NaN NaN NaN NaN NaN];
            else
                [rCalcNodeResult_] = sv_NodeCalcSchuster(params,mNodeCatalog_);
                mValueGrid_= [mValueGrid_; rCalcNodeResult_.fMc_max rCalcNodeResult_.fMc_90 rCalcNodeResult_.fMc_95 rCalcNodeResult_.fMc_com...
                        rCalcNodeResult_.fMcSch rCalcNodeResult_.flogProbSch rCalcNodeResult_.flogv1Srange];
            end; % End of if on length(mNodeCatalog_(:,1)
            params.vcsGridNames = cellstr(char('Mc max. curvature' , 'Mc 90% goodness of fit' , 'Mc 95% goodness of fit',...
                'Mc best combination', 'Mc Schuster', 'log10(Prob) Schuster', 'log10(Prob) range'));
            params.mValueGrid = mValueGrid_;

            if rem(nNode_,length(nNode_)/10) == 0
                waitbar(nNode_/length(params.mPolygon(:,1)))
            end; % End updating waitbar

        end; % for nNode
        close(hWaitbar1);
        % Add parameter to params.sComment
        if  params.nGriddingMode == 0;   % Constant number
            params.sComment = ['Starttime ' num2str(fTstart) ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
                    ' Time period ' num2str(params.fTimePeriod) ' d, Constant number: ' num2str(params.nNumberEvents) ', MaxRadius: '...
                    num2str(params.fMaxRadius) ' km, StartMag: ' num2str(fStartMag)];
            vResults = params;
            save(['result_Time' num2str(fTstart) '_Constnum_' num2str(params.nNumberEvents) '_MaxRad_' num2str(params.fMaxRadius)...
                    '_Nmin_' num2str(params.nMinimumNumber) '_Node' num2str(nNode_)  '_SMag_' num2str(fStartMag) '.mat'], 'vResults');
        elseif params.nGriddingMode == 1;   % Constant radius
            params.sComment = ['Starttime ' num2str(fTstart) ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
                    ' Time period ' num2str(params.fTimePeriod) ' d, Radius: ' num2str(params.fRadius) ' km, Nmin: ' num2str(params.nMinimumNumber) ' StartMag: ' num2str(fStartMag)];
            vResults = params;
            save(['result_Time' num2str(fTstart) '_Rad_' num2str(params.fRadius) '_Nmin_' num2str(params.nMinimumNumber)  '_Node' num2str(nNode_)  '_SMag_' num2str(fStartMag) '.mat'], 'vResults');
        else  % Rectangle mode
            params.sComment = ['Starttime ' num2str(fTstart) ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
                    ' Time period ' num2str(params.fTimePeriod) ' d, Rect. X: ' num2str(params.fSizeRectHorizontal) ' km, Rect. Y: ' num2str(params.fSizeRectDepth)...
                    ' km, Nmin: ' num2str(params.nMinimumNumber) ' StartMag: ' num2str(fStartMag)];
            vResults = params;
            save(['result_Time' num2str(fTstart) '_RectX_' num2str(params.fSizeRectHorizontal) '_RectY_' num2str(params.fSizeRectDepth)...
                    '_Nmin_' num2str(params.nMinimumNumber)  '_Node' num2str(nNode_) '_SMag_' num2str(fStartMag) '.mat'], 'vResults');
        end; % END of params.nGriddingmode
        vResults =[];
        mValueGrid_=[];
    end; % END FOR on fStartMag
    fTstart = fTstart+fTimePeriod;
end; % End of while fTstart
