function [mNewCatalog] = syn_create_magnitudes(mCatalog, fBValue, fMc, fInc)

global bDebug
if bDebug
  report_this_filefun(mfilename('fullpath'));
end

mNewCatalog = mCatalog;

nNumberEvents = size(mCatalog,1);

% Gutenberg-Richter: log10(N)=A-B*M
vMagnitudes = [fMc:fInc:10];
vNumbers = 10.^(log10(nNumberEvents) - fBValue*(vMagnitudes-fMc));
vNumbers = round(vNumbers);

new = nan(nNumberEvents,1)

ct1=1;
while vNumbers(ct1+1)~=0;
  ct1=ct1+1;
end
ctM=vMagnitudes(ct1);
count=0;
ct=0;
for I=fMc:fInc:ctM;
  ct=ct+1;
  if I~=ctM
    for sc=1:(vNumbers(ct)-vNumbers(ct+1));
      count=count+1;
      new(count)=I;
    end
  else
    count=count+1;
    new(count)=I;
  end
end

% Randomize
rng('shuffle');
l=rand(length(new),1);
[ii, is] =sort(l);
tmpo=new(is);

mNewCatalog(:,6) = tmpo(1:nNumberEvents);


