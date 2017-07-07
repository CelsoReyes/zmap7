%RELMTEST
%script to test two earthqauake rate hypotheses using earthquake data
%
region='Northern California Aftershock model';
nsim=100;
mt=2;
 park1=vRatesH;
 park2=vRatesN;
%load H1;
%load H2;
%park1=H1; %Hypothesis with variable b-values
%park2=H2; %Null hypothesis, uniform b-value
clear test null;
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
nquake=park1(:,11);
[m,n] = size(park1);
magmin=park1(:,7);
lamda1=park1(:,9);
lamda2=park2(:,9);
weight1=park1(:,10);
weight2=park2(:,10);
weight=weight1.*weight2.*(magmin>mt);
%
% Remove rows of matrix for which weight is zero
%
j=0;
for i = 1:m
    if weight(i)>0
        j=j+1;
        w(j)=weight(i);
        nq(j)=nquake(i);
        lam1(j)=lamda1(i);
        lam2(j)=lamda2(i);
        mmin(j)=magmin(i);
    end
end
nq=w.*nq;
Nquake=sum(nq);
lam1=w.*lam1;
lam2=w.*lam2;
clear park1 park2 lamda1 lamda2 nquake magmin weight weight1 weight2;
%
%make a weighted magnitude-frequency plot
%
mf=[mmin;nq;lam1;lam2]';
mfsort=sortrows(mf);
mag=mfsort(:,1);


Fobs=flip(cumsum(flip(mfsort(:,2))));
Fth1=flip(cumsum(flip(mfsort(:,3))));
Fth2=flip(cumsum(flip(mfsort(:,4))));
figure%(1)
semilogy(mag,Fobs,'r',mag,Fth1,'g',mag,Fth2,'b');
grid;
axis([3,8,.0001,100]);


%
%    Evaluate whether total number of quakes is consistent with H1
%
%
Nhat=sum(lam1)
peq=poisspdf(Nquake, Nhat); % probability of exactly Nquake
Ple=poisscdf(Nquake, Nhat); % probability of less than or equal to Nquake
Pless=Ple-peq;              % probability of less than Nquake
Pmore=1-Ple                 % probability of more than Nquake
P1_equal=peq;
P1_less=Pless;
P1_more=Pmore;
Nhat1=Nhat;
lamcum1=cumsum(lam1)/Nhat1;

%   Evaluate whether total number of quakes is consistent with H2

Nhat=sum(lam2)
peq=poisspdf(Nquake, Nhat); % probability of exactly Nquake
Ple=poisscdf(Nquake, Nhat); % probability of less than or equal to Nquake
Pless=Ple-peq;              % probability of less than Nquake
Pmore=1-Ple                 % probability of more than Nquake
P2_equal=peq;
P2_less=Pless;
P2_more=Pmore;
Nhat2=Nhat;
lamcum2=cumsum(lam2)/Nhat2;
%
%   simulate catalogs according to H1,
%   and evaluate likelihood scores of nsquake1 and real catalog using lamda1 and lamda2
%
nsquake=simulate(Nquake,lam1, nsim);
[LLR1, rank11,rank12] = Rtest(lam1, lam2, nq, nsquake, w);
%
%   simulate catalogs according to H2,
%   and evaluate likelihood scores of nsquake1 and real catalog using lamda1 and lamda2
%
nsquake=simulate(Nquake,lam2, nsim);
[LLR2, rank21,rank22] = Rtest(lam1, lam2, nq, nsquake, w);
%
%Plot cumulative likelihood scores for two hypotheses
%
alpha = sum(LLR2>0)/nsim
beta = sum(LLR1<0)/nsim
index=[1:nsim]/nsim;
x=[0,0];y=[0,1];
figure_w_normalized_uicontrolunits(2);
plot(LLR1,index,'g',LLR2,index,'r',x,y,'b')';
xlabel('Likelihood ratio (Variable b/Constant b)')';
ylabel('Fraction of cases');
title('Green assumes variable-b hypothesis; Red assumes constant=b hypothesis');

region, mt,Nquake, Nhat1,Nhat2,P1_less,P1_more,P2_less,P2_more, alpha, beta, rank11,rank12, rank21, rank22
%[rank1,rank2]
%[Nhat1,Nhat2]
%[P1_less, P2_less]
%[P1_more, P2_more]




