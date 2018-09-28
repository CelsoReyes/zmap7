function [uOutput] = ncedc_fomech_imp(nFunction, sFilename)

% Set some constants
MODE_EVENT = 0;
MODE_PICKS = 1;

% Filter function switchyard
if nFunction == FilterOp.getDescription
  uOutput = 'SIMULPS';
elseif nFunction == FilterOp.importCatalog
  % Read formatted data
  mData = textread(sFilename, '%s', 'delimiter', '\n', 'whitespace', '');
  % Create empty catalog
  uOutput = [];
  % Initial read mode (SIMULPS start with an event line)
  nMode = MODE_EVENT;
  % Loop thru all lines of catalog and convert them
  for i = 1:length(mData)
    if rem(i,100) == 0
      % Notify the user every 100 processed events
      disp([num2str(i) ' of ' num2str(length(mData)) ' lines processed.']);
    end
    % Mode switchyard
    if nMode == MODE_EVENT
      try
        % Create vector for one event
        vOutput = zeros(1,9);
        % Replace whitespace in first column with '0'
        l = find(mData{i} == ' ');
        mData{i}(l) = '0';
        % Read values into vector
        vOutput(1) = str2num(mData{i}(28:30));      % Longitude
        if mData{i}(31) == 'W'
          vOutput(1) = vOutput(1) * -1;
        end
        fTmp = str2double(mData{i}(32:36));
        vOutput(1) = vOutput(1) + (fTmp/60);
        vOutput(2) = str2num(mData{i}(18:20));      % Latitude
        if mData{i}(31) == 'S'
          vOutput(2) = vOutput(2) * -1;
        end
        fTmp = str2double(mData{i}(22:26));
        vOutput(2) = vOutput(2) + (fTmp/60);

        vOutput(3) = str2num(mData{i}(1:2)) + 1900; % Year
        if vOutput(3) < 1930
          vOutput(3) = vOutput(3) + 100;
        end
        vOutput(4) = str2num(mData{i}(3:4));        % Month
        vOutput(5) = str2num(mData{i}(5:6));        % Day
        vOutput(6) = str2num(mData{i}(46:50));      % Magnitude
        vOutput(7) = str2num(mData{i}(37:43));      % Depth
        vOutput(8) = str2num(mData{i}(8:9));        % Hour
        vOutput(9) = str2num(mData{i}(10:11));      % Minute
        % Compute decimal year
        vOutput(3) = decyear([vOutput(3) vOutput(4) vOutput(5) vOutput(8) vOutput(9)]);
      catch
        msg.dbfprintf('Import: Problem in line %d of %s. Line ignored.\n',i, sFilename);
        vOutput(:) = nan;
      end
      % Add vector to catalog
      uOutput = [uOutput; vOutput];
      % Change mode (pick lines are following)
      nMode = MODE_PICKS;
    elseif nMode == MODE_PICKS
      % If skip line ('0') return to event reading mode
      if (length(mData{i}) == 1) & (mData{i} == '0')
        nMode = MODE_EVENT;
      end
    end
  end
  % Delete all invalidated events from catalog
  vSel = isnan(uOutput(:,1));
  uOutput(vSel,:) = [];
end

