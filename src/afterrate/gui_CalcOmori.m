function [params] = gui_CalcOmori(params,nNodeStart, nNodeEnd)
    % function [params] = gui_CalcOmori(params,nNodeStart, nNodeEnd);
    % ----------------------------------------------------------------
    % Calculate Omori parameters, here setting up the data
    %
    % Input parameters:
    %   params.mCatalog           Earthquake catalog
    %   params.mPolygon           Polygon (defined by ex_selectgrid)
    %   params.vX                 X-vector (defined by ex_selectgrid)
    %   params.vY                 Y-vector (defined by ex_selectgrid)
    %   params.vUsedNodes         Used nodes vX * vY defining the mPolygon (defined by ex_selectgrid)
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
    %   Check gui_NodeCalcOmori.m for a list of variables!!
    %
    % J. Woessner; j.woessner@sed.ethz.ch
    % last update: 16.02.2006

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

    % Init result matrix
    mValueGrid_ = [];

    % Temporary saving the original catalog
    mCatalog = params.mCatalog;

    % Force saving all 100 nodes
    fDivide = length(params.mPolygon(:,1))/100
    fForceSave = length(params.mPolygon(:,1))/fDivide;

    % % Loop over time
    fTstart = params.fTstart;
    % while fTstart < params.fTmaxCat
    % mValueGrid_ = [];
    % params.mCatalog = mCatalog;

    % Create Indices to catalog
    % vSel = (fTstart <= params.mCatalog(:,3) & params.mCatalog(:,3) < fTstart+fTimePeriod);
    % params.mCatalog = params.mCatalog(vSel,:);
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
        % Check for number of events in aftershock sequence
        % Create catalog after split time (aftershock sequence)
        vSelAf = (params.fTstart <= mNodeCatalog_(:,3) & mNodeCatalog_(:,3) < params.fTstart+params.fTimePeriod);
        [nX,nY] = size(mNodeCatalog_(vSelAf,:));
        if (nX < params.nMinimumNumber)
            [nNumBgr,nY2] = size(mNodeCatalog_(~vSelAf,:));
            mValueGrid_= [mValueGrid_; NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN nNumBgr nNumBgr/params.fTimeBgr NaN NaN];
        else
            [rCalcNodeResult_] = gui_NodeCalcOmori(params,mNodeCatalog_);
            % Store the results
            mValueGrid_= [mValueGrid_;rCalcNodeResult_.pval1 rCalcNodeResult_.cval1 rCalcNodeResult_.kval1 rCalcNodeResult_.nNumEvents rCalcNodeResult_.fLogEqdens...
                rCalcNodeResult_.H rCalcNodeResult_.pmean1 rCalcNodeResult_.cmean1 rCalcNodeResult_.kmean1...
                rCalcNodeResult_.pmeanStd1 rCalcNodeResult_.cmeanStd1 rCalcNodeResult_.kmeanStd1...
                rCalcNodeResult_.fTafseq rCalcNodeResult_.fTafseqmean rCalcNodeResult_.nNumAf rCalcNodeResult_.nNumBgr...
                rCalcNodeResult_.fBgrate rCalcNodeResult_.fLog10Bgrate rCalcNodeResult_.fLog10Tafseq];
        end % End of if on nNode_
        if rem(nNode_,floor(fForceSave)) == 0
            waitbar(nNode_/length(params.mPolygon(:,1)))
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Temporary saving
            params.vcsGridNames = cellstr(char('p-value','c-value','k-value','Number of events','log(EQ_density)',...
                'H','p-mean','c-mean','k-mean','\sigma (p)','\sigma (c)','\sigma (k)','t_a [years]','t_a(Bst) [years]',...
                'Number of aftershock','Num. events background','Background rate [year]','Log10(Bgr rate) [year]',...
                'log10(t_a) [years]'));
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
            end % END of params.nGriddingmode
            vResults =[];
        end % End updating waitbar
    end % for nNode
    close(hWaitbar1);
    % Parameter description
    params.vcsGridNames = cellstr(char('p-value','c-value','k-value','Number of events','log(EQ_density)',...
        'H','p-mean','c-mean','k-mean','\sigma (p)','\sigma (c)','\sigma (k)','t_a [years]','t_a(Bst) [years]',...
        'Number of aftershock','Num. events background','Background rate [year]','Log10(Bgr rate) [year]',...
        'log10(t_a) [years]'));
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
    %     vResults =[];
    %     fTstart = fTstart+fTimePeriod;
    % end % End of while fTstart

