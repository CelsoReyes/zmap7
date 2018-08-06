function [params] = sv_calcMc(params)
% function [params] = sv_calcMc(params)
% -------------------------------------
% Calculation of magnitude of completeness
%
% Input parameters:
%   params.mCatalog           Earthquake catalog
%   params.mPolygon           Polygon (defined by ex_selectgrid)
%   params.vX                 X-vector (defined by ex_selectgrid)
%   params.vY                 Y-vector (defined by ex_selectgrid)
%   params.vUsedNodes         Used nodes vX * vY defining the mPolygon (defined by ex_selectgrid)
%   params.bRandom            Perform random simulation (true) or real calculation (false)
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
%   Check sv_NodeCalcMc.m for a list of variables!!
%
% J. Woessner; woessner@seismo.ifg.ethz.ch
% updated: 11.06.03

report_this_filefun();

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

% Check for bootstrapping or not
% ------------------------------
% Case of calculations with bootstrapping
if params.bBstnum
    % Loop over time
    fTstart = params.fTstart;
    while fTstart < params.fTmaxCat
        mValueGrid_ = [];
        params.mCatalog = mCatalog;
        % Create Indices to catalog and select quakes in time period
        vSel = (fTstart <= params.mCatalog.Date & params.mCatalog.Date < fTstart+fTimePeriodDays);
        params.mCatalog = params.mCatalog.subset(vSel);
        [params.caNodeIndices] = ex_CreateIndexCatalog(params.mCatalog, params.mPolygon, params.bMap, params.nGriddingMode, ...
         params.nNumberEvents, params.fRadius, params.fSizeRectHorizontal, params.fSizeRectDepth);
        % Loop over all grid nodes
        hWaitbar1 = waitbar(0,'Calculating nodes...');
        set(hWaitbar1,'Numbertitle','off','Name','Node percentage');
        for nNode_ = 1:length(params.mPolygon(:,1))
            % Create node catalog
            mNodeCatalog_ = params.mCatalog(params.caNodeIndices{nNode_}, :);
            % Check for constant number of events calculations
            if (params.nGriddingMode == 0)
                [mNodeCatalog_] = ex_CheckMaxRadius(mNodeCatalog_, params.mPolygon, nNode_, params.caNodeIndices, params.fMaxRadius, params.nNumberEvents, params.bMap);
            end
            [nX,nY] = size(mNodeCatalog_);
            if (nX < params.nMinimumNumber)
               mValueGrid_= [mValueGrid_; NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN nX NaN NaN NaN NaN];
            else
                [rCalcNodeResult_] = sv_NodeCalcMc(params,mNodeCatalog_);
                % Store the results
                mValueGrid_= [mValueGrid_; rCalcNodeResult_.fMc_max rCalcNodeResult_.fMc_90 rCalcNodeResult_.fMc_95 rCalcNodeResult_.fMc_com...
                        rCalcNodeResult_.fMc_EMR rCalcNodeResult_.fMc_shi rCalcNodeResult_.fMc_Bst...
                        rCalcNodeResult_.fStd_Mc rCalcNodeResult_.fBvalue_Bst rCalcNodeResult_.fStd_B...
                        rCalcNodeResult_.fAvalue_Bst rCalcNodeResult_.fStd_A nX...
                        rCalcNodeResult_.bH rCalcNodeResult_.fPval rCalcNodeResult_.bH_Bst rCalcNodeResult_.fPval_Bst];
            end; % End of if on length(mNodeCatalog_(:,1)
            if rem(nNode_,500) == 0
                waitbar(nNode_/length(params.mPolygon(:,1)))
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Temporary saving
                params.vcsGridNames = cellstr(char('Mc max. curvature' , 'Mc 90% goodness of fit' , 'Mc 95% goodness of fit',...
                    'Mc best combination', 'Mc EMR-method', 'Mc(Shi-b-uncertainty)', 'Mc(Bst-mean)', 'Mc(Bst-2nd-moment)',...
                    'Mc(Bst-b)', 'Mc(b_2nd-moment)','Mc(Bst-a)', 'Mc(a_2nd-moment)','Number of events',...
                    'H(KST)','P(KST)','H(KST_Bst)','P(KST_Bst)'));
                params.mValueGrid = mValueGrid_;
                % Add parameter to params.sComment
                if  params.nGriddingMode == 0;   % Constant number
                    params.sComment = ['Starttime ' num2str(fTstart) ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
                            ' Time period (days) ' num2str(params.fTimePeriodDays) ' d, Constant number: ' num2str(params.nNumberEvents) ', MaxRadius: '...
                            num2str(params.fMaxRadius) ' km'];
                    vResults = params;
                    save(['result_Time' num2str(fTstart) '_Constnum_' num2str(params.nNumberEvents) '_MaxRad_' num2str(params.fMaxRadius)...
                            '_Nmin_' num2str(params.nMinimumNumber) '_Node' num2str(nNode_) '.mat'], 'vResults');
                elseif params.nGriddingMode == 1;   % Constant radius
                    params.sComment = ['Starttime ' num2str(fTstart) ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
                            ' Time period (days) ' num2str(params.fTimePeriodDays) ' d, Radius: ' num2str(params.fRadius) ' km, Nmin: ' num2str(params.nMinimumNumber)];
                    vResults = params;
                    save(['result_Time' num2str(fTstart) '_Rad_' num2str(params.fRadius) '_Nmin_' num2str(params.nMinimumNumber)  '_Node' num2str(nNode_) '.mat'], 'vResults');
                else  % Rectangle mode
                    params.sComment = ['Starttime ' num2str(fTstart) ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
                            ' Time period (days) ' num2str(params.fTimePeriodDays) ' d, Rect. X: ' num2str(params.fSizeRectHorizontal) ' km, Rect. Y: ' num2str(params.fSizeRectDepth)...
                            ' km, Nmin: ' num2str(params.nMinimumNumber)];
                    vResults = params;
                    save(['result_Time' num2str(fTstart) '_RectX_' num2str(params.fSizeRectHorizontal) '_RectY_' num2str(params.fSizeRectDepth)...
                            '_Nmin_' num2str(params.nMinimumNumber)  '_Node' num2str(nNode_) '.mat'], 'vResults');
                end; % END of params.nGriddingmode
                vResults =[];
            end; % End updating waitbar
        end; % for nNode
        close(hWaitbar1);
        % Parameter description
        params.vcsGridNames = cellstr(char('Mc max. curvature' , 'Mc 90% goodness of fit' , 'Mc 95% goodness of fit',...
                    'Mc best combination', 'Mc EMR-method', 'Mc(Shi-b-uncertainty)', 'Mc(Bst-mean)', 'Mc(Bst-2nd-moment)',...
                    'Mc(Bst-b)', 'Mc(b_2nd-moment)','Mc(Bst-a)', 'Mc(a_2nd-moment)','Number of events',...
                    'H(KST)','P(KST)','H(KST_Bst)','P(KST_Bst)'));
        params.mValueGrid = mValueGrid_;
        % Add parameter to params.sComment
        if  params.nGriddingMode == 0;   % Constant number
            params.sComment = ['Starttime ' num2str(fTstart) ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
                    ' Time period (days) ' num2str(params.fTimePeriodDays) ' d, Constant number: ' num2str(params.nNumberEvents) ', MaxRadius: '...
                    num2str(params.fMaxRadius) ' km'];
            vResults = params;
            save(['result_Time' num2str(fTstart) '_Constnum_' num2str(params.nNumberEvents) '_MaxRad_' num2str(params.fMaxRadius)...
                    '_Nmin_' num2str(params.nMinimumNumber) '.mat'], 'vResults');
        elseif params.nGriddingMode == 1;   % Constant radius
            params.sComment = ['Starttime ' num2str(fTstart) ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
                    ' Time period (days) ' num2str(params.fTimePeriodDays) ' d, Radius: ' num2str(params.fRadius) ' km, Nmin: ' num2str(params.nMinimumNumber)];
            vResults = params;
            save(['result_Time' num2str(fTstart) '_Rad_' num2str(params.fRadius) '_Nmin_' num2str(params.nMinimumNumber) '.mat'], 'vResults');
        else  % Rectangle mode
            params.sComment = ['Starttime ' num2str(fTstart) ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
                    ' Time period (days) ' num2str(params.fTimePeriodDays) ' d, Rect. X: ' num2str(params.fSizeRectHorizontal) ' km, Rect. Y: ' num2str(params.fSizeRectDepth)...
                    ' km, Nmin: ' num2str(params.nMinimumNumber)];
            vResults = params;
            save(['result_Time' num2str(fTstart) '_RectX_' num2str(params.fSizeRectHorizontal) '_RectY_' num2str(params.fSizeRectDepth)...
                    '_Nmin_' num2str(params.nMinimumNumber) '.mat'], 'vResults');
        end
        vResults =[];
        fTstart = fTstart+params.fTimePeriodDays;
    end; % End of while fTstart

    % Case of no bootstrapping
else
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
        for nNode_ = 1:length(params.mPolygon(:,1))
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
            end; % End of if on length(mNodeCatalog_(:,1)
            if rem(nNode_,500) == 0
                waitbar(nNode_/length(params.mPolygon(:,1)))
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Temporary saving
                % Witout Lognormal, but mean and median for Norm Mc
                params.vcsGridNames = cellstr(char('Mc max. curvature' , 'Mc 90% goodness of fit' , 'Mc 95% goodness of fit',...
                    'Mc best combination', 'Mc EMR-method', 'Mc(Shi-b-uncertainty)','Number of events'));
                params.mValueGrid = mValueGrid_;
                % Add parameter to params.sComment
                if  params.nGriddingMode == 0;   % Constant number
                    params.sComment = ['Starttime ' num2str(fTstart) ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
                            ' Time period (days) ' num2str(params.fTimePeriodDays) ' d, Constant number: ' num2str(params.nNumberEvents) ', MaxRadius: '...
                            num2str(params.fMaxRadius) ' km'];
                    vResults = params;
                    save(['result_Time' num2str(fTstart) '_Constnum_' num2str(params.nNumberEvents) '_MaxRad_' num2str(params.fMaxRadius)...
                            '_Nmin_' num2str(params.nMinimumNumber) '_Node' num2str(nNode_) '.mat'], 'vResults');
                elseif params.nGriddingMode == 1;   % Constant radius
                    params.sComment = ['Starttime ' num2str(fTstart) ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
                            ' Time period (days) ' num2str(params.fTimePeriodDays) ' d, Radius: ' num2str(params.fRadius) ' km, Nmin: ' num2str(params.nMinimumNumber)];
                    vResults = params;
                    save(['result_Time' num2str(fTstart) '_Rad_' num2str(params.fRadius) '_Nmin_' num2str(params.nMinimumNumber)  '_Node' num2str(nNode_) '.mat'], 'vResults');
                else  % Rectangle mode
                    params.sComment = ['Starttime ' num2str(fTstart) ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
                            ' Time period (days) ' num2str(params.fTimePeriodDays) ' d, Rect. X: ' num2str(params.fSizeRectHorizontal) ' km, Rect. Y: ' num2str(params.fSizeRectDepth)...
                            ' km, Nmin: ' num2str(params.nMinimumNumber)];
                    vResults = params;
                    save(['result_Time' num2str(fTstart) '_RectX_' num2str(params.fSizeRectHorizontal) '_RectY_' num2str(params.fSizeRectDepth)...
                            '_Nmin_' num2str(params.nMinimumNumber)  '_Node' num2str(nNode_) '.mat'], 'vResults');
                end; % END of params.nGriddingmode
                vResults =[];
            end; % End updating waitbar
        end; % for nNode
        close(hWaitbar1);
        % Parameter description
        params.vcsGridNames = cellstr(char('Mc max. curvature' , 'Mc 90% goodness of fit' , 'Mc 95% goodness of fit',...
            'Mc best combination', 'Mc EMR-method', 'Mc(Shi-b-uncertainty)','Number of events'));
        params.mValueGrid = mValueGrid_;
        % Add parameter to params.sComment
        if  params.nGriddingMode == 0;   % Constant number
            params.sComment = ['Starttime ' num2str(fTstart) ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
                    ' Time period (days) ' num2str(params.fTimePeriodDays) ' d, Constant number: ' num2str(params.nNumberEvents) ', MaxRadius: '...
                    num2str(params.fMaxRadius) ' km'];
            vResults = params;
            save(['result_Time' num2str(fTstart) '_Constnum_' num2str(params.nNumberEvents) '_MaxRad_' num2str(params.fMaxRadius)...
                    '_Nmin_' num2str(params.nMinimumNumber) '.mat'], 'vResults');
        elseif params.nGriddingMode == 1;   % Constant radius
            params.sComment = ['Starttime ' num2str(fTstart) ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
                    ' Time period (days) ' num2str(params.fTimePeriodDays) ' d, Radius: ' num2str(params.fRadius) ' km, Nmin: ' num2str(params.nMinimumNumber)];
            vResults = params;
            save(['result_Time' num2str(fTstart) '_Rad_' num2str(params.fRadius) '_Nmin_' num2str(params.nMinimumNumber) '.mat'], 'vResults');
        else  % Rectangle mode
            params.sComment = ['Starttime ' num2str(fTstart) ' Spacing ' num2str(params.fSpacingHorizontal) ' deg.,'...
                    ' Time period (days) ' num2str(params.fTimePeriodDays) ' d, Rect. X: ' num2str(params.fSizeRectHorizontal) ' km, Rect. Y: ' num2str(params.fSizeRectDepth)...
                    ' km, Nmin: ' num2str(params.nMinimumNumber)];
            vResults = params;
            save(['result_Time' num2str(fTstart) '_RectX_' num2str(params.fSizeRectHorizontal) '_RectY_' num2str(params.fSizeRectDepth)...
                    '_Nmin_' num2str(params.nMinimumNumber) '.mat'], 'vResults');
        end
        vResults =[];
        fTstart = fTstart+params.fTimePeriodDays;
    end; % End of while fTstart
end; % END of if params.bBst
