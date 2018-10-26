function[] =loadDecRes(numSim)
%

% FIXME this depends on long gone files. REWRITE entirely
unimplemented_error();

resFileIn = '/home/matt/mProjects/MonteDeclus/Results/DeclusResFixP.mat';
parmFileIn = '/home/matt/mProjects/MonteDeclus/Results/DeclusParmsFixP.mat';

load(resFileIn);
load(parmFileIn);
for simNum = 1:numSim
    decCat = decResult{simNum};
    [numEvents4(simNum) wRes4(simNum)] = size(decCat);
    isG5 = decCat(:,6) >= 5;
    numEvents5(simNum) = sum(isG5);

    taumin(simNum) = monteParms{simNum}(1);
    taumax(simNum) = monteParms{simNum}(2);
    P(simNum) = monteParms{simNum}(3);
    xk(simNum) = monteParms{simNum}(4);
    xmeff(simNum) = monteParms{simNum}(5);
    rfact(simNum) = monteParms{simNum}(6);
    err(simNum) = monteParms{simNum}(7);
    derr(simNum) = monteParms{simNum}(8);
end

[Vals, E4ind] = sort(numEvents4);
sortedE4 = numEvents4(E4ind);
stmin4 = taumin(E4ind);
stmax4 = taumax(E4ind);
sP4 = P(E4ind);
sxk4 = xk(E4ind);
sxmeff4 = xmeff(E4ind);
srfact4 = rfact(E4ind);
serr4 = err(E4ind);
sderr4 = derr(E4ind);
minE4 = min(sortedE4);
maxE4 = max(sortedE4);
histStepE4 = minE4:(maxE4-minE4)/100:maxE4;
histE4 = histogram(sortedE4,histStepE4);

[Vals, E5ind] = sort(numEvents5);
sortedE5 = numEvents5(E5ind);
stmin5 = taumin(E5ind);
stmax5 = taumax(E5ind);
sP5 = P(E5ind);
sxk5 = xk(E5ind);
sxmeff5 = xmeff(E5ind);
srfact5 = rfact(E5ind);
serr5 = err(E5ind);
sderr5 = derr(E5ind);
minE5 = min(sortedE5);
maxE5 = max(sortedE5);
histStepE5 = minE5:(maxE5-minE5)/100:maxE5;
histE5 = histogram(sortedE5,histStepE5);

printMinMax = @(val) fprintf('%s: %g %g\n', inputname(1), min(val), max(val));
printMinMax(taumin);
printMinMax(taumax);
printMinMax(P);
printMinMax(rfact);
printMinMax(xk);
printMinMax(xmeff);

figure
plot(numEvents5,rfact,'.k');
figure
histogram(numEvents5);


%figure
%plot(histStepE4,cumsum(histE4),'k');
%figure
%plot(histStepE5,cumsum(histE5),'r');

