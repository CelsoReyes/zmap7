function[] = MonteReasenberg(numSim,Cat)

%%
% Wrapper function to do Monte Carlo simulations of the
% input parameters into the Reasenberg Declustering algorithm
%%

% if ~exist('FileOut','var')
%     disp(['You must provide the output results filename!'])
%     return
% end
resFileOut = 'Results/DeclusResFixP';
parmFileOut = 'Results/DeclusParmsFixP';

%  default values
dfTaumin = 1;
dfTaumax = 10;
dfP = 0.95;
dfXk = 0.5;
dfXmeff = 1.5;
dfRfact = 10;
dfErr=1.5;
dfDerr=2;

% %%
% % set Default ranges for Reasenberg input variables and find their range
% raTaumin = [1 10];
% raTaumax = [1 100];
% raP = [.8 1];
% raXk = [0 1];
% raXmeff = [4 4];
% raRfact = [1 20];
% raErr = [.5 5];
% raDerr = [2 5];


%%
% set Default ranges for Reasenberg input variables and find their range
raTaumin = [1 1];
raTaumax = [10 10];
raP = [.8 1.0];
raXk = [.4 .4];
raXmeff = [4 4];
raRfact = [10 10];
raErr = [2 2];
raDerr = [5 5];



tauminDiff = (raTaumin(2) - raTaumin(1));
taumaxDiff = (raTaumax(2) - raTaumax(1));
pDiff = (raP(2) - raP(1));
xkDiff = (raXk(2) - raXk(1));
xmeffDiff = (raXmeff(2) - raXmeff(1));
rfactDiff = (raRfact(2) - raRfact(1));
errDiff = raErr(2) - raErr(1);
derrDiff = raDerr(2) - raDerr(1);

% set the rand number generator state
rng('shuffle');

P_Sim = .8:.01:1;
numP = length(P_Sim);


rdc= ReasenbergDeclusterClass(Cat, ....
    'AutoShowPlots',false,'DelayProcessing',true,'InteractiveMode',false);

% simulate parameter values and run the delcustering code
for simNum = 1:numP

    randNum = rand(1,8);
    rdc.taumin = raTaumin(1) + tauminDiff*randNum(1);
    rdc.taumax = raTaumax(1) + taumaxDiff*randNum(2);
    %lP = raP(1) + pDiff*randNum(3);
    rdc.P = P_Sim(simNum);
    rdc.xk = raXk(1) + xkDiff*randNum(4);
    rdc.xmeff = raXmeff(1) + xmeffDiff*randNum(5);
    rdc.rfact = raRfact(1) + rfactDiff*randNum(6);
    rdc.err = raErr(1) + errDiff*randNum(7);
    rdc.derr = raDerr(1) + derrDiff*randNum(8);

    declusCat = rdc.ReasenbergDeclus();
    %[declusCat] = ReasenbergDeclus(lTaumin,lTaumax,lXk,lXmeff,lP,lRfact,lErr,lDerr,Cat);
    decResult(simNum) = {declusCat};
    save(resFileOut,'decResult');

    monteParms(simNum) = {[rdc.taumin;rdc.taumax;rdc.P;rdc.xk;rdc.xmeff;rdc.rfact;rdc.err;rdc.derr]};
    save(parmFileOut,'monteParms');
    disp(num2str(simNum));
end

