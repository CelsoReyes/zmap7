classdef comp2periodz < ZmapHGridFunction
    % COMP2PERIODZ compares seismicity rates for two time periods
    % The differences are as z- and beta-values and as percent change.
    
    properties
        t1 datetime % start time for period 1
        t2 datetime % end time for period 1
        t3 datetime % start time for period 2
        t4 datetime % end time for period 2
        binsize duration = ZmapGlobal.Data.bin_dur;
    end
    
    properties(Constant)
        PlotTag='myplot';
        ReturnDetails = { ... VariableNames, VariableDescriptions, VariableUnits
            ...
            ... % these are returned by the calculation function
            'z_value','z-value', '';... #1 'valueMap'
            'pct_change', 'percent change', 'pct';... #2  'per'
            'beta_value', 'Beta value map','';... #3 'beta_map'
            'Number_of_Events_1', 'Number of events in first period', '';... #4
            'Number_of_Events_2', 'Number of events in second period', '';... #5
            ...
            };

        CalcFields={'z_value','pct_change','beta_value',...
            'Number_of_Events_1','Number_of_Events_2'}
    end
    
    methods
        function obj=comp2periodz(zap, varargin)
            % COMP2PERIODZ compares seismicity rates for two time periods.
            % The differences are as z- and beta-values and as percent change.
            %   Stefan Wiemer 1/95
            %   Rev. R.Z. 4/2001
            
            report_this_filefun(mfilename('fullpath'));
            
            obj@ZmapHGridFunction(zap, 'z_value');
            
            if nargin <2
                % create dialog box, then exit.
                obj.InteractiveSetup();
            else
                % run this function without human intervention
                obj.doIt();
            end
            
        end
        
        function InteractiveSetup(obj)
            
            t0b = min(obj.RawCatalog.Date);
            teb = max(obj.RawCatalog.Date);
            obj.t1 = t0b;
            obj.t4 = teb;
            obj.t2 = t0b + (teb-t0b)/2;
            obj.t3 = obj.t2+minutes(0.01);
            
            % get two time periods, along with grid and event parameters
            zdlg=ZmapDialog([]);
            zdlg.AddBasicHeader('Please define two time periods to compare');
            zdlg.AddBasicEdit('t1','start period 1',obj.t1,'start time for period 1');
            zdlg.AddBasicEdit('t2','end period 1',obj.t2,'end time for period 1');
            zdlg.AddBasicEdit('t3','start period 2',obj.t3,'start time for period 2');
            zdlg.AddBasicEdit('t4','end period 2',obj.t4,'end time for period 2');
            zdlg.AddBasicEdit('binsize','Bin Size (days)',obj.binsize,'number of days in each bin');
            %zdlg.AddEventSelectionParameters('eventsel', ZG.ni, ra, 50)
            %zdlg.AddGridParameters('gridparam',dx,'deg', dy,'deg', [],[])
            [res,okPressed]=zdlg.Create('Please choose rate change estimation option');
            if ~okPressed
                return
            end
            
            obj.SetValuesFromDialog(res)
            
            obj.doIt()
        end
        
        function SetValuesFromDialog(obj, res)
            obj.t1=res.t1;
            obj.t2=res.t2;
            obj.t3=res.t3;
            obj.t4=res.t4;
            obj.binsize=res.binsize;
        end
        
        function CheckPreConditions(obj)
            assert(obj.t1 < obj.t2,'Period 1 starts before it ends');
            assert(obj.t3 < obj.t4,'Period 2 starts before it ends');
            assert(isa(obj.binsize,'duration'),'bin size should be a duration in days');
        end
        
        
        function results=Calculate(obj)
            
            %  make grid, calculate start- endtime etc.  ...
            
            lt =  (obj.RawCatalog.Date >= obj.t1 &  obj.RawCatalog.Date < obj.t2) ...
                | (obj.RawCatalog.Date >= obj.t3 &  obj.RawCatalog.Date <= obj.t4);
            obj.RawCatalog = obj.RawCatalog.subset(lt);
            
            
            interval1_bins = obj.t1 : obj.binsize : obj.t2; % starts
            interval2_bins = obj.t3 : obj.binsize : obj.t4; % starts
            interval1_edges = [interval1_bins, interval1_bins(end)+obj.binsize];
            interval2_edges = [interval2_bins, interval2_bins(end)+obj.binsize];
            
            
            obj.gridCalculations(@calculation_function);
           
            obj.Result.period1.dateRange=[obj.t1 obj.t2];
            obj.Result.period2.dateRange=[obj.t3 obj.t4];
            
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

                idx_back =  catalog.Date >= obj.t1 &  catalog.Date < obj.t2 ;
                [cumu1, ~] = histcounts(catalog.Date(idx_back),interval1_edges);
                
                idx_after =  catalog.Date >= obj.t3 &  catalog.Date <= obj.t4 ;
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
            h=uimenu(parent,'Label',label,MenuSelectedFcnName(), @(~,~)comp2periodz(zapFcn()));
        end
    end % static methods
end % classdef
    
        