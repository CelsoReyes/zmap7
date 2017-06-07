function [vInterpolated] = gui_Interpolate(fStart, fEnd, nSteps)

fDiff_ = fEnd - fStart;
fDiffStep_ = fDiff_./nSteps;


for nCnt_ = 0:nSteps
  vInterpolated(nCnt_ + 1,1) = fStart(1) + (nCnt_' .* fDiffStep_(1));
  vInterpolated(nCnt_ + 1,2) = fStart(2) + (nCnt_' .* fDiffStep_(2));
  vInterpolated(nCnt_ + 1,3) = fStart(3) + (nCnt_' .* fDiffStep_(3));
end
