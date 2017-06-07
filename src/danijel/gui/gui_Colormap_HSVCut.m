function mColormap = gui_Colormap_HSVCut(nSize)

% If size is not specified, set it to 256
if nargin < 1
  nSize = 256;
end

nTmpSize = floor(nSize/0.85);
mColormap = hsv(nTmpSize);
mColormap = mColormap(1:nSize,:);

