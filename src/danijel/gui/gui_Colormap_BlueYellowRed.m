function mColormap = gui_Colormap_BlueYellowRed(nSize)

% If size is not specified, set it to 256
if nargin < 1
  nSize = 256;
end

mColormap = [];

nSteps = floor(nSize * 0.25);
mColormap = [mColormap; gui_Interpolate([0.000000, 0.000000, 1.000000], [0.500000, 0.500000, 0.500000], nSteps)];

nSteps = floor(nSize * 0.25);
mColormap = [mColormap; gui_Interpolate([0.500000, 0.500000, 0.500000], [1.000000, 1.000000, 0.000000], nSteps)];

nSteps = floor(nSize * 0.25);
mColormap = [mColormap; gui_Interpolate([1.000000, 1.000000, 0.000000], [1.000000, 0.500000, 0.000000], nSteps)];

nSteps = floor(nSize * 0.25);
mColormap = [mColormap; gui_Interpolate([1.000000, 0.500000, 0.000000], [1.000000, 0.000000, 0.000000], nSteps)];
