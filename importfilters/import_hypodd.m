function [uOutput] = import_hypodd(nFunction, sFilename)
% ------------------------------------------------------
% Import data from a double difference relocated dataset
% Reference: Waldhauser, F. A., A computer program to compute daouble
% -difference hypocenter location, U.S. Geol. Surv. Open File Report,
% 01-113,25 pp.,2001
% See page 21
% Note: Remove header


% Filter function switchyard
if nFunction == FilterOp.getDescription
    uOutput = 'HypoDD - ';
elseif nFunction == FilterOp.importCatalog
    % Read formated data
    mData = textread(sFilename, '%s', 'delimiter', '\n', 'whitespace', '');
    % Create empty catalog
    uOutput = zeros(length(mData), 10);
    % Loop thru all lines of catalog and convert them
    for i = 1:length(mData)
        try
            uOutput(i,1) = str2num(mData{i}(20:30));  % Longitude
            uOutput(i,2) = str2num(mData{i}(10:18));  % Latitude
            uOutput(i,3) = str2num(mData{i}(93:96));    % Year
            uOutput(i,4) = str2num(mData{i}(98:99));    % Month
            uOutput(i,5) = str2num(mData{i}(101:102));   % Day
            uOutput(i,6) = str2num(mData{i}(116:119));  % Magnitude
            uOutput(i,7) = str2num(mData{i}(33:37));  % Depth
            uOutput(i,8) = str2num(mData{i}(104:105));  % Hour
            uOutput(i,9) = str2num(mData{i}(107:108));  % Minute
            uOutput(i,10) = str2num(mData{i}(110:114));  % Second
            uOutput(i,11) = nan;  % leave empty for cross section values
            uOutput(i,12) = nan;  % strike
            uOutput(i,13) = nan;  % dip direction
            uOutput(i,14) = nan;  % rake
            uOutput(i,15) = nan;  % dip
            % Create decimal year
             uOutput(i,3) = decyear([uOutput(i,3) uOutput(i,4) uOutput(i,5) uOutput(i,8) uOutput(i,9) uOutput(i,10)]);
        catch
            disp(['Import: Problem in line ' num2str(i) ' of ' sFilename '. Line ignored.']);
        end
    end
end

