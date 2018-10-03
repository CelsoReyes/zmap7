classdef ZmapTimeFunction < ZmapFunction
    % ZMAPTimeFUNCTION is a ZmapFunction that produces results that vary through time, but are NOT spatially dependent
    %
    % see also ZMAPFUNCTION
    
    properties
        active_col        char            = ''           % the name of the column of the results to be plotted
        WindowDuration    duration        = seconds(nan) % size of analysis window
        TimeStep          duration        = seconds(nan)
        FirstStartTime    datetime        = NaT
        ForceStartBounds  char      {ismember('','year','quarter','month','day','hour','minute','second')} = '';
        do_memoize        logical         = false
    end
    properties(Constant,Abstract)
        
        % table containing columns 'Names', 'Descriptions', 'Units', corresponding to 
        % VariableNames, VariableDescriptions, VariableUnits
        ReturnDetails; 
        
        % cell of VariableNames (chosen from first row of ReturnDetails) that
        % describe the data returned from the calculation function. [in order]
        CalcFields;
    end
    
    methods
        function obj=ZmapTimeFunction(zap, active_col)
            % ZMAPGRIDFUNCTION constructor  assigns grid, event, catalog, and shape properties
            if isempty(zap)
                zap = ZmapAnalysisPkg.fromGlobal();
            end
            obj@ZmapFunction(zap.Catalog);
            
            
            obj.active_col=active_col;
        end
        
        function saveToDesktop(obj)
            % SAVETODESKTOP 
            
            % super must be called last, since it does the actual writing
            saveToDesktop@ZmapFunction(obj) 
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
            allvalues(:, fieldname==obj.ReturnDetails.Names) = thesevalues;
            
        end
        
        function [starts, ends] = getTimeWindowBoundaries(obj)
            if obj.FirstStartTime == NaT
                firstTime = min(obj.RawCatalog.Date);
            else
                firstTime = obj.FirstStartTime;
            end
                
            starts = firstTime : TimeStep : max(obj.RawCatalog.Date);
            
            if ~isempty(obj.ForceStartBounds)
                starts = dateshift(starts, 'start', obj.ForceStartBounds);
            end
            starts = unique(starts); % in case there was overlap
            ends = starts + WindowDuration;
        end
            
        function timeCalculations(obj, calculationFcn, modificationFcn)
            % TIMECALCULATIONS do requested calculation for each gridpoint and store result in obj.Result
            % TIMECALCULATIONS(obj, calculationFcn, modificationfcn)
            % calculate values for all windows
            %
            % Determine the time-windows, based on existing object properties,
            % then calculate metrics for each time window, which are then
            % turned into an annotated table, and kept in obj.ReturnDetails
            %
            % once metrics aree calculated for each point, the modificationFcn (if it exists)
            % will be run, using the results table as an input. eg:
            %    myResultsTable = modificationFcn(myResultsTable)
            %
            % The idea is that addiional calculations that rely upon calculated table values
            % may be done outside the main time loop. Generally, these are confined to
            % matrix/vector operations.
   
            [starttimes, endtimes] = obj.getTimeWindowBoundaries();
            
            [...
                vals, ...
                nEvents, ...
                dateSpread, ...
                maxMag, ...
                wasEvaluated...
                ] = datetimefun( calculationFcn, obj.RawCatalog, starttimes, endtimes, mineventcount, numel(obj.CalcFields) );
            
            mytable = array2table(vals,'VariableNames', obj.CalcFields);
            
            whichdetails = ismember(obj.ReturnDetails.Names, obj.CalcFields);

            descs=[obj.ReturnDetails.Descriptions(whichdetails)',...
                {'Date spread','Window start date','Window end date','Maximum magnitude in window',...
                'Number of events in node','was evaluated'}];
            units = [obj.ReturnDetails.Units(whichdetails)',{'duration','datetime','datetime','mag','','logical'}];
                
            
            % include local items into the table
            mytable.StartDate = starttimes;
            mytable.EndDate = endtimes;
            
            % include the return values from datetimefun in the table
            mytable.DateSpread = dateSpread;
            mytable.max_mag = maxMag;
            mytable.Number_of_Events = nEvents;
            mytable.was_evaluated = wasEvaluated;
            
            % update the table with proper descriptions of its contents
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
                    mytable.Properties.VariableDescriptions(j)=obj.ReturnDetails.Descriptions(row);
                    mytable.Properties.VariableUnits(j)=obj.ReturnDetails.Units(row);
                end
                    
                    
            end
            obj.Result.values=mytable;
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

