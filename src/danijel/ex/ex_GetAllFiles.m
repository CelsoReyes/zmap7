function [stFiles] = ex_GetAllFiles(sBaseDir)
% function [stFiles] = ex_GetAllFiles(sBaseDir)
% ---------------------------------------------
% Collects all filenames form a given directory and its subdirectories
%
% Input parameter:
%   sBaseDir    Base directory for filesearch. Function looks into this directory and its subdirectories
%
% Output parameter:
%   stFiles     Vector of structure containing filenames. Filenames are stored in .name element
%
% Danijel Schorlemmer
% October 7, 2002

% Init return values
stFiles = [];

% Get the list of the base directory
files = dir(sBaseDir);

% Iterate through this list store the filenames
for nCnt = 1:(length(files))
  % If element is a directory, analyze it
  if files(nCnt).isdir == 1
    % If it doesn't point upwards, recurse into the subdirectory
    if ~strcmp(files(nCnt).name, '.')  &&  ~strcmp(files(nCnt).name, '..')
      sDir = fullfile(fileparts(sBaseDir), files(nCnt).name);
      stFiles = [stFiles; GetAllFiles(sDir)];
    end
  else
    stFiles = [stFiles; struct('name', fullfile(fileparts(sBaseDir), files(nCnt).name))];
  end
end
