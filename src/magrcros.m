classdef magrcros < ZmapVGridFunction
    % TODO document this
    % TODO make this the first x-section function
    
    
    properties
        cutoff % time of cut
        use_fixed_start = false;
        t0b % windows start time [where pre-window data starts]
        use_fixed_end = false;
        teb % windows end time [where post-window data ends]
        window_duration = ZmapGlobal.Data.compare_window_dur;
    end
    
    properties(Constant)
        PlotTag='zsection';
        ReturnDetails = { ... TODO update this. it hasn't been really done.
            ... VariableNames, VariableDescriptions, VariableUnits
            'AST','Z-value comparing rate before to rate after cutoff','',...
            'LTA','Z-value comparing rate outside window to inside window','',...
            'RUB','Z-value comparing rate before cutoff [before window] to rate inside window','',...
            'PCT','Compare ','',...
            'nBeforeCutoff','','',...
            'nAfterCutoff','','',...
            'nInWindow','','',...
            'nNotInWindow','','',...
            'dist_along_strike','Distance along strike','km';...
            };
        CalcFields = {'AST','LTA','RUB','PCT',...
            'nBeforeCutoff','nAfterCutoff','nInWindow','nNotInWindow'}
        
        %Negative z-values indicate an increase in the seismicity rate, positive values a decrease.
            unit_options = {'seconds','hours','days','years'};
            unit_functions = {@seconds, @hours, @days, @years};
    end
    methods
        function obj=magrcros(zap,varargin)
            obj@ZmapVGridFunction(zap,'z_value');
            obj.t0b = min(obj.RawCatalog.Date);
            obj.teb = max(obj.RawCatalog.Date);
            obj.InteractiveSetup();
            obj.Caclulate();
            % magrcros_orig(sel,obj);
            
            
            % consider this for future: uimenu(op1,'Label','Show Circles ', 'callback',@(~,~)plotcirc)
        end
        
        function InteractiveSetup(obj)
            % get the grid parameter
            
            
            % these are provided by the eventselection
            %ni = 100;
            %ra = ZG.ra;
            
            if isempty(obj.Cutoff)
                % set the default cutoff to the time of the biggest event in catalog. 
                % selects first event if multiple events are same size
                biggest=find(obj.RawCatalog.Magnitude==max(obj.RawCatalog.Magnitude) , 1);
                obj.cutoff = obj.RawCatalog.Date(biggest);
            end
            % make the interface
            %
            zdlg = ZmapDialog([]);
            % zdlg.AddEventSelectionParameters('evtparams', ni, ra);
            if ~isempty(obj.shape)
                zdlg.AddBasicCheckbox('useGridFromShape', 'Limit grid to shape', true,[],...
                    'Only evaluate for gridpoints within the shape region. Does not restrict the catalog');
                zdlg.AddBasicCheckbox('useCatFromShape', 'Limit catalog to shape', false,[],...
                    'Only evaluate for events within the shape region. Does not restrict the grid');
                
            end
            
            % these provided by the grid
            %dd = 1.00;
            %dx = 1.00 ;
            %zdlg.AddBasicEdit('dx_km','Spacing along strike [km]',dx,'spacing in horizontal plane');
            %zdlg.AddBasicEdit('dd_km','Spacing in depth [km]',dd,'spacing in vertical plane');
            
            %zdlg.AddBasicEdit('bin_dur','Time steps in days',ZG.bin_dur,'time steps in days');
            
            default_unit = find(strcmp(obj.unit_options,'days'));
            unitizer = obj.unit_functions{default_unit};
            
            zdlg.AddBasicCheckbox('use_fixed_start', 'Fix StartTime', obj.use_fixed_end,'fixed_start',...
                'Otherwise, the StartTime will depend on the catalog');
            
            zdlg.AddBasicEdit('fixed_start','Use Start time',obj.t0b,...
                'window size in specified units');
            
            
            zdlg.AddBasicCheckbox('use_fixed_end', 'Fix StartTime', obj.use_fixed_start,'fixed_end',...
                'Otherwise, the StartTime will depend on the catalog');
            
            zdlg.AddBasicEdit('fixed_end','Use Start time',obj.teb,...
                'window size in specified units');
            
            zdlg.AddBasicEdit('cutoff','Please enter date & time of cut:',obj.cutoff,'Cutoff Date as yyyy-mm-dd hh:MM:ss');
            
            zdlg.AddBasicEdit('win_dur','Window Size',unitizer(obj.window_duration),...
                'window size in specified units');
            
            zdlg.AddBasicPopup('win_dur_unit','Window Size Units:',obj.unit_options, default_unit,...
                'Chooose units for window duration');
            zdlg.AddBasicEdit('n_bins_in_window','Number of bins within window',...
                round(obj.window_duration/obj.ZG.bin_dur),...
                'Number of windows used to divide up the window [INTEGER]. this determines the bin size');
            
            [zparam,okPressed]=zdlg.Create('Z-value xsection input parameters');
            if ~okPressed
                return
            end
            
            %dd=zparam.dd_km;
            %dx=zparam.dx_km;
            
            if zparam.useCatFromShape
                errordlg('not yet implemented: use catalog from shape. First limit catalog by shape, THEN call this function');
                return
            end
            
            SetValuesFromDialog(obj,zparam);
            obj.doIt();
            
        end  % function InteractiveSetup
        
        function SetValuesFromDialog(obj, res)
            if res.use_fixed_start
                obj.t0b = min(obj.RawCatalog.Date);
            else
                obj.t0b = res.fixed_start;
            end
            
            if res.use_fixed_end
                obj.teb = max(obj.RawCatalog.Date);
            else
                obj.teb = res.fixed_end;
            end
            unitizer = obj.unit_functions{res.win_dur_unit};
            obj.window_duration = unitizer(res.win_dur);
            obj.bin_dur = obj.window_duration/res.n_bins_in_window;
            obj.cutoff = res.cutoff;
            
            if zparam.useGridFromShape
                obj.Grid = obj.Grid.MaskWithShape(obj.shape);
            end
        end
        
        function CheckPreConditions(obj)
            assert(obj.cutoff > obj.t0b && obj.cutoff < obj.teb,...
                'Cutoff date should be some time after %s and before %s', char(obj.t0b), char(obj.teb));
            assert(obj.t0b < obj.teb,'Invalid dates: Start date is after End date');
            assert (obj.cutoff + obj.window_duration > obj.teb,...
                'window extends past end date. Manually set end date or change window');
        end
        
        function Calculate(obj)
            
            % this is how to get a xsection grid from ZmapMainWindow (aa is handle to window)
            % xsz  = aa.xsec_zap('A - A''')
            % gr = xsz.Grid.MaskWithShape(aa.shape)
            % and the above should already be pulled into the object.
      
            edges_for_cov = unique([obj.cutoff : - bj.bin_dur : obj.t0b, obj.cutoff : obj.bin_dur : obj.teb]);
            
            obj.gridCalculations(@calculation_function);
            obj.Result.t0b = obj.t0b;
            obj.Result.teb = obj.teb;
            obj.Result.cutoff = obj.cutoff;
            obj.Result.bin_dur = obj.bin_dur;
            
             {'AST','LTA','RUB','PCT','nBeforeCutoff','nAfterCutoff','nInWindow','nNotInWIndow'}
            % post calculations
            
            function out=calc_probability(old)
                %calculate probabliity, where old is one of the zmaps.
                % salvaged from vi_cucro
                valueMap = old;
                l = valueMap < 2.57;
                valueMap(l) = ones(1,length(find(l)))*2.65;
                pr = 0.0024 + 0.03*(valueMap - 2.57).^2;
                pr = (1-1./(exp(pr)));
                out = pr;
            end
            
            catsave3('magrcros');
            
            % Plot the results
            %
            
            %det = 'nop'
            %in2 = 'nocal'
            %menucros() -> which was at one point hooked up to incube, but not while I've been manipulating it. CGR
            
            
            function out=calculation_function(catalog)
                if n <= catalog.Count
                    out = [ nan nan nan nan ...
                        nan nan nan nan];
                    return
                end
                
                %% do prelim calculations, so that they are only done ONCE per grid point
                
                % this had all been done with histogram and bins, but makes much more sense
                % to let the time periods dictate duration
                
                nPerBin = histcounts(catalog.Date,edges_for_cov);
                idxBeforeCutoff = edges_for_cov(2:end) <= obj.cutoff;
                idxAfterCutoff = ~idxBeforeCutoff;
                idxInWindow = idxAfterCutoff  & edges_for_cov(2:end) <= obj.cutoff + obj.window_duration;
                idxNotInWindow = ~idxInWindow;
                
                
                nBeforeCutoff = nPerBin(idxBeforeCutoff); 
                nInWindow = nPerBin(idxInWindow); % NALL(2) : # IN window
                nAfterCutoff = nPerBin(idxAfterCutoff); 
                nNotInWindow = nPerBin(idxNotInWindow);
                
                covBeforeCutoff = cov(nPerBin(idxBeforeCutoff));
                covAfterCutoff = cov(nPerBin(idxAfterCutoff));
                covInWindow = cov(nPerBin(idxInWindow));
                covNotInWindow = cov(nPerBin(idxNotInWindow));
                
                durBeforeCutoff = sum(idxBeforeCutoff) * obj.bin_dur;
                durAfterCutoff = sum(idxAfterCutoff) * obj.bin_dur;
                durInWindow = sum(idxInWindow) * obj.bin_dur;
                durNotInWindow = sum(idxNotInWindow) * obj.bin_dur;
                
                meanBeforeCutoff = mean(nBeforeCutoff);
                meanAfterCutoff  = mean(nAfterCutoff);
                meanInWindow = mean(nInWindow);
                meanNotInWindow = mean(nNotInWindow);
                
                out = [calc_ast() calc_lta() calc_rubberband() calc_percent(),...
                    nBeforeCutoff, nAfterCutoff, nInWindow, nNotInWindow];
                
                % now comes the actual calculations for 
                function out=calc_percent()
                    out =  -((meanBeforeCutoff-meanAfterCutoff)./meanBeforeCutoff)*100;
                end
                
                function out=calc_rubberband()
                    % loop over all point for rubber band : compare window to before cutoff
                    term1 = covBeforeCutoff / durBeforeCutoff;
                    term2 = covInWindow / durInWindow;
                    out =  (meanBeforeCutoff - meanInWindow) ./ (sqrt(term1 + term2));
                end
                
                function out=calc_ast()
                    % make the AST function map : compare before and after cutoff
                    term1 =covBeforeCutoff / durBeforeCutoff;
                    term2 = covAfterCutoff / durAfterCutoff;
                    out = (meanBeforeCutoff - meanAfterCutoff) ./ (sqrt(term1 + term2));
                end
                
                function out=calc_lta()
                    % Calculate LTA: compare window to everything else
                    term1 = covNotInWindow / durNotInWindow;
                    term2 = covInWindow  / durInWindow;
                    out =  (meanNotInWindow - meanInWindow)./(sqrt(term1+term2));
                end
                
                % removed something that calculated 'maz', since it was never referenced elsewhere, and
                % the original code was seriously convoluted. -CGR

                
            end % function calculation_function
        end %function Calculate
        
        

    end % methods
    methods(Static)
        function h=AddMenuItem(parent,zap_Fcn) %xsec_zap
            % create a menu item
            label='Z-value section map';
            h=uimenu(parent,'Label',label,'Callback', @(~,~)magrcros(zap_Fcn()));
        end
            
        %{
        %% UNMODIFIED/UNIMPLEMENTED BY CGR
        function obj=my_load()
            % Load exist z-grid
            [file1,path1] = uigetfile(['*.mat'],'z-value gridfile');
            if length(path1) > 1

                load([path1 file1])
                det = 'nop'
                in2 = 'nocal'
                menucros
            else
                return
            end
        end
        %}
        
    end % static methods
    
end
