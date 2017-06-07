function mColormap = gui_Colormap_RedGrayBlueEx(nSize)

% If size is not specified, set it to 256
if nargin < 1
  nSize = 256;
end

mColormap = [];

nSteps = floor(nSize / 4);
mColormap = [mColormap; gui_Interpolate([0.50, 0.00, 0.00], [1.00, 0.00, 0.00], nSteps)];

nSteps = floor(nSize / 4);
mColormap = [mColormap; gui_Interpolate([1.00, 0.00, 0.00], [0.75, 0.75, 0.75], nSteps)];

nSteps = floor(nSize / 4);
mColormap = [mColormap; gui_Interpolate([0.75, 0.75, 0.75], [0.00, 0.00, 1.00], nSteps)];

nSteps = floor(nSize / 4);
mColormap = [mColormap; gui_Interpolate([0.00, 0.00, 1.00], [0.00, 0.00, 0.50], nSteps)];

mColormap(mColormap < 0) = 0;
