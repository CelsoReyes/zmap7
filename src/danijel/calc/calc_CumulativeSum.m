function [vCumulativeSum] = calc_CumulativeSum(mCatalog)





[vDummy, vIndices] = sort(mCatalog(:,3));
mSortedCatalog = mCatalog(vIndices(:,1),:) ;

par1 = 28;
fMinTime = min(mSortedCatalog(:,3));
fMaxTime = max(mSortedCatalog(:,3));
tdiff = (fMaxTime - fMinTime)*365;

%cumu = 0:1:(tdiff*365/par1)+2;
%cumu2 = 0:1:(tdiff*365/par1)-1;
%cumu = cumu * 0;
%cumu2 = cumu2 * 0;
%n = length(mCata(:,1));
vHist = histogram(mSortedCatalog(:,3), (fMinTime:par1/365:fMaxTime));
vCumulativeSum = cumsum(vHist);
