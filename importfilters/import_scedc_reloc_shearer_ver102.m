function [uOutput,Error_lines] = import_scedc_reloc_shearer_ver102(nFunction, sFilename)
% function [uOutput] = import_scedc_reloc_sheaererver10(nFunction, sFilename);
% ----------------------------------------------------------------
% Import relocated data set for Southern California (P. Shearer)
% Get data http://www.data.scec.org/ftp/catalogs/SHLK/
% Version 1.02
%
% last update: 04.02.2006, J. Woessner
% jowoe@gps.caltech.edu

% Filter function switchyard
%%%%     CHANGE THESE LINES %%%%%%%%%%%
if nFunction == 0     % Return info about filter
    uOutput = 'SCEDC - Shearer relocated Ver 1.02';
elseif nFunction == 2 % Return filename of helpfile (HTML)
  uOutput = 'http://www.data.scec.org/ftp/catalogs/SHLK/';
 %%%%    DO NOT CHANGE %%%%%%%%%%%
elseif nFunction == 1 % Import and return catalog
    % Read formated data
    mData = textread(sFilename, '%s', 'delimiter', '\n', 'whitespace', '');
    % Create empty catalog
    uOutput = zeros(length(mData),18);
    Error_lines = [];
    % Loop through all lines of catalog and convert them
    mData = char(mData);
    l = find( mData == ' ' );
    mData(l) = '0';
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
                uOutput(i,:)=nan;
                Error_lines = [Error_lines; i];
            end
        end

    end
    l = isnan(uOutput(:,1));
    uOutput(l,:) = [];
end

%%%%%%%%%%%%%%%%%%%%%%
%%%%     CHANGE THESE LINES %%%%%%%%%%%

function [uOutput] = readvalues(mData,i,k)

uOutput(k,1) =-str2num(mData(i,45:53));  % Longitude [deg]
uOutput(k,2) = str2num(mData(i,35:42));  % Latitude [deg]
uOutput(k,3) = str2num(mData(i,1:4));    % Year
uOutput(k,4) = str2num(mData(i,6:7));    % Month
uOutput(k,5) = str2num(mData(i,9:10));   % Day
uOutput(k,6) = str2num(mData(i,62:65));  % Magnitude
uOutput(k,7) = str2num(mData(i,55:60));  % Depth [km]
uOutput(k,8) = str2num(mData(i,12:13));  % Hour
uOutput(k,9) = str2num(mData(i,15:16));  % Minute
uOutput(k,10) = str2num(mData(i,18:23));  % Second
uOutput(k,11) = nan;  % Reserved for cross section values
uOutput(k,12) = nan;  % strike
uOutput(k,13) = nan;  % dip direction
uOutput(k,14) = nan;  % rake
uOutput(k,15) = nan;  % dip
uOutput(k,16) = str2num(mData(i,112:117)); % Horizontal error [km]
uOutput(k,17) = str2num(mData(i,119:125)); % Vertical error [km]
uOutput(k,18) = str2num(mData(i,95:98)); % Cluster number
uOutput(k,19) = str2num(mData(i,101:104)); % Number of events in cluster
uOutput(k,20) = str2num(mData(i,107:109)); % Number of links to other events used to locating this event
uOutput(k,21) = str2num(mData(i,90)); % Local (Californian) day (0) / night (1) flag
uOutput(k,22) = str2num(mData(i,92)); % location method flag (=0 for SSST, =1 for waveform cross-correlation)
uOutput(k,23) = str2num(mData(i,25:33)); % SCSN cuspid (up to 9 digits)
uOutput(k,24) = mData(i,127); % SCSN flag for event type (l=local, r=regional, q=quarry)

% convert to decimal years
uOutput(k,3) = decyear([uOutput(k,3) uOutput(k,4) uOutput(k,5) uOutput(k,8) uOutput(k,9) uOutput(k,10)]);


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
