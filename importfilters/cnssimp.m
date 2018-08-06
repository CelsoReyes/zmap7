function [uOutput] = cnssimp(nFunction, sFilename)
    % CNSSIMP import data of the ANSS/CNSS raw format catalog 
    %
% [uOutput] = cnssimp(nFunction, sFilename);
%
% ANSS/CNSS raw format: (http://quake.geo.berkeley.edu/ncedc/documents.html#catalog_formats)
% Description of the parameters can be found at http://quake.geo.berkeley.edu/ftp/pub/doc/cat5/cnss.catalog.5
%
% updated: 15.09.03, J. Woessner

if nFunction == FilterOp.getDescription
    uOutput = 'ANSS/CNSS format (string conversion)';
elseif nFunction == FilterOp.importCatalog

    mData = textread(sFilename, '%s', 'delimiter', '\n', 'whitespace', '');

    %transform data to ZMAP format
    uOutput = zeros(size(mData, 1), 9);



    for i = 1:length(mData)
        if rem(i,100) == 0 ; disp([ num2str(i) ' of ' num2str(length(mData)) ' events processed ']); end
        try
            %             uOutput(i,1) = str2num(mData{i}(33:41));    %lon
            %             uOutput(i,2) = str2num(mData{i}(24:31));    %lat
            %             uOutput(i,3) = str2num(mData{i}(1:4));      %yr
            %             uOutput(i,4) = str2num(mData{i}(6:7));      %mo
            %             uOutput(i,5) = str2num(mData{i}(9:10));     %da
            %             uOutput(i,6) = str2num(mData{i}(51:54));    %mag

            uOutput(i,1) = str2num(mData{i}(34:43));    %lon
            uOutput(i,2) = str2num(mData{i}(25:33));    %lat
            uOutput(i,3) = str2num(mData{i}(6:9));      %yr
            uOutput(i,4) = str2num(mData{i}(10:11));      %mo
            uOutput(i,5) = str2num(mData{i}(12:13));     %da
            uOutput(i,6) = str2num(mData{i}(130:134));    %mag
            str = '      ';
            if  strcmp(mData{i}(44:51),str)== 1%strcmp(mData{i}(43:48),str)== 1
                uOutput(i,7) = 0;
            else
                %uOutput(i,7) = str2num(mData{i}(43:48));%dep
                uOutput(i,7) = str2num(mData{i}(44:51));%dep
            end

            %             uOutput(i,8) = str2num(mData{i}(12:13));    %hr
            %             uOutput(i,9) = str2num(mData{i}(15:16));    %min
            uOutput(i,8) = str2num(mData{i}(14:15));    %hr
            uOutput(i,9) = str2num(mData{i}(16:17));    %min
            %uOutput(i,:);
        catch
            disp(['Import: Problem in line ' num2str(i) ' of ' sFilename '. Line ignored.']);
            uOutput(i,:)=nan;
        end
    end
    l = isnan(uOutput(:,1));
    uOutput(l,:) = [];
end
