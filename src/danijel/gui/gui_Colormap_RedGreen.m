function mColormap = gui_Colormap_Rastafari(nSize)

% If size is not specified, set it to 256
if nargin < 1
  nSize = 256;
end

mColormap = [];

nSteps = floor(nSize / 2);
mColormap = [mColormap; gui_Interpolate([0.024169, 0.287879, 0.012572], [0.206233, 1.000000, 0.148478], nSteps)];

mColormap = [mColormap; [0.75 0.75 0.75]];

nSteps = floor(nSize / 2);
mColormap = [mColormap; gui_Interpolate([1.000000, 0.235294, 0.235294], [0.621212, 0.017977, 0.035956], nSteps)];

