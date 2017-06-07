function mColormap = gui_Colormap_HotCut(nSize)

% If size is not specified, set it to 256
if nargin < 1
  nSize = 256;
end
% Compute the larger size of the hot-colormap
nNewSize = floor(nSize * 6/5);
% Create the larger hot-colormap
mColormap = hot(nNewSize);
% Cut the upper part of the hot-colormap
mColormap = mColormap(1:nSize,:);
