function [uOutput] = scecdcimp(nFunction, sFilename)

%example
%1973,03,05,235946.60, 27.686,  33.644,4.5, 25,PDE


% Filter function switchyard
if nFunction == 0     % Return info about filter
    uOutput = 'USGS PDE Data Center Compressed Format comma delimited(stringconvert)';
elseif nFunction == 1 % Import and return catalog
    % Read formated data
    mData = textread(sFilename, '%s', 'delimiter', '\n', 'whitespace', '');
    % Create empty catalog
    uOutput = zeros(length(mData), 10);
    % Loop thru all lines of catalog and convert them
    for i = 1:length(mData)
        if rem(i,100) == 0 ; disp([ num2str(i) ' of ' num2str(length(mData)) ' events processed ']); end
        try
            myline=mData{i};
            theComma=find(myline==',');

            val = str2num(myline(1:theComma(1)));    % Year
            if isempty(val);val=0;end
            uOutput(i,3) = val;

            val = str2num(myline(theComma(1)+1:theComma(2)-1));     % Month
            if isempty(val);val=0;end
            uOutput(i,4) = val;

            val = str2num(myline(theComma(2)+1:theComma(3)-1));   % Day
            if isempty(val);val=0;end
            uOutput(i,5) = val;

            TimeString=myline(theComma(3)+1:theComma(4)-1);   % TimeString

            val = str2num(TimeString(1:2));  % Hour
            if isempty(val);val=0;end
            uOutput(i,8) = val;

            val = str2num(TimeString(3:4));  % Minute
            if isempty(val);val=0;end
            uOutput(i,9) = val;

            val = str2num(TimeString(5:end));  % second
            if isempty(val);val=0;end
            uOutput(i,10) = val;

            uOutput(i,2) = str2num(myline(theComma(4)+1:theComma(5)-1));  % Latitude
            uOutput(i,1) = str2num(myline(theComma(5)+1:theComma(6)-1));  % Longitude

            val = str2num(myline(theComma(6)+1:theComma(7)-1));  % Magnitude
            if isempty(val);val=0;end
            uOutput(i,6) = val;

            val = str2num(myline(theComma(7)+1:theComma(8)-1));  % Depth
            if isempty(val);val=0;end
            uOutput(i,7) = val;


             %Create decimal year
             uOutput(i,3) = decyear([uOutput(i,3) uOutput(i,4) uOutput(i,5) uOutput(i,8) uOutput(i,9) uOutput(i,10)]);
         catch
            disp(['Import: Problem in line ' num2str(i) ' of ' sFilename '. Line ignored.']);
            uOutput(i,:)=nan;
        end
    end
    l = isnan(uOutput(:,1));
    uOutput(l,:) = [];
end

