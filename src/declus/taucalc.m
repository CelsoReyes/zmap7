function tau = taucalc
    %tauclac.m                                         A.Allmann
    %routine to claculate the look ahead time for clustered events
    %gives tau back

    global newcat xk mbg xmeff k1 P
    global top denom deltam bgdiff


    deltam = (1-xk)*mbg(k1)-xmeff;        %delta in magnitude
    if deltam<0
        deltam=0;
    end
    denom  = 10^((deltam-1)*2/3);              %expected rate of aftershocks
    top    = -log(1-P)*bgdiff;
    tau    = top/denom;                        %equation out of Raesenberg paper

