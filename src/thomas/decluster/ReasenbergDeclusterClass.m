classdef ReasenbergDeclusterClass < ZmapFunction
    % Reasenberg Declustering codes
    % made from code originally from A.Allman that has chopped up and rebuilt
    
    properties
        taumin  duration    = days(1)   % look ahead time for not clustered events
        taumax  duration    = days(10)  % maximum look ahead time for clustered events
        P                   = 0.95      % confidence level that this is next event in sequence
        xk                  = 0.5       % is the factor used in xmeff
        
        % effective lower magnitude cutoff for catalog. 
        % During clusteres, it is raised by a factor xk*cmag1
        xmeff               = 1.5       
        
        rfact               = 10        % factor for interaction radius for dependent events
        err                 = 1.5       % epicenter error
        derr                = 2         % depth error, km
        %declustRoutine      = "ReasenbergDeclus"
        declusteredCatalog   ZmapCatalog
        replaceSequenceWithEquivMainshock   logical = false
        
         % if empty, clustering details will not be saved to workspace
        clusterDetailsVariableName          char    = 'cluster_details'
        
        % if empty, catalog will not be saved to workspace
        declusteredCatalogVariableName      char    = 'declustered_catalog' 
        memorizeOriginalCatalog             logical = true
    end
    
    properties(Constant)
        PlotTag = "ReasenbergDecluster"
        
        ParameterableProperties = ["taumin", "taumax", "P",...
            "xk","xmeff","rfact","err","derr",..."declustRoutine",...
            "replaceSequenceWithEquivMainshock",...
            "clusterDetailsVariableName",...
            "declusteredCatalogVariableName",...
            "memorizeOriginalCatalog"];
        
        References = ['Paul Reasenberg (1985) ',...
            '"Second -order Moment of Central California Seismicity"',...
            ', JGR, Vol 90, P. 5479-5495.'];
        
    end
    
    methods
        function obj = ReasenbergDeclusterClass(catalog, varargin)
            % BVALGRID 
            % obj = BVALGRID() takes catalog, grid, and eventselection from ZmapGlobal.Data
            %
            % obj = BVALGRID(ZAP) where ZAP is a ZmapAnalysisPkg
            
            obj@ZmapFunction(catalog);
            
            report_this_filefun();
            obj.parseParameters(varargin);
            obj.clusterDetailsVariableName = matlab.lang.makeValidName(obj.clusterDetailsVariableName);
            obj.declusteredCatalogVariableName = matlab.lang.makeValidName(obj.declusteredCatalogVariableName);
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
            %zdlg.AddHeader('Output')
            zdlg.AddCheckbox('replaceSequenceWithEquivMainshock','Replace clusters with equivalent event',...
                obj.replaceSequenceWithEquivMainshock, {},...
                'Will replace each set of cluster earthquakes with a single event of equivalent Magnitude');
            zdlg.AddEdit('clusterDetailsVariableName',      'Save Clusters to workspace as', ...
                obj.clusterDetailsVariableName, 'if empty, then nothing will be separately saved');
            zdlg.AddEdit('declusteredCatalogVariableName',  'Save Declustered catalog to workspace as', ...
                obj.declusteredCatalogVariableName,'if empty, then nothing will be separately saved');
            zdlg.AddCheckbox('memorizeOriginalCatalog',     'Memorize Original catalog after sucessful decluster:', ...
                obj.memorizeOriginalCatalog, {}, 'Memorize original catalog prior to declustering');
            
            
            
            zdlg.Create('Name', 'Reasenberg Declustering','WriteToObj',obj,'OkFcn',@obj.Calculate);
          
        end
        
        function Results = Calculate(obj)
            calcFn = @obj.declus;
            [obj.declusteredCatalog, misc] = calcFn(obj);
            if nargout == 1
                Results = obj.declusteredCatalog;
            end
            
            obj.CalcFinishedFcn();
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
            % interactzone_main_km  interaction zone for not clustered events
            % interactzone_in_clust_km     interaction zone for clustered events
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
            %global clus % number of the cluster with which this event is associated.
            % global eqtime   %time of all earthquakes catalogs
            % global k k1 bg mbg bgevent bgdiff          %indices
            % global equi %[OUT]
            % global clust
            % global clustnumbers
            % global cluslength %[OUT]
            %  global taumin taumax
            % global xk xmeff P
            
            
            max_mag_in_cluster=[];
            idx_biggest_event_in_cluster=[];
            
            %% calculate interaction_zone  (1 value per event)
            
            interactzone_main_km = 0.011*10.^(0.4* obj.RawCatalog.Magnitude); %interaction zone for mainshock
            interactzone_in_clust_km = obj.rfact * interactzone_main_km;      %interaction zone if included in a cluster
                      
            
            tau_min = days(obj.taumin);
            tau_max = days(obj.taumax);
            
            %calculation of the eq-time relative to 1902
            eqtime = clustime(obj.RawCatalog);
            
            %variable to store information whether earthquake is already clustered
            clus = zeros(1,obj.RawCatalog.Count);
            
            k = 0;                                %clusterindex
            
            wai = waitbar(0,' Please Wait ...  Declustering the catalog');
            set(wai,'NumberTitle','off','Name','Declustering Progress');
            drawnow
            declustering_start = tic;
            %for every earthquake in catalog, main loop
            confine_value = @(value, min_val, max_val) max( min( value, max_val), min_val);
            for i = 1: (obj.RawCatalog.Count-1)
                
                % "myXXX" refers to the XXX for this event
                
                my_mag = obj.RawCatalog.Magnitude(i);
                
                
                if rem(i,50)==0
                    waitbar(i/(obj.RawCatalog.Count-1));
                end
                
                % variable needed for distance and timediff
                my_cluster = clus(i);
                alreadyInCluster = my_cluster~=0;
                
                % attach interaction time
                
                if alreadyInCluster  
                    if my_mag >= max_mag_in_cluster(my_cluster)
                        max_mag_in_cluster(my_cluster) = my_mag;
                        idx_biggest_event_in_cluster(my_cluster) = i;
                        look_ahead_days = tau_min;
                    else
                        bgdiff = eqtime(i) - eqtime(idx_biggest_event_in_cluster(my_cluster));
                        look_ahead_days = clustLookAheadTime(obj.xk, max_mag_in_cluster(my_cluster), obj.xmeff, bgdiff, obj.P);
                        look_ahead_days = confine_value(look_ahead_days, tau_min, tau_max);
                    end
                else
                    look_ahead_days = tau_min;
                end
                
                %extract eqs that fit interation time window
                [~,ac] = timediff(i, look_ahead_days, clus, eqtime);
                
                
                
                
                if ~isempty(ac)   %if some eqs qualify for further examination
                    
                    rtest1 = interactzone_in_clust_km(i);
                    if look_ahead_days == obj.taumin
                        rtest2 = 0;
                    else
                        rtest2 = interactzone_main_km(idx_biggest_event_in_cluster(my_cluster));
                    end
                    
                    if alreadyInCluster                % if i is already related with a cluster
                        tm1 = clus(ac) ~= my_cluster;  % eqs with a clustnumber different than i
                        if any(tm1)
                            ac = ac(tm1);
                        end
                        bg_ev_for_dist = idx_biggest_event_in_cluster(my_cluster);
                    else
                        bg_ev_for_dist = i;
                    end
                    
                    %calculate distances from the epicenter of biggest and most recent eq
                    [dist1,dist2]=distance2(i,bg_ev_for_dist,ac, obj.RawCatalog);
                    
                    %extract eqs that fit the spatial interaction time
                    sl0 = dist1<= rtest1 | dist2<= rtest2;
                    
                    if any(sl0)             %if some eqs qualify for further examination
                        ll = ac(sl0);            %eqs that fit spatial and temporal criterion
                        lla = ll(clus(ll)~=0);   %eqs which are already related with a cluster
                        llb = ll(clus(ll)==0);   %eqs that are not already in a cluster
                        if ~isempty(lla)         %find smallest clustnumber in the case several
                            sl1 = min(clus(lla));     %numbers are possible
                            if alreadyInCluster
                                my_cluster = min([sl1, my_cluster]);
                            else
                                my_cluster = sl1;
                            end
                            if clus(i)==0
                                clus(i) = my_cluster;
                            end
                            % merge related clusters together into cluster with the smallest number
                            sl2 = lla(clus(lla) ~= my_cluster);
                            for j1 = [i,sl2]
                                if clus(j1) ~= my_cluster
                                    clus(clus==clus(j1)) = my_cluster;
                                end
                            end
                        end
                        
                        if my_cluster==0   %if there was neither an event in the interaction zone nor i, already related to cluster
                            k = k+1;                         %
                            my_cluster = k;
                            clus(i) = my_cluster;
                            max_mag_in_cluster(my_cluster) = my_mag;
                            idx_biggest_event_in_cluster(my_cluster) = i;
                        end
                        
                        if size(llb)>0     % attach clustnumber to events yet unrelated to a cluster
                            clus(llb) = my_cluster * ones(1,length(llb));  %
                        end
                        
                    end       %if ac
                end         %if sl0
            end
            
            close(wai);
            msg.dbfprintf('Declustering complete. It took %g seconds\n',toc(declustering_start));
            
            %% this table contains all we need to know about the clusters. maybe.
            details = table;
            details.Properties.UserData = struct;
            for j = 1 : numel(obj.ParameterableProperties)
                details.Properties.UserData.(obj.ParameterableProperties(j)) = obj.(obj.ParameterableProperties(j));
            end
            
            details.Properties.Description  = 'Details for cluster, from reasenberg declustering';
            details.eventNumber             = (1:obj.RawCatalog.Count)';
            details.clusterNumber           = clus(:);
            details.clusterNumber(details.clusterNumber==0) = missing;
            details.isBiggest               = false(size(details.clusterNumber));
            details.isBiggest(idx_biggest_event_in_cluster) = true;
            
            details.Latitude                = obj.RawCatalog.Latitude;
            details.Properties.VariableUnits(width(details)) = {'degrees'};
            
            details.Longitude               = obj.RawCatalog.Longitude;
            details.Properties.VariableUnits(width(details)) = {'degrees'};
            
            details.Depth                   = obj.RawCatalog.Depth;
            details.Properties.VariableUnits(width(details)) = {'kilometers'};
            
            details.Magnitude               = obj.RawCatalog.Magnitude;
            
            details.MagnitudeType           = obj.RawCatalog.MagnitudeType;
            
            details.Date                    = obj.RawCatalog.Date;
            
            details.InteractionZoneIfMain   = interactzone_main_km;
            details.Properties.VariableUnits(width(details)) = {'kilometers'};
            
            details.InteractionZoneIfInClust = interactzone_in_clust_km;
            details.Properties.VariableUnits(width(details)) = {'kilometers'};
            
            clusterFreeCatalog = obj.RawCatalog.subset(ismissing(details.clusterNumber));
            %biggest_events_in_cluster = obj.RawCatalog.subset(details.isBiggest);
            
            outputcatalog = clusterFreeCatalog;
            
            if ~any(clus)
                return
            end
            
            
            %build a matrix clust that stored clusters
            [~, biggest_events_in_cluster, max_mag_in_cluster,~,~] = funBuildclu(obj.RawCatalog,idx_biggest_event_in_cluster,clus,max_mag_in_cluster);
            
            
            % replace cluster sequences with summary events
            if obj.replaceSequenceWithEquivMainshock
                equi = obj.equevent(details(~ismissing(details.clusterNumber),:));  % calculates equivalent events
                if isempty(equi)
                    disp('No clusters in the catalog with this input parameters');
                    return;
                end
                tmpcat = cat(clusterFreeCatalog, equi);  %new, unsorted catalog
                
            else
                tmpcat = cat(clusterFreeCatalog, biggest_events_in_cluster); % builds catalog with biggest events instead
                disp('Original mainshocks kept');
            end
            
            tmpcat.sort('Date');
            
            tmpcat.Name = string(tmpcat.Name) + " (declust)";
                      
            % save clustering details to workspace
            if ~isempty(obj.clusterDetailsVariableName)
                assignin('base',matlab.lang.makeValidName(obj.clusterDetailsVariableName),details);
            end
            
            if obj.memorizeOriginalCatalog
                mm = MemorizedCatalogManager();
                mm.memorize(obj.RawCatalog,'predeclust')
            end
            
            ZG              = ZmapGlobal.Data;
            ZG.original     = obj.RawCatalog;       %save catalog in variable original
            %ZG.newcat       = ZG.primeCatalog;
            %ZG.storedcat    = ZG.original;
            ZG.cluscat      = ZG.original.subset(clus(clus~=0));
            
            % save declustered catalog to workspace
            if ~isempty(obj.declusteredCatalogVariableName)
                assignin('base', obj.declusteredCatalogVariableName, tmpcat);
            end
                
            st1 = sprintf([' The declustering found %d clusters of earthquakes, a total of %d'...
                ' events (out of %d). The map window now displays the declustered catalog containing %d events.'], ...
                biggest_events_in_cluster.Count, ZG.cluscat.Count, ZG.original.Count , ZG.primeCatalog.Count);
            
            msgbox(st1,'Declustering Information')
            
            watchoff
            outputcatalog = tmpcat;
                        
            obj.Result(1).values.cluster_details  = details;
            
        end
        
        function plot(obj, varargin)
            f = figure('Name','Reasenberg Deslustering Results');
            ax = subplot(2,2,1);
            ZG = ZmapGlobal.Data;
            biggest = obj.Result.values.cluster_details(obj.Result.values.cluster_details.isBiggest,:);
            non_cluster = obj.Result.values.cluster_details(ismissing(obj.Result.values.cluster_details.clusterNumber),:);
            msf = str2func(ZG.MainEventOpts.MarkerSizeFcn);
            scatter3(biggest.Longitude,biggest.Latitude,biggest.Depth,msf(biggest.Magnitude));
            ax.ZDir='reverse';
            title(ax,'Biggest events in each cluster');
            hold on
            ax.XLabel.String = 'Longitude';
            ax.YLabel.String = 'Latitude';
            ax.ZLabel.String = 'Depth [km]';
            feats = findobj(allchild(findobj('Tag','mainmap_ax')),'-regexp','Tag','mainmap_.+');
            copyobj(feats,ax); %copy features
            
            
            ax = subplot(2,2,2);
            
            ax = subplot(2,1,2);
            
            isInClust = ~ismissing(obj.Result.values.cluster_details.clusterNumber);
            isNotBig = ~obj.Result.values.cluster_details.isBiggest;
            clust = obj.Result.values.cluster_details(isInClust&isNotBig, :);
            scatter(clust.Date,clust.Depth,[],[.8 .8 .8],'Marker','.','DisplayName','other events in each cluster');
            ax.YDir='reverse';
            hold on;
            scatter(biggest.Date,biggest.Depth,msf(biggest.Magnitude),categorical(biggest.clusterNumber),'DisplayName','primary events in each cluster');
            cb = colorbar;
            cb.Label.String = 'Cluster #';
            ax.YLabel.String = 'Depth [km]';
            ax.XLabel.String = 'Date';
            title(ax,'Clusters through time');
            legend('show')
        end
    end
    
    methods(Static)
        function h = AddMenuItem(parent,catalog)
            % create a menu item
            label='Reasenberg Decluster';
            h = uimenu(parent,'Label',label,MenuSelectedField(), @(~,~)ReasenbergDeclusterClass(catalog));
        end
        
        
        function equi = equevent(tb)
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
            
            equi = ZmapCatalog;
            equi.Name='clusters';
            
            if isempty(tb)
                return
            end
            j = 0;
            nClusts = max(tb.clusterNumber);
            [elat, elon, edep, emag] = deal(nan(nClusts,1));
            edate(nClusts,1) = datetime(missing);
            emagtype(nClusts,1) = categorical(missing);
            
            for n = 1 : max(tb.clusterNumber)
                clust_events = tb(tb.clusterNumber==n,:);
                if isempty(clust_events)
                    continue;
                end
                j = j + 1;
                
                eqmoment = 10.^(clust_events.Magnitude .* 1.2);
                emoment = sum(eqmoment);         %moment
                
                weights = eqmoment./emoment;      %weightfactor
                elat(j)     = sum(clust_events.Latitude .* weights);
                elon(j)     = sum(clust_events.Longitude .* weights); %longitude
                edep(j)     = sum(clust_events.Depth .* weights); %depth
                emag(j)     = (log10(emoment))/1.2;
                theBiggest  = find(clust_events.isBiggest,1,'first');
                edate(j)    = clust_events.Date(theBiggest);
                emagtype(j) = clust_events.MagnitudeType(theBiggest);
                
            end
            
            
            %equivalent events for each cluster
            equi.Latitude = elat(1:j);
            equi.Longitude = elon(1:j);
            equi.Date = edate(1:j);
            equi.Magnitude = emag(1:j);
            equi.MagnitudeType = emagtype(1:j);
            equi.Depth = edep(1:j);
            [equi.Dip, equi.DipDirection, equi.Rake]=deal(nan(size(equi.Date)));
        end
    end
    
    
end

