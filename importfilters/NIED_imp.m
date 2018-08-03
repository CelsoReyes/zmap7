function [uOutput] = scecdcimp(nFunction, sFilename)

% Filter function switchyard
if nFunction == FilterOp.getDescription
    uOutput = 'NIED catalog ';
elseif nFunction == FilterOp.importCatalog
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

            uOutput(i,1) = str2num(mData{i}(53:60)) ;  % Longitude
            uOutput(i,2) =  str2num(mData{i}(36:42))  ;  % Latitude
            uOutput(i,3) = str2num(mData{i}(8:11));    % Year
            uOutput(i,4) = str2num(mData{i}(12:13));    % Month
            uOutput(i,5) = str2num(mData{i}(14:15));   % Day
            uOutput(i,6) = str2num(mData{i}(88:90));  % Magnitude
            uOutput(i,7) = str2num(mData{i}(71:75));  % Depth
            uOutput(i,8) = str2num(mData{i}(17:18));  % Hour
            uOutput(i,9) = str2num(mData{i}(20:21));  % Minute

            %Create decimal year
            uOutput(i,3) = decyear([uOutput(i,3) uOutput(i,4) uOutput(i,5) uOutput(i,8) uOutput(i,9)]);

           % if mData{i}(84) ~= '*'
           %     uOutput(i,:)=nan;
           % end


        catch
            disp(['Import: Problem in line ' num2str(i) ' of ' sFilename '. Line ignored.']);
            uOutput(i,:)=nan;
        end
    end
    l = isnan(uOutput(:,1));
    uOutput(l,:) = [];
end

