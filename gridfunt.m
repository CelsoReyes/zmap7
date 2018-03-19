function [mytable, wasEvaluated]=gridfunt(obj, calculationFcn, modificationFcn)
    % [mytable, wasEvaluated]=GRIDFUNT(obj, calculationFcn, modificationFcn)
    
    %TODO delete me
    error('this is something that would be a member of ZmapGridFunction')
    assert(isa(obj,'ZmapGridFunction'));
    [...
        vals, ...
        nEvents, ...
        maxDists, ...
        maxMag, ...
        wasEvaluated...
        ] = gridfun( calculationFcn, catalog, zgrid, selcrit, numel(obj.CalcFields) );

    
    mytable = array2table(vals,'VariableNames', obj.CalcFields);

    useZ = ~isempty(obj.Grid.Z);
    if ~useZ
        descs=[obj.ReturnDetails(:,2),...
            {'Radius','Longitude','Latitude','Maximum magnitude at node',...
            'Number of events in node','was evaluated'}];
        units = [obj.ReturnDetails(:,3),{'km','deg','deg','mag','','logical'}];
        
    else
        descs=[obj.ReturnDetails(:,2),...
            {'Radius','Longitude','Latitude','Depth','Maximum magnitude at node',...
            'Number of events in node','was evaluated'}];
        
        units = [obj.ReturnDetails(:,3),{'km','deg','deg','km','mag','','logical'}];
    end
    
    mytable.Radius_km = maxDists;
    mytable.x=obj.Grid.X(:);
    mytable.y=obj.Grid.Y(:);
    if ~isempty(obj.Grid.Z)
        mytable.z=obj.Grid.Z(:);
    end
    mytable.max_mag = maxMag;
    mytable.Number_of_Events = nEvents;
    mytable.was_evaluated = wasEvaluated;
    
    mytable.Properties.VariableDescriptions = descs;
    mytable.Properties.VariableUnits = units;
    
    if exist('modificationFcn','var')
        mytable= modificationFcn(mytable);
    end
end