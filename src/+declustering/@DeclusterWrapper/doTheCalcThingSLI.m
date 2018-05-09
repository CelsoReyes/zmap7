function doTheCalcThingSLI(obj)
		%everything for the calculation itself goes in here
		import mapseis.projector.*;
		import mapseis.declustering.*;
		
		
		%get parameter into variables
		ShortCat = getShortCatalog(obj.Datastore,obj.SendedEvents);
		Sli_Type=obj.CalcParameter.Sli_Type;
		MainMag=obj.CalcParameter.MainMag;
		BackTime=obj.CalcParameter.BackTime;
		ForeTime=obj.CalcParameter.ForeTime;
		MinRad=obj.CalcParameter.MinRad;
		MagRadScale=obj.CalcParameter.MagRadScale;
		MagRadConst=obj.CalcParameter.MagRadConst;

	
		
		
		if Sli_Type==1
			%run declustering with magnitude
			disp('please wait....');
			tic;
			[clusterID,EventType,AlgoInfo] = clusterSLIDERmag(ShortCat,MainMag,BackTime,ForeTime,MinRad,MagRadScale,MagRadConst);
			obj.CalcTime=toc;
			disp('finished!');
			
		elseif Sli_Type==2
			%run declustering with time
			disp('please wait....');
			tic;
			[clusterID,EventType,AlgoInfo] = clusterSLIDERtime(ShortCat,MainMag,BackTime,ForeTime,MinRad,MagRadScale,MagRadConst);
			obj.CalcTime=toc;
			disp('finished!');
		
		end
		
		
		%store result
		obj.CalcRes.clusterID=clusterID;
		obj.CalcRes.EventType=EventType;
		obj.CalcRes.AlgoInfo=AlgoInfo;
		
		%write to datastore
		obj.Datastore.setDeclusterData(EventType,clusterID,obj.SendedEvents,[]);
		obj.Datastore.DeclusterMetaData=AlgoInfo;
		
		%correct for old datastore version, it makes sense to do this here, because it is needed only by the declustering
		NumberedUserData=getNumberedFields(obj.Datastore);
		setNumberedFields(obj.Datastore,union(NumberedUserData,{'Month','Day','Hour','Minute','Second','MilliSecond','DecYear'}));
    

end