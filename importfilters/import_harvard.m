function [uOutput] = import_harvard(nFunction, sFilename)
% function [uOutput] = harvardcmt_imp(nFunction, sFilename);
% ----------------------------------------------------------
% Imports Harvard CMT data of a selfmade ASCII-file.
% Use 'getharvardcatalog' in the importfilters/harvard directory.
% See import_harvard_doc.html for more information.
%
% D. Schorlemmer; schorlemmer@sed.ethz.ch
%
% 17.05.2005

% Filter function switchyard
if nFunction == FilterOp.getDescription
  uOutput = 'Harvard CMT catalog';
elseif nFunction == FilterOp.getWebpage
  uOutput = 'import_harvard_doc.html';
elseif nFunction == FilterOp.importCatalog
  % Read formated data
  mData = textread(sFilename, '%s', 'delimiter', '\n', 'whitespace', '');
  % Create empty catalog
  uOutput = zeros(length(mData), 10);
  % Loop thru all lines of catalog and convert them
  for i = 1:length(mData)
    if rem(i,100) == 0 ; disp([ num2str(i) ' of ' num2str(length(mData)) ' events processed']); end
    try
      uOutput(i,1) = str2num(mData{i}(28:34));      % Longitude (PDE)
      uOutput(i,2) = str2num(mData{i}(21:25));      % Latitude  (PDE)
      uOutput(i,3) = str2num(mData{i}(1:2));        % Year
      if uOutput(i,3) < 76
        uOutput(i,3) = uOutput(i,3)+2000;
      else
        uOutput(i,3) = uOutput(i,3)+1900;
      end
      uOutput(i,4) = str2num(mData{i}(4:5));        % Month
      uOutput(i,5) = str2num(mData{i}(7:8));        % Day
      uOutput(i,6) = str2num(mData{i}(82:85));      % Magnitude Mw
      uOutput(i,7) = str2num(mData{i}(36:40));      % Depth (PDE)
      uOutput(i,8) = str2num(mData{i}(10:11));      % Hour
      uOutput(i,9) = str2num(mData{i}(13:14));      % Minute
      uOutput(i,10) = str2num(mData{i}(16:19));     % Second
      uOutput(i,11) = nan;                          % Reserved for cross-section values

      uOutput(i,12) = str2num(mData{i}(87:89));     % Strike (Plane 1)
      uOutput(i,13) = uOutput(i,12) + 90;           % Dip direction (Plane 1)
      uOutput(i,13) = mod(uOutput(i,13) + 360, 360);
      uOutput(i,14) = str2num(mData{i}(91:92));     % Dip (Plane 1)
      uOutput(i,15) = str2num(mData{i}(94:97));     % Rake (Plane 1)

      uOutput(i,16) = str2num(mData{i}(99:101));    % Strike (Plane 2)
      uOutput(i,17) = uOutput(i,16) + 90;           % Dip direction (Plane 2)
      uOutput(i,17) = mod(uOutput(i,17) + 360, 360);
      uOutput(i,18) = str2num(mData{i}(103:104));   % Dip (Plane 2)
      uOutput(i,19) = str2num(mData{i}(106:109));   % Rake (Plane 2)

      uOutput(i,20) = str2num(mData{i}(42:44));     % Magnitude mb
      uOutput(i,21) = str2num(mData{i}(46:48));     % Magnitude Ms
      uOutput(i,22) = str2num(mData{i}(50:55));     % Latitude (HAV)
      uOutput(i,23) = str2num(mData{i}(57:63));     % Longitude (HAV)
      uOutput(i,24) = str2num(mData{i}(65:69));     % Depth (HAV)
      uOutput(i,25) = str2num(mData{i}(72:75));     % Cen_time
      uOutput(i,26) = str2num(mData{i}(77:80));     % Half Duration
      % Create decimal year
      uOutput(i,3) = decyear([uOutput(i,3) uOutput(i,4) uOutput(i,5) uOutput(i,8) uOutput(i,9) uOutput(i,16)]);
    catch
      disp(['Import: Problem in line ' num2str(i) ' of ' sFilename '. Line ignored.']);
    end
  end
end

