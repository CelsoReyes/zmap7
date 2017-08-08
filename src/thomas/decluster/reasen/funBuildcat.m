function [othercat,is_mainshock]=funBuildcat(mycat,clus,bg,bgevent)
%builds declustered catalog with equivalent events
% buildcat.m                                A.Allmann

tm1=find(clus==0);    %elements which are not related to a cluster
tmpcat=[mycat.subset(tm1); bgevent]; % builds catalog with biggest events instead

% I am not sure that this is right , may need 10 coloum
                                   %equivalent event
[tm2,i]=sort([tm1';bg']);  %i is the index vector to sort tmpcat


othercat=tmpcat.subset(i);       %sorted catalog,ready to load in basic program

is_mainshock = [tm1';bg'];  %% contains indeces of all cluster mainshocks.  added  12/7/05




