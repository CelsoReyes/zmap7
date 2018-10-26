function [uOutput] = import_KJRelm(nFunction, sFilename)

% Filter function switchyard
if nFunction == FilterOp.getDescription
  uOutput = 'RELM - Kagan & Jackson PDE-based catalog';
elseif nFunction == FilterOp.importCatalog
  % Read formated data
  mData = textread(sFilename, '%s', 'delimiter', '\n', 'whitespace', '');
  % Create empty catalog
  uOutput = zeros(length(mData), 9);
  % Loop thru all lines of catalog and convert them
  for i = 1:length(mData)
    if rem(i,100) == 0 ; disp([ num2str(i) ' of ' num2str(length(mData)) ' events processed ']); end
    try
      uOutput(i,1) = str2num(mData{i}(33:40));  % Longitude
      uOutput(i,2) = str2num(mData{i}(25:31));  % Latitude
      uOutput(i,3) = str2num(mData{i}(7:10));   % Year
      uOutput(i,4) = str2num(mData{i}(12:13));  % Month
      uOutput(i,5) = str2num(mData{i}(15:16));  % Day
      uOutput(i,6) = str2num(mData{i}(59:62));  % Magnitude
      uOutput(i,7) = str2num(mData{i}(53:57));  % Depth
      uOutput(i,8) = str2num(mData{i}(19:20));  % Hour
      uOutput(i,9) = str2num(mData{i}(22:23));  % Minute
      %Create decimal year
      uOutput(i,3) = decyear([uOutput(i,3) uOutput(i,4) uOutput(i,5) uOutput(i,8) uOutput(i,9)]);
    catch
      msg.dbfprintf('Import: Problem in line %d of %s. Line ignored.\n',i, sFilename);
      uOutput(i,:)=nan;
    end
  end
  l = isnan(uOutput(:,1));
  uOutput(l,:) = [];
end

