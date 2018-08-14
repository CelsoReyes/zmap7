function[] = Param_Space(Cat)

    
rdc= ReasenbergDeclusterClass(Cat, ....
    'AutoShowPlots',false,'DelayProcessing',true,'InteractiveMode',false);

lTaumin     = 1;
lTaumax     = 10;
lP          = .95;
lXk         = .4;
lXmeff      = 3;
lRfact      = 10;
lErr        = 2;
lDerr       = 5;

rdc.taumin  = lTaumin;
rdc.taumax  = lTaumax;
rdc.P       = lP;
rdc.xk      = lXk;
rdc.xmeff   = lXmeff;
rdc.rfact   = lRfact;
rdc.err     = lErr;
rdc.derr    = lDerr;

%% loop for P

resFileOut = 'decResP';
parmFileOut = 'decParmP';
P_Sim = .8:.01:1;
numSim = length(P_Sim);


for simNum = 1:numSim
    rdc.P = P_sim(simNum);
    [declusCat] = rdc.ReasenbergDeclus();
    decResult(simNum) = {declusCat};
    save(resFileOut,'decResult');

    monteParms(simNum) = {[rdc.taumin;rdc.taumax;rdc.P;rdc.xk;rdc.xmeff;rdc.rfact;rdc.err;rdc.derr]};
    save(parmFileOut,'monteParms');
    disp(num2str(simNum));
end

rdc.P = lTauP;

%% loop for Taumin

resFileOut = 'decResTmin';
parmFileOut = 'decParmTmin';
T_Sim = .2:.1:5;
numSim = length(T_Sim);


for simNum = 1:numSim
    rdc.taumin = T_Sim(simNum);
    [declusCat] = rdc.ReasenbergDeclus();
    decResult(simNum) = {declusCat};
    save(resFileOut,'decResult');

    monteParms(simNum) = {[rdc.taumin;rdc.taumax;rdc.P;rdc.xk;rdc.xmeff;rdc.rfact;rdc.err;rdc.derr]};
    save(parmFileOut,'monteParms');
    disp(num2str(simNum));
end

rdc.taumin = lTaumin;

%% loop for Taumax

resFileOut = 'decResTmax';
parmFileOut = 'decParmTmax';
T_Sim = 1:1:20;
numSim = length(T_Sim);


for simNum = 1:numSim
    rdc.taumax = T_Sim(simNum);
    [declusCat] = rdc.ReasenbergDeclus();
    decResult(simNum) = {declusCat};
    save(resFileOut,'decResult');

    monteParms(simNum) = {[rdc.taumin;rdc.taumax;rdc.P;rdc.xk;rdc.xmeff;rdc.rfact;rdc.err;rdc.derr]};
    save(parmFileOut,'monteParms');
    disp(num2str(simNum));
end
rdc.taumax  = lTaumax;

%% loop for rFact

resFileOut = 'decRes_rFact';
parmFileOut = 'decParm_rFact';
R_Sim = 0:1:40;
numSim = length(R_Sim);


for simNum = 1:numSim
    rdc.rfact = R_Sim(simNum);
    [declusCat] = rdc.ReasenbergDeclus();
    decResult(simNum) = {declusCat};
    save(resFileOut,'decResult');

    monteParms(simNum) = {[rdc.taumin;rdc.taumax;rdc.P;rdc.xk;rdc.xmeff;rdc.rfact;rdc.err;rdc.derr]};
    save(parmFileOut,'monteParms');
    disp(num2str(simNum));
end

%% loop for xK

resFileOut = 'decRes_xk';
parmFileOut = 'decParm_xk';
Xk_Sim = 0:.1:1;
numSim = length(Xk_Sim);


for simNum = 1:numSim
    rdc.xk = Xk_Sim(simNum);
    [declusCat] = rdc.ReasenbergDeclus();
    decResult(simNum) = {declusCat};
    save(resFileOut,'decResult');

    monteParms(simNum) = {[rdc.taumin;rdc.taumax;rdc.P;rdc.xk;rdc.xmeff;rdc.rfact;rdc.err;rdc.derr]};
    save(parmFileOut,'monteParms');
    disp(num2str(simNum));
end

