function [mResult] = calc_GridMcBboot(vResults, nMethod)
% function [mResult] = calc_GridMcBboot(vResults, nMethod)
% --------------------------------------------------------
% Calculate Mc and b-value using the bootstrap mean value for an already
% existing grid with another Mc method
%
% Incoming variables:
% vResults : Struct array from grid calculated with sv_calcMc / sv_calc
% nMethod  : Method to calculate Mc
%
% Outgoing variables:
% mResult : [nNodeGridPoint fMc fStd_Mc fBvalue fStd_B fAvalue fStd_A]
%          Standard deviations by bootstrap
%          fMc, fBvalue, fAvalue are mean values from the bootstrap
%
% J. Woessner: woessner@seismo.ifg.ethz.ch
% last update: 25.11.03

mResult = [];

for nNodeGridPoint=1:length(vResults.mPolygon(:,1))
    % Get the data for the grid node
    mNodeCatalog_ = vResults.mCatalog(vResults.caNodeIndices{nNodeGridPoint}, :);
    % Create the frequency magnitude distribution
    [vFMD, vNonCFMD] = calc_FMD(mNodeCatalog_);
    [nY,nX]=size(mNodeCatalog_);
    if nY > vResults.nMinimumNumber
       [fMc, fStd_Mc, fBvalue, fStd_B, fAvalue, fStd_A, vMc, mBvalue] = calc_McBboot(mNodeCatalog_,vResults.fBinning, vResults.fBstnum, nMethod);
       mResult = [mResult; nNodeGridPoint fMc fStd_Mc fBvalue fStd_B fAvalue fStd_A];
    else
       mResult = [mResult; nNodeGridPoint NaN NaN NaN NaN NaN NaN];
    end
    if rem(nNodeGridPoint,500) == 0
        save(['result' num2str(nNodeGridPoint) '.mat'],'mResult');
    end
end
save(['result' num2str(nNodeGridPoint) '.mat'],'mResult');
