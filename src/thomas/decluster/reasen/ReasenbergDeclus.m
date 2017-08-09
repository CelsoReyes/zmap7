function[declustered_cat, is_mainshock] = ReasenbergDeclus(taumin,taumax,xk,xmeff,P,rfact,err,derr,mycat)
% declus.m                                A.Allmann
% main decluster algorithm
% modified version, uses two different circles for already related events
% works on mycat
% different clusters stored with respective numbers in clus
% Program is based on Raesenberg paper JGR;Vol90;Pages5479-5495;06/10/85
%

% variables given by inputwindow
%
% rfact  is factor for interaction radius for dependent events (default 10)
% xmeff  is "effective" lower magnitude cutoff for catalog,it is raised
%         by a factor xk*cmag1 during clusters (default 1.5)
% xk     is the factor used in xmeff    (default .5)
% taumin is look ahead time for not clustered events (default one day)
% taumax is maximum look ahead time for clustered events (default 10 days)
% P      to be P confident that you are observing the next event in
%        the sequence (default is 0.95)



%basic variables used in the program
%
% rmain  interaction zone for not clustered events
% r1     interaction zone for clustered events
% rtest  radius in which the program looks for clusters
% tau    look ahead time
% tdiff  time difference between jth event and biggest eq
% mbg    index of earthquake with biggest magnitude in a cluster
% k      index of the cluster
% k1     working index for cluster

%routine works on mycat

report_this_filefun(mfilename('fullpath'));



%declaration of global variables
%
% global mycat clus rmain r1 eqtime              %catalogs
% global  a                                       %catalogs
% global k k1 bg mbg bgevent equi bgdiff          %indices
% global ltn                                      %variable to shorten code
% global clust clustnumbers cluslength            %used in fnBuildclu
% global faults coastline main mainfault name
% global xmeff xk rfact taumin taumax P
% global err derr ijma 

bg=[];k=[];k1=[];mbg=[];bgevent=[];equi=[];bgdiff=[];clust=[];clustnumbers=[];
cluslength=[];rmain=[];r1=[];


man =[taumin;taumax;xk;xmeff;P;rfact;err;derr];

[rmain,r1]=funInteract(mycat,rfact);                     %calculation of interaction radii

%calculation of the eq-time relative to 1902
eqtime=clustime(mycat);

%variable to store information wether earthquake is already clustered
clus = zeros(1,mycat.Count);

k = 0;                                %clusterindex

ltn=mycat.Count-1;

% wai = waitbar(0,' Please Wait ...  ');
% set(wai,'NumberTitle','off','Name','Decluster - Percent done');
% drawnow

%for every earthquake in mycat, main loop
for i = 1:ltn
%    i
   % variable needed for distance and timediff
   j=i+1;
   k1=clus(i);

   % attach interaction time
   if k1~=0                          % if i is already related with a cluster
      if mycat(i,6)>=mbg(k1)         % if magnitude of i is biggest in cluster
         mbg(k1)=mycat(i,6);         %set biggest magnitude to magnitude of i
         bgevent(k1)=i;                  %index of biggest event is i
         tau=taumin;
      else
         bgdiff=eqtime(i)-eqtime(bgevent(k1));
         tau = funTaucalc(xk,mbg,k1,xmeff,bgdiff,P);
         if tau>taumax
            tau=taumax;
         end
         if tau<taumin
            tau=taumin;
         end
      end
   else
      tau=taumin;
   end

   %extract eqs that fit interation time window
   [tdiff,ac]=funTimediff(j,i,tau,clus,eqtime);


   if size(ac)~=0   %if some eqs qualify for further examination

      if k1~=0                       % if i is already related with a cluster
         tm1=find(clus(ac)~=k1);       %eqs with a clustnumber different than i
         if ~isempty(tm1)
            ac=ac(tm1);
         end
      end
      if tau==taumin
         rtest1=r1(i);
         rtest2=0;
      else
         rtest1=r1(i);
         rtest2=rmain(bgevent(k1));
      end

      %calculate distances from the epicenter of biggest and most recent eq
      if k1==0
         [dist1,dist2]=funDistance(i,i,ac,mycat,err,derr);
      else
         [dist1,dist2]=funDistance(i,bgevent(k1),ac,mycat,err,derr);
      end
      %extract eqs that fit the spatial interaction time
      sl0=find(dist1<= rtest1 | dist2<= rtest2);

      if size(sl0)~=0    %if some eqs qualify for further examination
         ll=ac(sl0);       %eqs that fit spatial and temporal criterion
         lla=ll(find(clus(ll)~=0));   %eqs which are already related with a cluster
         llb=ll(find(clus(ll)==0));   %eqs that are not already in a cluster
         if ~isempty(lla)            %find smallest clustnumber in the case several
            sl1=min(clus(lla));            %numbers are possible
            if k1~=0
               k1= min([sl1,k1]);
            else
               k1 = sl1;
            end
            if clus(i)==0
               clus(i)=k1;
            end
            %merge all related clusters together in the cluster with the smallest number
            sl2=lla(find(clus(lla)~=k1));
            for j1=[i,sl2]
               if clus(j1)~=k1
                  sl5=find(clus==clus(j1));
                  tm2=length(sl5);
                  clus(sl5)=k1*ones(1,tm2);
               end
            end
         end

         if k1==0                    %if there was neither an event in the interaction
            k=k+1;                         %zone nor i, already related to cluster
            k1=k;
            clus(i)=k1;
            mbg(k1)=mycat(i,6);
            bgevent(k1)=i;
         end

         if size(llb)>0                   %attach clustnumber to events not already
            clus(llb)=k1*ones(1,length(llb));  %related to a cluster
         end

      end                          %if ac
   end                           %if sl0
end                            %for loop

if ~find(clus~=0)
    return
else
   [cluslength,bgevent,mbg,bg,clustnumbers] = funBuildclu(mycat,bgevent,clus,mbg,bg);  
   [declustered_cat,is_mainshock] = funBuildcat(mycat,clus,bg,bgevent);   %new catalog for main program

end


