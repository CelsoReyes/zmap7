function [magco, fMc95, fMc90] = calc_McBestMag(vMagnitudes, fBinning)

global bDebug;
if bDebug
  report_this_filefun(mfilename('fullpath'));
end

% First estimation of magnitude of completeness (maximum curvature)
[vEvents, vMag] = hist(vMagnitudes, -2:0.1:6);
nSel = max(find(vEvents == max(vEvents)));
magco0 =  vMag(nSel);


dat = [];

%if exist('fBinning')
%  inc=fBinning;
%else
inc = 0.1 ; %magnitude increment
%end;

for i = magco0-0.9:0.1:magco0+1.5
  l = vMagnitudes >= i - 0.0499;
  nu = length(vMagnitudes(l));
  if nu >= 25
    [mw, B, stan2,  av] =  bmemag(mCatalog(l));

    IM= i; %starting magnitude (hypothetical Mc)

    % log10(N)=A-B*M
    M=[IM:inc:15];
    N=10.^(log10(nu)-B*(M-IM));
    N=round(N);

    ct1  = min(find(N == 0)) - 1;
    if isempty(ct1) == 1
      ct1 = length(N);
    end

    ctM=M(ct1);
    ct=0;
    for I=IM:inc:ctM
      ct=ct+1;
    end

    PM=M(1:ct);
    N = N(1:ct);
    [bval,xt2] = hist(vMagnitudes(l),PM);
    b3 = fliplr(cumsum(fliplr(bval)));    % N for M >= (counted backwards)
    res2 = sum(abs(b3 - N))/sum(b3)*100;
    dat = [dat ; i res2];
  else
    dat = [dat ; i NaN];
  end
end

% Is fMc90 available
nSel = min(find(dat(:,2) < 10));
if isempty(nSel) == 1
  fMc90 = NaN;
else
  fMc90 = dat(nSel,1);
end

% Is fMc95 available
nSel = min(find(dat(:,2) < 5));
if isempty(nSel) == 1
  fMc95 = NaN;
else
  fMc95 = dat(nSel,1);
end

% ?????
j =  min(find(dat(:,2) < 10 ));
if isempty(j) == 1; j =  min(find(dat(:,2) < 15 )); end
if isempty(j) == 1; j =  min(find(dat(:,2) < 20 )); end
if isempty(j) == 1; j =  min(find(dat(:,2) < 25 )); end
%j2 =  min(find(dat(:,2) == min(dat(:,2)) ));

magco = dat(j,1);
if isempty(magco) == 1
  magco = NaN;
end


