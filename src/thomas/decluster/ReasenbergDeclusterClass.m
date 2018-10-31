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
        declusteredCatalog   ZmapCatalog
    end
    
    properties(Constant)
        PlotTag = "ReasenbergDecluster"
        ParameterableProperties = ["taumin", "taumax", "P",...
            "xk","xmeff","rfact","err","derr","declustRoutine"];
        References = 'Paul Reasenberg (1985) "SECOND -ORDER MOMENT OF CENTRAL CALIFORNIA SEISMICITY", JGR, VOL 90, P. 5479-5495.';
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
            zdlg.AddDurationEdit('taumin', '(min) for UNclustered events' ,obj.taumin, '<b>TauMin</b> look ahead time for not clustered events',@days);
            zdlg.AddDurationEdit('taumax', '(max) for   clustered events', obj.taumax,  '<b>TauMax</b> maximum look ahead time for clustered events',@days);
            zdlg.AddHeader('');
            zdlg.AddEdit('P',       'Confidence Level',             obj.P,          '<b>P1</b> Confidence level : observing the next event in the sequence');
            zdlg.AddEdit('xk',      'XK factor',                    obj.xk,         '<b>XK</b> factor used in xmeff');
            zdlg.AddEdit('xmeff',   'Effective min mag cutoff',     obj.xmeff,   '<b>XMEFF</b> "effective" lower magnitude cutoff for catalog, during clusters, it is xmeff^{xk*cmag1}');
            zdlg.AddEdit('rfact',   'Interation radius factor:',    obj.rfact,      '<b>RFACT>/b>factor for interaction radius for dependent events');
            zdlg.AddEdit('err',     'Epicenter error',              obj.err,        '<b>Epicenter</b> error');
            zdlg.AddEdit('derr',    'Depth error',                  obj.derr,       '<b>derr</b>Depth error');
            
            zdlg.Create('Name', 'Reasenberg Declustering','WriteToObj',obj,'OkFcn',@obj.declus);
          
        end
        
        function Results = Calculate(obj)
            calcFn = str2func(obj.declustRoutine);
            [declustered_catalog, misc] = calcFn(obj);
            if nargout == 1
                Results = declustered_catalog;
            end
        end
        
        function plot(obj)
            unimplemented_error()
        end
        
        function [outputcatalog, details] = declus(obj, vals) 
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
            % global equi %[OUT]
            global clust
            global clustnumbers
            global cluslength %[OUT]
            %  global taumin taumax
            % global xk xmeff P
            
            ZG=ZmapGlobal.Data;
            
            bg=[];
            k1=[];
            max_mag_in_cluster=[];
            idx_biggest_event_in_cluster=[];
            % equi=[];
            bgdiff=[];
            clust=[];
            clustnumbers=[];
            cluslength=[];
            
            [rmain_km, r1]=interaction_zone(obj);   %calculation of interaction radii
            
            
            tau_min = days(obj.taumin);
            tau_max = days(obj.taumax);
            
            %calculation of the eq-time relative to 1902
            eqtime=clustime(obj.RawCatalog);
            
            %variable to store information whether earthquake is already clustered
            clus = zeros(1,obj.RawCatalog.Count);
            
            k = 0;                                %clusterindex
            
            wai = waitbar(0,' Please Wait ...  ');
            set(wai,'NumberTitle','off','Name','Decluster - Percent done');
            drawnow
            declustering_start = tic;
            %for every earthquake in catalog, main loop
            for i = 1: (obj.RawCatalog.Count-1)
                
                % "myXXX" refers to the XXX for this event
                
                my_mag = obj.RawCatalog.Magnitude(i);
                
                
                if rem(i,50)==0
                    waitbar(i/(obj.RawCatalog.Count-1));
                end
                
                % variable needed for distance and timediff
                my_cluster=clus(i);
                alreadyInCluster = my_cluster~=0;
                
                % attach interaction time
                
                if alreadyInCluster  
                    if my_mag >= max_mag_in_cluster(my_cluster)
                        max_mag_in_cluster(my_cluster) = my_mag;
                        idx_biggest_event_in_cluster(my_cluster)=i;
                        look_ahead_days=tau_min;
                    else
                        bgdiff = eqtime(i) - eqtime(idx_biggest_event_in_cluster(my_cluster));
                        look_ahead_days = clustLookAheadTime(obj.xk, max_mag_in_cluster(my_cluster), obj.xmeff, bgdiff, obj.P);
                        look_ahead_days = min(look_ahead_days, tau_max);
                        look_ahead_days = max(look_ahead_days, tau_min);
                    end
                else
                    look_ahead_days=tau_min;
                end
                
                %extract eqs that fit interation time window
                [~,ac]=timediff(i, look_ahead_days, clus, eqtime);
                
                
                
                
                if ~isempty(ac)   %if some eqs qualify for further examination
                    
                    rtest1=r1(i);
                    if look_ahead_days==obj.taumin
                        rtest2 = 0;
                    else
                        rtest2=rmain_km(idx_biggest_event_in_cluster(my_cluster));
                    end
                    
                    if alreadyInCluster                       % if i is already related with a cluster
                        tm1 = clus(ac) ~= my_cluster;       %eqs with a clustnumber different than i
                        if any(tm1)
                            ac=ac(tm1);
                        end
                        bg_ev_for_dist = idx_biggest_event_in_cluster(my_cluster);
                    else
                        bg_ev_for_dist = i;
                    end
                    
                    %calculate distances from the epicenter of biggest and most recent eq
                    [dist1,dist2]=distance2(i,bg_ev_for_dist,ac, obj.RawCatalog);
                    
                    %extract eqs that fit the spatial interaction time
                    sl0 = dist1<= rtest1 | dist2<= rtest2;
                    
                    if any(sl0)    %if some eqs qualify for further examination
                        ll=ac(sl0);       %eqs that fit spatial and temporal criterion
                        lla=ll(clus(ll)~=0);   %eqs which are already related with a cluster
                        llb=ll(clus(ll)==0);   %eqs that are not already in a cluster
                        if ~isempty(lla)            %find smallest clustnumber in the case several
                            sl1=min(clus(lla));            %numbers are possible
                            if alreadyInCluster
                                my_cluster= min([sl1,my_cluster]);
                            else
                                my_cluster = sl1;
                            end
                            if clus(i)==0
                                clus(i)=my_cluster;
                            end
                            %merge all related clusters together in the cluster with the smallest number
                            sl2 = lla(clus(lla)~=my_cluster);
                            for j1 = [i,sl2]
                                if clus(j1) ~= my_cluster
                                    clus(clus==clus(j1)) = my_cluster;
                                end
                            end
                        end
                        
                        if my_cluster==0   %if there was neither an event in the interaction zone nor i, already related to cluster
                            k=k+1;                         %
                            my_cluster=k;
                            clus(i) = my_cluster;
                            max_mag_in_cluster(my_cluster) = my_mag;
                            idx_biggest_event_in_cluster(my_cluster) = i;
                        end
                        
                        if size(llb)>0     %attach clustnumber to events not already related to a cluster
                            clus(llb) = my_cluster * ones(1,length(llb));  %
                        end
                        
                    end                          %if ac
                end                           %if sl0
            end                            %for loop
            
            close(wai);
            toc(declustering_start)
            
            if ~any(clus)
                outputcatalog=obj.RawCatalog;
                details=struct();
                return
            end
            
            % this table contains all we need to know about the clusters. maybe.
            tb = table;
            tb.eventNumber = (1:obj.RawCatalog.Count)';
            tb.clusterNumber = clus(:);
            tb.clusterNumber(tb.clusterNumber==0)=missing;
            tb.isBiggest=false(size(tb.clusterNumber));
            tb.isBiggest(idx_biggest_event_in_cluster)=true;
            tb.Latitude = obj.RawCatalog.Latitude;
            tb.Longitude = obj.RawCatalog.Longitude;
            tb.Depth = obj.RawCatalog.Depth;
            tb.Magnitude = obj.RawCatalog.Magnitude;
            tb.MagnitudeType = obj.RawCatalog.MagnitudeType;
            tb.Date = obj.RawCatalog.Date;
            
            clusterFreeCatalog = obj.RawCatalog.subset(ismissing(tb.clusterNumber));
            %biggest_events_in_cluster = obj.RawCatalog.subset(tb.isBiggest);
            outputcatalog=clusterFreeCatalog;
            assignin('base','reas_cluster_details',tb);
            
            
            
            %build a matrix clust that stored clusters
            [cluslength, biggest_events_in_cluster, max_mag_in_cluster,bg,clustnumbers] = funBuildclu(obj.RawCatalog,idx_biggest_event_in_cluster,clus,max_mag_in_cluster);
            
            equi = obj.equevent(tb(~ismissing(tb.clusterNumber),:));  % calculates equivalent events
            
            if isempty(equi)
                disp('No clusters in the catalog with this input parameters');
                return;
            end
            
            
            ans_ = questdlg('Replace mainshocks with equivalent events?',...
                'Replace mainshocks with equivalent events?',...
                'Replace','No','No' );
            
            switch ans_
                case 'Replace'
                    tmpcat=cat(clusterFreeCatalog, equi);  %new catalog, but not sorted
                case 'No'
                    tmpcat=cat(clusterFreeCatalog, biggest_events_in_cluster); % builds catalog with biggest events instead
                    
                    disp('Original mainshocks kept');
                    
            end
            
            % I am not sure that this is right , may need 10 coloum
            %equivalent event
            tmpcat.sort('Date')
            
            
            ZG = ZmapGlobal.Data;
            ZG.original=obj.RawCatalog;       %save catalog in variable original
            ZG.newcat=ZG.primeCatalog;
            ZG.storedcat=ZG.original;
            ZG.cluscat=ZG.original.subset(clus(clus~=0));
            assignin('base','declustered_catalog', tmpcat);
            
            
            %{
                warning('should somehow zmap_update_displays()');
                plot_ax = findobj(gcf,'Tag','mainmap_ax');
                hold(plot_ax,'on');
                pl=scatter3(plot_ax,ZG.cluscat.Longitude, ZG.cluscat.Latitude,ZG.cluscat.Depth,[],'m', 'DisplayName','Clustered Events');
                pl.ZData=ZG.cluscat.Depth;
            %}
            st1 = sprintf([' The declustering found %d clusters of earthquakes, a total of %d'...
                ' events (out of %d). The map window [would] now display the declustered catalog containing %d events.'...
                'The individual clusters are displayed as magenta on the  map.' ], ...
                biggest_events_in_cluster.Count, ZG.cluscat.Count, ZG.original.Count , ZG.primeCatalog.Count);
            
            msgbox(st1,'Declustering Information')
            
            watchoff
            outputcatalog=ZG.cluscat;
            
            % set global variables. get rid of this eventually.
            mbg = max_mag_in_cluster;
            bgevent = idx_biggest_event_in_cluster;
            return

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
        
    end
    
    methods(Static)
        function h=AddMenuItem(parent,catalog)
            % create a menu item
            label='Reasenberg Decluster';
            h=uimenu(parent,'Label',label,MenuSelectedField(), @(~,~)ReasenbergDeclusterClass(catalog));
        end
        
        
        function equi=equevent(tb)
            % equevent calc equivalent event to cluster
            % equi = equevent(catalog, cluster, bg)
            %   catalog : earthquake catalog
            %   cluster :
            %   bg : index of a big event (?)
            %  equevent.m                        A.Allmann
            % calculates equivalent event to a cluster
            % weight according to seismic moment
            % time for equivalent event is time of first biggest event
            %
            report_this_filefun();
            
            equi=ZmapCatalog;
            equi.Name='clusters';
            
            if isempty(tb)
                return
            end
            j=0;
            for n=1 : max(tb.clusterNumber)
                clust_events = tb(tb.clusterNumber==n,:);
                if isempty(clust_events)
                    continue;
                end
                j = j + 1;
                
                eqmoment = 10.^(clust_events.Magnitude .* 1.2);
                emoment=sum(eqmoment);         %moment
                
                weights = eqmoment./emoment;      %weightfactor
                elat(j) = sum(clust_events.Latitude .* weights);
                elon(j) = sum(clust_events.Longitude .* weights); %longitude
                edep(j) = sum(clust_events.Depth .* weights); %depth
                emag(j) = (log10(emoment))/1.2;
                theBiggest = find(clust_events.isBiggest,1,'first');
                edate(j)=clust_events.Date(theBiggest);
                emagtype(j) = clust_events.MagnitudeType(theBiggest);
                
            end
            
            
            %equivalent events for each cluster
            equi.Latitude = elat(:);
            equi.Longitude = elon(:);
            equi.Date = edate(:);
            equi.Magnitude = emag(:);
            equi.MagnitudeType = emagtype(:);
            equi.Depth=edep(:);
            [equi.Dip, equi.DipDirection, equi.Rake]=deal(repmat(nan,size(equi.Date)));
        end
    end
    
end

