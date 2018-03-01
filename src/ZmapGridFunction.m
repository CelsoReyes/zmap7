classdef ZmapGridFunction < ZmapFunction
    % ZMAPGRIDFUNCTION is a ZmapFunction that produces a grid of 1 or more results as output
    % and can be plotted on a map
    %
    % see also ZMAPFUNCTION
    
    properties
        active_col='';  % the name of the column of the results to be plotted
        showgridcenters=true; % toggle the grid points on and off.
        Grid % ZmapGrid
        EventSelector % how to choose events for the grid points
        Shape % shape to be used 
    end
    properties(Constant,Abstract)
        % array of {VariableNames, VariableDescriptions, VariableUnits}
        % that must contain the VariableNames: 'x', 'y', 'Radius_km', 'Number_of_Events'
        ReturnDetails; 
    end
    
    methods
        function obj=ZmapGridFunction(zap, active_col)
            % ZMAPGRIDFUNCTION constructor  assigns grid, event, catalog, and shape properties
            if isempty(zap)
                zap = ZmapAnalysisPkg.fromGlobal();
            end
            
            ZmapFunction.verify_catalog(zap.Catalog);
            
            obj.EventSelector = zap.EventSel;
            obj.RawCatalog = zap.Catalog;
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
        function gridCalculations(obj, calculationFcn, nReturnValuesPerPoint, modificationFcn)
            % GRIDCALCULATIONS do requested calculation for each gridpoint and store result in obj.Result
            % GRIDCALCULATIONS(obj, calculationFcn, nReturnValuesPerPoint)
            %calculate values at all points
             [vals,nEvents,maxDists,maxMag, ll]=gridfun(calculationFcn,...
                obj.RawCatalog, ...
                obj.Grid, ...
                obj.EventSelector,...
                nReturnValuesPerPoint);
            
            
            returnFields = obj.ReturnDetails(:,1);
            returnDesc = obj.ReturnDetails(:,2);
            returnUnits = obj.ReturnDetails(:,3);
            
            
            vals(:,strcmp('x',returnFields))=obj.Grid.X(:);
            vals(:,strcmp('y',returnFields))=obj.Grid.Y(:);
            if ~isempty(obj.Grid.Z)
                vals(:,strcmp('z',returnFields))=obj.Grid.Z(:);
            end
            
            vals(:,strcmp('Number_of_Events',returnFields))=nEvents;
            vals(:,strcmp('Radius_km',returnFields))=maxDists;
            vals(:,strcmp('max_mag',returnFields))=maxMag;
            
            if exist('modificationFcn','var')
                vals= modificationFcn(vals);
            end
            
            myvalues = array2table(vals,'VariableNames', returnFields);
            myvalues.Properties.VariableDescriptions = returnDesc;
            myvalues.Properties.VariableUnits = returnUnits;
            
            obj.Result.values=myvalues;
        end
        
        function togglegrid_cb(src,~)
            gph=findobj(gcf,'tag','pointgrid');
            if isempty(gph)
                gph=obj.Grid.plot();
                gph.Tag='pointgrid';
                gph.PickableParts='none';
                gph.Visible=tf2onoff(obj.showgridcenters);
            end
            switch src.Checked
                case 'on'
                    src.Checked='off';
                    gph.Visible='off';
                    obj.showgridcenters=false;
                case 'off'
                    src.Checked='on';
                    gph.Visible='on';
                    obj.showgridcenters=true;
            end
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