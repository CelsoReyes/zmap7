classdef ZmapGridFunction < ZmapFunction
    % ZMAPGRIDFUNCTION is a ZmapFunction that produces a grid of 1 or more results as output
    % and can be plotted on a map
    %
    % see also ZMAPFUNCTION
    
    properties
        active_col      char                            = '';  % the name of the column of the results to be plotted
        showgridcenters matlab.lang.OnOffSwitchState    = matlab.lang.OnOffSwitchState.on; % toggle the grid points on and off.
        Grid                        {mustBeZmapGrid}    = ZmapGlobal.Data.Grid % ZmapGrid
        EventSelector   EventSelectionParameters        = ZmapGlobal.Data.GridSelector% how to choose events for the grid points
        NodeMinEventCount   double {mustBeInteger}     = 1; % minimum number of events in a sample for that sample to be calculated
        OverallMinEventCount   double {mustBeInteger}  = 1; % minimum number of events in catalog, for calculations to operate
        Shape                       {mustBeShape}       = ShapeGeneral % shape to be used
        do_memoize                                      = false;
    end
    properties(Constant,Abstract)
        
        % table with columns: Names, Descriptions, Units
        ReturnDetails;
        
        % cell of VariableNames (chosen from first row of ReturnDetails) that
        % describe the data returned from the calculation function. [in order]
        CalcFields;
        Type; %XY, XZ, XYZ
    end
    
    methods
        function obj=ZmapGridFunction(zap, active_col)
            % ZMAPGRIDFUNCTION constructor  assigns grid, event, catalog, and shape properties
            obj@ZmapFunction();
            %obj@ZmapFunction(zap.Catalog);
            if isempty(zap) || ~isa(zap,'ZmapAnalysisPkg')
                %zap = ZmapAnalysisPkg.fromGlobal();
                zap = obj.ZAPfrom(zap);
            end
            obj.RawCatalog = zap.Catalog;
            
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
        
        function obj=set.EventSelector(obj,value)
            if isa(value,'EventSelectionParameters')
                obj.EventSelector = value;
            else
                obj.EventSelector = EventSelectionParameters.fromStruct(value);
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
        
    end
    methods(Access=protected)
        
        function allvalues=putInMatrix(obj, allvalues, fieldname, thesevalues)
            % put values into matrix based on position in ReturnDetails array
            %
            % PUTINMATRIX(obj,allvalues, fieldname, thesevalues)
            
            % returnFields = obj.ReturnDetails.Names;
            % returnDesc = obj.ReturnDetails.Descriptions;
            % returnUnits = obj.ReturnDetails.Units;
            fieldname = string(fieldname);
            
            assert (isequal(strcmp(fieldname,obj.ReturnDetails.Names) ,...
                fieldbname == obj.ReturnDetails.Names)); % if this doesn't trigger,leave the following
            allvalues(:, fieldname == obj.ReturnDetails.Names ) = thesevalues;
            % allvalues(:,strcmp(fieldname,obj.ReturnDetails.Names)) = thesevalues;
            
        end
        
        function gridCalculations(obj, calculationFcn, modificationFcn)
            % GRIDCALCULATIONS perform calculation at each gridpoint, storing result in obj.Result
            % GRIDCALCULATIONS(obj, calculationFcn, modificationfcn)
            % calculate values at all points
            %
            % 1. Determine the sample catalogs, based on existing object properties
            % 2. calculate metrics for each sample catalog. 
            % 3. Turn results into an annotated table, stored in obj.ReturnDetails
            %
            % And if modificationFcn is provided....
            %
            % 4. Run the modificationFcn on obj.ReturnDetails.  eg:
            %    myResultsTable = modificationFcn(myResultsTable)
            %
            % The idea is that additional calculations that rely upon calculated table values
            % may be done outside the main spatial loop. Generally, these are confined to
            % matrix/vector operations.
            
            [...
                vals, ...
                nEvents, ...
                maxDists, ...
                maxMag, ...
                wasEvaluated...
                ] = gridfun( calculationFcn, obj.RawCatalog, obj.Grid, obj.EventSelector, obj.NodeMinEventCount ,numel(obj.CalcFields), 'noreshape' );
            mytable = array2table(vals,'VariableNames', obj.CalcFields);
            
            useZ = ~isempty(obj.Grid.Z);
            whichdetails = ismember(obj.ReturnDetails.Names, obj.CalcFields);
            if ~useZ
                descs=[obj.ReturnDetails.Descriptions(whichdetails)',...
                    {'Radius','Longitude','Latitude','Maximum magnitude at node',...
                    'Number of events in node','was evaluated'}];
                units = [obj.ReturnDetails.Units(whichdetails)',{'km','deg','deg','mag','','logical'}];
                
            else
                descs=[obj.ReturnDetails.Descriptions(whichdetails)',...
                    {'Radius','Longitude','Latitude','Depth','Maximum magnitude at node',...
                    'Number of events in node','was evaluated'}];
                
                units = [obj.ReturnDetails.Units(whichdetails)', {'km','deg','deg','km','mag','','logical'}];
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
                    row=strcmp(obj.ReturnDetails.Names,mytable.Properties.VariableNames{j});
                    if ~any(row)
                        warning('ZMAP:missingDescription','Could not find matching description for %s',...
                            mytable.Properties.VariableNames{j});
                    end
                    mytable.Properties.VariableDescriptions(j)=obj.ReturnDetails.Units(row);
                    mytable.Properties.VariableUnits(j)=obj.ReturnDetails.Units(row);
                end
                
                
            end
            obj.Result(1).values=mytable;
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
        
        function add_grid_centers(obj)
            % show grid centers, but don't make them clickable
            report_this_filefun();
            dbk=dbstack(1);
            disp(dbk(1).name);
            
            gph=obj.Grid.plot(gca,'ActiveOnly');
            gph.Tag='pointgrid';
            gph.PickableParts='none';
            gph.Visible=char(obj.showgridcenters);
        end
        
        
        function AddDialogOption(obj, zdlg, choice)
            switch choice
                case 'NodeMinEventCount'
                    zdlg.AddEdit('NodeMinEventCount',   'Min. # events > Mc (per node)',...
                        obj.NodeMinEventCount, 'Min # events greater than magnitude of completeness (Mc) at each node');
                    
                case 'OverallMinEventCount'
                    zdlg.AddEdit('NodeMinEventCount',   'Min. # events > Mc (overall)',...
                        obj.NodeMinEventCount, 'Min # events in catalog greater than magnitude of completeness (Mc)');
                    
                case 'EventSelector'
                    zdlg.AddEventSelector('EventSelector', obj.EventSelector)
                    
                case 'active_col'
                    unimplemented_error();
                    
                otherwise
                    error('unrecognized dialog option');
            end
            
        end
        
        function zapObj=ZAPfrom(obj, v)
            
            if isempty(v)
                zapObj = ZmapAnalysisPkg.fromGlobal();
                return
            end
            
            if ZmapGlobal.Data.Interactive
                errfn = @errordlg;
            else
                errfn = @error;
            end
            
            if ischarlike(v)
                vn = genvarname(v); % make it safe!
                if v ~= vn
                    errfn("[" + v + "] is not a valid variable name");
                    return
                end
                try
                    vl=evalin('base',char("whos('" + v + "')"));
                catch ME
                    errfn(ME.message,ME.identifier);
                    return
                end
                if numel(vl)==1
                    v = evalin('base',vl.name);
                elseif isempty(vl)
                    errfn("No variable named [" + v + "] found in base");
                    return
                else
                    errfn('unexpected error');
                    return
                end
            end
            
            switch class(v)
                case 'ZmapData'
                    % create ZAP from ZmapData
                    zapObj = ZmapAnalysisPkg.fromGlobal('primeCatalog');
                case 'ZmapMainWindow'
                    % create ZAP from the main window
                    switch obj.Type
                        case 'XY'
                            zapObj = v.map_zap;
                        case 'XZ'
                            zapObj = v.xsec_zap;
                        case 'xyz'
                            error("unimplemented");
                        otherwise
                            error("unimplemented");
                    end
                otherwise
                    errfn('do not know what to do with this')
            end
            %ZmapAnalysisPkg();
        end
        
           
    end % Protected methods
    
    methods(Static) % was protected
        
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
        
        function cb_deleteTab(src,ev)
            % also delete the selection lines
            watchon
            drawnow nocallbacks
            
            tagBase = src.Tag;
            tg=ancestor(src,'uitabgroup');
            mySelectionChangedEvent = struct('OldValue', src, 'NewValue', ...
                findobj(tg.Children','flat','Tag','mainmap_tab'));
            tg.SelectionChangedFcn([],mySelectionChangedEvent);
            regexp_str = tagBase + " .*selection";
            delete(findobj(ancestor(src,'figure'),'-regexp','Tag',regexp_str));
            watchoff
        end
        
        function cb_changecontours(src,ev)
            activeTab=get(findobj(gcf,'Tag','main plots'),'SelectedTab');
            ax=findobj(activeTab.Children,'Type','axes','-and','Tag','result_map');
            changecontours(ax)
        end
        function cb_shading(val)
            % must be in function because ax must be evaluated in real-time
            activeTab = get(findobj(gcf,'Tag','main plots'),'SelectedTab');
            ax = findobj(activeTab.Children,'Type','axes','-and','Tag','result_map');
            shading(ax, val)
        end
        
        function cb_brighten(val)
            activeTab=get(findobj(gcf,'Tag','main plots'),'SelectedTab');
            ax=findobj(activeTab.Children,'Type','axes','-and','Tag','result_map');
            cm=colormap(ax);
            colormap(ax,brighten(cm,val));
        end
        
        function cb_alpha(val)
            activeTab=get(findobj(gcf,'Tag','main plots'),'SelectedTab');
            ax=findobj(activeTab.Children,'Type','axes','-and','Tag','result_map');
            ss = findobj(ax.Children,'Tag','result overlay');
            if isprop(ss,'FaceAlpha')
                newAlpha = ss.FaceAlpha + val;
                if newAlpha < 0; newAlpha = 0; end
                if newAlpha > 1; newAlpha = 1; end
                alpha(ss,newAlpha);
            else
                beep;
                fprintf('alpha not supported for %s\n',ss.Type);
            end
        end
        
    end % Protected STATIC methods
end

%% nice-to-have functionality for gridfunctions or its children:
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