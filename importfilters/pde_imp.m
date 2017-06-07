function [uOutput] = scecdcimp(nFunction, sFilename)

% Filter function switchyard
if nFunction == 0     % Return info about filter
    uOutput = 'USGS PDE Data Center Compressed Format (stringconvert)';
elseif nFunction == 1 % Import and return catalog
    % Read formated data
    mData = textread(sFilename, '%s', 'delimiter', '\n', 'whitespace', '');
    % Create empty catalog
    uOutput = zeros(length(mData), 9);
    % Loop thru all lines of catalog and convert them
    for i = 1:length(mData)
        if rem(i,100) == 0 ; disp([ num2str(i) ' of ' num2str(length(mData)) ' events processed ']); end
        try

            uOutput(i,1) = str2num(mData{i}(35:42));  % Longitude
            uOutput(i,2) = str2num(mData{i}(28:34));  % Latitude
            uOutput(i,3) = str2num(mData{i}(8:11));    % Year
            uOutput(i,4) = str2num(mData{i}(13:14));    % Month
            uOutput(i,5) = str2num(mData{i}(15:16));   % Day
            uOutput(i,6) = str2num(mData{i}(66:68));  % Magnitude
            uOutput(i,7) = str2num(mData{i}(43:47));  % Depth
            uOutput(i,8) = str2num(mData{i}(17:18));  % Hour
            uOutput(i,9) = str2num(mData{i}(19:20));  % Minute


             %Create decimal year
            % uOutput(i,3) = decyear([uOutput(i,3) uOutput(i,4) uOutput(i,5) uOutput(i,8) uOutput(i,9)]);
         catch
            disp(['Import: Problem in line ' num2str(i) ' of ' sFilename '. Line ignored.']);
            uOutput(i,:) = uOutput(i,:)*nan;
        end
    end
    l = isnan(uOutput(:,1));
    uOutput(l,:) = [];
end

