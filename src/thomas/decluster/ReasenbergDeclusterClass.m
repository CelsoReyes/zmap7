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
        
        % interaction formula bundles assumptions about stress drop into a mag-dependent formula
        InteractFormula = struct('Reasenberg1985', @(m) 0.011 .* 10.^ (0.4 .* m),...
            'WellsCoppersmith1994', @(m) 0.01 * 10 .^ (0.5 * m)) 
    end
    
    methods
        function obj = ReasenbergDeclusterClass(catalog, varargin)
            % ReasenbergDeclusterClass
            
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
        
        %{
        function [clustnum, eqs_in_clust] = decluster_from_python(obj)
              obj.verbose = config.get('verbose', obj.verbose);
            % Get relevant parameters
            neq = catalog.get_number_events()  % Number of earthquakes

            min_lookahead_days = obj.taumin;
            max_lookahead_days = obj.taumax;

            % Get elapsed days
            elapsed = days_from_first_event(catalog);

            assert(all(elapsed(2:end) >= elapsed(1:end-1)), "catalog needs to be in ascending date order")

            % easy-access variables
            dmethod='p2p';
            switch dmethod
                case 'gc'
                    surf_pos = [catalog.latitude, catalog.longitude];
                    event_distance = event_gc_distance;
                case'p2p'
                    surf_pos = geodetic_to_ecef(catalog.latitude, catalog.longitude);  % assumes at surface
                    event_distance = event_p2p_distance;
                otherwise
                    except(ValueError("unknown configuration dmethod. it should be 'gc' or 'p2p'"))
            end
            
            mags = catalog.magnitude;
            deps = catalog.depth;

            if isempty(obj.err)
                horiz_error = catalog.data.get('horizError', 0);
            else
                horiz_error = obj.err;
            end
            if isempty(obj.derr)
                depth_error = catalog.data.get('depthError', 0);
            else
                depth_error = obj.derr;
            end
            % Pre-allocate cluster index vectors
            vcl = zeros(neq, 1);

            % set the interaction zones, in km
            % Reasenberg 1987 or alternate version: Wells & Coppersmith 1994 / Helmstetter (SRL) 2007
            zone_noclust, zone_clust = obj.get_zone_distances_per_mag(mags, obj.rfact,...
                obj.interaction_formulas.(obj.interaction_formula), obj.taumax)

            k = 0  % clusterindex

            % variable to store information whether earthquake is already clustered
            clusmaxmag = ones(neq,1) * -inf;
            clus_biggest_idx = zeros(neq,1);

            % for every earthquake in catalog, main loop
            for i = 0 : neq-1 % in range(neq - 1)
                my_mag = mags(i);

                % variable needed for distance and timediff
                my_cluster = vcl(i);
                not_classified = my_cluster == 0;

                % attach interaction time

                if not_classified
                    obj.debug_print(i, ' is not in a cluster')
                    % this event is not associated with a cluster, yet
                    look_ahead_days = min_lookahead_days;

                elseif my_mag >= clusmaxmag(my_cluster)
                    % note, if this is now the biggest, then the cluster range collapses into its radius
                    printf('%d is the biggest event of cluster M=%g\n', i, my_mag);
                    % this is the biggest event  in this cluster, so far (or equal to it).
                    clusmaxmag(my_cluster) = my_mag;
                    clus_biggest_idx(my_cluster) = i;
                    look_ahead_days = min_lookahead_days;
                else
                    printf('%d is already in cluster, but not biggest', i);
                    % this event is already tied to a cluster, but is not the largest
                    idx_biggest = clus_biggest_idx(my_cluster);
                    days_since_biggest = elapsed(i) - elapsed(idx_biggest);
                    look_ahead_days = obj.clust_look_ahead_time(clusmaxmag(my_cluster),...
                        days_since_biggest, obj.xk, obj.xmeff, obj.P);
                    
                    look_ahead_days(look_ahead_days<min_lookahead_days) = min_lookahead_days;
                    look_ahead_days(look_ahead_days>max_lookahead_days) = max_lookahead_days;
                end
                % extract eqs that fit interaction time window --------------

                max_elapsed = elapsed(i) + look_ahead_days;
                next_event = i + 1;
                last_event = bisect_left(elapsed, max_elapsed, next_event);
                temporal_evs = np.arange(next_event, last_event)
                if my_cluster ~= 0
                    temporal_evs = temporal_evs(vcl(temporal_evs) ~= my_cluster);
                end
                if len(temporal_evs) == 0
                    continue
                end
                % ------------------------------------
                % one or more events have now passed the time window test. Now compare
                % this subcatalog in space to A) most recent and B) largest event in cluster
                % ------------------------------------

                obj.debug_print('temporal_evs:', temporal_evs)
                my_biggest_idx = clus_biggest_idx(my_cluster)
                if not_classified
                    bg_ev_for_dist = i;
                else
                    bg_ev_for_dist = my_biggest_idx;
                end

                obj.debug_print('bg_ev_for_dist:', bg_ev_for_dist)
                % noinspection PyTypeChecker
                dist_to_recent = event_distance(surf_pos, deps, i, temporal_evs, horiz_error, depth_error)
                dist_to_biggest = event_distance(surf_pos, deps, bg_ev_for_dist, temporal_evs, horiz_error, depth_error)
                printf('dist_to_recent', dist_to_recent)
                printf('dist_to_biggest', dist_to_biggest)
                % extract eqs that fit the spatial interaction
                if look_ahead_days == min_lookahead_days
                    l_big = dist_to_biggest == 0;  % all false
                    l_recent = dist_to_recent <= zone_noclust(my_mag);
                    printf('Connecting those near to this event [dist <= {zone_noclust[my_mag]}]')
                else
                    l_big = dist_to_biggest <= zone_clust(clusmaxmag(my_cluster))
                    l_recent = dist_to_recent <= zone_clust(clusmaxmag(my_cluster))
                    printf('Connecting those near to this OR largest event [dist <= {zone_clust[clusmaxmag(my_cluster)]}]')
                end
                spatial_evs = l_recent | l_big;

                if ~any(spatial_evs)
                    continue
                end
                % ------------------------------------
                % one or more events have now passed both spatial and temporal window tests
                %
                % if there are events in this cluster that are already related to another
                % cluster, figure out the smallest cluster number. Then, assign all events
                % (both previously clustered and unclustered) to this new cluster number.
                % ------------------------------------

                % spatial events only include events AFTER i, not i itself
                % so vcl(events_in_any_cluster) is independent from vcl(i)

                candidates = temporal_evs(spatial_evs) ; % eqs that fit spatial and temporal criterion
                events_in_any_cluster = candidates(vcl(candidates) ~= 0);  % eqs which are already related with a cluster
                events_in_no_cluster = candidates(vcl(candidates) == 0);  % eqs that are not already in a cluster

                % if this cluster overlaps with any other cluster, then merge them
                % assign every event in all related clusters to the same (lowest) cluster number
                % set this cluster's maximum magnitude "clusmaxmag" to the largest magnitude of all combined events
                % set this cluster's clus_biggest_idx to the most recent largest event of all combined events

                if len(events_in_any_cluster) > 0
                    if not_classified
                        related_clust_nums = unique(vcl(events_in_any_cluster));
                    else
                        % include this cluster number in the reckoning
                        related_clust_nums = unique(np.hstack((vcl(events_in_any_cluster), my_cluster,)))
                    end
                    % associate all related events with my cluster
                    my_cluster = related_clust_nums(0);
                    vcl(i) = my_cluster;
                    vcl(candidates) = my_cluster;

                    for clustnum  = related_clust_nums
                        vcl(vcl == clustnum) = my_cluster;
                    end
                    events_in_my_cluster = vcl == my_cluster;
                    biggest_mag = np.max(mags(events_in_my_cluster));
                    biggest_mag_idx = find(mags == biggest_mag & events_in_my_cluster, 1, 'last');

                    % reset values for other clusters
                    clusmaxmag(related_clust_nums) = -inf;
                    clus_biggest_idx(related_clust_nums) = 0;

                    % assign values for this cluster
                    clusmaxmag(my_cluster) = biggest_mag;
                    clus_biggest_idx(my_cluster) = biggest_mag_idx;

                elseif my_cluster == 0
                    k = k + 1;
                    vcl(i) = k;
                    my_cluster = k;
                    clusmaxmag(my_cluster) = my_mag;
                    clus_biggest_idx(my_cluster) = i;
                else
                    pass  % no events found, and attached to existing cluster
                end
                % attach clustnumber to catalog yet unrelated to a cluster
                vcl(events_in_no_cluster) = my_cluster;

            end
            clustnum = vcl;
            eqs_in_clust = vcl > 0;
        end
        %}    
        
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
                        
            max_mag_in_cluster=[];
            idx_biggest_event_in_cluster=[];
            
            %% calculate interaction_zone  (1 value per event)
            
            interactzone_main_km = obj.InteractFormula.Reasenberg1985(obj.RawCatalog.Magnitude); %interaction zone for mainshock
            interactzone_in_clust_km = obj.rfact * interactzone_main_km;      %interaction zone if included in a cluster
            
            tau_min = days(obj.taumin);
            tau_max = days(obj.taumax);
            
            %calculation of the eq-time relative to 1902
            eqtime = days( obj.RawCatalog.Date - min(obj.RawCatalog.Date) );
            
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
                not_classified = my_cluster==0;
                assert(not_classified~=alreadyInCluster)
                
                % attach interaction time
                if not_classified
                    look_ahead_days = tau_min;
                else
                    if my_mag >= max_mag_in_cluster(my_cluster)
                        max_mag_in_cluster(my_cluster) = my_mag;
                        idx_biggest_event_in_cluster(my_cluster) = i;
                        look_ahead_days = tau_min;
                    else
                        bgdiff = eqtime(i) - eqtime(idx_biggest_event_in_cluster(my_cluster));
                        look_ahead_days = clustLookAheadTime(obj.xk, max_mag_in_cluster(my_cluster), obj.xmeff, bgdiff, obj.P);
                        look_ahead_days = confine_value(look_ahead_days, tau_min, tau_max);
                    end
                end
                
                %extract eqs that fit interation time window
                temporal_evs = timediff(i, look_ahead_days, clus, eqtime); %local version
                
                
                
                if isempty(temporal_evs)
                    continue;
                end
                
                % ---------------------------
                % only continue if events passed the time test
                % ---------------------------
                
                rtest1 = interactzone_in_clust_km(i);
                if look_ahead_days == obj.taumin
                    rtest2 = 0;
                else
                    rtest2 = interactzone_main_km(idx_biggest_event_in_cluster(my_cluster));
                end
                
                if alreadyInCluster                % if i is already related with a cluster
                    tm1 = clus(temporal_evs) ~= my_cluster;  % eqs with a clustnumber different than i
                    if any(tm1)
                        temporal_evs = temporal_evs(tm1);
                    end
                    bg_ev_for_dist = idx_biggest_event_in_cluster(my_cluster);
                else
                    bg_ev_for_dist = i;
                end
                
                %calculate distances from the epicenter of biggest and most recent eq
                [dist1,dist2]=distance2(i,bg_ev_for_dist,temporal_evs, obj.RawCatalog);
                
                %extract eqs that fit the spatial interaction time
                sl0 = dist1<= rtest1 | dist2<= rtest2;
                
                if ~any(sl0)
                    continue
                end
                
                % ----------
                % only continue if events passed the distance test
                % ----------
                
                ll = temporal_evs(sl0);            %eqs that fit spatial and temporal criterion
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
                    if clus(i) ~= my_cluster
                        clus(clus==clus(i)) = my_cluster;
                    end
                    
                    for j1 = sl2
                        if clus(j1) ~= my_cluster
                            clus(clus==clus(i)) = my_cluster;
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
                    clus(llb) = my_cluster;  %
                end
                    
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
            
            details.Latitude                = obj.RawCatalog.Y;
            details.Properties.VariableUnits(width(details)) = {'degrees'};
            
            details.Longitude               = obj.RawCatalog.X;
            details.Properties.VariableUnits(width(details)) = {'degrees'};
            
            details.Depth                   = obj.RawCatalog.Z;
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
            ZG.original     = obj.RawCatalog;    %save catalog in variable original
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
        function tau = clust_look_ahead_time(mag_big, dt_big, xk, xmeff, P)
            % CLUSTLOOKAHEAD calculate look ahead time for clustered events (days)
            deltam = (1-xk) .* mag_big - xmeff;
            if deltam < 0
                deltam = 0;
            end
            denom = 10.0 .^ ((deltam - 1) * (2/3));
            top = log(1 - P) * dt_big;
            tau = top / denom;
        end
                
        function h = AddMenuItem(parent, catalog, varargin)
            % create a menu item
            label = 'Reasenberg Decluster';
            h = uimenu(parent, 'Label', label,...
                'MenuSelectedFcn', @(~,~)ReasenbergDeclusterClass(catalog),...
                varargin{:});
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

%% helper 
function ac  = timediff(clus_idx, look_ahead_time, clus, eqtimes)
    % TIMEDIFF calculates the time difference between the ith and jth event
    % works with variable eqtime from function CLUSTIME
    % gives the indices ac of the eqs not already related to cluster k1
    % eqtimes should be sorted!
    %
    % clus_idx : ith cluster (ci)
    % look_ahead : look-ahead time (tau)
    % clus: clusters (length of catalog)
    % eqtimes: datetimes for event catalog, in days  [did not use duration because of overhead]
    %
    % tdiff: is time between jth event and eqtimes(clus_idx)
    % ac: index of each event within the cluster
    
    %assert(clus_idx <100, 'testing. remove me')
    
    comparetime = eqtimes(clus_idx);
    
    first_event = clus_idx + 1; % in cluster
    last_event = numel(eqtimes);
    max_elapsed = comparetime + look_ahead_time;
    
    if eqtimes(end) >= max_elapsed
        last_event = find(eqtimes(first_event : last_event) < max_elapsed, 1, 'last') + clus_idx;
    end
        
    if first_event == last_event
        % no additional events were found.
        ac = [];
        return
    end
    
    this_clusternum = clus(clus_idx);
    
    range = first_event : last_event;
    
    if this_clusternum == 0
        ac = range;
    else
        % indices of eqs not already related to this cluster
        ac = (find(clus(range) ~= this_clusternum)) + clus_idx;
    end
    ac = ac(:);
end

