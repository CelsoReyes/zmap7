function [uOutput] = scecdcimp(nFunction, sFilename)

% Filter function switchyard
if nFunction == 0     % Return info about filter
  uOutput = 'NIED (Kanto-Tokai) catalog with focal mechanism';
elseif nFunction == 2 % Return filename of help-file
  uOutput = 'import_NIED_doc.html';
elseif nFunction == 1 % Import and return catalog
  % Read formated data
  mData = textread(sFilename, '%s', 'delimiter', '\n', 'whitespace', '');
  % Create empty catalog
  uOutput = zeros(length(mData), 13);
  % Loop thru all lines of catalog and convert them
  for i = 1:length(mData)
    if rem(i,100) == 0 ; disp([ num2str(i) ' of ' num2str(length(mData)) ' events processed ']); end
    try
      l = find(mData{i} == ' ');
      mData{i}(l) = '0';
      uOutput(i,1) = str2num(mData{i}(37:44));  % Longitude
      uOutput(i,2) =  str2num(mData{i}(29:35)); % Latitude
      uOutput(i,3) = str2num(mData{i}(8:11));   % Year
      uOutput(i,4) = str2num(mData{i}(12:13));  % Month
      uOutput(i,5) = str2num(mData{i}(14:15));  % Day
      uOutput(i,6) = str2num(mData{i}(52:55));  % Magnitude
      uOutput(i,7) = str2num(mData{i}(46:50));  % Depth
      uOutput(i,8) = str2num(mData{i}(17:18));  % Hour
      uOutput(i,9) = str2num(mData{i}(20:21));  % Minute

      uOutput(i,10) = str2num(mData{i}(113:120));  % strike of nodal plane 1
      uOutput(i,11) = str2num(mData{i}(122:129));  % dip of nodal plane
      uOutput(i,12) = str2num(mData{i}(131:138));  % rake of nodal plane 1

      uOutput(i,13) = str2num(mData{i}(107:111));  % quality

      uOutput(i,14) = str2num(mData{i}(140:147));  % strike of nodal plane 2
      uOutput(i,15) = str2num(mData{i}(149:156));  % dip of nodal plane 2
      uOutput(i,16) = str2num(mData{i}(158:165));  % rake of nodal plane 2

      %Create decimal year
      uOutput(i,3) = decyear([uOutput(i,3) uOutput(i,4) uOutput(i,5) uOutput(i,8) uOutput(i,9)]);
    catch
      disp(['Import: Problem in line ' num2str(i) ' of ' sFilename '. Line ignored.']);
      uOutput(i,:) = uOutput(i,:)*nan;
    end
  end
  l = isnan(uOutput(:,1));
  uOutput(l,:) = [];
end
