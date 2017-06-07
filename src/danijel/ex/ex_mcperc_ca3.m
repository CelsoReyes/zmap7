function [magco, Mc95, Mc90] = ex_mcperc_ca3(mCatalog)

global bDebug;
if bDebug
  report_this_filefun(mfilename('fullpath'));
end

% This is a comleteness determination test
[bval, xt2] = hist(mCatalog(:,6),-2:0.1:6);
l = max(find(bval == max(bval)));
magco0 =  xt2(l);


dat = [];

for i = magco0-0.9:0.1:magco0+1.5
   l = mCatalog(:,6) >= i - 0.0499; nu = length(mCatalog(l,6));
   if length(mCatalog(l,6)) >= 25;
      [mw bv2 stan2,  av] =  bmemag(mCatalog(l,:));


TN = length(mCatalog(l,:));%total number of events
B = bv2 ;%b-value
IM= i;%starting magnitude (hypothetical Mc)
inc = 0.1 ;%magnitude increment

% log10(N)=A-B*M
M=[IM:inc:15];
N=10.^(log10(TN)-B*(M-IM));
aval=(log10(TN)-B*(0-IM));
N=round(N);

syn = ones(TN,9)*nan;
new = ones(TN,1)*nan;

ct1  = min(find(N == 0)) - 1;
if isempty(ct1) == 1 ; ct1 = length(N); end

ctM=M(ct1);
count=0;
ct=0;
swt=0;
sc=0;
for I=IM:inc:ctM
   ct=ct+1;
   if I~=ctM
      for sc=1:(N(ct)-N(ct+1))
         count=count+1;
         new(count)=I;
      end
   else
      count=count+1;
      new(count)=I;
   end
end


PM=M(1:ct);
PN=log10(N(1:ct));
N = N(1:ct);
le = length(mCatalog(l,:));
[bval,xt2] = hist(mCatalog(l,6),PM);
b3 = fliplr(cumsum(fliplr(bval)));    % N for M >= (counted backwards)
res2 = sum(abs(b3 - N))/sum(b3)*100;
res = res2;




      %      synthb_aut
      dat = [dat ; i res2];
   else
      dat = [dat ; i NaN];
   end

end

j =  min(find(dat(:,2) < 10 ));
if isempty(j) == 1; Mc90 = NaN ;
else;
   Mc90 = dat(j,1);
end

j =  min(find(dat(:,2) < 5 ));
if isempty(j) == 1; Mc95 = NaN ;
else;
   Mc95 = dat(j,1);
end

j =  min(find(dat(:,2) < 10 ));
if isempty(j) == 1; j =  min(find(dat(:,2) < 15 )); end
if isempty(j) == 1; j =  min(find(dat(:,2) < 20 )); end
if isempty(j) == 1; j =  min(find(dat(:,2) < 25 )); end
j2 =  min(find(dat(:,2) == min(dat(:,2)) ));

Mc = dat(j,1);
magco = Mc;
prf = 100 - dat(j2,2);
if isempty(magco) == 1; magco = NaN; prf = 100 -min(dat(:,2)); end


