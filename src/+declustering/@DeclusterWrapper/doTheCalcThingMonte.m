function doTheCalcThingMonte(obj)
		%everything for the calculation itself goes in here
		import mapseis.projector.*;
		import mapseis.calc.declustering.*;
		
		
		%Calculation with an added MonteCarlo simulation
		%(the things done by Thomas Van Stiphout) 
		%LATER, first to the normal version
		
		
		%What the monte-carlo reasenberg does is simple
		
		
		%get parameter into variables
		ShortCatalog = getShortCatalog(obj.Datastore,obj.SendedEvents);
		taumin=obj.CalcParameter.Tau_min;
		taumax=obj.CalcParameter.Tau_max;
		xk=obj.CalcParameter.XMagFactor;
		xmeff=obj.CalcParameter.XMagEff;
		P=obj.CalcParameter.ProbObs;
		rfact=obj.CalcParameter.RadiusFactor;
		err=obj.CalcParameter.EpiError;
		derr=obj.CalcParameter.DepthError;
		
		
		%run declustering
		disp('please wait....');
		
		tic;
		[clusterID,EventType,AlgoInfo] = ReasenbergDecluster(taumin,taumax,xk,xmeff,P,rfact,err,derr,ShortCat);
		obj.CalcTime=toc;
		disp('finished!');
		
		
		%store result
		obj.CalcRes.clusterID=clusterID;
		obj.EventType=EventType;
		obj.AlgoInfo=AlgoInfo;
		
		%write to datastore
		obj.Datastore.setDeclusterData(EventType,clusterID,obj.SendedEvents,[]);
		obj.Datastore.DeclusterMetaData=AlgoInfo;
		
		%correct for old datastore version, it makes sense to do this here, because it is needed only by the declustering
		NumberedUserData=getNumberedFields(obj.Datastore);
		setNumberedFields(obj.Datastore,union(NumberedUserData,{'Month','Day','Hour','Minute','Second','MilliSecond' ,'DecYear'}));

end