classdef ZaliapinDeclusterClass < ZmapFunction
    % Zaliapin Declustering Codes
    
    % inital code by Shyam Nandan, Conformed to ZMAP by Celso Reyes
    % TOFIX this isn't really hooked up yet, it's half Zaliapin and half reasenberg
    properties
        fractalDimension    double = 1
        bvalue              double = 1
        theta               double = 1
        threshhold          double = nan
        
        %declustRoutine      = "ReasenbergDeclus"
        declusteredCatalog   ZmapCatalog
        
         % if empty, clustering details will not be saved to workspace
        clusterDetailsVariableName          char    = 'cluster_details'
        
        % if empty, catalog will not be saved to workspace
        declusteredCatalogVariableName      char    = 'declustered_catalog' 
        memorizeOriginalCatalog             logical = true
    end
    
    properties(Constant)
        PlotTag = "ZaliapinDecluster"
        
        ParameterableProperties = ["fractalDimension", "bvalue", "theta",...
            "clusterDetailsVariableName",...
            "declusteredCatalogVariableName",...
            "memorizeOriginalCatalog"];
        
        References = ['Zaliapin, I., Gabrielov, A., Keilis-Borok, V. and Wong, H., 2008.', ...
            'Clustering analysis of seismicity and aftershock identification. ', ...
            'Physical review letters, 101(1), p.018501.'];
        
    end
    
    methods
        function obj = ZaliapinDeclusterClass(catalog, varargin)
            
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
            zdlg.AddHeader('Zaliapin Declustering parameters','FontSize',12);
            zdlg.AddHeader('Delustering factors');
            zdlg.AddEdit('fractalDimension' , 'Fractal Dimension' , obj.fractalDimension, '<b>fractalDimension</b> weight for spatial distance');
            zdlg.AddEdit('theta'            , 'Theta'             , obj.theta, '<b>theta</b> weight for temporal distance');
            zdlg.AddEdit('bvalue'           , 'B value'           , obj.bvalue, '<b>Bvalue</b> used to weight magnitude distance');
            zdlg.AddHeader('');
            zdlg.AddEdit('threshhold'       , 'Cluster Threshhold', obj.threshhold,'<b>threshhold</b>Independence Probabilities above threshold considered cluster ');
            % zdlg.AddHeader('');
            % zdlg.AddHeader('Output')
            zdlg.AddEdit('clusterDetailsVariableName',      'Save Clusters to workspace as', ...
                obj.clusterDetailsVariableName, 'if empty, then nothing will be separately saved');
            zdlg.AddEdit('declusteredCatalogVariableName',  'Save Declustered catalog to workspace as', ...
                obj.declusteredCatalogVariableName,'if empty, then nothing will be separately saved');
            zdlg.AddCheckbox('memorizeOriginalCatalog',     'Memorize Original catalog after sucessful decluster:', ...
                obj.memorizeOriginalCatalog, {}, 'Memorize original catalog prior to declustering');
            
            
            
            zdlg.Create('Name', 'Zaliapin Declustering','WriteToObj',obj,'OkFcn',@obj.Calculate);
          
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
            
            
            
            
            totalEvents = obj.RawCatalog.Count;
            evDay = days(obj.RawCatalog.Date - min(obj.RawCatalog.Date));
            [y,x] = geodetic2ned(obj.RawCatalog.Latitude, obj.RawCatalog.Longitude, 0,...
                median(obj.RawCatalog.Latitude), median(obj.RawCatalog.Longitude), 0,...
                obj.RawCatalog.RefEllipsoid);
            
            
            xy_km = [x,y];
            mag = obj.RawCatalog.Magnitude;
            
            nearestNeighborDist   = nan(totalEvents,1);
            
            pdist_yk_ver2 = @(A,B) sqrt((B(:,1) - A(1)).^2 + (B(:,2)-A(2)).^2);
            
            
            wai = waitbar(0,' Please Wait ...  Declustering the catalog');
            set(wai,'NumberTitle','off','Name','Declustering Progress');
            drawnow
            declustering_start = tic;
            %for every earthquake in catalog, main loop
            effective_magnitudes = 10 .^ (-obj.bvalue * mag);
            for fromEv=2:totalEvents
                
                if rem(fromEv,50)==0
                    waitbar(fromEv / (obj.RawCatalog.Count-1));
                end
                
                toEv = 1:(fromEv-1);
                deltaDist    = pdist_yk_ver2(xy_km(fromEv,:), xy_km(toEv,:)) .^ obj.fractalDimension;
                deltaTime    = (evDay(fromEv) - evDay(toEv)) .^ obj.theta;
                
                nearestNeighborDist(fromEv) = min( deltaDist .* deltaTime .* effective_magnitudes(toEv) );
            end
            
            nearestNeighborDist(nearestNeighborDist == 0) = nan;
            logNearestNeighborDist = log10(nearestNeighborDist);
             
            % Fit a Gaussian mixture distribution to data
            gmmObj = fitgmdist(logNearestNeighborDist,2);
            
            % mu is the mean for each found gaussian curve.  The larger value of mu represents
            % the curve matching the background events. It is this value that provides the 
            % independence probabilities, which we return.
            
            [~, indbkg] = max(gmmObj.mu);  % mu is Matrix of component means.
            IP = gmmObj.posterior(logNearestNeighborDist);
            
            IP = IP(:,indbkg);
            IP(1) = 1;
            IP(isnan(IP)) = 0;
            
            close(wai);
            msg.dbfprintf('Declustering complete. It took %g seconds\n',toc(declustering_start));
            
            %% this table contains all we need to know about the clusters. maybe.
            details = table;
            details.Properties.UserData = struct;
            for j = 1 : numel(obj.ParameterableProperties)
                details.Properties.UserData.(obj.ParameterableProperties(j)) = obj.(obj.ParameterableProperties(j));
            end
            
            details.Properties.Description  = 'Details for cluster, from Zaliapin declustering';
            details.IndependenceProbability = IP;
            details.eventNumber             = (1:obj.RawCatalog.Count)';
            %details.isBiggest               = false(size(details.clusterNumber));
            %details.isBiggest(idx_biggest_event_in_cluster) = true;
            
            details.Latitude                = obj.RawCatalog.Y;
            details.Properties.VariableUnits(width(details)) = {'degrees'};
            
            details.Longitude               = obj.RawCatalog.X;
            details.Properties.VariableUnits(width(details)) = {'degrees'};
            
            details.Depth                   = obj.RawCatalog.Z;
            details.Properties.VariableUnits(width(details)) = {'kilometers'};
            
            details.Magnitude               = obj.RawCatalog.Magnitude;
            
            details.MagnitudeType           = obj.RawCatalog.MagnitudeType;
            
            details.Date                    = obj.RawCatalog.Date;
            
            clusterFreeCatalog = obj.RawCatalog.subset(ismissing(details.IndependenceProbability >= obj.threshhold ));
            %biggest_events_in_cluster = obj.RawCatalog.subset(details.isBiggest);
            
            outputcatalog = clusterFreeCatalog;
            
            if ~any(clus)
                return
            end
            
            
            %build a matrix clust that stored clusters
            [~, biggest_events_in_cluster, max_mag_in_cluster,~,~] = funBuildclu(obj.RawCatalog, idx_biggest_event_in_cluster, clus, max_mag_in_cluster);
            
            
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
            f = figure('Name','Zaliapin Deslustering Results');
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
        function h = AddMenuItem(parent, catalog, varargin)
            % create a menu item
            label = 'Zaliapin Decluster';
            h = uimenu(parent, 'Label', label,...
                MenuSelectedField(), @(~,~)ZaliapinDeclusterClass(catalog),...
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

