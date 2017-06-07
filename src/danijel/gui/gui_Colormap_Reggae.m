function mColormap = gui_Colormap_Rastafari(nSize)

% If size is not specified, set it to 256
if nargin < 1
  nSize = 256;
end

mColormap = [];

nSteps = floor(nSize / 2);
mColormap = [mColormap; gui_Interpolate([0.696970, 0.020417, 0.030501], [1.000000, 1.000000, 0.250000], nSteps)];

nSteps = floor(nSize / 2);
mColormap = [mColormap; gui_Interpolate([1.000000, 1.000000, 0.250000], [0.030000, 0.568182, 0.000000], nSteps)];

mColormap(mColormap < 0) = 0;

