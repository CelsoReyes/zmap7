function [uOutput] = ncedc_imp(nFunction, sFilename)

% Filter function switchyard
%%%%     CHANGE THESE LINES %%%%%%%%%%%
if nFunction == 0     % Return info about filter
  uOutput = 'SCEC_DC Data Center format';
elseif nFunction == 2 % Return filename of helpfile (HTML)
  uOutput = 'SCEC_DC.htm'; %%%%    DO NOT CHANGE %%%%%%%%%%%
elseif nFunction == 1 % Import and return catalog
    % Read formated data
    mData = textread(sFilename, '%s', 'delimiter', '\n', 'whitespace', '');
    % Create empty catalog
    uOutput = zeros(length(mData), 10);
    % Loop through all lines of catalog and convert them
    mData = char(mData);
    mData(mData == ' ') = '0';
    mData(mData == 'L') = '1';
    mData(mData == 'R') = '2';
    mData(mData == 'T') = '3';
    mData(mData == 'Q') = '4';
    mData(mData == 'D') = '5';
    errc = 1;

    try % this is the fast method ....
        i = 1:length(mData(:,1));
        [uOutput] = readvalues(mData,i,i);

    catch  % this is the line by line method ..
        for i = 1:length(mData(:,1))
            if rem(i,100) == 0 ; disp([ num2str(i) ' of ' num2str(length(mData)) ' events processed ']); end
            try
                uOutput(i,:) = readvalues(mData,i,1);
            catch
                errc = errc + 1;
                if errc == 100
                    if stoploop
                        return
                    end
                end
                disp(['Import: Problem in line ' num2str(i) ' of ' sFilename '. Line ignored.']);
                uOutput(i,:) = uOutput(i,:)*nan;
            end
        end

    end
    l = isnan(uOutput(:,1));
    uOutput(l,:) = [];
    l = uOutput(:,10) ==1  | uOutput(:,10) == 5 ;
    uOutput = uOutput(l,1:9);

end

%%%%%%%%%%%%%%%%%%%%%%
%%%%     CHANGE THESE LINES %%%%%%%%%%%

function [uOutput] = readvalues(mData,i,k)

      uOutput(k,1) = str2num(mData(i,39:46));  % Longitude
      uOutput(k,2) = str2num(mData(i,32:38));  % Latitude
      uOutput(k,3) = str2num(mData(i,1:4));    % Year
      uOutput(k,4) = str2num(mData(i,6:7));    % Month
      uOutput(k,5) = str2num(mData(i,9:10));   % Day
      uOutput(k,6) = str2num(mData(i,25:27));  % Magnitude
      uOutput(k,7) = str2num(mData(i,48:52));  % Depth
      uOutput(k,8) = str2num(mData(i,12:13));  % Hour
      uOutput(k,9) = str2num(mData(i,15:16));  % Minute
      uOutput(k,10) = str2num(mData(i,23));  % Type

% convert to decimal years
uOutput(k,3) = decyear([uOutput(k,3) uOutput(k,4) uOutput(k,5) uOutput(k,8) uOutput(k,9)]);


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
