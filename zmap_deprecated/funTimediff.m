function [tdiff, ac]  = funTimediff(j,ci,tau,clus, eqtime)
    % FUNTIMEDIFF calculates the time difference between the ith and jth event
    % works with variable eqtime from function CLUSTIME
    % gives the indices ac of the eqs not already related to cluster k1
    %
    % [tdiff, ac]  = funTimediff(j,ci,tau,clus, eqtime) where:
    %   j: index
    %   ci: index [constant]
    %   tau: look ahead time
    %   clus: number for this cluster
    %   eqtime: list of event times
    %   
    %  outputs: 
    %   tdiff:
    %   ac: indices of eqs not already related to cluster k1
    %
    %                                         A.Allmann
    
    tdiff(1)=0;
    n=1;
    ac=[];
    
    
    %fprintf('funTimediff(%d, %d, %d, clus, eqtime)\n',j,ci,tau);
    %% this has been tested, so right-or-wrong it matches the original output. -CGRs
    tdiffs = eqtime(j:end) - eqtime(ci); % start with jth event
    j2=j+ sum(tdiffs<tau)+1;
    origtdiffs=[0 ;tdiffs;tau];
    tdiffs(tdiffs >= tau) = []; % get rid of events at or past look ahead time.
    tdiffs = [0; tdiffs; tau]; % because... (?) 
    if j2 > numel(clus)+1,j2=j2-1;end
    
    %%
    
    %{
    while origtdiffs(n)<tau%tdiff(n) < tau       % while time difference smaller than look ahead time
        assert(origtdiffs(n)==tdiff(n))
        if j <= numel(clus)     %to avoid problems at end of catalog
            n=n+1;
            tdiff(n)=eqtime(j)-eqtime(ci);
            j=j+1;
            
        else
            n=n+1;
            tdiff(n)=tau;
        end
        
        
    end
    %}
    k2=clus(ci);
    j=j-2;
    if k2~=0
        if ci~=j
            ac = (find(clus(ci+1:j)~=k2))+ci;      %indices of eqs not already related to cluster k1
        end
    else
        if ci~=j                                    %if no cluster is found already
            ac = ci+1:j;
        end
    end
end