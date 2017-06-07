%maincheck.m
%check whether an earthquake is followed by an equal or bigger sized
%eq in a certain distance
%Last change    11/95 Alexander Allmann
%

%TODO Delete, it was error-full -CGR
global newcat err derr;
newcat=a;
n=0;               %counter
n1=0;
mcut1=5;           %default for magnitudes of interest
mcut2=5;           %default for magnitudes of eqs following first event
dist=30;           %distance in which programs looks for following events
tcut1=30;          %time intervall in which program searches for other events
err=2;derr=2;
newcat=newcat(:,6)>mcut1;
backnewcat=newcat;
eqtime=clustime(1);      %onset time of earthquakes

for i=1:length(newcat(:,1)

    tmp=find((eqtime-eqtime(i))>0 & (eqtime - eqtime(i))<tcut1);
    if ~isempty(tmp)
        tmp2=newcat(tmp,:));
        tmp3=find(tmp2(:,6)>=newcat(i,6));
        if ~isempty(tmp3)
            newcat=[newcat(i,:);tmp2(tmp3,:);
                [dist1, dist2] = distance(1,1,2:length(newcat(:,1)));
                tmp4=dist1<dist;
                if ~isempty(tmp4);
                n=n+1;
                if length(tmp4)>1
                    n1=n1+1;                %more than one bigger event follows in sequence
                end
                end
                newcat=backnewcat;
        end
    end
end
n
n1
