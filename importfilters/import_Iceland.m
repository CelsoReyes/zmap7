function [uOutput] = import_Iceland(nFunction, sFilename)

% Filter function switchyard
if nFunction == FilterOp.getDescription
  uOutput = 'Iceland (with focal mechanisms)';
elseif nFunction == FilterOp.importCatalog
  % Init catalog variable
  uOutput = [];
  % Open file
  hFile = fopen(sFilename, 'r');
  while ~feof(hFile)
    sLine = fgetl(hFile);
    % Ignore empty line
    if ~isempty(sLine)
      % Ignore comment lines
      if sLine(1) ~= 'C'
        [bOK, vEvent] = ConvertLine(sLine);
        if bOK
          uOutput = [uOutput; vEvent];
        else
          disp(sLine);
        end
      end
    end
  end
  fclose(hFile);
% elseif nFunction == FilterOp.getWebpage
%   uOutput = 'import_Iceland_doc.html';
end


% - Subfunction -

function [bOK, vEvent] = ConvertLine(sLine)

% Replace 0xA0 with 0x20
for nCnt = 1:length(sLine)
  if double(sLine(nCnt)) == 160
    sLine(nCnt) = ' ';
  end
end

% Default
bOK = true;
vEvent = zeros(1,12);

% Read year
sPart = sLine(1:4);
vEvent(3) = str2double(sPart);

% Read month
sPart = sLine(5:6);
vEvent(4) = str2double(sPart);

% Read day
sPart = sLine(7:8);
vEvent(5) = str2double(sPart);

% Read hour
sPart = sLine(10:11);
vEvent(8) = str2double(sPart);

% Read minutes
sPart = sLine(12:13);
vEvent(9) = str2double(sPart);

[vVal, count, errmsg] = sscanf(sLine, '%f');

% Read longitude
vEvent(1) = vVal(5);

% Read latitude
vEvent(2) = vVal(3);

% Read magnitude
vEvent(6) = vVal(9);

% Read depth
vEvent(7)= vVal(7);

% Read dip-direction
vEvent(10) = vVal(14) + 90;

% Read dip
vEvent(11) = vVal(15);

% Read rake
vEvent(12) = vVal(16);

% Replace year by decimal year
vEvent(3) = decyear([vEvent(3) vEvent(4) vEvent(5) vEvent(8) vEvent(9)]);
