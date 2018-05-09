function DisplayResultInfo(obj)
		%displays result infos and asks for further analysis
		
		switch obj.CalcMode
			case 'Reasenberg' 
				foundClusters=numel(unique(obj.CalcRes.clusterID(~isnan(obj.CalcRes.clusterID))));
				inCluster=sum(obj.CalcRes.EventType>1);
				notCluster=sum(obj.CalcRes.EventType<=1);
				if iscell(obj.CalcRes.AlgoInfo.ClusterLengths);
					longestClust=max(obj.CalcRes.AlgoInfo.ClusterLengths{2});
				else
					longestClust=max(obj.CalcRes.AlgoInfo.ClusterLengths(:,2));
				end
				
				infoText={'Reasenberg declustering finished';...
					  ['Calculation Time: ',num2str(obj.CalcTime/60),' min'];... 
					  ['Number of Clusters: ',num2str(foundClusters)];...
					  ['Total Eq in the Clusters: ',num2str(inCluster)];...
					  ['Total Eq unclustered: ',num2str(notCluster)];...
					  ['LongestCluster: ',num2str(longestClust)]};
					  
				h = msgbox('Declustering is finished and has been applied to the catalog, the different parts can be switch on and off in the Commander','Calculation finished','none');
				h1 = msgbox(infoText,'Declustering Info','help');	  
					  
				%ask if further analysis is wanted;
				%Later, I need the viewer first
				
				
			case 'MonteReasenberg'
			
			
			
			case 'Gardner-Knopoff'
				foundClusters=numel(unique(obj.CalcRes.clusterID(~isnan(obj.CalcRes.clusterID))));
				inCluster=sum(obj.CalcRes.EventType>1);
				notCluster=sum(obj.CalcRes.EventType<=1);
				if iscell(obj.CalcRes.AlgoInfo.ClusterLengths);
					longestClust=max(obj.CalcRes.AlgoInfo.ClusterLengths{1});
				else
					longestClust=max(obj.CalcRes.AlgoInfo.ClusterLengths(:,1));
				end
				
				infoText={'Gardner-Knopoff declustering finished';...
					  ['Calculation Time: ',num2str(obj.CalcTime/60),' min'];... 
					  ['Number of Clusters: ',num2str(foundClusters)];...
					  ['Total Eq in the Clusters: ',num2str(inCluster)];...
					  ['Total Eq unclustered: ',num2str(notCluster)];...
					  ['LongestCluster: ',num2str(longestClust)]};
					  
				h = msgbox('Declustering is finished and has been applied to the catalog, the different parts can be switch on and off in the Commander','Calculation finished','none');
				h1 = msgbox(infoText,'Declustering Info','help');	  
					  
				%ask if further analysis is wanted;
				%Later, I need the viewer first
				
			case 'SLIDER'
				foundClusters=numel(unique(obj.CalcRes.clusterID(~isnan(obj.CalcRes.clusterID))));
				inCluster=sum(obj.CalcRes.EventType>1);
				notCluster=sum(obj.CalcRes.EventType<=1);
				
				infoText={'SLIDER declustering finished';...
					  ['Calculation Time: ',num2str(obj.CalcTime/60),' min'];... 
					  ['Number of Clusters: ',num2str(foundClusters)];...
					  ['Total Eq in the Clusters: ',num2str(inCluster)];...
					  ['Total Eq unclustered: ',num2str(notCluster)]};
			
				
				h = msgbox('Declustering is finished and has been applied to the catalog, the different parts can be switch on and off in the Commander','Calculation finished','none');
				h1 = msgbox(infoText,'Declustering Info','help');
	
		end
		
		
end