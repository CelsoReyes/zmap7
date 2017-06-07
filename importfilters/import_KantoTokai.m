function [uOutput] = import_KantoTokai(nFunction, sFilename)
% function [uOutput] = import_KantoTokai(nFunction, sFilename)
% ------------------------------------------------------------
% Imports Kanto-Tokai data of a selfmade ASCII-file.
% Use 'gettokaicatalog' in the importfilters/KantoTokai directory.
% See import_KantoTokai_doc.html for more information.
%
% D. Schorlemmer; danijel@seismo.ifg.ethz.ch
%
% 23.05.2005

% Filter function switchyard
if nFunction == 0     % Return info about filter
  uOutput = 'NIED (Kanto-Tokai) with focal mechanism';
elseif nFunction == 2 % Return filename of help-file
  uOutput = 'import_KantoTokai_doc.html';
elseif nFunction == 1 % Import and return catalog
  % Read formated data
  mData = textread(sFilename, '%s', 'delimiter', '\n', 'whitespace', '');
  % Create empty catalog
  uOutput = zeros(length(mData), 13);
  % Loop thru all lines of catalog and convert them
  for i = 1:length(mData)
    if rem(i,100) == 0 ; disp([ num2str(i) ' of ' num2str(length(mData)) ' events processed']); end
    try
      l = find(mData{i} == ' ');
      mData{i}(l) = '0';
      uOutput(i,1)  = str2num(mData{i}(37:44));      % Longitude
      uOutput(i,2)  = str2num(mData{i}(29:35));      % Latitude
      uOutput(i,3)  = str2num(mData{i}(8:11));       % Year
      uOutput(i,4)  = str2num(mData{i}(12:13));      % Month
      uOutput(i,5)  = str2num(mData{i}(14:15));      % Day
      uOutput(i,6)  = str2num(mData{i}(52:55));      % Magnitude
      uOutput(i,7)  = str2num(mData{i}(46:50));      % Depth
      uOutput(i,8)  = str2num(mData{i}(17:18));      % Hour
      uOutput(i,9)  = str2num(mData{i}(20:21));      % Minute
      uOutput(i,10) = str2num(mData{i}(23:27));      % Second
      uOutput(i,11) = nan;                           % Reserved for cross-section values

      fPAzimuth = str2double(mData{i}(69:76));
      fPTheta   = str2double(mData{i}(78:85));
      fTAzimuth = str2double(mData{i}(89:96));
      fTTheta   = str2double(mData{i}(98:105));

      % [fDipDir, fDip, fRake] = ex_pt2fm(fPAzimuth, fPTheta, fTAzimuth, fTTheta);
      [fStrike1, fDip1, fRake1, fDipdir1, fStrike2, fDip2, fRake2, fDipdir2, ierr] ...
        = focal_pt2pl(fPAzimuth, 90-fPTheta, fTAzimuth, 90-fTTheta);
      uOutput(i,12) = fStrike1;                     % Strike (Plane 1)
      uOutput(i,13) = fDipdir1;                     % Dip direction (Plane 1)
      uOutput(i,14) = fDip1;                        % Dip (Plane 1)
      uOutput(i,15) = fRake1;                       % Rake (Plane 1)

      uOutput(i,16) = fStrike2;                     % Strike (Plane 2)
      uOutput(i,17) = fDipdir2;                     % Dip direction (Plane 2)
      uOutput(i,18) = fDip2;                        % Dip (Plane 2)
      uOutput(i,19) = fRake2;                       % Rake (Plane 2)

      fNumPolarity   = str2double(mData{i}(59:61));
      fWrongPolarity = str2double(mData{i}(63:65));
      uOutput(i,20)  = fWrongPolarity/fNumPolarity; % Misfit

      uOutput(i,21) = str2num(mData{i}(113:120));   % Strike (Plane 1)
      uOutput(i,22) = str2num(mData{i}(122:129));   % Dip (Plane 1)
      uOutput(i,23) = str2num(mData{i}(131:138));   % Rake (Plane 1)
      uOutput(i,24) = str2num(mData{i}(140:147));   % Strike (Plane 2)
      uOutput(i,25) = str2num(mData{i}(149:156));   % Dip (Plane 2)
      uOutput(i,26) = str2num(mData{i}(158:165));   % Rake (Plane 2)

      uOutput(i,27) = str2num(mData{i}(107:111));   % Quality

      % Create decimal year
      uOutput(i,3) = decyear([uOutput(i,3) uOutput(i,4) uOutput(i,5) uOutput(i,8) uOutput(i,9)]);
    catch
      disp(['Import: Problem in line ' num2str(i) ' of ' sFilename '. Line ignored.']);
      uOutput(i,:) = uOutput(i,:)*nan;
    end
  end
  l = isnan(uOutput(:,1));
  uOutput(l,:) = [];
end
