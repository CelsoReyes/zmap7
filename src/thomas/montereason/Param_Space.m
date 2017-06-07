function[] = Param_Space(Cat)

lTaumin = [1];
lTaumax = [10];
lP = [.95];
lXk = [.4];
lXmeff = [3];
lRfact = [10];
lErr = [2];
lDerr = [5];



%% loop for P

resFileOut = 'decResP';
parmFileOut = 'decParmP';
P_Sim = .8:.01:1;
numSim = length(P_Sim);


for simNum = 1:numSim
    [declusCat] = ReasenbergDeclus(lTaumin,lTaumax,lXk,lXmeff,P_Sim(simNum),lRfact,lErr,lDerr,Cat);
    decResult(simNum) = {declusCat};
    save(resFileOut,'decResult');

    monteParms(simNum) = {[lTaumin;lTaumax;lP;lXk;lXmeff;lRfact;lErr;lDerr]};
    save(parmFileOut,'monteParms');
    disp(num2str(simNum));
end


%% loop for Taumin

resFileOut = 'decResTmin';
parmFileOut = 'decParmTmin';
T_Sim = .2:.1:5;
numSim = length(T_Sim);


for simNum = 1:numSim
    [declusCat] = ReasenbergDeclus(T_Sim(simNum),lTaumax,lXk,lXmeff,lP,lRfact,lErr,lDerr,Cat);
    decResult(simNum) = {declusCat};
    save(resFileOut,'decResult');

    monteParms(simNum) = {[lTaumin;lTaumax;lP;lXk;lXmeff;lRfact;lErr;lDerr]};
    save(parmFileOut,'monteParms');
    disp(num2str(simNum));
end

%% loop for Taumax

resFileOut = 'decResTmax';
parmFileOut = 'decParmTmax';
T_Sim = 1:1:20;
numSim = length(T_Sim);


for simNum = 1:numSim
    [declusCat] = ReasenbergDeclus(lTaumin,T_Sim(simNum),lXk,lXmeff,lP,lRfact,lErr,lDerr,Cat);
    decResult(simNum) = {declusCat};
    save(resFileOut,'decResult');

    monteParms(simNum) = {[lTaumin;lTaumax;lP;lXk;lXmeff;lRfact;lErr;lDerr]};
    save(parmFileOut,'monteParms');
    disp(num2str(simNum));
end

%% loop for rFact

resFileOut = 'decRes_rFact';
parmFileOut = 'decParm_rFact';
R_Sim = 0:1:40;
numSim = length(R_Sim);


for simNum = 1:numSim
    [declusCat] = ReasenbergDeclus(lTaumin,lTaumax,lXk,lXmeff,lP,R_Sim(simNum),lErr,lDerr,Cat);
    decResult(simNum) = {declusCat};
    save(resFileOut,'decResult');

    monteParms(simNum) = {[lTaumin;lTaumax;lP;lXk;lXmeff;lRfact;lErr;lDerr]};
    save(parmFileOut,'monteParms');
    disp(num2str(simNum));
end

%% loop for xK

resFileOut = 'decRes_xk';
parmFileOut = 'decParm_xk';
Xk_Sim = 0:.1:1;
numSim = length(Xk_Sim);


for simNum = 1:numSim
    [declusCat] = ReasenbergDeclus(lTaumin,lTaumax,Xk_Sim(simNum),lXmeff,lP,lRfact,lErr,lDerr,Cat);
    decResult(simNum) = {declusCat};
    save(resFileOut,'decResult');

    monteParms(simNum) = {[lTaumin;lTaumax;lP;lXk;lXmeff;lRfact;lErr;lDerr]};
    save(parmFileOut,'monteParms');
    disp(num2str(simNum));
end

