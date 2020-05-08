classdef magrcros < ZmapVGridFunction
    % MAGRCROS calcualtes Z-values in cross section
    %
    % TODO make this the first x-section function
    
    
    properties
        cutoff          datetime                % time of cut
        use_fixed_start logical     = false;
        periodA_start   datetime                % windows start time [where pre-window data starts]
        use_fixed_end   logical     = false;
        periodB_end     datetime                % windows end time [where post-window data ends]
        window_duration duration    = ZmapGlobal.Data.compare_window_dur;
        bin_dur         duration
    end
    
    properties(Constant)
        PlotTag         = 'zsection';
        ReturnDetails   = cell2table({ ... TODO update this. it hasn't been really done.
            ... VariableNames, VariableDescriptions, VariableUnits
            'AST',                  'Z-value comparing rate before to rate after cutoff','';...
            'LTA',                  'Z-value comparing rate outside window to inside window','';...
            'RUB',                  'Z-value comparing rate before cutoff [before window] to rate inside window','';...
            'PCT',                  'Compare ','';...
            'nBeforeCutoff',        '','';...
            'nAfterCutoff',         '','';...
            'nInWindow',            '','';...
            'nNotInWindow',         '','';...
            'DistAlongStrike',    'Distance along strike','km'...
            }, 'VariableNames', {'Names','Descriptions','Units'});
        
        CalcFields      = {...
            'AST','LTA','RUB','PCT',...
            'nBeforeCutoff','nAfterCutoff','nInWindow','nNotInWindow'}
        
        ParameterableProperties = ["cutoff", "use_fixed_start",...
            "periodA_start", "periodB_end", "use_fixed_end", "window_duration", "bin_dur"]
        
        References="";
        %Negative z-values indicate an increase in the seismicity rate, positive values a decrease.
            unit_options = {'seconds','hours','days','years'};
            unit_functions = {@seconds, @hours, @days, @years};
    end
    methods
        function obj=magrcros(zap,varargin)
            obj@ZmapVGridFunction(zap,'AST');
            report_this_filefun();
            
            % set the dependent variables here
            obj.periodA_start = min(obj.RawCatalog.Date);
            obj.periodB_end = max(obj.RawCatalog.Date);
            
            obj.parseParameters(varargin);
            warning('ZMAP:unimplemented','apparently still broken');
                
            obj.StartProcess();
            
            
            % consider this for future: uimenu(op1,'Label','Show Circles ','MenuSelectedFcn',@(~,~)plotcirc)
        end
        
        function InteractiveSetup(obj)
            % get the grid parameter
            
            
            % these are provided by the eventselection
            %ni = 100;
            %ra = ZG.ra;
            
            if isempty(obj.cutoff)
                % set the default cutoff to the time of the biggest event in catalog. 
                % selects first event if multiple events are same size
                biggest=find(obj.RawCatalog.Magnitude==max(obj.RawCatalog.Magnitude) , 1);
                obj.cutoff = obj.RawCatalog.Date(biggest);
            end
            % make the interface
            %
            zdlg = ZmapDialog();
            zdlg.AddEventSelector('evsel', obj.EventSelector);
            if ~isempty(obj.Shape)
                zdlg.AddCheckbox('useGridFromShape', 'Limit grid to polygon', true,[],...
                    'Only evaluate for gridpoints within the polygon region. Does not restrict the catalog');
                zdlg.AddCheckbox('useCatFromShape', 'Limit catalog to polygon', false,[],...
                    'Only evaluate for events within the shape region. Does not restrict the grid');
                
            end
            
            % these provided by the grid
            %dd = 1.00;
            %dx = 1.00 ;
            %zdlg.AddEdit('dx_km','Spacing along strike [km]',dx,'spacing in horizontal plane');
            %zdlg.AddEdit('dd_km','Spacing in depth [km]',dd,'spacing in vertical plane');
            
            %zdlg.AddEdit('bin_dur','Time steps in days',ZG.bin_dur,'time steps in days');
            
            default_unit = find(obj.unit_options == "days");
            unitizer = obj.unit_functions{default_unit};
            
            zdlg.AddCheckbox('use_fixed_start', 'Fix StartTime', obj.use_fixed_end, 'fixed_start',...
                'Otherwise, the StartTime will depend on the catalog');
            
            zdlg.AddEdit('fixed_start',         'Start time',    obj.periodA_start,...
                'window size in specified units');
           
            
            zdlg.AddCheckbox('use_fixed_end',   'Fix EndTime',  obj.use_fixed_start, 'fixed_end',...
                'Otherwise, the StartTime will depend on the catalog');
            
            zdlg.AddEdit('fixed_end',           'End time',     obj.periodB_end,...
                'end time');
            
            zdlg.AddEdit('cutoff','Please enter date & time of cut:', obj.cutoff, 'Cutoff Date as yyyy-mm-dd hh:MM:ss');
            
            zdlg.AddEdit('win_dur',             'Window Size',  unitizer(obj.window_duration),...
                'window size in specified units');
            
            zdlg.AddPopup('win_dur_unit', 'Window Size Units:', obj.unit_options,   default_unit,...
                'Chooose units for window duration');
            zdlg.AddEdit('n_bins_in_window',    'Number of bins within window',...
                round(obj.window_duration/obj.ZG.bin_dur),...
                'Number of windows used to divide up the window [INTEGER]. this determines the bin size');
            
            [zparam,okPressed]=zdlg.Create('Name', 'Z-value xsection input parameters');
            if ~okPressed
                return
            end
            
            %dd=zparam.dd_km;
            %dx=zparam.dx_km;
            
            if isfield(zparam,'useCatFromShape') && zparam.useCatFromShape
                errordlg('not yet implemented: use catalog from shape. First limit catalog by shape, THEN call this function');
                return
            end
            
            SetValuesFromDialog(obj,zparam);
            obj.doIt();
            
        end  %  InteractiveSetup
        
        function SetValuesFromDialog(obj, res)
            if res.use_fixed_start
                obj.periodA_start = min(obj.RawCatalog.Date);
            else
                obj.periodA_start = res.fixed_start;
            end
            
            if res.use_fixed_end
                obj.periodB_end = max(obj.RawCatalog.Date);
            else
                obj.periodB_end = res.fixed_end;
            end
            unitizer = obj.unit_functions{res.win_dur_unit};
            obj.window_duration = unitizer(res.win_dur);
            obj.bin_dur = obj.window_duration/res.n_bins_in_window;
            obj.cutoff = res.cutoff;
            obj.EventSelector=res.evsel;
            
            if isfield(res,'useGridFromShape') && res.useGridFromShape
                obj.Grid = obj.Grid.MaskWithShape(obj.Shape);
            end
        end
        
        function Calculate(obj)
            
            % this is how to get a xsection grid from ZmapMainWindow (aa is handle to window)
            % xsz  = aa.xsec_zap('A - A''')
            % gr = xsz.Grid.MaskWithShape(aa.shape)
            % and the above should already be pulled into the object.
      
            assert(obj.cutoff > obj.periodA_start && obj.cutoff < obj.periodB_end,...
                'Cutoff date should be some time after %s and before %s', char(obj.periodA_start), char(obj.periodB_end));
            assert(obj.periodA_start < obj.periodB_end,'Invalid dates: Start date is after End date');
            assert (obj.cutoff + obj.window_duration > obj.periodB_end,...
                'window extends past end date. Manually set end date or change window');


            edges_for_cov = unique([obj.cutoff : - obj.bin_dur : obj.periodA_start, obj.cutoff : obj.bin_dur : obj.periodB_end]);
            
            obj.gridCalculations(@calculation_function);
            obj.Result.periodA_start = obj.periodA_start;
            obj.Result.periodB_end = obj.periodB_end;
            obj.Result.cutoff = obj.cutoff;
            obj.Result.bin_dur = obj.bin_dur;
            
            function out = calc_probability(old)
                %calculate probabliity, where old is one of the zmaps.
                % salvaged from vi_cucro
                valueMap = old;
                l = valueMap < 2.57;
                valueMap(l) = 2.65;
                pr = 0.0024 + 0.03*(valueMap - 2.57).^2;
                pr = (1-1./(exp(pr)));
                out = pr;
            end
            
            % catsave3('magrcros');
            
            % Plot the results
            %det = 'nop'
            %in2 = 'nocal'
            %menucros() -> which was at one point hooked up to incube, but not while I've been manipulating it. CGR
            
            
            function out=calculation_function(catalog)
                if catalog.Count <= 4
                    out = nan(size(obj.CalcFields));
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
                    sum(nBeforeCutoff), sum(nAfterCutoff), sum(nInWindow), sum(nNotInWindow)];
                
                % now comes the actual calculations for 
                function out=calc_percent()
                    out =  -((meanBeforeCutoff-meanAfterCutoff)./meanBeforeCutoff)*100;
                    assert(numel(out)==1)
                end
                
                function out=calc_rubberband()
                    % loop over all point for rubber band : compare window to before cutoff
                    term1 = covBeforeCutoff / days(durBeforeCutoff);
                    term2 = covInWindow / days(durInWindow);
                    out =  (meanBeforeCutoff - meanInWindow) ./ (sqrt(term1 + term2));
                    assert(numel(out)==1)
                end
                
                function out=calc_ast()
                    % make the AST function map : compare before and after cutoff
                    term1 =covBeforeCutoff / days(durBeforeCutoff);
                    term2 = covAfterCutoff / days(durAfterCutoff);
                    out = (meanBeforeCutoff - meanAfterCutoff) ./ (sqrt(term1 + term2));
                    assert(numel(out)==1)
                end
                
                function out=calc_lta()
                    % Calculate LTA: compare window to everything else
                    term1 = covNotInWindow / days(durNotInWindow);
                    term2 = covInWindow  / days(durInWindow);
                    out =  (meanNotInWindow - meanInWindow)./(sqrt(term1+term2));
                    assert(numel(out)==1)
                end
                
                % removed something that calculated 'maz', since it was never referenced elsewhere, and
                % the original code was seriously convoluted. -CGR

                
            end %  calculation_function
        end % Calculate
        
        

    end % methods
    methods(Static)
        function h = AddMenuItem(parent, zapFcn, varargin) %xsec_zap
            % create a menu item
            label = 'Z-value section map';
            h = uimenu(parent, 'Label', label,...
                'MenuSelectedFcn', @(~,~)XZfun.magrcros(zapFcn()),...
                varargin{:});
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
