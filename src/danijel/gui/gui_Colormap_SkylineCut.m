function mColormap = gui_Colormap_Skyline(nSize)

% If size is not specified, set it to 256
if nargin < 1
  nSize = 256;
end

mColormap = [];

nSteps = floor(nSize * 0.342);
mColormap = [mColormap; gui_Interpolate([0.054902, 0.033334, 0.384313], [0.109804, 0.066667, 0.568627], nSteps)];

nSteps = floor(nSize * 0.258);
mColormap = [mColormap; gui_Interpolate([0.109804, 0.066667, 0.568627], [0.513725, 0.054902, 0.305882], nSteps)];

nSteps = floor(nSize * 0.160);
mColormap = [mColormap; gui_Interpolate([0.513725, 0.054902, 0.305882], [0.917647, 0.043137, 0.043137], nSteps)];

nSteps = floor(nSize * 0.044);
mColormap = [mColormap; gui_Interpolate([0.917647, 0.043137, 0.043137], [0.958824, 0.288235, 0.021569], nSteps)];

nSteps = floor(nSize * 0.082);
mColormap = [mColormap; gui_Interpolate([0.958824, 0.288235, 0.021569], [1.000000, 0.533333, 0.000000], nSteps)];

nSteps = floor(nSize * 0.034);
mColormap = [mColormap; gui_Interpolate([1.000000, 0.533333, 0.000000], [0.968627, 0.729411, 0.107843], nSteps)];

nSteps = floor(nSize * 0.025);
mColormap = [mColormap; gui_Interpolate([0.968627, 0.729411, 0.107843], [0.937255, 0.925490, 0.215686], nSteps)];
