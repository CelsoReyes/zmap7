function [declusCat,mNumDeclus] = MonteMarsan(numSim,Cat)
    % Monte Carlo Simulation for Model-independent stochastic declustering / misd
%%
% by van Stiphout, Thomas
% based on MonteReasenberg.m
% Created: 14. Feb. 2007
%
%
% Wrapper function to do Monte Carlo simulations of the
% input parameters into the Reasenberg Declustering algorithm
%
% %%
%
resFileOut = 'DeclusRes';
parmFileOut = 'DeclusParms';
mNumDeclus=[];

% add column for independence probability (actually will just be number of
% times the event has appeared in a catalogue (will need to divide by
% simNum to get P

Cat(:,10) = 0;

% set the rand number generator state
rng('shuffle');

% simulate parameter values and run the delcustering code
for simNum = 1:numSim

    [is_mainshock(:,simNum), vM_] = misd(Cat);

    Cat(is_mainshock(:,simNum),10) = Cat(is_mainshock(:,simNum),10) + 1;
    nIst=zeros(length(Cat),1);
    nIst(is_mainshock(:,simNum))=1;
    nIst=logical(nIst);
    mNumDeclus=[mNumDeclus,(nIst==1)];

end
if numSim > 1
    vSel=(sum(is_mainshock')' > 0.9*numSim);
    declusCat=Cat(vSel,:);
else
    declusCat=Cat(is_mainshock,:);
end
