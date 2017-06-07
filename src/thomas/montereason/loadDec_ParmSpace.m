function[] =loadDec_ParmSpace(numSim)

resFileIn = '/home/matt/mProjects/MonteDeclus/Results/decRes_xk.mat';
parmFileIn = '/home/matt/mProjects/MonteDeclus/Results/decParm_xk.mat';

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


figure
%plot(numEvents5,.8:.01:1,'+g');
plot(numEvents5,0:.1:1,'+g');
%plot(numEvents5,1:1:20,'+g');
%plot(numEvents5,.2:.1:5,'+g');
%plot(numEvents5,0:1:40,'+m');


title('XK')
