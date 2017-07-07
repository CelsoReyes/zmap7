%Matlab-Script:  plot_diff.m
ev_diff=ev_val2-ev_val;
sig_ev_diff= sign(ev_diff);

%ev_diff_sum=abs(ev_diff)
ev_diff_sum=cumsum(ev_diff')

figure_w_normalized_uicontrolunits(300);
subplot(2,1,1);
bar(mags,ev_diff);
subplot(2,1,2);
bar(mags,sig_ev_diff)



