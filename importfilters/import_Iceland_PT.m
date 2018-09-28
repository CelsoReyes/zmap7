function [uOutput] = import_Iceland_PT(nFunction, sFilename)

% Filter function switchyard
%%%%     CHANGE THESE LINES %%%%%%%%%%%
if nFunction == FilterOp.getDescription
    uOutput = 'Iceland (with P/T-axes)';
elseif nFunction == FilterOp.getWebpage
  uOutput = 'import_Iceland_PT_doc.html';
 %%%%    DO NOT CHANGE %%%%%%%%%%%

elseif nFunction == FilterOp.importCatalog
    % Read formated data
    mData = textread(sFilename, '%s', 'delimiter', '\n', 'whitespace', '');
    % Create empty catalog
    uOutput = zeros(length(mData), 12);
    % Loop through all lines of catalog and convert them
    mData = char(mData);
    l = find( mData == ' ' );
    mData(l) = '0';
    errc = 1;

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
                msg.dbfprintf('Import: Problem in line %d of %s. Line ignored.\n',i, sFilename);
                uOutput(i,:)=nan;
            end
        end

    l = isnan(uOutput(:,1));
    uOutput(l,:) = [];
end

%%%%%%%%%%%%%%%%%%%%%%
%%%%     CHANGE THESE LINES %%%%%%%%%%%

function [uOutput] = readvalues(mData,i,k)

uOutput(k,1) =-str2num(mData(i,29:30)) - (str2num(mData(i,31:35))/60); % Longitude
uOutput(k,2) = str2num(mData(i,20:21)) + (str2num(mData(i,22:26))/60); % Latitude
uOutput(k,3) = str2num(mData(i,2:3)) + 1900; % Year
uOutput(k,4) = str2num(mData(i,4:5));        % Month
uOutput(k,5) = str2num(mData(i,6:7));        % Day
uOutput(k,6) = str2num(mData(i,64:66));      % Magnitude
uOutput(k,7) = str2num(mData(i,37:41));      % Depth
uOutput(k,8) = str2num(mData(i,9:10));       % Hour
uOutput(k,9) = str2num(mData(i,11:12));      % Minute

fPTrend = str2double(mData(i,68:70));
fPDip = str2double(mData(i,72:73));
fTTrend = str2double(mData(i,75:77));
fTDip = str2double(mData(i,79:80));

% DipDirection, Dip, Rake
[uOutput(k,10), uOutput(k,11), uOutput(k,12)] = ex_pt2fm(fPTrend, fPDip, fTTrend, fTDip);

% Convert to decimal years
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
