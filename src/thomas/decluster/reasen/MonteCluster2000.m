function [declusCat,mNumDeclus] = MonteCluster2000(numSim,Cat,mRaParam)
%%
% by van Stiphout, Thomas
% based on MonteReasenberg.m
% Created: 14. Feb. 2007
%
%
% Wrapper function to do Monte Carlo simulations of the
% input parameters into the Reasenberg Declustering algorithm
%
%%

resFileOut = 'DeclusRes';
parmFileOut = 'DeclusParms';
mNumDeclus=[];

%  default values
dfTaumin = 1;
dfTaumax = 10;
dfP = 0.95;
dfXk = 0.5;
dfXmeff = 2.5;
dfRfact = 10;
dfErr=1.5;
dfDerr=2;

%%
% set Default ranges for Reasenberg input variables and find their range
% raTaumin = [.5 2.5];
% raTaumax = [3 20];
% raP = [.9 .999];
% raXk = [0.4 0.6];
% raXmeff = [1.8 2.0];
% raRfact = [5 20];
% raErr = [2 4];
% raDerr = [4 6];


% set Default ranges for Reasenberg input variables and find their range
raTaumin = [mRaParam(1,:)]; % [1 1];
raTaumax = [mRaParam(2,:)]; %[10 10];
raP = [mRaParam(3,:)]; %[0.95 .95];
raXk = [mRaParam(4,:)]; %[0.5 0.5];
raXmeff = [mRaParam(5,:)]; %[2.0 2.0];
raRfact = [mRaParam(6,:)]; %[10 10];
raErr = [mRaParam(7,:)]; %[1.5 1.5];
raDerr = [mRaParam(8,:)]; %[2  2];


tauminDiff = (raTaumin(2) - raTaumin(1));
taumaxDiff = (raTaumax(2) - raTaumax(1));
pDiff = (raP(2) - raP(1));
xkDiff = (raXk(2) - raXk(1));
xmeffDiff = (raXmeff(2) - raXmeff(1));
rfactDiff = (raRfact(2) - raRfact(1));
%errDiff = raErr(2) - raErr(1);
%derrDiff = raDerr(2) - raDerr(1);

% add column for independence probability (actually will just be number of
% times the event has appeared in a catalogue (will need to divide by
% simNum to get P
Cat(:,10) = 0;

% set the rand number generator state
rand('state',sum(100*clock));

% simulate parameter values and run the delcustering code
randNum = rand(1,8);
lTaumin = raTaumin(1) + tauminDiff*randNum(1);
lTaumax = raTaumax(1) + taumaxDiff*randNum(2);
lP = raP(1) + pDiff*randNum(3);
lXk = raXk(1) + xkDiff*randNum(4);
lXmeff = raXmeff(1) + xmeffDiff*randNum(5);
%     lXmeff = raXmeff(1) ;
lRfact = raRfact(1) + rfactDiff*randNum(6);
%lErr = raErr(1) + errDiff*randNum(7);
%lDerr = raDerr(1) + derrDiff*randNum(8);
lErr = raErr(1);
lDerr = raDerr(1);
% call function for reasenberg declustering code cluster200x
[is_mainshock, vClus] = cluster200x(lTaumin,lTaumax,lXk,lXmeff,lP,lRfact,lErr,lDerr,Cat);
% cluster200x(81,92,3.0,10,2880,2880,14400,0.99,0.5,Cat)

Cat(is_mainshock,10) = Cat(is_mainshock,10) + 1;
nIst=zeros(length(Cat),1);
nIst(is_mainshock)=1;
nIst=logical(nIst);
mNumDeclus=[mNumDeclus,(nIst==1)];
%decResult(simNum) = {Cat};
save(resFileOut,'Cat');

monteParms = {[lTaumin;lTaumax;lP;lXk;lXmeff;lRfact;lErr;lDerr]};
save(parmFileOut,'monteParms');
%     disp(num2str(cd));

declusCat=Cat(is_mainshock,:);
% fid=fopen('TestReasenberg','a')
% fprintf(fid,'%6.4f ',size(declusCat), lTaumax,lXk,lXmeff,lP,lRfact,lErr,lDerr)
% fprintf(fid,'\n');
% fclose(fid)
