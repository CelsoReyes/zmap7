function [vResultColorMap] = ex_dcolor(vColorMap, nBorder, vMidColor)
% function [vResultColorMap] = ex_dcolor(vColorMap, nBorder, vMidColor);
% Creates a new colormap using vColorMap as a base colormap and replacing
%   all elements > nBorder and < 64 - nBorder with vMidColor. If vMidColor is
%   not passed, it will be set to [0.7 0.7 0.7].

% Copy the original colormap
vResultColorMap = vColorMap;
% Check, if vMidColor is passed, otherwise set to default value
if ~exist('vMidColor')
  vMidColor = [0.7 0.7 0.7];
end
% Get the size of the colormap
[nSize, vDummy] = size(vColorMap);
% Create the necessary matrix of vMidColor-elements to fit into the colormap
mMidColor = repmat(vMidColor, nSize-(2*nBorder), 1);
% Replace the elements in the colormap
vResultColorMap((1+nBorder):(nSize-nBorder), :) = mMidColor;
