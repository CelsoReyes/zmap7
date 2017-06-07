function [params] = sv_calcB(vResults)
% function [vResults] = sv_calcB(vResults)
% -------------------------------------
% Calculation of b-value uncertainty from given mValueGrid_ determined with
% sv_calcMc
%
%
% Input parameters:
% vResults
%
% Output parameters:
%
%
% J. Woessner; woessner@seismo.ifg.ethz.ch
% last update: 14.04.03


% Initialize

% Create Indices to catalog
[vResults.caNodeIndices] = ex_CreateIndexCatalog(vResults.mCatalog, vResults.mPolygon, vResults.bMap, vResults.nGriddingMode,...
    vResults.nNumberEvents, vResults.fRadius, vResults.fSizeRectHorizontal, vResults.fSizeRectDepth);

% Determine time period of catalog
vResults.fTminCat = min(vResults.mCatalog(:,3));
vResults.fTmaxCat = max(vResults.mCatalog(:,3));
% Adjust to decimal years
fTimePeriod =vResults.fTimePeriod/365;

% Init result matrix
mValueGrid_ = [];

% Loop over all grid nodes
for nNode_ = 1:length(vResults.mPolygon(:,1))
    nNode_
    % Create node catalog
    mNodeCatalog_ = vResults.mCatalog(vResults.caNodeIndices{nNode_}, :);
    % Select time period for mNodeCatalog_
    vSel = (vResults.fTstart <= mNodeCatalog_(:,3) & mNodeCatalog_(:,3) < vResults.fTstart+fTimePeriod);
    mNodeCatalog_ = mNodeCatalog_(vSel,:);
    % Check for constant number of events calculations
    if (vResults.nGriddingMode == 0)
        [mNodeCatalog_] = ex_MaxRadius(vResults.mCatalog, vResults.mPolygon, nNode_, vResults.caNodeIndices, vResults.fMaxRadius, vResults.nNumberEvents, vResults.bMap);
    end
    [nX,nY] = size(mNodeCatalog_);
    if (nX < vResults.nMinimumNumber)
        mValueGrid_= [mValueGrid_; NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
    else
        try
            % b-value for median Mc(EMR)
            vSel1=(mNodeCatalog_(:,6) >= vResults.mValueGrid(nNode_,6));
            mCat1=mNodeCatalog_(vSel1,:);
            [fMeanMag1, fBValue1, fStdDev1, fAValue1] =  calc_bmemag(mCat1, vResults.fBinning);
            % b-value for 16 percentile Mc
            vSel2=(mNodeCatalog_(:,6) >= vResults.mValueGrid(nNode_,16));
            mCat2=mNodeCatalog_(vSel2,:);
            [fMeanMag2, fBValue2, fStdDev2, fAValue2] =  calc_bmemag(mCat2, vResults.fBinning);
            % b-value for 84 percentile Mc
            vSel3=(mNodeCatalog_(:,6) >= vResults.mValueGrid(nNode_,17));
            mCat3=mNodeCatalog_(vSel3,:);
            [fMeanMag3, fBValue3, fStdDev3, fAValue3] =  calc_bmemag(mCat3, vResults.fBinning);
            % b-value check for Mc(EMR)
            vSel4=(mNodeCatalog_(:,6) >= vResults.mValueGrid(nNode_,5));
            mCat4=mNodeCatalog_(vSel4,:);
            [fMeanMag4, fBValue4, fStdDev4, fAValue4] =  calc_bmemag(mCat4, vResults.fBinning);
            mValueGrid_= [mValueGrid_; fBValue1 fStdDev1 fAValue1 fBValue2 fStdDev2 fAValue2...
                    fBValue3 fStdDev3 fAValue3 fMeanMag4 fBValue4 fStdDev4 fAValue4];
        catch
            mValueGrid_= [mValueGrid_; NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
        end
    end; % End of if on length(mNodeCatalog_(:,1)
end; % for nNode
save(['Bval_result_Time' num2str(vResults.fTstart) '_Nmin_' num2str(vResults.nMinimumNumber) '.mat'], 'mValueGrid_');


