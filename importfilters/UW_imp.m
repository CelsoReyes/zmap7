function [uOutput] = scecdcimp(nFunction, sFilename)

% Filter function switchyard
if nFunction == 0     % Return info about filter
    uOutput = 'UW catalog ';
elseif nFunction == 1 % Import and return catalog
    % Read formated data
    mData = textread(sFilename, '%s', 'delimiter', '\n', 'whitespace', '');
    % Create empty catalog
    uOutput = zeros(length(mData), 9);
    % Loop thru all lines of catalog and convert them
    for i = 1:length(mData)
        if rem(i,100) == 0 ; disp([ num2str(i) ' of ' num2str(length(mData)) ' events processed ']); end
        try
            l = find(mData{i} == ' ');
            mData{i}(l) = '0';
            uOutput(i,1) = -str2num(mData{i}(30:32)) - str2num(mData{i}(34:37))/6000 ;  % Longitude
            if mData{i}(33) == 'E' ; uOutput(i,1)  = -1*uOutput(i,1); end
            uOutput(i,2) =  str2num(mData{i}(22:23)) + str2num(mData{i}(25:28))/6000 ;  % Latitude
            if mData{i}(24) == 'S' ; uOutput(i,1)  = -1*uOutput(i,1); end
            uOutput(i,3) = str2num(mData{i}(3:6));    % Year
            uOutput(i,4) = str2num(mData{i}(7:8));    % Month
            uOutput(i,5) = str2num(mData{i}(9:10));   % Day
            uOutput(i,6) = str2num(mData{i}(45:48));  % Magnitude
            uOutput(i,7) = str2num(mData{i}(38:43));  % Depth
            uOutput(i,8) = str2num(mData{i}(11:12));  % Hour
            uOutput(i,9) = str2num(mData{i}(13:14));  % Minute

            %Create decimal year
            uOutput(i,3) = decyear([uOutput(i,3) uOutput(i,4) uOutput(i,5) uOutput(i,8) uOutput(i,9)]);

            if mData{i}(2) == 'P'  ||  mData{i}(2) == 'X'  ||  mData{i}(2) == 'L'
                uOutput(i,:) = uOutput(i,:)*nan;
            end

        catch
            disp(['Import: Problem in line ' num2str(i) ' of ' sFilename '. Line ignored.']);  % eliminate explosions
            uOutput(i,:) = uOutput(i,:)*nan;
        end
    end
    l = isnan(uOutput(:,1));
    uOutput(l,:) = [];
end

