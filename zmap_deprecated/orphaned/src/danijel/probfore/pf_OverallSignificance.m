function [fSignificanceLevel] = pf_OverallSignificance(nNumberNodesTotal, nNumberNodesHit, fHitProbability)

fIncSumProb = [];
fSumProb = 0;
for nCnt_= 0:nNumberNodesTotal
  nNumberCombinations = nchoosek(nNumberNodesTotal, nCnt_);
  fProbCombination = ((1 - fHitProbability)^(nNumberNodesTotal - nCnt_) * fHitProbability^nCnt_) * nNumberCombinations;
  fSumProb = fSumProb + fProbCombination;
  fIncSumProb = [fIncSumProb; fSumProb];
end
fSignificanceLevel = 1 - (fIncSumProb(nNumberNodesHit + 1));
