function bgdiff = bgtdiff(ll,llex)
    %bgtdiff.m                                         A.Allmann
    %calculates the time difference between jth and biggest event
    %in an aftershock sequence
    %works with eqtime from function clustime.m
    %gives the indices ac of the eqs not already related to cluster k1
    %Last modification 6/95
    global  eqtime k1 bg mbg

    z=ll(llex);                               %indices of the eqs to examine
    %mbg(k1)=bg(k1);                   %bgdiff not calculated from the last
    %  biggest eq but the first biggest eq
    bgdiff=zeros(length(z),1);
    if bg(k1)~=mbg(k1)                          %if more eqs with biggest magnitude
        tm1 = max(find(z<=mbg(k1)));                 %position of mbg

        if size(tm1)~=0                          %if eqs before mbg(k1)
            bgdiff(1:tm1,1)=eqtime(z(1:tm1),1)-eqtime(bg(k1));

            if tm1~=length(z)                    %if mbg(k1) is not the last eq to examine
                bgdiff((tm1+1):length(z),1)=eqtime(z((tm1+1):length(z)),1)-eqtime(mbg(k1));
            end

        else                          %bg and mbg are smaller than all indices in z
            bgdiff=eqtime(z)-eqtime(mbg(k1));
        end

    else                              %only one eq with biggest magnitude
        bgdiff=eqtime(z)-eqtime(bg(k1));

    end

