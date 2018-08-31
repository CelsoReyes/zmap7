classdef ReasenbergDeclusterClass < ZmapFunction
    % Reasenberg Declustering codes
    % made from code originally from A.Allman that has chopped up and rebuilt
    
    properties
        taumin  duration    = days(1)   % look ahead time for not clustered events
        taumax  duration    = days(10)  % maximum look ahead time for clustered events
        P                   = 0.95      % confidence level, that you are observing next event in sequence
        xk                  = 0.5       % is the factor used in xmeff
        xmeff               = 1.5       % effective" lower magnitude cutoff for catalog. it is raised by a factor xk*cmag1 during clusters
        rfact               = 10        % factor for interaction radius for dependent events
        err                 = 1.5       % epicenter error
        derr                = 2         % depth error, km
        declustRoutine       = "ReasenbergDeclus";
    end
    
    properties(Constant)
        PlotTag = "ReasenbergDecluster"
        ParameterableProperties = ["taumin", "taumax", "P", "xk","xmeff","rfact","err","derr","declustRoutine"];
    end
    
    methods
        function obj=ReasenbergDeclusterClass(catalog, varargin)
            % BVALGRID 
            % obj = BVALGRID() takes catalog, grid, and eventselection from ZmapGlobal.Data
            %
            % obj = BVALGRID(ZAP) where ZAP is a ZmapAnalysisPkg
            
            obj@ZmapFunction(catalog);
            
            report_this_filefun();
            obj.parseParameters(varargin);
            obj.StartProcess();
        end
        
        function InteractiveSetup(obj)
            
            % make the interface
            
            zdlg = ZmapDialog();
            zdlg.AddHeader('Reasenberg Declustering parameters','FontSize',12);
            zdlg.AddHeader('look-ahead times');
            zdlg.AddDurationEdit('taumin', '(min) for UNclustered events' ,obj.taumin, '<b>TauMin</b> look ahead time for not clustered events');
            zdlg.AddDurationEdit('taumax', '(max) for   clustered events', obj.taumax,  '<b>TauMax</b> maximum look ahead time for clustered events');
            zdlg.AddHeader('');
            zdlg.AddEdit('P',       'Confidence Level',             obj.P,          '<b>P1</b> Confidence level : observing the next event in the sequence');
            zdlg.AddEdit('xk',      'XK factor',                    obj.xk,         '<b>XK</b> factor used in xmeff');
            zdlg.AddEdit('xmeff',   'Effective min mag cutoff',     obj.xmeff,   '<b>XMEFF</b> "effective" lower magnitude cutoff for catalog, during clusters, it is xmeff^{xk*cmag1}');
            zdlg.AddEdit('rfact',   'Interation radius factor:',    obj.rfact,      '<b>RFACT>/b>factor for interaction radius for dependent events');
            zdlg.AddEdit('err',     'Epicenter error',              obj.err,        '<b>Epicenter</b> error');
            zdlg.AddEdit('derr',    'Depth error',                  obj.derr,       '<b>derr</b>Depth error');
            
            [vals, okpressed]=zdlg.Create('Name', 'Reasenberg Declustering');
            if okpressed
                [outputcatalog,details]=declus(catalog,vals);
                assignin('base','declustered_reas',outputcatalog);
                error('hey developer. do something with outputcatalog')
                % TODO do something with the declustered catalog
            end
            
        end
        
        function Results = Calculate(obj)
            calcFn = str2func(obj.declustRoutine);
            [declustered_catalog, misc] = calcFn(obj);
            if nargout == 1
                Results = declustered_catalog;
            end
        end
        
        function [outputcatalog, details] = declus(obj) 
            % DECLUS main decluster algorithm
            % A.Allmann
            % main decluster algorithm
            % modified version, uses two different circles for already related events
            % works on catalog
            % different clusters stored with respective numbers in clus
            % Program is based on Raesenberg paper JGR;Vol90;Pages5479-5495;06/10/85
            %
            %basic variables used in the program
            %
            % rmain_km  interaction zone for not clustered events
            % r1     interaction zone for clustered events
            % rtest  radius in which the program looks for clusters
            % tau    look ahead time
            % tdiff  time difference between jth event and biggest eq
            % mbg    index of earthquake with biggest magnitude in a cluster
            % k      index of the cluster
            % k1     working index for cluster
            %
            % modified by Celso Reyes, 2017
            
            
            report_this_filefun();
            
            % FIXME this apparently can return empty clusters (?)
            
            %declaration of global variables
            %
            global clus % number of the cluster with which this event is associated.
            global rmain_km % interaction zone for mainshock, km
            global r1   % interaction zone if included in a cluster, km
            global eqtime   %time of all earthquakes catalogs
            global k k1 bg mbg bgevent bgdiff          %indices
            global equi %[OUT]
            global clust
            global clustnumbers
            global cluslength %[OUT]
            %  global taumin taumax
            % global xk xmeff P
            
            ZG=ZmapGlobal.Data;
            
            bg=[];
            k1=[];
            mbg=[];
            bgevent=[];
            equi=[];
            bgdiff=[];
            clust=[];
            clustnumbers=[];
            cluslength=[];
            
            [rmain_km, r1]=interaction_zone(obj);   %calculation of interaction radii
            
            %calculation of the eq-time relative to 1902
            eqtime=clustime(obj.RawCatalog);
            
            %variable to store information whether earthquake is already clustered
            clus = zeros(1,obj.RawCatalog.Count);
            
            k = 0;                                %clusterindex
            
            wai = waitbar(0,' Please Wait ...  ');
            set(wai,'NumberTitle','off','Name','Decluster - Percent done');
            drawnow
            
            %for every earthquake in catalog, main loop
            for i = 1: (obj.RawCatalog.Count-1)
                
                if rem(i,50)==0
                    waitbar(i/(obj.RawCatalog.Count-1));
                end
                
                % variable needed for distance and timediff
                k1=clus(i);
                
                % attach interaction time
                if k1~=0                %If i is already related with a cluster
                    if obj.RawCatalog.Magnitude(i)>=mbg(k1) %if magnitude of i is biggest in cluster
                        mbg(k1)=obj.RawCatalog.Magnitude(i);    %set biggest magnitude to magnitude of i
                        bgevent(k1)=i;                  %index of biggest event is i
                        tau=obj.taumin;
                    else
                        bgdiff=eqtime(i)-eqtime(bgevent(k1));
                        tau=clustLookAheadTime(obj.xk,mbg,k1,obj.xmeff,bgdiff,obj.P);
                        tau = min(tau,obj.taumax);
                        tau = max(tau, obj.taumin);
                    end
                else
                    tau=obj.taumin;
                end
                
                %extract eqs that fit interation time window
                [tdiff,ac]=timediff(i+1, i, tau, clus, eqtime);
                
                
                if ~isempty(ac)   %if some eqs qualify for further examination
                    
                    rtest1=r1(i);
                    if tau==obj.taumin
                        rtest2 = 0;
                    else
                        rtest2=rmain_km(bgevent(k1));
                    end
                    
                    if k1~=0                       % if i is already related with a cluster
                        tm1 = clus(ac) ~= k1;       %eqs with a clustnumber different than i
                        if any(tm1)
                            ac=ac(tm1);
                        end
                        bg_ev_for_dist = bgevent(k1);
                    else
                        bg_ev_for_dist = i;
                    end
                    
                    %calculate distances from the epicenter of biggest and most recent eq
                    [dist1,dist2]=distance2(i,bg_ev_for_dist,ac);
                    
                    %extract eqs that fit the spatial interaction time
                    sl0 = dist1<= rtest1 | dist2<= rtest2;
                    
                    if any(sl0)    %if some eqs qualify for further examination
                        ll=ac(sl0);       %eqs that fit spatial and temporal criterion
                        lla=ll(clus(ll)~=0);   %eqs which are already related with a cluster
                        llb=ll(clus(ll)==0);   %eqs that are not already in a cluster
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
                            sl2=lla(clus(lla)~=k1);
                            for j1=[i,sl2]
                                if clus(j1)~=k1
                                    sl5=find(clus==clus(j1));
                                    tm2=length(sl5);
                                    clus(sl5)=k1*ones(1,tm2);
                                end
                            end
                        end
                        
                        if ~k1   %if there was neither an event in the interaction zone nor i, already related to cluster
                            k=k+1;                         %
                            k1=k;
                            clus(i) = k1;
                            mbg(k1) = obj.RawCatalog.Magnitude(i);
                            bgevent(k1) = i;
                        end
                        
                        if size(llb)>0     %attach clustnumber to events not already related to a cluster
                            clus(llb) = k1*ones(1,length(llb));  %
                        end
                        
                    end                          %if ac
                end                           %if sl0
            end                            %for loop
            
            close(wai);
            
            if ~any(clus)
                outputcatalog=obj.RawCatalog;
                details=struct();
                return
            else
                [cluslength,bgevent,mbg,bg,clustnumbers] = funBuildclu(obj.RawCatalog,bgevent,clus,mbg);%builds a matrix clust that stored clusters
                equi=equevent(obj.RawCatalog, clus);               % calculates equivalent events
                if isempty(equi)
                    disp('No clusters in the catalog with this input parameters');
                    return;
                end
                
                
                juggle_catalogs(clus,obj.RawCatalog)
                
                warning('should somehow zmap_update_displays()');
                plot_ax = findobj(gcf,'Tag','mainmap_ax');
                hold(plot_ax,'on');
                pl=scatter3(plot_ax,ZG.cluscat.Longitude, ZG.cluscat.Latitude,ZG.cluscat.Depth,[],'m', 'DisplayName','Clustered Events');
                pl.ZData=ZG.cluscat.Depth;
                
                st1 = sprintf([' The declustering found %d clusters of earthquakes, a total of %d'...
                    ' events (out of %d). The map window now display the declustered catalog containing %d events.'...
                    'The individual clusters are displayed as magenta on the  map.' ] ...
                    , bgevent.Count, ZG.cluscat.Count, ZG.original.Count , ZG.primeCatalog.Count);
                
                msgbox(st1,'Declustering Information')
                
                
                if user_wants_to_analyze_clusters()
                    plot(plot_ax,clust)
                else
                    disp('keep on going');
                end
                
                watchoff
                
            end
            
            
        end
        
        function juggle_catalogs(clus, catalog)
            ZG = ZmapGlobal.Data;
            ZG.primeCatalog=build_declustered_cat('interactive');  % create new catalog for main program
            ZG.original=catalog;       %save catalog in variable original
            ZG.newcat=ZG.primeCatalog;
            ZG.storedcat=ZG.original;
            ZG.cluscat=ZG.original.subset(clus(clus~=0));
        end
        
        function tf = user_wants_to_analyze_clusters()
            % USER_WANTS_TO_ANALYZE_CLUSTERS ask user whether clusters should be analyzed
            myans = questdlg('                                                           ',...
                'Analyse clusters? ',...
                'Yes please','No thank you','No thank you' );
            
            switch myans
                case 'Yes please'
                    tf=true;
                otherwise
                    tf=false;
            end
        end
        
        function [rmain_km,r1]= interaction_zone(obj)
            % interaction_zone calculates the interaction zones of the earthquakes in [km]
            %
            % output:
            %    rmain_km : interaction zone for mainshock, km
            %    r1 : interaction zone if included in a cluster, km
            
            rmain_km = 0.011*10.^(0.4* obj.RawCatalog.Magnitude); %interaction zone for mainshock
            r1 = obj.rfact * rmain_km;                  %interaction zone if included in a cluster
        end
        
        
        function[declustered_cat, is_mainshock] = ReasenbergDeclus(obj)
            mycat = obj.RawCatalog;
            % ReasenbergDeclus main decluster algorithm
            %
            % modified version, uses two different circles for already related events
            % works on mycat
            % different clusters stored with respective numbers in clus
            % Program is based on Raesenberg paper JGR;Vol90;Pages5479-5495;06/10/85
            %
            
            
            %basic variables used in the program
            %
            % rmain_km  interaction zone for not clustered events
            % r1     interaction zone for clustered events
            % rtest  radius in which the program looks for clusters
            % tau    look ahead time
            % tdiff  time difference between jth event and biggest eq
            % mbg    index of earthquake with biggest magnitude in a cluster
            % k      index of the cluster
            % k1     working index for cluster
            
            %routine works on mycat
            
            report_this_filefun();
            
            
            bg=[];k=[];k1=[];mbg=[];bgevent=[];equi=[];bgdiff=[];clust=[];clustnumbers=[];
            cluslength=[];
            rmain_km=[];
            r1=[];
            
            [rmain_km,r1]=interaction_zone(obj);                     %calculation of interaction radii
            
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
                % j=i+1; hardwired into the TIMEDIFF call
                k1=clus(i);
                
                % attach interaction time
                if k1~=0                          % if i is already related with a cluster
                    if mycat(i,6)>=mbg(k1)         % if magnitude of i is biggest in cluster
                        mbg(k1)=mycat(i,6);         %set biggest magnitude to magnitude of i
                        bgevent(k1)=i;                  %index of biggest event is i
                        tau=obj.taumin;
                    else
                        bgdiff=eqtime(i)-eqtime(bgevent(k1));
                        tau = clustLookAheadTime(obj.xk,mbg,k1,obj.xmeff,bgdiff,obj.P);
                        if tau>obj.taumax
                            tau=obj.taumax;
                        end
                        if tau<obj.taumin
                            tau=obj.taumin;
                        end
                    end
                else
                    tau=obj.taumin;
                end
                
                %extract eqs that fit interation time window
                [tdiff,ac] = timediff(i+1,i,tau,clus,eqtime);
                
                
                if size(ac)~=0   %if some eqs qualify for further examination
                    
                    if k1~=0                       % if i is already related with a cluster
                        tm1=find(clus(ac)~=k1);       %eqs with a clustnumber different than i
                        if ~isempty(tm1)
                            ac=ac(tm1);
                        end
                    end
                    if tau==obj.taumin
                        rtest1=r1(i);
                        rtest2=0;
                    else
                        rtest1=r1(i);
                        rtest2=rmain_km(bgevent(k1));
                    end
                    
                    %calculate distances from the epicenter of biggest and most recent eq
                    if k1==0
                        [dist1,dist2]=obj.funDistance(i,i,ac,obj.err,obj.derr);
                    else
                        [dist1,dist2]=obj.funDistance(i,bgevent(k1),ac,obj.err,obj.derr);
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
                [declustered_cat,is_mainshock] = obj.funBuildcat(clus,bg,bgevent);   %new catalog for main program
                
            end
        end
        
        function [othercat,is_mainshock] = funBuildcat(obj, clus, bg, bgevent)
            % FUNBUILDCAT builds declustered catalog with equivalent events
            
            tm1=find(clus==0);    %elements which are not related to a cluster
            tmpcat=[obj.RawCatalog.subset(tm1); bgevent]; % builds catalog with biggest events instead
            
            % I am not sure that this is right , may need 10 column
            %equivalent event
            [tm2,i]=sort([tm1';bg']);  %i is the index vector to sort tmpcat
            othercat=tmpcat.subset(i);       %sorted catalog,ready to load in basic program
            is_mainshock = [tm1';bg'];  %% contains indeces of all cluster mainshocks.  added  12/7/05
            
        end

function [dist1, dist2] = funDistance(obj, i,bgevent,ac,err,derr)
    % distance.m                                          A.Allmann
    % calculates the distance in [km] between two eqs
    % precise version based on Raesenbergs Program
    % the calculation is done simultaniously for the biggest event in the
    % cluster and for the current event
    mycat = obj.RawCatalog;
    pi2 = 1.570796;
    rad = 1.745329e-2;
    flat= 0.993231;
    
    alatr1=mycat.Latitude(i)*rad;     %conversion from degrees to rad
    alonr1=mycat.Longitude(i)*rad;
    alatr2=mycat.Latitude(bgevent)*rad;
    alonr2=mycat.Longitude(bgevent)*rad;
    blonr=mycat.Longitude(ac)*rad;
    blatr=mycat.Latitude(ac)*rad;
    
    tana(1)=flat*tan(alatr1);
    tana(2)=flat*tan(alatr2);
    geoa=atan(tana);
    acol=pi2-geoa;
    tanb=flat*tan(blatr);
    geob=atan(tanb);
    bcol=pi2-geob;
    diflon(:,1)=blonr-alonr1;
    diflon(:,2)=blonr-alonr2;
    cosdel(:,1)=(sin(acol(1))*sin(bcol)).*cos(diflon(:,1))+(cos(acol(1))*cos(bcol));
    cosdel(:,2)=(sin(acol(2))*sin(bcol)).*cos(diflon(:,2))+(cos(acol(2))*cos(bcol));
    delr=acos(cosdel);
    top=sin(diflon)';
    den(1,:)=sin(acol(1))/tan(bcol)-(cos(acol(1))*cos(diflon(:,1)))';
    den(2,:)=sin(acol(2))/tan(bcol)-(cos(acol(2))*cos(diflon(:,2)))';
    azr=atan2(top,den);                   %azimuth to North
    colat(:,1)=pi2-(alatr1+blatr)/2;
    colat(:,2)=pi2-(alatr2+blatr)/2;
    radius=6371.227*(1+(3.37853e-3)*(1/3-((cos(colat)).^2)));
    r=delr.*radius;            %epicenter distance
    r=r-1.5*err;               %influence of epicenter error
    tmp1=find(r<0);
    if ~isempty(tmp1)
        r(tmp1)=zeros(length(tmp1),1);
    end
    z(:,1)=abs(mycat.Depth(ac)-mycat.Depth(i));    %depth distance
    z(:,2)=abs(mycat.Depth(ac)-mycat.Depth(bgevent));
    z=z-derr;
    tmp2=find(z<0);
    if ~isempty(tmp2)
        z(tmp2)=zeros(length(tmp2),1);
    end
    r=sqrt(z.^2+r.^2);                   %hypocenter distance
    dist1=r(:,1);           %distance between eqs
    dist2=r(:,2);
end

    end
    
    methods(Static)
        function h=AddMenuItem(parent,catalog)
            % create a menu item
            label='Reasenberg Decluster';
            h=uimenu(parent,'Label',label,MenuSelectedField(), @(~,~)ResenbergDeclusterClass(catalog));
        end
    end
    
end



