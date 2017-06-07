function [fJointProbability, fSigFirst, fSigSecond] = st_probability(fBValueFirst, vBValuesFirst, fBValueSecond, vBValuesSecond)

vBValuesFirst = vBValuesFirst(~isnan(vBValuesFirst),:);
vBValuesSecond = vBValuesSecond(~isnan(vBValuesSecond),:);

vBValuesFirstHi_ = vBValuesFirst(vBValuesFirst >= fBValueFirst);
vBValuesFirstLo_ = vBValuesFirst(vBValuesFirst <= fBValueFirst);
if fBValueSecond < fBValueFirst
  fSigFirst = calc_GetPercentile(fBValueSecond, vBValuesFirstLo_, 1)/100;
elseif fBValueSecond > fBValueFirst
  fSigFirst = calc_GetPercentile(fBValueSecond, vBValuesFirstHi_, 0)/100;
else
  fSigFirst = 1;
end

vBValuesSecondHi_ = vBValuesSecond(vBValuesSecond >= fBValueSecond);
vBValuesSecondLo_ = vBValuesSecond(vBValuesSecond <= fBValueSecond);
if fBValueFirst < fBValueSecond
  fSigSecond = calc_GetPercentile(fBValueFirst, vBValuesSecondLo_, 1)/100;
elseif fBValueFirst > fBValueSecond
  fSigSecond = calc_GetPercentile(fBValueFirst, vBValuesSecondHi_, 0)/100;
else
  fSigSecond = 1;
end

fJointProbability = fSigFirst * fSigSecond;
