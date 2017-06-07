function pf_load
% function pf_load
%   Opens a open dialog to load result data
%   and invokes the display dialog
%
% Danijel Schorlemmer
% August 22, 2002

global bDebug;
if bDebug
  report_this_filefun(mfilename('fullpath'));
end

% Invoke the open dialog
[newfile, newpath] = uigetfile('*.mat','Load calculated data');
% Cancel pressed?
if newfile == 0
  return;
end
% Everything ok?
newfile = [newpath newfile];
if length(newfile) > 1
  % Load the data
  load(newfile, 'vResults');
  % Open dialog
  hResultFig = pf_result(vResults);
end
