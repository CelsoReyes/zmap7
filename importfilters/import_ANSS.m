function [uOutput] = import_ANSS(nFunction, sFilename)
% function [uOutput] = import_ANSS(nFunction, sFilename)
% ------------------------------------------------------
% Importfilter for ANSS readable format catalog
% (http://quake.geo.berkeley.edu/anss/catalog-search.html)
%
% updated: 18.08.2005, D. Schorlemmer

if nFunction == 0
  uOutput = 'ANSS readable format';
elseif nFunction == 1
  % Read the full catalog
  mData = textread(sFilename, '%s', 'delimiter', '\n', 'whitespace', '');

  % Create empty output catalog
  uOutput = zeros(size(mData, 1), 10);

  % Import
  for i = 1:length(mData)
    if rem(i,100) == 0
      disp([num2str(i) ' of ' num2str(length(mData)) ' events processed']);
    end
    try
      uOutput(i,1) = str2num(mData{i}(33:41));   % Longitude
      uOutput(i,2) = str2num(mData{i}(24:31));   % Latitude
      uOutput(i,3) = str2num(mData{i}(1:4));     % Year
      uOutput(i,4) = str2num(mData{i}(6:7));     % Month
      uOutput(i,5) = str2num(mData{i}(9:10));    % Day
      uOutput(i,6) = str2num(mData{i}(51:54));   % Magnitude
      str = '      ';
      if  strcmp(mData{i}(43:48),str)== 1
        uOutput(i,7) = 0;
      else
        uOutput(i,7) = str2num(mData{i}(43:48)); % Depth
      end
      uOutput(i,8) = str2num(mData{i}(12:13));   % Hour
      uOutput(i,9) = str2num(mData{i}(15:16));   % Minute
      uOutput(i,10) = str2num(mData{i}(18:22));  % Second
      % Compute decimal year
      uOutput(i,3) = decyear([uOutput(i,3) uOutput(i,4) uOutput(i,5) uOutput(i,8) uOutput(i,9) uOutput(i,10)]);
    catch
      disp(['Import: Problem in line ' num2str(i) ' of ' sFilename '. Line ignored.']);
      uOutput(i,:)=nan;
    end
  end
  % Delete empty rows
  l = isnan(uOutput(:,1));
  uOutput(l,:) = [];
end
