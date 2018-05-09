function doTheCalcThingGK(obj)
		%everything for the calculation itself goes in here
		import mapseis.projector.*;
		import mapseis.declustering.*;
		
		
		%get parameter into variables
		ZmapCatalog = getZMAPFormat(obj.Datastore,obj.SendedEvents);
		WinMethod=obj.CalcParameter.GK_Method;
		SetMain=obj.CalcParameter.GK_SetMain;
	
		
		
		
		%run declustering
		disp('please wait....');
		tic;
		[clusterID,EventType,AlgoInfo] = calc_decluster_gardKnop(ZmapCatalog,WinMethod,SetMain);
		obj.CalcTime=toc;
		disp('finished!');
		
		%store result
		obj.CalcRes.clusterID=clusterID;
		obj.CalcRes.EventType=EventType;
		obj.CalcRes.AlgoInfo=AlgoInfo;
		
		%write to datastore
		obj.Datastore.setDeclusterData(EventType,clusterID,obj.SendedEvents,[]);
		obj.Datastore.DeclusterMetaData=AlgoInfo;
		
		%correct for old datastore version, it makes sense to do this here, because it is needed only by the declustering
		NumberedUserData=getNumberedFields(obj.Datastore);
		setNumberedFields(obj.Datastore,union(NumberedUserData,{'Month','Day','Hour','Minute','Second','MilliSecond' ,'DecYear'}));
    
	
	
end