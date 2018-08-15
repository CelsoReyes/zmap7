function [uOutput] = harvardcmt_imp(nFunction, sFilename)
% [uOutput] = harvardcmt_imp(nFunction, sFilename);
% ----------------------------------------------------------
% Read in Harvard CMT data of a selfmade Ascii-file. Ascii-file needs to be produced from a Harvard *.dek file
% converted using an executable of cmtsel.f
%
% Stepwise:
% 1. First use an executable of cmtsel.f to produce the Ascii-file
% 2. Use Data import filter tool to import Ascii-file
%
% J. Woessner; woessner@seismo.ifg.ethz.ch
% updated: 10.03.02

% Filter function switchyard
if nFunction == FilterOp.getDescription
    uOutput = 'Harvard CMT import';
elseif nFunction == FilterOp.importCatalog
    % Read formated data
    mData = textread(sFilename, '%s', 'delimiter', '\n', 'whitespace', '');
    % Create empty catalog
    uOutput = zeros(length(mData), 10);
    % Loop thru all lines of catalog and convert them
    for i = 1:length(mData)
        try
            uOutput(i,1) = str2num(mData{i}(28:34));  % Longitude (PDE)
            uOutput(i,2) = str2num(mData{i}(21:25));  % Latitude  (PDE)
            uOutput(i,3) = str2num(mData{i}(1:2));    % Year
            if uOutput(i,3) < 76
                uOutput(i,3) = uOutput(i,3)+2000;
            else
                uOutput(i,3) = uOutput(i,3)+1900;
            end
            uOutput(i,4) = str2num(mData{i}(4:5));    % Month
            uOutput(i,5) = str2num(mData{i}(7:8));   % Day
            uOutput(i,6) = str2num(mData{i}(82:85));  % Magnitude Mw
            uOutput(i,7) = str2num(mData{i}(36:40));  % Depth (PDE)
            uOutput(i,8) = str2num(mData{i}(10:11));  % Hour
            uOutput(i,9) = str2num(mData{i}(13:14));  % Minute
            uOutput(i,10) = str2num(mData{i}(16:19));  % Second
            uOutput(i,11) = str2num(mData{i}(42:44));  % mb
            uOutput(i,12) = str2num(mData{i}(46:48));  % Ms
            uOutput(i,13) = str2num(mData{i}(87:89));  % Strike : Fault plane 1
            uOutput(i,14) = str2num(mData{i}(91:92));  % Dip : Fault plane 1
            uOutput(i,15) = str2num(mData{i}(94:97));  % Rake  : Fault plane 1
            uOutput(i,16) = str2num(mData{i}(99:101));  % Strike : Fault plane 2
            uOutput(i,17) = str2num(mData{i}(103:104));  % Dip : Fault plane 2
            uOutput(i,18) = str2num(mData{i}(106:109));  % Rake  : Fault plane 2
            uOutput(i,19) = str2num(mData{i}(50:55));  % Latitude (HAV)
            uOutput(i,20) = str2num(mData{i}(57:63));  % Longitude (HAV)
            uOutput(i,21) = str2num(mData{i}(65:69));  % Depth (HAV)
            uOutput(i,22) = str2num(mData{i}(72:75));  % Cen_time
            uOutput(i,23) = str2num(mData{i}(77:80));  % Half Duration
            %uOutput(i,24) = mData{i}(111:113);  % Agency
            % Create decimal year
             uOutput(i,3) = decyear([uOutput(i,3) uOutput(i,4) uOutput(i,5) uOutput(i,8) uOutput(i,9)]);
        catch
            disp(['Import: Problem in line ' num2str(i) ' of ' sFilename '. Line ignored.']);
        end
    end
end

