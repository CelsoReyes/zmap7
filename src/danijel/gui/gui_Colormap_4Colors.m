function mColormap = gui_Colormap_4Colors(nSize)

% If size is not specified, set it to 256
if nargin < 1
  nSize = 256;
end

nPart = floor(nSize / 8);

mFirstPart = winter(nPart * 3);
mFourthPart = flipud(autumn(nPart * 3));

mSecondPart = [];
mThirdPart = [];

for nCnt = 1:nPart
  mSecondPart = [mSecondPart; (nCnt*(0.75/nPart)) (1 - (nCnt*(0.25/nPart))) (0.5 + (nCnt*(0.25/nPart)))];
  mThirdPart = [mThirdPart; (0.75 + (nCnt*(0.25/nPart))) (0.75 + (nCnt*(0.25/nPart))) (0.75 - (nCnt*(0.75/nPart)))];
end

mColormap = [mFirstPart; mSecondPart; mThirdPart; mFourthPart];

