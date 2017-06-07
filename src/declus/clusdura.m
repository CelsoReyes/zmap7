function [dura, foretime,forepercent] = clusdura(j)
    % clusdura.m                                      A.Allmann
    % normaly j should be clustnumbers
    % calculates the duration of the cluster and
    % calculates duration and percentage of foreshock activity
    % Last modification 9/95
    %

    global newcat bg k1 clust cluslength eqtime check1
    check1=j;
    %duration of the cluster
    dura=eqtime(diag(clust(cluslength(j),j)))-eqtime(clust(1,j));

    %foreshock duration and percentage
    foretime=eqtime(bg(j))-eqtime(clust(1,j));
    tmp1=find(dura==0);
    if ~isempty(tmp1)          %if eqs are at the exact same time
        dura(tmp1)=.01*ones(length(tmp1),1);     %give it a duration of one to
    end                                       %avoid an NaN
    forepercent=foretime./dura;
