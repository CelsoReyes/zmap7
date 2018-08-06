function [bOK, sFilePath] = ex_GetFile(vFilterSpec, sDialogTitle, nXPos, nYPos)
% function [bOK, sFilePath] = ex_GetFile(vFilterSpec, sDialogTitle, nXPos, nYPos)
% -------------------------------------------------------------------------------
% Wrapper for the uigetfile function of Matlab. Simplifies the output parameter analysis
%
% Input parameter:
%   vFilterSpec   Filter rules for selection, e. g. '*.mat'
%   sDialogTitle  String to appear in the titlebar
%   nXPos         X-position of dialog
%   nYPos         Y-position of dialog
%
% Output parameters:
%   bOK         Result of user interaction: 1: OK pressed, 0: Cancel pressed
%   sFilePath   Complete filepath of selected file
%
% Danijel Schorlemmer
% December 18, 2001

% Init return values
bOK = false;
sFilePath = '';
% Invoke Matlab's original function
if ~exist('vFilterSpec')
  vFilterSpec = '';
end
if ~exist('sDialogTitle')
  sDialogTitle = '';
end
if (exist('nXPos') & exist('nYPos'))
  [sFile, sPath] = uigetfile(vFilterSpec, sDialogTitle, nXPos, nYPos);
else
  [sFile, sPath] = uigetfile(vFilterSpec, sDialogTitle);
end
% Cancel pressed?
if isequal(sFile, 0)  ||  isequal(sPath, 0)
  return;
end
% Everything ok?
sFilePath = [sPath sFile];
if length(sFilePath) > 1
  % We got everything
  bOK = true;
end
