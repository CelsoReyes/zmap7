function [rResult] = relm_HypothesisTest(vRatesH, vRatesN, nNumberSimulation, fMagThreshold)
%RELMTEST
%script to test two earthqauake rate hypotheses using earthquake data
%
% park1=vRatesH;
% park2=vRatesN;
% clear test null;
%     xmin(i)=park1(j,1);
%     xmax(i)=park1(j,2);
%     ymin(i)=park1(j,3);
%     ymax(i)=park1(j,4);
%     zmin(i)=park1(j,5);
%     zmax(i)=park1(j,6);
%     magmin(i)=park1(j,7);
%     magmax(i)=park1(j,8);
%     lamda1(i)=park1(j,9);
%     weight(i)=park1(j,10);
% Get the numbers of observed earthquakes per bin
vNumberQuake = vRatesH(:,11);
% Get the lower magnitude-limits per bin
vMagMin = vRatesH(:,7);
% Get the forecasted numbers of events per bin
vLambdaH = vRatesH(:,9);
vLambdaN = vRatesN(:,9);
% Get the weightings per bins
vWeightH = vRatesH(:,10);
vWeightN = vRatesN(:,10);
vWeightCombined = vWeightH .* vWeightN .* (vMagMin > fMagThreshold);

% Remove rows of matrix for which weight is zero
[nRow, nColumn] = size(vRatesH);
nNewIndex = 0;
for nCnt = 1:nRow
  if vWeightCombined(nCnt)>0
    nNewIndex = nNewIndex + 1;
    vWeight(nNewIndex) = vWeightCombined(nCnt);
    vNumberQuakeSel(nNewIndex) = vNumberQuake(nCnt);
    vLambdaHSel(nNewIndex) = vLambdaH(nCnt);
    vLambdaNSel(nNewIndex) = vLambdaN(nCnt);
    mmin(nNewIndex) = vMagMin(nCnt);
  end
end

% Get the number of events (weighted)
vNumberQuake = vWeight .* vNumberQuakeSel;
nNumberQuake = sum(vNumberQuake);

% Weight the important columns
vLambdaH = vWeight .* vLambdaHSel;
vLambdaN = vWeight .* vLambdaNSel;
% Garbage collection
clear vRatesH vRatesN vLambdaHSel vLambdaNSel vNumberQuakeSel vMagMin vWeightCombined vWeightH vWeightN;

%make a weighted magnitude-frequency plot
%
% mf=[mmin;vNumberQuake;vLambdaH;vLambdaN]';
% mfsort=sortrows(mf);
% mag=mfsort(:,1);
%
% Fobs=flip(cumsum(flip(mfsort(:,2))));
% Fth1=flip(cumsum(flip(mfsort(:,3))));
% Fth2=flip(cumsum(flip(mfsort(:,4))));
% figure%(1)
% semilogy(mag,Fobs,'r',mag,Fth1,'g',mag,Fth2,'b');
% grid;
% axis([3,8,.0001,100]);
%
%    Evaluate whether total number of quakes is consistent with H1
%
%
Nhat=sum(vLambdaH);
peq=poisspdf(nNumberQuake, Nhat); % probability of exactly Nquake
Ple=poisscdf(nNumberQuake, Nhat); % probability of less than or equal to Nquake
Pless=Ple-peq;              % probability of less than Nquake
Pmore=1-Ple;                 % probability of more than Nquake
rResult.P_H_Equal = peq;
rResult.P_H_Less = Pless;
rResult.P_H_More = Pmore;
rResult.Nhat_H = Nhat;
lamcum1=cumsum(vLambdaH)/rResult.Nhat_H;
%   Evaluate whether total number of quakes is consistent with H2
Nhat=sum(vLambdaN);
peq=poisspdf(nNumberQuake, Nhat); % probability of exactly Nquake
Ple=poisscdf(nNumberQuake, Nhat); % probability of less than or equal to Nquake
Pless=Ple-peq;              % probability of less than Nquake
Pmore=1-Ple;                 % probability of more than Nquake
rResult.P_N_Equal = peq;
rResult.P_N_Less = Pless;
rResult.P_N_More = Pmore;
rResult.Nhat_N = Nhat;
lamcum2=cumsum(vLambdaN)/rResult.Nhat_N;
%
%   simulate catalogs according to H1,
%   and evaluate likelihood scores of nsquake1 and real catalog using lamda1 and lamda2
%
try
  nsquake=simulate(nNumberQuake, vLambdaH, nNumberSimulation);
  [rResult.LLR_H, rResult.fRank11, rResult.fRank12] = Rtest(vLambdaH, vLambdaN, vNumberQuake, nsquake, vWeight);
catch
  rResult.LLR_H = nan;
  rResult.fRank11 = nan;
  rResult.fRank12 = nan;
end
%
%   simulate catalogs according to H2,
%   and evaluate likelihood scores of nsquake1 and real catalog using lamda1 and lamda2
%
try
  nsquake=simulate(nNumberQuake, vLambdaN, nNumberSimulation);
  [rResult.LLR_N, rResult.fRank21, rResult.fRank22] = Rtest(vLambdaH, vLambdaN, vNumberQuake, nsquake, vWeight);
catch
  rResult.LLR_N = nan;
  rResult.fRank21 = nan;
  rResult.fRank22 = nan;
end
%
%Plot cumulative likelihood scores for two hypotheses
%
rResult.fAlpha = sum(rResult.LLR_N > 0)/nNumberSimulation;
rResult.fBeta = sum(rResult.LLR_H < 0)/nNumberSimulation;
%index=[1:nNumberSimulation]/nNumberSimulation;
%x=[0,0];y=[0,1];
%figure_w_normalized_uicontrolunits(2);
%plot(rResult.LLR_H,index,'g',rResult.LLR_N,index,'r',x,y,'b')';
%xlabel('Likelihood ratio (Variable b/Constant b)')';
%ylabel('Fraction of cases');
%title('Green assumes variable-b hypothesis; Red assumes constant=b hypothesis');
% nNumberQuake, Nhat1,Nhat2,P1_less,P1_more,P2_less,P2_more, alpha, beta, rank11,rank12, rank21, rank22
rResult.nNumberQuake = nNumberQuake;
rResult.nNumberSimulation = nNumberSimulation;

