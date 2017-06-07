function [mColormap] = gui_Colormap_ReadPovRay(sFilename, nSize)

if ~exist('nSize', 'var')
  nSize = 256;
end

mData = [];

hFile = fopen(sFilename, 'r');
while ~(feof(hFile))
  sLine = fgetl(hFile);
  % Ignore unused line
  if IsUsed(sLine)
    [vDataLine] = ConvertLine(sLine);
    mData = [mData; vDataLine];
  end
end
fclose(hFile);

%[mData] = ReduceData(mData);

[mColormap] = ComposeColormap(mData, nSize);

% - Subfunction -

function [bUsed] = IsUsed(sLine)

if ((sLine(1) == '/') | (sLine(1) == 'c') | (sLine(1) == '}'))
  bUsed = 0;
else
  bUsed = 1;
end

% ---

function [vDataLine] = ConvertLine(sLine)

fPart  = str2double(sLine(3:10));
fRed   = str2double(sLine(24:31));
fGreen = str2double(sLine(34:41));
fBlue  = str2double(sLine(44:51));
vDataLine = [fPart fRed fGreen fBlue];

% ---

function [mData] = ReduceData(mData)

nLen = length(mData(:,1));
for nCnt = (nLen-1):-1:1
  if mData(nCnt,1) == mData(nCnt+1,1)
    mData(nCnt+1,:) = [];
  end
end

% ---

function [mColormap] = ComposeColormap(mData, nSize)

mColormap = [];
nLen = length(mData(:,1));

for nCnt = 1:(nLen-1)
  nSteps = floor(nSize * (mData(nCnt+1,1) - mData(nCnt,1)));
  if nSteps > 0
    mColormap = [mColormap; gui_Interpolate(mData(nCnt, 2:4), mData(nCnt+1,2:4), nSteps)];
  end
end


%/* color_map file created by the GIMP */
%/* http://www.gimp.org/               */
%color_map {
%	[0.000000 color rgbt <0.128028, 0.725490, 0.128028, 0.000000>]
%	[0.168005 color rgbt <0.564014, 0.862745, 0.564014, 0.000000>]
%	[0.333333 color rgbt <1.000000, 1.000000, 1.000000, 0.000000>]
%	[0.333333 color rgbt <1.000000, 1.000000, 1.000000, 0.000000>]
%	[0.500678 color rgbt <0.996078, 0.904645, 0.538908, 0.000000>]
%	[0.668022 color rgbt <0.992157, 0.809289, 0.077816, 0.000000>]
%	[0.668022 color rgbt <0.992157, 0.809289, 0.077816, 0.000000>]
%	[0.834011 color rgbt <0.970588, 0.449304, 0.174595, 0.000000>]
%	[1.000000 color rgbt <0.949020, 0.089319, 0.271374, 0.000000>]
%} /* color_map */
