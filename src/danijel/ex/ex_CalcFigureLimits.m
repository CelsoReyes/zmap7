function [fMinLimit, fMaxLimit, nTickStep] = ex_CalcFigureLimits(fMin, fMax)

fDiff = fMax - fMin;
nDigits = ceil(log10(fDiff));
nTickStep = 10^(nDigits-1);

bMinPositive = (fMin >= 0);
if ~bMinPositive
  fMin = (-1) * fMin;
end
bMaxPositive = (fMax >= 0);
if ~bMaxPositive
  fMax = (-1) * fMax;
end

if (fMin == 0)
  fMinLimit = 0;
else
  if bMinPositive
    fMinLimit = (fMin - 10^(nDigits-1));
    fMinLimit = ceil(fMinLimit * 10^(-nDigits+1))/10^(-nDigits+1);
  else
    fMinLimit = (fMin + 10^(nDigits-1));
    fMinLimit = floor(fMinLimit * 10^(-nDigits+1))/10^(-nDigits+1);
  end
  if ~bMinPositive
    fMinLimit = (-1) * fMinLimit;
  end
end
if (fMax == 0)
  fMaxLimit = 0;
else
  fMaxLimit = (fMax + 10^(nDigits-1));
  fMaxLimit = floor(fMaxLimit * 10^(-nDigits+1))/10^(-nDigits+1);
  if ~bMaxPositive
    fMaxLimit = (-1) * fMaxLimit;
  end
end

