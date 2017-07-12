function [fMc, fMc95, fMc90] = calc_McBest(mCatalog, fBinning)

global bDebug;
if bDebug
  report_this_filefun(mfilename('fullpath'));
end

% First estimation of magnitude of completeness (maximum curvature)
[vEvents, vMag] = hist(mCatalog.Magnitude, -2:0.1:6);
nSel = max(find(vEvents == max(vEvents)));
fMcStart = vMag(nSel);

% Data container
mData = [];

% Magnitude increment
if ~exist('fBinning')
  fBinning = 0.1;
end

for nCnt = (fMcStart - 0.9):fBinning:(fMcStart + 1.5)
  vSel = mCatalog.Magnitude > (nCnt - (fBinning/2));
  %vSel = mCatalog.Magnitude >= nCnt - 0.0499;
  nNumberEvents = sum(vSel);
  if nNumberEvents >= 25
    [fDummy fBValue fDummy,  fDummy] =  bmemag(mCatalog.subset(vSel));

    fStartMag = nCnt; % Starting magnitude (hypothetical Mc)

    % log10(N)=A-B*M
    vMag = [fStartMag:fBinning:15]; % Ending magnitude must be sufficiently high
    vNumber = 10.^(log10(nNumberEvents)-fBValue*(vMag - fStartMag));
    vNumber = round(vNumber);

    % Find the last bin with an event
    nLastEventBin = min(find(vNumber == 0)) - 1;
    if isempty(nLastEventBin)
      nLastEventBin = length(vNumber);
    end

%    ctM=vMag(ct1);

    % Determine set of all magnitude bins with number of events > 0
    ct = round((vMag(nLastEventBin)-fStartMag)*(1/fBinning) + 1);
%     ct=0;
%     for I=fStartMag:fBinning:ctM;
%       ct=ct+1;
%     end

    PM=vMag(1:ct);
    vNumber = vNumber(1:ct);
    [bval, vDummy] = hist(mCatalog.Magnitude(vSel),PM);
    b3 = fliplr(cumsum(fliplr(bval)));    % N for M >= (counted backwards)
    res2 = sum(abs(b3 - vNumber))/sum(b3)*100;
    mData = [mData; nCnt res2];
  else
    mData = [mData; nCnt NaN];
  end
end

% Evaluation of results

% Is fMc90 available
nSel = min(find(mData(:,2) < 10));
if isempty(nSel)
  fMc90 = NaN;
else
  fMc90 = mData(nSel,1);
end

% Is fMc95 available
nSel = min(find(mData(:,2) < 5));
if isempty(nSel)
  fMc95 = NaN;
else
  fMc95 = mData(nSel,1);
end

% ?????
j =  min(find(mData(:,2) < 10 ));
if isempty(j) == 1; j =  min(find(mData(:,2) < 15 )); end
if isempty(j) == 1; j =  min(find(mData(:,2) < 20 )); end
if isempty(j) == 1; j =  min(find(mData(:,2) < 25 )); end
%j2 =  min(find(dat(:,2) == min(dat(:,2)) ));

fMc = mData(j,1);
if isempty(fMc)
  fMc = NaN;
end


