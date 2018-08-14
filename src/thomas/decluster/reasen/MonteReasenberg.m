function [declusCat,mNumDeclus] = MonteReasenberg(numSim,Cat)

%%
% Wrapper function to do Monte Carlo simulations of the
% input parameters into the Reasenberg Declustering algorithm
%%

% if ~exist('FileOut','var')
%     disp(['You must provide the output results filename!'])
%     return
% end

resFileOut = 'DeclusRes';
parmFileOut = 'DeclusParms';
mNumDeclus=[];

%  default values
dfTaumin = 1;
dfTaumax = 10;
dfP = 0.95;
dfXk = 0.5;
dfXmeff = 1.5;
dfRfact = 10;
dfErr=1.5;
dfDerr=2;

%%
% set Default ranges for Reasenberg input variables and find their range
raTaumin = [.5 2.5];
raTaumax = [3 20];
raP = [.9 .999];
raXk = [0.4 0.6];
raXmeff = [2.7 2.9];
raRfact = [5 20];
raErr = [2 4];
raDerr = [4 6];




tauminDiff = (raTaumin(2) - raTaumin(1));
taumaxDiff = (raTaumax(2) - raTaumax(1));
pDiff = (raP(2) - raP(1));
xkDiff = (raXk(2) - raXk(1));
xmeffDiff = (raXmeff(2) - raXmeff(1));
rfactDiff = (raRfact(2) - raRfact(1));

%% add column for independence probability 
% actually will just be number of times the event has appeared in a catalogue
% (will need to divide by simNum to get P)

Cat(:,10) = 0;

% set the rand number generator state
rng('shuffle');

% simulate parameter values and run the delcustering code
for simNum = 1:numSim

    randNum = rand(1,8);
    lTaumin = raTaumin(1) + tauminDiff*randNum(1);
    lTaumax = raTaumax(1) + taumaxDiff*randNum(2);
    lP = raP(1) + pDiff*randNum(3);
    lXk = raXk(1) + xkDiff*randNum(4);
    lXmeff = raXmeff(1) + xmeffDiff*randNum(5);
    lRfact = raRfact(1) + rfactDiff*randNum(6);
    lErr = raErr(1);
    lDerr = raDerr(1);

    [declusCat,is_mainshock] = ReasenbergDeclus(lTaumin,lTaumax,lXk,lXmeff,lP,lRfact,lErr,lDerr,Cat);


    Cat(is_mainshock,10) = Cat(is_mainshock,10) + 1;
    nIst=zeros(length(Cat),1);
    nIst(is_mainshock)=1;
    nIst=logical(nIst);
    mNumDeclus=[mNumDeclus,(nIst==1)];
    save(resFileOut,'Cat');

    monteParms(simNum) = {[lTaumin;lTaumax;lP;lXk;lXmeff;lRfact;lErr;lDerr]};
    save(parmFileOut,'monteParms');
    disp(num2str(simNum));


end

