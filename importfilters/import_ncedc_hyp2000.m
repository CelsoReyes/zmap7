function [uOutput,Error_lines] = import_ncedc_hyp2000(nFunction, sFilename)
% function [uOutput] = import_ncedc_hyp2000(nFunction, sFilename);
% ----------------------------------------------------------------
% Function to import catalog data from the NCEDC (http://quake.geo.berkeley.edu) in HYPO2000 format
%
% updated: 06.06.2005, D. Schorlemmer
%
% Authors: J. Woessner (jochen.woessner@sed.ethz.ch)
%          D. Schorlemmer (danijel@sed.ethz.ch)

% Filter function switchyard
%%%%     CHANGE THESE LINES %%%%%%%%%%%
if nFunction == 0     % Return info about filter
    uOutput = 'Northern California Earthquake Data Center - HYP2000 format incl.seconds';
elseif nFunction == 2 % Return filename of helpfile (HTML)
  uOutput = 'hypo2000.htm';
 %%%%    DO NOT CHANGE %%%%%%%%%%%

elseif nFunction == 1 % Import and return catalog
    % Read formated data
    mData = textread(sFilename, '%s', 'delimiter', '\n', 'whitespace', '');
    % Create empty catalog
    uOutput = zeros(length(mData), 22);
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

uOutput(k,1) =-str2num(mData(i,24:26)) - str2num(mData(i,28:31))/6000 ;  % Longitude
uOutput(k,2) = str2num(mData(i,17:18)) + str2num(mData(i,20:23))/6000 ;  % Latitude
uOutput(k,3) = str2num(mData(i,1:4));    % Year
uOutput(k,4) = str2num(mData(i,5:6));    % Month
uOutput(k,5) = str2num(mData(i,7:8));   % Day
uOutput(k,6) = str2num(mData(i,148:150))/100;  % Magnitude
uOutput(k,7) = str2num(mData(i,32:36))/100;  % Depth
uOutput(k,8) = str2num(mData(i,9:10));  % Hour
uOutput(k,9) = str2num(mData(i,11:12));  % Minute
uOutput(k,10) = str2num(mData(i,13:16))/100;  % Second
uOutput(k,11) = nan;  % Reserved for cross section values
uOutput(k,12) = nan;  % Strike (Plane 1)
uOutput(k,13) = nan;  % Dip direction (Plane 1)
uOutput(k,14) = nan;  % Dip (Plane 1)
uOutput(k,15) = nan;  % Rake (Plane 1)
uOutput(k,16) = nan;  % Strike (Plane 2)
uOutput(k,17) = nan;  % Dip direction (Plane 2)
uOutput(k,18) = nan;  % Dip (Plane 2)
uOutput(k,19) = nan;  % Rake (Plane 2)
uOutput(k,20) = str2num(mData(i,86:89))/100; % Horizontal error [km]
uOutput(k,21) = str2num(mData(i,90:93))/100; % Vertical error [km]
uOutput(k,22) = str2num(mData(i,137:146)); % CUSPID

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
