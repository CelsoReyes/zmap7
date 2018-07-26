classdef ZmapGridFunction < ZmapFunction
    % ZMAPGRIDFUNCTION is a ZmapFunction that produces a grid of 1 or more results as output
    % and can be plotted on a map
    %
    % see also ZMAPFUNCTION
    
    properties
        active_col      char                            = '';  % the name of the column of the results to be plotted
        showgridcenters matlab.lang.OnOffSwitchState    = matlab.lang.OnOffSwitchState.on; % toggle the grid points on and off.
        Grid                        {mustBeZmapGrid}    = ZmapGlobal.Data.Grid % ZmapGrid
        EventSelector               {EventSelectionChoice.mustBeEventSelector} = ZmapGlobal.Data.GridSelector% how to choose events for the grid points
        Shape                       {mustBeShape}       = ShapeGeneral % shape to be used 
        do_memoize                                      = true;
    end
    properties(Constant,Abstract)
        
        % array of {VariableNames, VariableDescriptions, VariableUnits}
        % that must contain the VariableNames: 'x', 'y', 'Radius_km', 'Number_of_Events'
        ReturnDetails; 
        
        % cell of VariableNames (chosen from first row of ReturnDetails) that
        % describe the data returned from the calculation function. [in order]
        CalcFields;
    end
    
    methods
        function obj=ZmapGridFunction(zap, active_col)
            % ZMAPGRIDFUNCTION constructor  assigns grid, event, catalog, and shape properties
            if isempty(zap)
                zap = ZmapAnalysisPkg.fromGlobal();
            end
            obj@ZmapFunction(zap.Catalog);
            
            obj.EventSelector = zap.EventSel;
            %obj.RawCatalog = zap.Catalog;
            obj.Grid = zap.Grid;
            obj.Shape = zap.Shape;
            
            obj.active_col=active_col;
        end
        
        function saveToDesktop(obj)
            % SAVETODESKTOP saves the grid, eventselector and shape before calling superclass
            obj.Result.Grid = obj.Grid;
            obj.Result.EventSelector = obj.EventSelector;
            obj.Result.Shape = obj.Shape;
            
            % super must be called last, since it does the actual writing
            saveToDesktop@ZmapFunction(obj) 
        end
        

    end
    methods(Access=protected)
        
        function allvalues=putInMatrix(obj, allvalues, fieldname, thesevalues)
            % put values into matrix based on position in ReturnDetails array
            %
            % PUTINMATRIX(obj,allvalues, fieldname, thesevalues)
            
            % returnFields = obj.ReturnDetails(:,1);
            % returnDesc = obj.ReturnDetails(:,2);
            % returnUnits = obj.ReturnDetails(:,3);
            
            allvalues(:,strcmp(fieldname,obj.ReturnDetails(:,1))) = thesevalues;
            
        end
            
        function gridCalculations(obj, calculationFcn, modificationFcn)
            % GRIDCALCULATIONS do requested calculation for each gridpoint and store result in obj.Result
            % GRIDCALCULATIONS(obj, calculationFcn, modificationfcn)
            %calculate values at all points
            %
            assert(isa(obj,'ZmapGridFunction'));
            [...
                    vals, ...
                    nEvents, ...
                    maxDists, ...
                    maxMag, ...
                    wasEvaluated...
                    ] = gridfun( calculationFcn, obj.RawCatalog, obj.Grid, obj.EventSelector, numel(obj.CalcFields) );
            mytable = array2table(vals,'VariableNames', obj.CalcFields);
            
            useZ = ~isempty(obj.Grid.Z);
            whichdetails = ismember(obj.ReturnDetails(:,1),obj.CalcFields);
            if ~useZ
                descs=[obj.ReturnDetails(whichdetails,2)',...
                    {'Radius','Longitude','Latitude','Maximum magnitude at node',...
                    'Number of events in node','was evaluated'}];
                units = [obj.ReturnDetails(whichdetails,3)',{'km','deg','deg','mag','','logical'}];
                
            else
                descs=[obj.ReturnDetails(whichdetails,2)',...
                    {'Radius','Longitude','Latitude','Depth','Maximum magnitude at node',...
                    'Number of events in node','was evaluated'}];
                
                units = [obj.ReturnDetails(whichdetails,3)', {'km','deg','deg','km','mag','','logical'}];
            end
            
            mytable.RadiusKm = maxDists;
            mytable.x=obj.Grid.X(:);
            mytable.y=obj.Grid.Y(:);
            if useZ
                mytable.z=obj.Grid.Z(:);
            end
            mytable.max_mag = maxMag;
            mytable.Number_of_Events = nEvents;
            mytable.was_evaluated = wasEvaluated;
            
            mytable.Properties.VariableDescriptions = descs;
            mytable.Properties.VariableUnits = units;
            
            if exist('modificationFcn','var')
                mytable= modificationFcn(mytable);
                
                % now tweak descriptions & units
                descriptions = mytable.Properties.VariableDescriptions;
                idxEmptyDesc=find(isempty(descriptions));
                
                for j=idxEmptyDesc % for each empty description field
                    row=strcmp(obj.ReturnDetails(:,1),mytable.Properties.VariableNames{j});
                    if ~any(row)
                        warning('Could not find matching description for %s',...
                            mytable.Properties.VariableNames{j});
                    end
                    mytable.Properties.VariableDescriptions(j)=obj.ReturnDetails(row,2);
                    mytable.Properteis.VariableUnits(j)=obj.ReturnDetails(row,3);
                end
                    
                    
            end
            obj.Result.values=mytable;
        end
        
        function togglegrid_cb(obj,src,~)
            gph=findobj(gcf,'tag','pointgrid');
            if isempty(gph)
                gph=obj.Grid.plot();
                gph.Tag='pointgrid';
                gph.PickableParts='none';
                gph.Visible=char(obj.showgridcenters);
            end
            switch src.Checked
                case 'on'
                    src.Checked='off';
                    gph.Visible='off';
                    obj.showgridcenters = matlab.lang.OnOffSwitchState.off;
                case 'off'
                    src.Checked='on';
                    gph.Visible='on';
                    obj.showgridcenters = matlab.lang.OnOffSwitchState.on;
            end
        end
        
        function [numeric_choice, name, desc, units] = ActiveDataColumnDetails(obj, choice)
            if ~exist('choice','var')
                choice = obj.active_col;
            end
            
            if ~isnumeric(choice)
                numeric_choice = find(strcmp(obj.Result.values.Properties.VariableNames, choice));
            else
                numeric_choice = choice;
            end
            
            desc = obj.Result.values.Properties.VariableDescriptions{numeric_choice};
            name = obj.Result.values.Properties.VariableNames{numeric_choice};
            units = obj.Result.values.Properties.VariableUnits{choice};
            
        end
    end % Protected methods
    
    methods(Access=protected, Static)
        
        function txt = mydatacursor(~,event_obj)
            try
                % wrapped in Try-Catch because the datacursor routines fail relatively quietly on
                % errors. They simply mention that they couldn't update the datatip.
                
                pos=get(event_obj,'Position');
                
                im=event_obj.Target;
                details=im.UserData.vals(abs(im.UserData.vals.x - pos(1))<=.0001 & abs(im.UserData.vals.y-pos(2))<=.0001,:);
            catch ME
                
                disp(ME.message)
                ME
            end
            try
                mymapval=details.(im.UserData.myname);
                if isnumeric(mymapval)
                    trans=@(x)num2str(mymapval);
                elseif isa('datetime','val') || isa('duration','val')
                    trans=@(x)char(mymapval);
                else
                    trans=@(x)x;
                end
                txt={sprintf('Map Value [%s] : %s %s\n%s\n-------------',...
                    im.UserData.myname, trans(mymapval), im.UserData.myunit, im.UserData.mydesc)};
                for n=1:width(details)
                    fld=details.Properties.VariableNames{n};
                    val=details.(fld);
                    units=details.Properties.VariableUnits{n};
                    if isnumeric(val)
                        trans=@(x)num2str(val);
                    elseif isa('datetime','val') || isa('duration','val')
                        trans=@(x)char(val);
                    else
                        trans=@(x)x;
                    end
                    txt=[txt,{sprintf('%-10s : %s %s',fld, trans(val), units)}];
                end
                
            catch ME
                ME
                disp(ME.message)
            end
        end
    end % Protected STATIC methods
end

%% nice-to-have functionality for gridfucntions or its children:
    %     Threshold: You can set the maximum size that
    %       a volume is allowed to have in order to be
    % displayed in the map. Therefore, areas with
    % a low seismicity rate are not displayed.
    % edit the size (in km) and click the mouse
    % outside the edit window.
    %    FixAx: You can chose the minimum and maximum
    %values of the color-legend used.
    %    Polygon: You can select earthquakes in a
    %     polygon either by entering the coordinates or
    %     defining the corners with the mouse
    %
    %    Circle: Select earthquakes in a circular volume:
    %    Ni, the number of selected earthquakes can
    %    be edited in the upper right corner of the
    %    window.
    %     Refresh Window: Redraws the figure, erases
    %     selected events.
    %
    %     zoom: Selecting Axis -> zoom on allows you to
    %     zoom into a region. Click and drag with
    %     the left mouse button. type <help zoom>
    %     for details.
    %     Aspect: select one of the aspect ratio options
    %     Text: You can select text items by clicking.The
    %     selected text can be rotated, moved, you
    %     can change the font size etc.
    %     Double click on text allows editing it.