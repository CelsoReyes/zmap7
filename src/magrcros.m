classdef magrcros < ZmapVGridFunction
    % TODO document this
    % TODO make this the first x-section function
    
    
    properties
        useOnlyCompleteBins = true;
        bin_edges
        cutoff % time of cut
        window_duration = ZmapGlobal.Data.compare_window_dur;
        bin_duration = ZmapGlobalData.bin_dur;
        binsBeforeCutoff
        binsAfterCutoff
        binsInWindow
        binsAfterWindow
        bins_per_window;
    end
    
    properties(Constant)
        PlotTag='myplot';
        ReturnDetails = { ... TODO update this. it hasn't been really done.
            ... VariableNames, VariableDescriptions, VariableUnits
            'Mc_value', 'Magnitude of Completion (Mc)', '';...
            'Mc_std', 'Std. of Magnitude of Completion', '';...
            'x', 'Longitude', 'deg';...
            'y', 'Latitude', 'deg';...
            'z', 'Depth','km';...
            'dist_along_strike','Distance along strike','km';...
            'Radius_km', 'Radius of chosen events (Resolution) [km]', 'km';...
            'b_value', 'b-value', '';...
            'b_value_std', 'Std. of b-value', '';...
            'a_value', 'a-value', '';...
            'a_value_std', 'Std. of a-value', '';...
            'power_fit', 'Goodness of fit to power-law', '';...
            'max_mag', 'Maximum magnitude at node', 'mag';...
            'Additional_Runs_b_std', 'Additional runs: Std b-value', '';...
            'Additional_Runs_Mc_std', 'Additional runs: Std of Mc', '';...
            'Number_of_Events', 'Number of events in node', ''...
            };
        
        %Negative z-values indicate an increase in the seismicity rate, positive values a decrease.
            unit_options = {'seconds','hours','days','years'};
            unit_functions = {@seconds, @hours, @days, @years};
    end
    methods
        function obj=magrcros(zap,varargin)
            obj@ZmapVGridFunction(zap,'z_value');
            
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
            
            zdlg.AddBasicEdit('cutoff','Please enter time of cut:',obj.cutoff,'Cutoff Date as yyyy-mm-dd hh:MM:ss');
            
            zdlg.AddBasicEdit('win_dur','Window Size',unitizer(obj.window_duration),...
                'window size in specified units');
            
            zdlg.AddBasicPopup('win_dur_unit','Window Size Units:',obj.unit_options, default_unit,...
                'Chooose units for window duration');
            
            zdlg.AddBasicEdit('bins_per_window','Number of bins in window [integer is best]',...
                obj.window_duration/obj.bin_duration,...
                'Number of bins in window. If not an integer value, partial values are tossed.');
            
            zdlg.AddBasicCheckbox('useOnlyCompleteBins', 'Discard incomplete bins', obj.useOnlyCompleteBins,[],...
                'Bins are measured timesteps from the cutoff. If FALSE, then partial bins at beginning and end of periods are included.');
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
            
        end  % function InteractiveSetup
        
        function SetValuesFromDialog(obj, res)
            obj.bin_duration = res.bin_dur;
            unitizer = obj.unit_functions{res.win_dur_unit};
            obj.window_duration = unitizer(res.win_dur);
            obj.bin_duration = obj.window_duration / res.bins_per_window;
            obj.useOnlyCompleteBins = res.useOnlyCompleteBins;
            obj.cutoff = res.cutoff;
            
            if zparam.useGridFromShape
                obj.Grid = obj.Grid.MaskWithShape(obj.shape);
            end
        end
        
        function CheckPreConditions(obj)
            t0b = min(obj.RawCatalog.Date);
            teb = max(obj.RawCatalog.Date);
            assert(obj.cutoff > t0b && obj.cutoff < teb,...
                'Cutoff date should be some time after %s and before %s', char(t0b), char(teb));
            if obj.bins_per_window ~=round(obj.bins_per_window)
                warning('Bins per window is not an integer. This means that window boundaries will not be exact');
            end
        end
        
        function Calculate(obj)
            
            % this is how to get a xsection grid from ZmapMainWindow (aa is handle to window)
            % xsz  = aa.xsec_zap('A - A''')
            % gr = xsz.Grid.MaskWithShape(aa.shape)
            % and the above should already be pulled into the object.
      
            [t0b, teb] = obj.RawCatalog.DateRange() ;
            
            timestep=obj.bin_duration;
            % create bins so that the cutoff is a bin edge. 
            % the first events or last events are excluded if the time period is incomplete.
            obj.bin_edges = unique([obj.cutoff : -timestep : t0b , obj.cutoff: timestep:teb]);
            edges = obj.bin_edges;
            if ~obj.useOnlyCompleteBins
                % make sure ALL earthquakes are included, even if bin is too small.
                obj.bin_edges=unique([t0b, obj.bin_edges, teb]);
               
            end
            
            edgeidx2valindex=@(edges)edges(1:end-1) & edges(2:end);
            
            obj.binsBeforeCutoff = obj.bin_edges <= obj.cutoff;
            idxBeforeCutoff = edgeidx2valindex(obj.binsBeforeCutoff);
            obj.binsAfterCutoff = obj.bin_edges >= obj.cutoff;
            idxAfterCutoff = edgeidx2valindex(obj.binsAfterCutoff);
            obj.binsInWindow = obj.BinsAfter & obj.bin_edges <= (obj.cutoff + obj.window_duration);
            idxInWindow = edgeidx2valindex(obj.binsInWindow);
            obj.binsAfterWindow = obj.bin_edges >= (obj.cutoff + obj.window_duration);
            idxAfterWindow = edgeidx2valindex(obj.binsAfterWindow);
            
            idxNotInWindow = idxBeforeCutoff & idxAfterWindow;
            
            nBinsBeforeCutoff = sum(idxBeforeCutoff);
            nBinsAfterCutoff = sum(idxAfterCutoff);
            nBinsInWindow = sum(idxInWindow);
            nBinsNotInWindow = sum(idxNotInWindow);
            
            obj.gridCalculations(@calculation_function, 4);
            
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
                    out = [ nan nan nan nan];
                    return
                end
                
                %% do prelim calculations, so that they are only done ONCE per grid point
                
                % get one overarching histogram...
                nAll = histcounts(catalog.Date, edges); %was cumu
                
                % ... and access it via existing indices
                nBeforeCutoff = nAll(idxBeforeCutoff);
                nAfterCutoff = nAll(idxAfterCutoff);
                nInWindow = nAll(idxInWindow);
                nNotInWindow = nAll(idxNotInWindow);
                
                meanBeforeCutoff = mean(nBeforeCutoff);
                meanAfterCutoff  = mean(nAfterCutoff);
                meanInWindow = mean(nInWindow);
                meanNotInWindow = mean(nNotInWindow);
                
                covBeforeCutoff = cov(nBeforeCutoff);
                covAfterCutoff = cov(nAfterCutoff);
                covInWindow = cov(nInWindow);
                covNotInWindow = cov(nNotInWindow);
                
                out = [calc_ast() calc_lta() calc_rubberband() calc_percent()];
                
                % now comes the actual caclulations for 
                function out=calc_percent()
                    % loop over all grid points for percent
                    
                    out =  -((meanBeforeCutoff-meanAfterCutoff)./meanBeforeCutoff)*100;
                end
                
                function out=calc_rubberband()
                    % loop over all point for rubber band : compare window to before cutoff
                    term1 = covBeforeCutoff / nBinsBeforeCutoff;
                    term2 = covInWindow / nBinsInWindow;
                    out =  (meanBeforeCutoff - meanInWindow) ./ (sqrt(term1 + term2));
                end
                
                function out=calc_ast()
                    % make the AST function map : compare before and after cutoff
                    term1 =covBeforeCutoff / nBinsBeforeCutoff;
                    term2 = covAfterCutoff / nBinsAfterCutoff;
                    out = (meanBeforeCutoff - meanAfterCutoff) ./ (sqrt(term1 + term2));
                end
                
                function out=calc_lta()
                    % Calculate LTA: compare window to everything else
                    term1 = covNotInWindow / nBinsNotInWindow;
                    term2 = covInWindow  / nBinsInWindow;
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
