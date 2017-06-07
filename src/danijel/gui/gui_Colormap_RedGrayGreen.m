function mColormap = gui_Colormap_RedGrayGreen(nSize)

% If size is not specified, set it to 256
if nargin < 1
  nSize = 256;
end
nPart = floor(nSize / 2);

mRedPart = [];
mGreenPart = [];

for nCnt = 1:nPart
  mRedPart = [mRedPart; 0.75  (nCnt*(0.75/nPart)) (nCnt*(0.75/nPart))];
  mGreenPart = [mGreenPart; (0.75 - (nCnt*(0.75/nPart))) 0.75 (0.75 - (nCnt*(0.75/nPart)))];
end

mColormap = [mRedPart; mGreenPart];
