function [uOutput] = yourfilterimp(nFunction, sFilename)
%
% Import filter template
%

% Filter function switchyard
if nFunction == FilterOp.getDescription
    uOutput = 'Your data format - adjust the file yourfilterimp.m';
elseif nFunction == FilterOp.importCatalog
    % Read formated data
    mData = textread(sFilename, '%s', 'delimiter', '\n', 'whitespace', ''); % USE TEXTSCAN INSTEAD OF TEXTREAD
    % Create empty catalog
    uOutput = zeros(length(mData), 15);
    % Loop thru all lines of catalog and convert them
    for i = 1:length(mData)
        try
            uOutput(i,1) = str2num(mData{i}(41:48));  % Longitude
            uOutput(i,2) = str2num(mData{i}(34:39));  % Latitude
            uOutput(i,3) = str2num(mData{i}(1:4));    % Year
            uOutput(i,4) = str2num(mData{i}(6:7));    % Month
            uOutput(i,5) = str2num(mData{i}(9:10));   % Day
            uOutput(i,6) = str2num(mData{i}(26:28));  % Magnitude
            uOutput(i,7) = str2num(mData{i}(51:54));  % Depth
            uOutput(i,8) = str2num(mData{i}(12:13));  % Hour
            uOutput(i,9) = str2num(mData{i}(15:16));  % Minute
            uOutput(i,10) = str2num(mData{i}(15:16));  % Second
            %uOutput(i,11) = str2num(mData{i}(15:16));  % leave empty for cross section values
            uOutput(i,12) = str2num(mData{i}(15:16));  % strike
            uOutput(i,13) = str2num(mData{i}(15:16));  % dip direction
            uOutput(i,14) = str2num(mData{i}(15:16));  % rake
            uOutput(i,15) = str2num(mData{i}(15:16));  % dip
            % Create decimal year
             uOutput(i,3) = decyear([uOutput(i,3) uOutput(i,4) uOutput(i,5) uOutput(i,8) uOutput(i,9) uOutput(i,10) ]);
        catch
            disp(['Import: Problem in line ' num2str(i) ' of ' sFilename '. Line ignored.']);
        end
    end
end

