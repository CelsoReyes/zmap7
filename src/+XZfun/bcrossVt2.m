classdef bcrossVt2 < ZmapVGridFunction
    % BCROSSVT2 compares b-values for 2 time periods within a cross section
    %   Stefan Wiemer 1/95
    properties
        
        ni = 100;
        ra = ZmapGlobal.Data.ra;
        dd = 1.0
        dx = 1.0
        
        % get the time periods of interest
        t0b datetime = ZmapGlobal.Data.t0b;
        teb datetime = ZmapGlobal.Data.teb;
        StartA  datetime = ZmapGlobal.Data.t0b;
        EndA  datetime = ZmapGlobal.Data.t0b + ([ ZmapGlobal.Data.teb - ZmapGlobal.Data.t0b])/2;
        
        StartB  datetime = ZmapGlobal.Data.t0b + ([ ZmapGlobal.Data.teb - ZmapGlobal.Data.t0b])/2 + seconds(.1);
        EndB  datetime = ZmapGlobal.Data.teb;
        mcAuto      McAutoEstimate              = true;
        wtAuto      LSWeightingAutoEstimate     = true;
    end
    
    properties(Constant)
        PlotTag = 'bcrossVt2'
        ReturnDetails = cell2table({... VariableNames, VariableDescriptions, VariableUnits
            'b_value_1' , 'b-value I', '';...1 bv > valueMap [discarded later]
            'Mc_value1' , 'Magnitude of Completion (Mc) I', '';...2 magco > old1
            'stan1'     , 'error in b I', '';...9 stan > stanm
            'a_value1'  , 'a-value I', '';... 8 av > avm
            'probability', 'Probability I', '';...7 pr > pro
            'count_1'   , 'Number of events I', '';...
            ...
            'b_value_2' , 'b-value II', '';...1 bv2 > valueMap [discarded later]
            'Mc_value2' , 'Magnitude of Completion (Mc) II', '';...2 magco2 > old1
            'stan2'     , 'error in b II', '';...9 stan2 > stanm
            'a_value2'  , 'a-value II', '';... 8 av2 > avm
            'probability2', 'Probability II', '';...7 pr2 > pro
            'count_2'   , 'Number of events II', '';...
            ...
            'dM'        , 'Difference in Mc', 'mag';... Mc_value2 - Mc_value1 (Not)maxm-magco
            'delta_bval', 'Difference in b-values', '';... old - meg  : BV2 - BV1
            'dbperc'    , 'b-value change', 'pct';... bv2/bv*100-100 
            }, 'VariableNames', {'Names','Descriptions','Units'});
        
        % fields returned by the calculation. must match column 1 of ReturnDetails
        CalcFields = {...
            'b_value_1','Mc_value1','stan1','a_value1','probability','count_1',...
            'b_value_2','Mc_value2', 'stan2','a_value2','probability2','count_2'};
        
        ParameterableProperties = ["NodeMinEventCount", "StartA", "EndA", "StartB", "EndB",...
            "mcAuto", "wtAuto"]
        
        References = ""

    end
    
    methods
        function obj=bcrossVt2(zap, varargin)
            obj@ZmapVGridFunction(zap, 'd_b');
            
            obj.NodeMinEventCount = 100;
            
            obj.parseParameters(varargin);
            obj.StartProcess();
        end
        
        function InteractiveSetup(obj)
            report_this_filefun();
            
            %% make the interface
            zdlg = ZmapDialog();
            zdlg.AddHeader('Automatically estimate magnitude of completeness?');
            zdlg.AddMcAutoEstimateCheckbox('mcAuto', obj.mcAuto);
            zdlg.AddCheckbox('wtAuto', 'AUTOMATIC Least Squares Weighting', obj.wtAuto,...
                [],'Choose the calculation weighting method for Mc');
            % obj.AddDialogOption(zdlg,'EventSelector');
            obj.AddDialogOption(zdlg, 'NodeMinEventCount');
            zdlg.AddHeader('Catalog Part A')
            zdlg.AddEdit('StartA', 'Start Date', obj.StartA, '');
            zdlg.AddEdit('EndA',   'End Date',   obj.EndA, '');
            zdlg.AddHeader('Catalog Part B')
            zdlg.AddEdit('StartB', 'Start Date', obj.StartB, '');
            zdlg.AddEdit('EndB',   'End Date',   obj.EndB, '');
            
            zdlg.Create('Name', 'differential b-value map X-section Grid Parameters', 'WriteToObj', obj, 'OkFcn', @obj.doIt);
        end
        
        function SetValuesFromDialog(obj,res)
            % called when the dialog's OK button is pressed
            obj.mcAuto = res.mcAuto; % MC Calculation using Max Likelihood automatic  Mcomp 
            obj.wtAuto = res.wtAuto; % 1 is automatic LSW, 2 is  not automatic
            obj.dx = res.gridOpts.dx;
            obj.dd = res.gridOpts.dz;
            obj.ni = res.eventSelector.NumClosestEvents;
            obj.ra = res.eventSelector.RadiusKm;
            obj.NodeMinEventCount = res.eventSelector.requiredNumEvents;
        end

        % get the grid-size interactively and
        % calculate the b-value in the grid by sorting
        % the seismicity and selectiong the ni neighbors
        % to each grid point
        
        function results = Calculate(obj)
            
            %  make grid, calculate start- endtime etc.  ...
            %
            n = obj.RawCatalog.Count;
                        
            % overall b-value
            bv =  bvalca3(obj.RawCatalog.Magnitude, obj.mcAuto);
            b_value_overall = bv;
            obj.ZG.overall_b_value = bv;
            %
            
            returnFields = obj.ReturnDetails.Names;
            returnDesc = obj.ReturnDetails.Descriptions;
            returnUnits = obj.ReturnDetails.Units;
            
            obj.gridCalculations(@do_calculation, @modification_function);
            
            if nargout
                results = obj.Result.values;
            end
            
            % View the b-value map
            %  TODO: PLOTTING SHOULD BE HANDLED BY THE ZMAPGRIDFUNCTION class
            % view_bvt([],valueMap)
            
            function tb = modification_function(tb)
                tb.delta_bval = tb.b_value_2 - tb.b_value_1;
                tb.dM         = tb.Mc_value2 - tb.Mc_value1;
                tb.dbperc     = tb.b_value_2 ./ tb.b_value_1 .* 100 - 100;
            end
            
            function out = do_calculation(catalog, calcFcn)       
                % calculate values at a single point
                out = nan(1,12);         
                
                % Added to obtain goodness-of-fit to powerlaw value  
                [~, ~, ~, ~, out(7)] = mcperc_ca3(catalog.Magnitude); 
                Mc_value = mcCalculator(catalog);
                
                idx = catalog.Magnitude >= Mc_value-(obj.fBinning/2);
                nEvents_gt_local_mc = sum(idx);
                
                out(11) = nEvents_gt_local_mc;
                
                if nEvents_gt_local_mc >= obj.NodeMinEventCount
                    out = calcFcn(catalog, idx, out); % runs either calculation_function_boot or calculation_function_noboot
                else
                    out(10) = 1;
                end
            end
            
            function out = calculation_function(catalog)
                % The guts of calculating at an individual point goes here
                
                out = NaN(1,12); % [bv magco stan av pr no1 bv2 magco2 stan2 av2 pr2 no2];
                out([5,11]) = 50; % set pr and pr2;
                out([6,12]) = 0;  % set no1 and no2;
                tmp = out; % [bv magco stan av pr no1 bv2 magco2 stan2 av2 pr2 no2];
                
                
                if catalog.Count >= obj.NodeMinEventCount
                    minForTimeslice = obj.NodeMinEventCount/2;
                    % call the catalog-value function
                    
                    % this was [apparently] sloppy, output values migth be result of one or the other
                    % catalog piece, depending on the number of events.
                    lt =  catalog.Date >= obj.StartA &  catalog.Date < obj.EndA;
                    count1 = sum(lt);
                    if  count1 > minForTimeslice
                        [tmp(1), tmp(2), tmp(3), tmp(4), tmp(5)] =  bvalca3(catalog.Magnitude(lt), obj.mcAuto, b_value_overall);
                        obj.ZG.overall_b_value = bv;
                        tmp(6) = count1;
                    end
                    
                    lt = catalog.Date >= obj.StartB &  catalog.Date < obj.EndB ;
                    count2 = sum(lt);
                    if  count2 > minForTimeslice
                        [tmp(7), tmp(8), tmp(9), tmp(10), tmp(11)] =  bvalca3(catalog.Magnitude(lt), obj.mcAuto, b_value_overall);
                        tmp(12) = count2;
                    end
                    
                    if pr2 >= 99 % don't know what [specifically] this is accomplishing.
                        out = tmp; % changed to return relevent properies
                    end
                end
            end
        end
        
        function ModifyGlobals(obj)
            % if something is changed that goes back to ZG, do it here
            obj.ZG.bvg=obj.Result.values;
        end
        
        % Load exist b-grid
        function my_load()
            load_existing_bgrid_version_A
        end
    end
    
    methods(Static)
        function h = AddMenuItem(parent, zapFcn, varargin)
            % create a menu item
            label='differential b-value [xsec]';
            h = uimenu(parent, 'Label', label,...
                MenuSelectedField(), @(~,~)XZfun.bcrossVt2(zapFcn()),...
                varargin{:});
        end
        
    end % static method
        
end

