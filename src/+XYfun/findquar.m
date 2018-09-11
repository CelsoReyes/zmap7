classdef findquar < ZmapHGridFunction
    % description of this function
    %
    % in the function that generates the figure where this function can be called:
    %
    %     % create some menu items...
    %     h=sample_ZmapFunction.AddMenuItem(hMenu,@catfn) %create subordinate to menu item with handle hMenu
    %     % create the rest of the menu items...
    %
    %  once the menu item is clicked, then sample_ZmapFunction.interative_setup(true,true) is called
    %  meaning that the user will be provided with a dialog to set up the parameters,
    %  and the results will be automatically calculated & plotted once they hit the "GO" button
    %
    
    properties
        inDaytime         (24,1) logical    = false(24,1) % true for hours that are "daytime" hours
        localNoonEstimate (1,1)  double     = 12; % estimate time where local noon is. used with dayLength
        dayLength         (1,2)  double   {mustBePositive}    = [4, 6] % hours BEFORE noon to hours AFTER noon
    end
    
    properties(Constant)
        PlotTag         = 'QuarryRatios'
        ReturnDetails   = cell2table({...VariableNames, VariableDescriptions, VariableUnits
            'day_night_ratio',      'Day-Night event ratio', '';
            'day_night_ratio_norm', 'Day-Night event ratio (normalized by hrs in day)', '';
            'n_day',                'Number of events during day','';
            'n_night',              'Number of events during night',''...
            }, 'VariableNames', {'Names','Descriptions','Units'})
        
        CalcFields      = {'day_night_ratio','day_night_ratio_norm','n_day','n_night'}
        DayColor        = [0.8 0.8 0.2] % for histogram
        NightColor      = [0.1 0.0 0.6] % for histogram
        
        ParameterableProperties = ["inDaytime" "localNoonEstimate" "dayLength" "NodeMinEventCount"];
        References="";
    end
    
    methods
        function obj=findquar(zap,varargin) %CONSTRUCTOR
            % create a [...]
            
            obj@ZmapHGridFunction(zap, 'day_night_ratio_norm');
            report_this_filefun();
            
            
            obj.CalcLocalNoon();
            obj.NodeMinEventCount = 20;
            % set the deafult days & nights based on  local noon and the "day" length
            dayStart = mod(obj.localNoonEstimate - obj.dayLength(1),24);
            dayEnd = mod(obj.localNoonEstimate + obj.dayLength(2),24);
            eachHour = 0:23;
            if dayStart < dayEnd
                obj.inDaytime = dayStart <= eachHour  & eachHour < dayEnd;
            else
                obj.inDaytime = dayStart <= eachHour | eachHour < dayEnd;
            end
            
            obj.parseParameters(varargin);
            obj.StartProcess();
        end
        
        function InteractiveSetup(obj)
            % allow user to determine grid and selection parameters
            
            obj.InteractiveSetup_part2();
            
        end
        
        function InteractiveSetup_part2(obj)
            % allow user to define which hours are in a "day"
            
            fifhr = figure(...
                'Name','Daytime (explosion) hours',...
                'NumberTitle','off', ...
                'NextPlot','new', ...
                'units','points',...
                'Visible','on', ...
                'Tag','fifhr',...
                'Position',[ 100 100 500 650]);
            axis off
            ax = gca;
            
            uicontrol(fifhr,'Style','text','String','Detect Quarry Events',...
                'FontWeight','Bold','FontSize',14,'Units','points','Position',[50 620 300 20]);
          
            set(ax,'NextPlot','add');
            hax = axes(fifhr,'Units','points','pos', [50 320 300 270]);
            eventHours = obj.ToHourlyCategorical(obj.RawCatalog.Date.Hour);
            
            dayHist = histogram(hax,eventHours,'DisplayName','day','FaceColor',obj.DayColor);
            set(hax,'NextPlot','add');
            
            nightHist = histogram(hax,eventHours,'DisplayName','night','FaceColor', obj.NightColor);
            title(' Select the daytime hours and then "GO"')
            [X,N,B] = histcounts(obj.RawCatalog.Date.Hour,-0.5:1:24.5);
            %[X,~,B] = histcounts(eventHours);
            %[X,~] = hist(obj.RawCatalog.Date.Hour,-0.5:1:24.5);
            
            xlabel(hax,'Hr of the day')
            ylabel(hax,'Number of events per hour')
            
            evsel=EventSelectionChoice(fifhr,'evsel', [40,100], obj.EventSelector);
            
            chkpos = @(n)[.80 1-n/28-0.03 .17 1/26];
            for i = 1:24
                hHourly(i)=uicontrol(fifhr,'Style','checkbox',...
                    'string',[num2str(i-1) ' - ' num2str(i) ],...
                    'Units','normalized',...
                    'Position',chkpos(i),'tag',num2str(i),...
                    'Callback',{@cb_flip,i});
            end
            
            obj.CalcLocalNoon();
            dayStart = mod(obj.localNoonEstimate - obj.dayLength(1),24);
            dayEnd = mod(obj.localNoonEstimate + obj.dayLength(2),24);
            eachHour = 0:23;
            if dayStart < dayEnd
                obj.inDaytime = dayStart <= eachHour  & eachHour < dayEnd;
            else
                obj.inDaytime = dayStart <= eachHour | eachHour < dayEnd;
            end
            % turn on checkboxes according to their percentile score
            %  idx = X(1:end-1) > prctile2(X,60); % then set values from this
            
            for hr = 1:24
                hHourly(hr).Value = obj.inDaytime(hr);
            end
            update_histograms();
            %nightHist.Data(obj.inDaytime)=nan;
            legend(hax,'show');
            if isempty(findobj(fifhr,'Tag','quarryinfo'))
                add_menu_divider();
                uimenu(fifhr,'Label','Info',MenuSelectedField(),@cb_info,'tag','quarryinfo');
            end
            
            uicontrol(fifhr,'style','pushbutton','String','GO','Callback',@cb_go,'Position',[330 10 60 25]);
            
            uicontrol(fifhr,'style','pushbutton','String','Cancel','Callback',@cb_cancel,'Position',[400 10 60 25]);
            
            function cb_flip(~,~,i)
                obj.inDaytime(i) = ~obj.inDaytime(i);
                update_histograms();
            end
            function update_histograms()
                dayCats = obj.ToHourlyCategorical(find(obj.inDaytime)-1);
                nightCats = obj.ToHourlyCategorical(find(~obj.inDaytime)-1);
                dayHist.Data = eventHours(ismember(eventHours, dayCats));
                nightHist.Data = eventHours(ismember(eventHours, nightCats));
            end
            function cb_go(~,~)
                
                obj.EventSelector = EventSelectionParameters.fromStruct(evsel.toStruct());
                obj.inDaytime=logical([hHourly.Value]); %same as idx
                close;
                obj.doIt();
            end
            
            function cb_cancel(~,~)
                close;
            end
        end
        
        function results=Calculate(obj)
            % once the properties have been set, either by the constructor or by interactive_setup
        
            
            close(findobj('Tag','fifhr'));
            
            ld = sum(obj.inDaytime);
            
            assert(ld ~= 0, 'No daytime hours chosen. This calculation will have no meaning.');
            assert(ld ~= 24, 'No nighttime hours chosen. This calculation will have no meaning.');
            
            ln = sum(~obj.inDaytime);
            daynight_hr_ratio=ld/ln;
            
            % loop over all points in polygon. Evaluated for earthquakes that may extend outside
            % the points.
            %{
            [valueMap,nEv,r]=gridfun(@calculate_day_night_ratio, obj.RawCatalog, mygrid, obj.EvtSel);
            bvg=[valueMap(mygrid.ActivePoints), mygrid.ActiveGrid, r(mygrid.ActivePoints)];
            %}
            
            obj.gridCalculations(@calculate_day_night_ratio);
        
            if nargout
                results=obj.Result.values;
            end
            
            % plot the results
            % obj.oldratios and valueMap (initially ) is the b-value matrix
            
            %obj.oldratios = valueMap;
            
            % results of the calculation should be stored in fields belonging to obj.Result
            
            %obj.Result.bvg=bvg;
            %obj.Result.msg='bvg is [daynightratios x y maxdist_km]';
            %obj.Result.valueMap=valueMap;
            
            
            function val = calculate_day_night_ratio(catalog)
                hrofday= hour(catalog.Date);
                nDay= sum(obj.inDaytime(hrofday+1));
                nNight = catalog.Count - nDay;
                myratio = (nDay / nNight);
                normalizedRatioByHoursInDay = myratio * daynight_hr_ratio;
                val=[myratio normalizedRatioByHoursInDay nDay nNight];
            end
        end
        %{
        function plot(obj,varargin)
            % plots the results somewhere
            f=obj.Figure('deleteaxes',@create_my_menu); % nothing or 'deleteaxes'
            set(f,'Name','q-detect-map',...
                    'NumberTitle','off', ...
                    'NextPlot','new', ...
                    'backingstore','on',...
                    ...'Visible','off', ...
                    'Position',[ 50 50 800 600]);
                
            obj.ax=axes(f);
            
            obj.ZG.tresh_km = nan;
            re4 = obj.Result.valueMap;
            
            colormap(cool)
            
            %  plot the color-map of the value
            
            set(obj.ax,...
                ...'visible','off',
                'FontSize',ZmapGlobal.Data.fontsz.s,...
                'FontWeight','bold',...
                'FontWeight','bold','LineWidth',1.5,...
                'Box','on','SortMethod','childorder')
            
            % find max and min of data for automatic scaling
            %
            re4(obj.Result.maxRad > obj.ZG.tresh_km) = nan;
            maxc = ceil(max(re4(:)));
            minc = floor(min(re4(:)));
            % set values greater ZG.tresh_km = nan
            %
            
            % plot image
            %
            orient landscape
            
            set(obj.ax,'position',[0.18,  0.10, 0.7, 0.75]);
            set(gca,'NextPlot','add')
            pco1 = gridpcolor(obj.ax, obj.Grid.X, obj.Grid.Y, re4');
            
            axis(obj.ax, [ min(obj.Grid.X(:)) max(obj.Grid.X(:)) min(obj.Grid.Y(:)) max(obj.Grid.Y(:))])
            axis(obj.ax, 'image');
            hold(obj.ax, 'on');
            
            shading(obj.ax, obj.ZG.shading_style);
            
            fix_caxis(re4,'horiz',minc,maxc,false);
            fix_caxis.ApplyIfFrozen(obj.ax);
            titlestr = sprintf('%s; %s to %s',...
                obj.RawCatalog.Name, min(obj.RawCatalog.Date), max(obj.RawCatalog.Date));
            title(obj.ax, titlestr, ...
                'FontSize', ZmapGlobal.Data.fontsz.s,...
                'Interpreter', 'none', 'FontWeight', 'bold')
            
            xlabel(obj.ax,'Longitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
            ylabel(obj.ax,'Latitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
            
            % plot overlay
            %
            set(gca,'NextPlot','add')
            %zmap_update_displays();
            ploeq = plot(obj.ax,obj.RawCatalog.Longitude,obj.RawCatalog.Latitude,'k.');
            set(ploeq,'Tag','eq_plot','MarkerSize',obj.ZG.ms6,'Marker','.','Color',obj.ZG.someColor,'Visible','on')
            
            set(obj.ax,'visible','on','FontSize',obj.ZG.fontsz.s,'FontWeight','bold',...
                'FontWeight','bold','LineWidth',1.5,...
                'Box','on','TickDir','out')
            h1 = gca;
            hzma = gca;
            
            % Create a colorbar
            %
            h5 = colorbar('horiz');
            set(h5,...'Pos',[0.35 0.05 0.4 0.02],...
                'FontWeight','bold','FontSize',obj.ZG.fontsz.s)
            
            axes('position',[0.00,  0.0, 1, 1])
            axis('off')
            %  Text Object Creation
            txt1 = text(...
                'Units','normalized',...
                'Position',[ 0.33 0.07 0 ],...
                'HorizontalAlignment','right',...
                'FontSize',obj.ZG.fontsz.s,....
                'FontWeight','bold',...
                'String','Day-Night ratio');
            
            % Make the figure visible
            %
            set(gca,'FontSize',obj.ZG.fontsz.s,'FontWeight','bold',...
                'FontWeight','bold','LineWidth',1.5,...
                'Box','on','TickDir','out')
            axes(h1)
            whitebg(gcf,[ 0 0 0 ])
            
            %% ui functions
            function create_my_menu()
                add_menu_divider();
                
                add_symbol_menu('eq_plot');
                
                options = uimenu('Label',' Select ');
                uimenu(options,'Label','Refresh ', MenuSelectedField(),@cb_refresh)
                uimenu(options,'Label','Edit Selection parameters',MenuSelectedField(),@(~,~)obj.InteractiveSetup());
                uimenu(options,'Label','Histogram: EQ in Circle', MenuSelectedField(),@cb_select_circle)
                uimenu(options,'Label','Histogram: EQ in Polygon ', MenuSelectedField(),@cb_select_poly)
                uimenu(options,'Label','Info',MenuSelectedField(),@cb_info);
                op1 = uimenu('Label',' Maps ');
                uimenu(op1,'Label','REVERT day/night value map',...
                    MenuSelectedField(),@callbackfun_005)
                
                
                add_display_menu(1);
            end
            
            %% callback functions
            
            function cb_refresh(mysrc,myevt)
                callback_tracker(mysrc,myevt,mfilename('fullpath'));
                delete(findobj(qmap,'Type','axes'));
                obj.plot();
            end
            
            function cb_select_circle(mysrc,myevt)
                callback_tracker(mysrc,myevt,mfilename('fullpath'));
                h1 = gca;
                
                % circle;
                hisgra(ZG.newt2.Date.Hour,'Hour',ZG.newt2.Name);
            end
            
            function cb_select_poly(mysrc,myevt)
                callback_tracker(mysrc,myevt,mfilename('fullpath'));
                stri = 'Polygon';
                h1 = gca;
                cufi = gcf;
                selectp;
                hisgra(obj.ZG.newt2,'Hour');
            end
            
            function callbackfun_005(mysrc,myevt)
                obj.Result.valueMap = obj.oldratios;
                obj.plot();
            end
            
            function callbackfun_bva_go(mysrc,myevt)
                
                callback_tracker(mysrc,myevt,mfilename('fullpath'));
                
                pause(1);
                re4 =valueMap;
                view_bva(valueMap);
            end
            
        end
        %}
        
        function ModifyGlobals(obj)
            % change the ZmapGlobal variable, if appropriate
            % obj.ZG.SOMETHING = obj.Result.SOMETHING
        end
        
        function CalcLocalNoon(obj)
            catMedianLatitude = median(obj.RawCatalog.Longitude);
            obj.localNoonEstimate = round( catMedianLatitude  / 15) + 12;
        end
        
    end %methods
    
    methods(Static)
        function h=AddMenuItem(parent, zapFcn)
            % create a menu item that will be used to call this function/class
            label='Find Quarry Events';
            h=uimenu(parent,'Label',label,MenuSelectedField(), @(~,~)XYfun.findquar(zapFcn()));
        end
        
        function ct = ToHourlyCategorical(val)
            ct = categorical(val, 0:23, 'ordinal', true);
        end
    end % static methods
    
end %classdef

%% Callbacks

% All callbacks should set values within the same field. Leave
% the gathering of values to the SetValuesFromDialog button.

function cb_info(mysrc,myevt)
    ZG=ZmapGlobal.Data;
    callback_tracker(mysrc,myevt,mfilename('fullpath'));
    web(['file:' ZG.hodi '/help/quarry.htm']) ;
end

