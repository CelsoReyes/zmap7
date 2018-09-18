function [uOutput] = import_Iceland_2(nFunction, sFilename)

% Filter function switchyard
if nFunction == FilterOp.getDescription
  uOutput = 'Iceland Mw (Bergthora Iceland)';
elseif nFunction == FilterOp.getWebpage
  uOutput = '';
elseif nFunction == FilterOp.importCatalog
  % Read formated data
  mData = textread(sFilename, '%s', 'delimiter', '\n', 'whitespace', '');
  % Create empty catalog
  uOutput = [];
%   % Loop through all lines of catalog and convert them
  mData = char(mData);
%   l = find( mData == ' ' );
%   mData(l) = '0';
  nError = 1;

  for nCnt = 1:length(mData(:,1))
    if rem(nCnt, 100) == 0
      disp([num2str(nCnt) ' of ' num2str(length(mData)) ' events processed']);
    end
    try
      uEvent = readvalues(mData, nCnt);
      uOutput = [uOutput; uEvent];
    catch
      nError = nError + 1;
      if nError == 100
        if stoploop
          return
        end
      end
      disp(['Import: Problem in line ' num2str(nCnt) ' of ' sFilename '. Line ignored.']);
      %uOutput(nCnt,:) = nan;
    end
  end
end
l = isnan(uOutput(:,1));
uOutput(l,:) = [];

% -----------------------------------------
function [uEvent] = readvalues(mData,i)

uEvent(1) = str2double(mData(i,30:38));  % Longitude
uEvent(2) = str2double(mData(i,21:28));  % Latitude
uEvent(3) = str2num(mData(i,1:4));    % Year
uEvent(4) = str2num(mData(i,5:6));    % Month
uEvent(5) = str2num(mData(i,7:8));   % Day
uEvent(6) = str2num(mData(i,47:51));  % Magnitude
uEvent(7) = str2num(mData(i,40:45));  % Depth
uEvent(8) = str2num(mData(i,10:11));  % Hour
uEvent(9) = str2num(mData(i,12:13));  % Minute
% convert to decimal years
uEvent(3) = decyear([uEvent(3) uEvent(4) uEvent(5) uEvent(8) uEvent(9)]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    DO NOT CHANGE %%%%%%%%%%%

function [mystop] = stoploop()

ButtonName=questdlg('More than 100 lines could not be read. Continue?', ...
    'Interrupt?', ...
    'Yes','No','Nope');

switch ButtonName
case 'Yes'
    disp('going on');
    mystop = 0;
case 'No'
    mystop = 1;
end % switch
