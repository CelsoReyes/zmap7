classdef comp2periodz < ZmapHGridFunction
    % COMP2PERIODZ compares seismicity rates for two time periods
    % The differences are as z- and beta-values and as percent change.
    
    properties
        periodA_start   datetime % start time for period 1
        periodA_end     datetime % end time for period 1
        periodB_start   datetime % start time for period 2
        periodB_end     datetime % end time for period 2
        binsize duration            = ZmapGlobal.Data.bin_dur;
    end
    
    properties(Constant)
        PlotTag = 'comp2periodz';
        ReturnDetails = cell2table({ ... VariableNames, VariableDescriptions, VariableUnits
            ...
            ... % these are returned by the calculation function
            'z_value',              'z-value',          '';...           #1 'valueMap'
            'pct_change',           'percent change',   'pct';... #2  'per'
            'beta_value',           'Beta value map',   '';...     #3 'beta_map'
            'Number_of_Events_1',   'Number of events in first period', '';... #4
            'Number_of_Events_2',   'Number of events in second period', '';... #5
            ...
            }, 'VariableNames', {'Names','Descriptions','Units'})
        
        CalcFields={...
            'z_value',              'pct_change',   'beta_value',...
            'Number_of_Events_1',   'Number_of_Events_2'}
        
        ParameterableProperties = ["periodA_start" "periodA_end" "periodB_start" "periodB_end" "binsize"];
        
        References="";
    end
    
    methods
        function obj=comp2periodz(zap, varargin)
            % COMP2PERIODZ compares seismicity rates for two time periods.
            % The differences are as z- and beta-values and as percent change.
            %   Stefan Wiemer 1/95
            %   Rev. R.Z. 4/2001
            
            obj@ZmapHGridFunction(zap, 'z_value');
            report_this_filefun();
            
            t0b = min(obj.RawCatalog.Date);
            teb = max(obj.RawCatalog.Date);
            obj.periodA_start = t0b;
            obj.periodB_end = teb;
            obj.periodA_end = t0b + (teb-t0b)/2;
            obj.periodB_start = obj.periodA_end+minutes(0.01);
            
            obj.parseParameters(varargin);
            
            obj.StartProcess();
            
        end
        
        function InteractiveSetup(obj)
            
            % get two time periods, along with grid and event parameters
            zdlg=ZmapDialog();
            zdlg.AddHeader('Please define two time periods to compare');
            zdlg.AddEdit('periodA_start','start period 1',  obj.periodA_start,'start time for period 1');
            zdlg.AddEdit('periodA_end',  'end period 1',    obj.periodA_end,'end time for period 1');
            zdlg.AddEdit('periodB_start','start period 2',  obj.periodB_start,'start time for period 2');
            zdlg.AddEdit('periodB_end',  'end period 2',    obj.periodB_end,'end time for period 2');
            zdlg.AddDurationEdit('binsize','Bin Size',      obj.binsize,'number of days in each bin',@days);
            obj.AddDialogOption(zdlg,'EventSelector');
            zdlg.Create('Name', 'Please choose rate change estimation option','WriteToObj',obj,'OkFcn',@obj.doIt);
        end
        
        function results=Calculate(obj)
            
            assert(obj.periodA_start < obj.periodA_end,'Period 1 starts before it ends');
            assert(obj.periodB_start < obj.periodB_end,'Period 2 starts before it ends');
            
            %  make grid, calculate start- endtime etc.  ...
            
            lt =  (obj.RawCatalog.Date >= obj.periodA_start &  obj.RawCatalog.Date < obj.periodA_end) ...
                | (obj.RawCatalog.Date >= obj.periodB_start &  obj.RawCatalog.Date <= obj.periodB_end);
            obj.RawCatalog = obj.RawCatalog.subset(lt);
            
            
            interval1_bins = obj.periodA_start : obj.binsize : obj.periodA_end; % starts
            interval2_bins = obj.periodB_start : obj.binsize : obj.periodB_end; % starts
            interval1_edges = [interval1_bins, interval1_bins(end)+obj.binsize];
            interval2_edges = [interval2_bins, interval2_bins(end)+obj.binsize];
            
            
            obj.gridCalculations(@calculation_function);
            
            obj.Result.period1.dateRange=[obj.periodA_start obj.periodA_end];
            obj.Result.period2.dateRange=[obj.periodB_start obj.periodB_end];
            
            if nargout
                results=obj.Result.values;
            end
            % save data
            
            % plot the results
            % old and valueMap (initially ) is the z-value matrix
            
            
            %det =  'ast';
            %ZG.shading_style = 'interp';
            % View the b-value map: view_ratecomp.m
            %    which could create a topography overlay ala dramap_z.m
            %
            %
            
            function out=calculation_function(catalog)
                % calulate values at a single point
                % calculate distance from center point and sort wrt distance
                
                idx_back =  catalog.Date >= obj.periodA_start &  catalog.Date < obj.periodA_end ;
                [cumu1, ~] = histcounts(catalog.Date(idx_back),interval1_edges);
                
                idx_after =  catalog.Date >= obj.periodB_start &  catalog.Date <= obj.periodB_end ;
                [cumu2, ~] = histcounts(catalog.Date(idx_after),interval2_edges);
                
                mean1 = mean(cumu1);        % mean seismicity rate in first interval
                mean2 = mean(cumu2);        % mean seismicity rate in second interval
                sum1 = sum(cumu1);          % number of earthquakes in the first interval
                sum2 = sum(cumu2);          % number of earthquakes in the second interval
                var1 = cov(cumu1);          % variance of cumu1
                var2 = cov(cumu2);          % variance of cumu2
                % remark (db): cov and var calculate the same value when applied to a vector
                ncu1 = length(interval1_bins);         % number of bins in first interval
                ncu2 = length(interval2_bins);         % number of bins in second interval
                
                % compute the z value "as":
                as = (mean1 - mean2)/ sqrt(var1/ncu1 +var2/ncu2);
                
                % calculate the percentage
                per = -((mean1-mean2)./mean1)*100;
                
                % beta nach reasenberg & simpson 1992, time of second interval normalised by time of first interval
                bet = (sum2-sum1*ncu2/ncu1)/sqrt(sum1*(ncu2/ncu1));
                
                out = [as  per bet sum1 sum2];
                
            end
        end
        function ModifyGlobals(obj)
            obj.ZG.bvg = obj.Result.values;
        end
    end %methods
    
    methods(Static)
        function h=AddMenuItem(parent,zapFcn)
            % create a menu item
            label='Compare two periods (z, beta, probabilty)';
            h=uimenu(parent,'Label',label,MenuSelectedField(), @(~,~)XYfun.comp2periodz(zapFcn()));
        end
    end % static methods
end % classdef

