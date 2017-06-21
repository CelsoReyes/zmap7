function [tdiff, ac]  = timediff(j,ci,tau,clus,k1,newcat,eqtime)
% timediff.m                                         A.Allmann
% calculates the time difference between the ith and jth event
% works with variable eqtime from function clustime.m
% gives the indices ac of the eqs not already related to cluster k1
% last modification 8/95
% global  clus eqtime k1 newcat

tdiff(1)=0;
n=1;
ac=[];
while tdiff(n) < tau       %while timedifference smaller than look ahead time

 if j <= newcat.Count     %to avoid problems at end of catalog
  n=n+1;
  tdiff(n)=eqtime(j)-eqtime(ci);
  j=j+1;

 else
  n=n+1;
  tdiff(n)=tau;
 end


end
k2=clus(ci);

j=j-2;
if k2~=0
 if ci~=j
  ac = (find(clus(ci+1:j)~=k2))+ci;      %indices of eqs not already related to
 end                                        %cluster k1
else
 if ci~=j                                    %if no cluster is found already
  ac = ci+1:j;
 end
end
