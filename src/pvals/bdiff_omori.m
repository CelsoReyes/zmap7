%%
% This routine etsimates the b-value of a curve automatically
%  The b-valkue curve is differenciated and the point
%  of maximum curvature marked. The b-value will be calculated
%  using this point and the point half way toward the high
%  magnitude end of the b-value curve.
%
%  THIS IS RUN AUTOMATICALLY FROM MIN_OMORI1
%
%%

global cluscat mess bfig backcat fontsz ho xt3 bvalsum3  bval aw bw t1 t2 t3 t4;
global ttcat les n teb t0b cb1 cb2 cb3 cua b1 n1 b2 n2  ew si  S mrt bvalsumhold b;
global selt magco bvml avml bvls avls bv;
global hndl2 inpr1;
think

%report_this_filefun(mfilename('fullpath'));


maxmag = ceil(10*max(newt2(:,6)))/10;
mima = min(newt2(:,6));
if mima > 0 ; mima = 0 ; end

% number of mag units
nmagu = (maxmag*10)+1;

bval = zeros(1,nmagu);
bvalsum = zeros(1,nmagu);
bvalsum3 = zeros(1,nmagu);

%%
%
% bval contains the number of events in each bin
% bvalsum is the cum. sum in each bin
% bval2 is number events in each bin, in reverse order
% bvalsum3 is reverse order cum. sum.
% xt3 is the step in magnitude for the bins == .1
%
%%

[bval,xt2] = hist(newt2(:,6),(mima:0.1:maxmag));
bvalsum = cumsum(bval); % N for M <=
bval2 = bval(length(bval):-1:1);
bvalsum3 = cumsum(bval(length(bval):-1:1));    % N for M >= (counted backwards)
xt3 = (maxmag:-0.1:mima);

backg_ab = log10(bvalsum3);


%%
% Estimate the b value -- based on one of 5 methods
%
% calculates max likelihood b value(bvml) && WLS(bvls)
%
%%

Nmin = 10;
bvs=newt2;
b=newt2;

% set DEFAULT to run using best of option
inpr1 = 5;


%% enough events??
if length(bvs) >= Nmin


    %%
    % calculation based on best combination of 90% and 95% probability -- default
    %%

    %            if inpr1 == 5
    mcperc_ca3;
    if isnan(Mc95) == 0 
        magco = Mc95;
    elseif isnan(Mc90) == 0 
        magco = Mc90;
    else
        [bv magco stan av me mer me2,  pr] =  bvalca3(bvs,1,1);
    end
    l = bvs(:,6) >= magco-0.05;
    if length(bvs(l)) >= Nmin
        %              [bvls magco0 stanls avls me mer me2,  pr] =  bvalca3(bvs(l,:),2,2);
        [mea bvml stanml avml ] =  bmemag(b(l,:));
    else
        bv = nan; bv2 = nan; magco = nan; av = nan; av2 = nan;
    end




end
