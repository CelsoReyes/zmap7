function doTheCalcThing(obj)
		%everything for the calculation itself goes in here
		%import mapseis.projector.*;
		import declustering.*;
		
		
		%get parameter into variables
		ShortCatalog = getShortCatalog(obj.Datastore.catalog,obj.SendedEvents);
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
		[clusterID,EventType,AlgoInfo] = ReasenbergDecluster(taumin,taumax,xk,xmeff,P,rfact,err,derr,ShortCatalog);
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
		NumberedUserData=obj.Datastore.NumberedUserData;
		obj.Datastore.NumberedUserData=union(NumberedUserData,{'Month','Day','Hour','Minute','Second','MilliSecond' ,'DecYear'});
    

end

function sc = getShortCatalog(catalog,rowIndices,PaleRider)
    % getShortCatalog : This projector builds a catalog similar in a way to the zmap 
	%		    type catalog but with the following coulumns:
	%		    [lon lat depth datennum mag]
    %
    % modified from MatSeis
    
    if isempty(rowIndices)
        rowIndices=true(catalog.Count, 1);
    end
    sc=[catalog.Longitude(rowIndices), catalog.Longitude(rowIndices), catalog.Depth(rowIndices), datenum(catalog.Date(rowIndices)), catalog.Magnitude(rowIndices)];
end
    