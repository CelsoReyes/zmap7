function kj_load
% function kj_load
%   Opens a open dialog to load a Kagan & Jackson test result
%   and invokes the display dialog
%
% Danijel Schorlemmer
% October 30, 2001

global bDebug;
if bDebug
  report_this_filefun(mfilename('fullpath'));
end

% Invoke the open dialog
[newfile, newpath] = uigetfile('*.mat','Load calculated Kagan & Jackson Test data');
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
  hResultFig = kj_result(vResults);
end
