function mColormap = gui_Colormap_Rastafari(nSize)

% If size is not specified, set it to 256
if nargin < 1
  nSize = 256;
end

mColormap = [];

nSteps = floor(nSize * 0.1);
mColormap = [mColormap; gui_Interpolate([0.036578, 0.159091, 0.015374], [0.022239, 0.234849, 0.007687], nSteps)];

nSteps = floor(nSize * 0.05);
mColormap = [mColormap; gui_Interpolate([0.022239, 0.234849, 0.007687], [0.007899, 0.310606, 0.000000], nSteps)];

nSteps = floor(nSize * 0.09);
mColormap = [mColormap; gui_Interpolate([0.007899, 0.310606, 0.000000], [0.101896, 0.443182, 0.042827], nSteps)];

nSteps = floor(nSize * 0.09);
mColormap = [mColormap; gui_Interpolate([0.101896, 0.443182, 0.042827], [0.195893, 0.575758, 0.085655], nSteps)];

nSteps = floor(nSize * 0.09);
mColormap = [mColormap; gui_Interpolate([0.195893, 0.575758, 0.085655], [0.560068, 0.663178, 0.139025], nSteps)];

nSteps = floor(nSize * 0.08);
mColormap = [mColormap; gui_Interpolate([0.560068, 0.663178, 0.139025], [0.924242, 0.750598, 0.192395], nSteps)];

nSteps = floor(nSize * 0.1);
mColormap = [mColormap; gui_Interpolate([0.924242, 0.750598, 0.192395], [0.939393, 0.495226, 0.162308], nSteps)];

nSteps = floor(nSize * 0.1);
mColormap = [mColormap; gui_Interpolate([0.939393, 0.495226, 0.162308], [0.954545, 0.239854, 0.132221], nSteps)];

nSteps = floor(nSize * 0.2);
mColormap = [mColormap; gui_Interpolate([0.954545, 0.239854, 0.132221], [0.742424, 0.279602, 0.184117], nSteps)];

nSteps = floor(nSize * 0.1);
mColormap = [mColormap; gui_Interpolate([0.742424, 0.279602, 0.184117], [0.530303, 0.319349, 0.236012], nSteps)];

mColormap(mColormap < 0) = 0;
