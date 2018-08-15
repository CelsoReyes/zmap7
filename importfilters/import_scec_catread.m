function [uOutput] = import_scec_catread(nFunction, sFilename)
% [uOutput] = import_scec_catread(nFunction, sFilename);
% ---------------------------------------------------------------
% Import data from SCEDC in CATREAD format, importing also uncertainties
% according to the rules published
%
% 29.10.2004, jochen.woessner@sed.ethz.ch

% Filter function switchyard
%%%%     CHANGE THESE LINES %%%%%%%%%%%
if nFunction == FilterOp.getDescription
  uOutput = 'SCEC (Caltech) Data Center format - CATREAD with location uncertainty';
elseif nFunction == FilterOp.getWebpage
  uOutput = 'SCEC.htm'; %%%%    DO NOT CHANGE %%%%%%%%%%%
elseif nFunction == FilterOp.importCatalog
    % Read formated data
    mData = textread(sFilename, '%s', 'delimiter', '\n', 'whitespace', '');
    % Create empty catalog
    uOutput = zeros(length(mData),17);
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
            end
        end

    end
    l = isnan(uOutput(:,1));
    uOutput(l,:) = [];


end

%%%%%%%%%%%%%%%%%%%%%%
%%%%     CHANGE THESE LINES %%%%%%%%%%%

function [uOutput] = readvalues(mData,i,k)

uOutput(k,1) = str2num(mData(i,34:37)) - str2num(mData(i,39:43))/60 ;  % Longitude
uOutput(k,2) = str2num(mData(i,26:27)) + str2num(mData(i,29:33))/60 ;  % Latitude
uOutput(k,3) = str2num(mData(i,1:4));    % Year
uOutput(k,4) = str2num(mData(i,6:7));    % Month
uOutput(k,5) = str2num(mData(i,9:10));   % Day
uOutput(k,6) = str2num(mData(i,47:49));  % Magnitude
uOutput(k,7) = str2num(mData(i,55:59));  % Depth
uOutput(k,8) = str2num(mData(i,13:14));  % Hour
uOutput(k,9) = str2num(mData(i,16:17));  % Minute
uOutput(k,10) = str2num(mData(i,19:24))/100;  % Seconds
uOutput(k,11) = nan;   % Reserved for cross-section values
uOutput(k,12) = nan;   % Reserved for Strike
uOutput(k,13) = nan;   % Reserved for Dip direction
uOutput(k,14) = nan;   % Reserved for Dip
uOutput(k,15) = nan;   % Reserved for Rake
uOutput(k,16) = mData(i,45);   % Quality code

% Select and add uncertainties
% Quality A=char(65)
vSelA = (uOutput(k,16) == 65);
uOutput(vSelA,16) = 1 ; % Horizontal location error [km]
uOutput(vSelA,17) = 2 ; % Vertical location error [km]
% Quality B=char(66)
vSelB = (uOutput(k,16) == 66);
uOutput(vSelB,16) = 2 ; % Horizontal location error [km]
uOutput(vSelB,17) = 5 ; % Vertical location error [km]
% Quality C=char(67)
vSelC = (uOutput(k,16) == 67);
uOutput(vSelC,16) = 5 ; % Horizontal location error [km]
uOutput(vSelC,17) = nan ; % Vertical location error [km]
% Quality D=char(68)
vSelD = (uOutput(k,16) == 68);
uOutput(vSelD,16) = nan ; % Horizontal location error [km]
uOutput(vSelD,17) = nan ; % Vertical location error [km]
% Quality Z=char(90)
vSelD = (uOutput(k,16) == 90);
uOutput(vSelD,16) = nan ; % Horizontal location error [km]
uOutput(vSelD,17) = nan ; % Vertical location error [km]

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
