function  [LLR, rank1,rank2] = Rtest(lamda1, lamda2, nquake, nsquake, weight)
%
%   [LLR,rank1,rank2] = Rtest(lamda1, lamda2, nquake, nsquake, weight)
%   lamda is a vector or poisson rates, one for each of n cells
%   nquake is a vector whose elements are the observed number of events in each cell
%   nsquake is a matrix of column vectors of simulated numbers of events per cell
%
%   make sure lamda1,lamda2,wieght, and nquake  are a column vectors;
%
[n,m]=size(lamda1);if  n == 1; lamda1 = lamda1'; end
[n,m]=size(lamda2);if  n == 1; lamda2 = lamda2'; end
[n,m]=size(weight);if  n == 1; weight = weight'; end
[n,m]=size(nquake);if  n == 1; nquake = nquake'; end
%
%    Evaluate likilihood for real catalog
%
L1 = weight'*(log(poisspdf(nquake,lamda1)));
L2 = weight'*(log(poisspdf(nquake,lamda2)));%
%   score the artificial catalogs
[nquake,nsim]=size(nsquake);
lammat = lamda1*ones(1,nsim); %makes lamda into a matrix the size of nsquake
Lsim1 = weight'*log(poisspdf(nsquake,lammat))-L1; %vector of scores of simulations, relative to observed
%Lsim1 = sort(Lsim1);
rank1 = sum(Lsim1<0)/nsim;

lammat = lamda2*ones(1,nsim); %makes lamda into a matrix the size of nsquake
Lsim2 = weight'*log(poisspdf(nsquake,lammat))-L2;
%Lsim2 = sort(Lsim2);
rank2 = sum(Lsim2<0)/nsim;
LLR = sort(Lsim1-Lsim2); %log likelihood ratio of H1 over H2
