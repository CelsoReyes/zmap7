
maxmag = ceil(10*max(newt2.Magnitude))/10;
mima = min(newt2.Magnitude);
if mima > 0 ; mima = 0 ; end

[bval,xt2] = hist(newt2.Magnitude,(mima:0.1:maxmag));
% normalise to annula rates
bval = bval/(max(newt2.Date)-min(newt2.Date));
bvalsum = cumsum(bval); % N for M <=
bval2 = bval(length(bval):-1:1);
bvalsum3 = cumsum(bval(length(bval):-1:1));    % N for M >= (counted backwards)
xt3 = (maxmag:-0.1:mima);

backg_ab = log10(bvalsum3);
BB = [];

for i = 1:2:length(TMC)-1
    magco = TMC(i,2);
    nn2 = newt2;
    l = nn2(:,6) >= magco;  nn2 = nn2(l,:);
    l = nn2(:,3) >= TMC(i,1) & nn2(:,3) < TMC(i+1,1) ;  nn2 = nn2(l,:);
    if length(nn2(:,1)) >0;
        [bval,xt2] = hist(nn2(:,6),(mima:0.1:maxmag));
        % normalise to annual rates
        bval = bval/(TMC(i+1,1) - TMC(i,1));
        k = mima:0.1:magco;
        bval(1:length(k)) = nan;
        BB = [BB ; bval];
        bvalsum = cumsum(bval); % N for M <=
        bval2 = bval(length(bval):-1:1);
        bvalsum3 = cumsum(bval(length(bval):-1:1));    % N for M >= (counted backwards)
    end

end
l = isinf(BB); BB(l) = 0;

allsum = nanmean(BB);
allsum2 = allsum(length(allsum):-1:1);
bvalsum = cumsum(allsum); % N for M <=
bvalsum3 = cumsum(allsum(length(allsum):-1:1));    % N for M >= (counted backwards)

i = find(allsum2 == max(allsum2));
% now compute the b-value
magco = max(xt3(i));
y2 = (allsum2(1:i));
x2 = xt3(1:i);
l = y2>0; miy = min(y2(l));
y0 = y2;
y2 = (y2/miy);

mean_ml = sum(x2.*y2)/sum(y2);
bw = (1/(mean_ml - magco + 0.05))*log10(exp(1));
aw = log10(sum(y0))+ bw*magco;


