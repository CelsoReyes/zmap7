report_this_filefun(mfilename('fullpath'));

pt = 4;

newt0 = newt2;


lt =  newt2(:,3) >= t0b &  newt2(:,3) <teb-pt ;
%lt =  newt2(:,3) >= 1981 &  newt2(:,3) < 1992 ;

obs = newt2(lt,:);

lt =  newt2(:,3) >= teb-pt &  newt2(:,3) <= teb ;

%lt =  newt2(:,3) >= 1995 &  newt2(:,3) <= 1999.9 ;
pre = newt2(lt,:);


newt2 = obs;
mcperc_ca3;
if isnan(Mc95) == 0 
    magco = Mc95;
elseif isnan(Mc90) == 0 
    magco = Mc90;
else
    [bv magco stan av me mer me2,  pr] =  bvalca3(newt2,1,1);
end
magco = magco+0;
l = obs(:,6) >= magco-0.05;

%[bv magco0 stan av me mer me2,  pr] =  bvalca3(obs(l,:),2,2);
[av4 bv4 stan4 ] =  bmemag(obs(l,:));

av4 = log10(length(obs(l,1))) + bv4*magco;
af = log10(length(obs(l,1))) + 0.85*magco;

tdpre = max(obs(:,3)) - min(obs(:,3));
tr2 = [];

for m = magco:0.1:7
    N = 10^(av4-bv4*m)/tdpre*pt;
    N2 = 10^(af-0.85*m)/tdpre*pt;   % this is with a fixed b =
    tr = (teb-t0b-pt)/(10^(av-bv*m));
    tr2 = [tr2 ; N  m N2];
end

pr = -diff(tr2(:,:),1);
pr = [  NaN NaN NaN ; pr];

% this i sthge observed
l = pre(:,6) > magco;
[px,xxv] = hist(pre(l,6),magco-0.05:0.1:7);

newt2 = newt0;


P = poisspdf(px',pr(:,1));
Pk = poisspdf(px',pr(:,3));

lP = log(P);
l = isinf(lP);
lP(l) = 0;

lPk = log(Pk);
l = isinf(lPk);
lPk(l) = 0;


%disp(['Log likelihood sum: local Tl model: ' num2str(sum(lP)) ' Kagan & Jackson model: ' num2str(sum(lPk)) ])
%str2 = ['Log likelihood sum: local Tl model: ' num2str(sum(lP)) ];
%str3 = ['Kagan & Jackson model: ' num2str(sum(lPk))  ];

dP = sum(lP) - sum(lPk);



