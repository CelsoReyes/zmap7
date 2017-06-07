% Routine to compute the b-val of two sequences
% by maximum likelihood estimation (use with compare)
% Ref:   Shi and Bolt, BSSA, 72, 1677-1687, 1982.

report_this_filefun(mfilename('fullpath'));

l = newcat(:,3) > t1p(1) & newcat(:,3) < t2p(1);
n = length(newcat(l,:));
mean_m1 = mean(newcat(l,6));
b1 = (1/(mean_m1-min(newcat(l,6))))*log10(exp(1));
sig1 = (sum((newcat(l,6)-mean_m1).^2))/(n*(n-1));
sig1 = sqrt(sig1);
sig1 = 2.30*sig1*b1^2;            % standard deviation
disp ([' b-value segment 1 = ' num2str(b1) ]);
disp ([' standard dev b_val_1 = ' num2str(sig1) ]);

l = newcat(:,3) > t3p(1) & newcat(:,3) < t4p(1);
n = length(newcat(l,:));
mean_m2 = mean(newcat(l,6));
b2 = (1/(mean_m2-min(newcat(l,6))))*log10(exp(1));
sig2 = (sum((newcat(l,6)-mean_m2).^2))/(n*(n-1));
sig2 = sqrt(sig2);
sig2 = 2.30*sig2*b2^2;           % standard deviation
disp ([' b-value segment 2 = ' num2str(b2) ]);
disp ([' standard dev b_val_2 = ' num2str(sig2) ]);

cc = b1/b2;

disp ([' b-val ratio = ' num2str(cc) ]);

