function [uOutput] = import_JMA(nFunction, sFilename)

% Filter function switchyard
if nFunction == FilterOp.getDescription
  uOutput = 'JMA';
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
elseif nFunction == FilterOp.getWebpage
  uOutput = 'import_JMA_doc.html';
end


% - Subfunction -

function [bOK, vEvent] = ConvertLine(sLine)

% Default
bOK = true;
vEvent = zeros(1,10);
% Replace 0xA0 with 0x20
for nCnt = 1:length(sLine)
  if double(sLine(nCnt)) == 160
    sLine(nCnt) = ' ';
  end
end

% Read longitude
sPart = sLine(33:36);
[bOK, fVal] = Decode(sPart, 4);
if ~bOK
  disp('No Longitude');
  return;
end
sPart = sLine(37:40);
[bOK, fVal2] = Decode(sPart, 4);
if ~bOK
  disp('No Longitude/Minute');
  return;
end
vEvent(1) = fVal + fVal2/6000;
% Read latitude
sPart = sLine(22:24);
[bOK, fVal] = Decode(sPart, 3);
if ~bOK
  disp('No Latitude');
  return;
end
sPart = sLine(25:28);
[bOK, fVal2] = Decode(sPart, 4);
if ~bOK
  disp('No Latitude/Minute');
  return;
end
vEvent(2) = fVal + fVal2/6000;
% Read year
sPart = sLine(2:5);
[fVal, nCnt] = sscanf(sPart, '%4d');
if nCnt == 0
  bOK = false;
   disp('No Year');
 return;
end
vEvent(3) = fVal;
% Read month
sPart = sLine(6:7);
[fVal, nCnt] = sscanf(sPart, '%2d');
if nCnt == 0
  bOK = false;
  disp('No Month');
  return;
end
vEvent(4) = fVal;
% Read day
sPart = sLine(8:9);
[fVal, nCnt] = sscanf(sPart, '%2d');
if nCnt == 0
  bOK = false;
  disp('No Day');
  return;
end
vEvent(5) = fVal;
% Read magnitude
sPart = sLine(53:54);
[fVal, nCnt] = sscanf(sPart, '%2d');
if nCnt == 0
  bOK = false;
  disp('No Magnitude');
  return;
end
vEvent(6) = fVal/10;
% Read depth
sPart = sLine(45:49);
[bOK, fVal] = Decode(sPart, 5);
if ~bOK
  disp('No Depth');
  return;
end
vEvent(7) = fVal/100;
% Read hour
sPart = sLine(10:11);
[fVal, nCnt] = sscanf(sPart, '%2d');
if nCnt == 0
  bOK = false;
  disp('No Hour');
  return;
end
vEvent(8) = fVal;
% Read minute
sPart = sLine(12:13);
[fVal, nCnt] = sscanf(sPart, '%2d');
if nCnt == 0
  bOK = false;
   disp('No Minute');
 return;
end
vEvent(9) = fVal;

% Read second
sPart = sLine(14:16);
[fVal, nCnt] = sscanf(sPart, '%4d');
if nCnt == 0
  bOK = false;
   disp('No seconds');
 return;
end
vEvent(10) = fVal/100;

% Replace year by decimal year
vEvent(3) = decyear([vEvent(3) vEvent(4) vEvent(5) vEvent(8) vEvent(9)]);


% --- Decode ---
function [bOK, fValue] = Decode(sLine, nLength)

if isempty(str2num(sLine))
  bOK = false;
  return;
end
fValue = 0;
for nCnt = 1:nLength
  nExp = nLength - nCnt;
  if ~isempty(str2num(sLine(nCnt)))
    fValue = fValue + (str2double(sLine(nCnt)) * 10^nExp);
  end
end
bOK = true;
