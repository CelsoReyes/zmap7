classdef findquar < ZmapFunction
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
        
        EvtSel
        Grid
        oldratios
        inDaytime=false(24,1);
    end
    
    properties(Constant)
        PlotTag='QuarryRatios';
    end
    
    methods
        function obj=findquar(catalog,varargin) %CONSTRUCTOR
            % create a [...]
            
            narginchk(1,inf); 
            ZmapFunction.verify_catalog(catalog);
            obj.RawCatalog=catalog;
            
            % depending on whether parameters were provided, either run automatically, or
            % request input from the user.
            if nargin<2
                % create dialog box, then exit.
                obj.InteractiveSetup();
                
            else
                %run this function without human interaction
                
                % set values for properties
                
                ...
                    
            % run the rest of the program
            obj.doIt();
            end
        end
        
        function InteractiveSetup(obj)
            % allow user to determin grid and selection paramters
            
            zdlg=ZmapDialog(...
                obj,...  pass it a handle that it can change when the OK button is pressed.
                @obj.InteractiveSetup_part2...  if OK is pressed, then this function will be executed.
                );
            
            %----------------------------
            % The dialog box is a vertically oriented series of controls
            % that allow you to choose parameters
            %
            %  every procedure takes a tag parameter. This is the name of the class variable
            %  where results will be stored for that field.  Results will be of the same type
            %  as the provided values.  That is, if I initialize a field with a datetime, then
            %  the result will be converted back to a datetime. etc.
            %
            % add items ex.  :
            %  zdlg.AddBasicHeader  : add line of bold text to separate areas
            %  zdlg.AddBasicPopup   : add popup that returns the # of chosen line
            %  zdlg.AddGridParameters : add section that returns grid defining params
            %  zdlg.AddBasicCheckbox : add checkbox that returns state,
            %                          and may affect other control's enable states
            %  zdlg.AddBasicEdit : add basic edit field & edit field label combo
            %  zdlg.AddEventSelectionParameters : add section that returns how grid points
            %                                     may be evaluated
            
            zdlg.AddGridParameters('Grid',1.0,'deg',1.0,'deg',[],[]);
            zdlg.AddEventSelectionParameters('EvtSel',100,[],1);
            % get the grid parameter
            
            zdlg.Create('Define Grid and Selection Parameters')
        end
        
        function InteractiveSetup_part2(obj)
            % allow user to define which hours are in a "day"
            
            fifhr=figure_w_normalized_uicontrolunits(...
                'Name','Daytime (explosion) hours',...
                'NumberTitle','off', ...
                'NextPlot','new', ...
                'units','points',...
                'Visible','on', ...
                'Tag','fifhr',...
                'Position',[ 100 200 500 450]);
            axis off
            text(...
                'Position',[0. 0.90 0 ],...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'FontWeight','bold',...
                'String',' Select the daytime hours and then ''GO''  ');
            figure(fifhr);
            hold on
            axes(fifhr,'pos',[0.1 0.2 0.6 0.6]);
            histogram(obj.RawCatalog.Date.Hour,-0.5:1:24.5);
            [X,N] = histcounts(obj.RawCatalog.Date.Hour,-0.5:1:24.5);
            %[X,~] = hist(obj.RawCatalog.Date.Hour,-0.5:1:24.5);
            
            xlabel('Hr of the day')
            ylabel('Number of events per hour')
            
            for i = 1:24
                hHourly(i)=uicontrol('Style','checkbox',...
                    'string',[num2str(i-1) ' - ' num2str(i) ],...
                    'Position',[.80 1-i/28-0.03 .17 1/26],'tag',num2str(i),...
                    'Units','normalized');
            end
            
            % turn on checkboxes according to their percentile score
            idx = X(1:end-1) > prctile2(X,60);
            for i = 1:length(idx)
                set(hHourly(i),'Value',idx(i));
            end
            
            if isempty(findobj(fifhr,'Tag','quarryinfo'))
                add_menu_divider();
                uimenu(fifhr,'Label','Info','callback',@cb_info,'tag','quarryinfo');
                uimenu(fifhr,'Label','Go','callback',@cb_go);
                uimenu(fifhr,'Label','Cancel','callback',@cb_cancel);
            end
            
            function cb_go(~,~)
                obj.inDaytime=logical([hHourly.Value]);
                close;
                obj.doIt();
            end
            
            function cb_cancel(~,~)
                close;
            end
        end
        
        function CheckPreconditions(obj)
            % check to make sure any inportant conditions are met.
            % for example,
            % - catalogs have what are expected.
            % - required variables exist or have valid values
            assert(true==true,'laws of logic are broken.');
        end
        
        function Calculate(obj)
            % once the properties have been set, either by the constructor or by interactive_setup
            
            % create the function call that someone could use to recreate this calculation.
            %
            % for example, if one would call this function with:
            %      myfun('bob',23,false);
            % with values that get assigned the variables:
            %     obj.name, obj.age, obj.runreport
            % then the next line should be:
            %      obj.FunctionCall={'name','age','runreport'};
            
            obj.FunctionCall={};
            
            
            close(findobj('Tag','fifhr'));
            
            
            %[fullGrid,gridInPolygon, polyMask]=selgp(obj.Grid);
            
            
            mygrid=ZmapGrid('quarry', obj.Grid);
            if ~obj.Grid.GridEntireArea
                mygrid=mygrid.MaskWithShape(ZG.selection_shape);
            end
            %  make grid, calculate start- endtime etc.  ...
            %
            
            
            ld = sum(obj.inDaytime);
            
            assert(ld ~= 0, 'No daytime hours chosen. This calculation will have no meaning.');
            assert(ld ~= 24, 'No nighttime hours chosen. This calculation will have no meaning.');
            
            ln = sum(~obj.inDaytime);
            daynight_hr_ratio=ld/ln;
            
            % loop over all points in polygon. Evaluated for earthquakes that may extend outside
            % the points.
            [valueMap,nEv,r]=gridfun(@calculate_day_night_ratio, obj.RawCatalog, mygrid, obj.EvtSel);
            bvg=[valueMap(mygrid.ActivePoints), mygrid.ActiveGrid, r(mygrid.ActivePoints)];
            
            % plot the results
            % obj.oldratios and valueMap (initially ) is the b-value matrix
            
            obj.oldratios = valueMap;
            
            % results of the calculation should be stored in fields belonging to obj.Result
            
            obj.Result.bvg=bvg;
            obj.Result.msg='bvg is [daynightratios x y maxdist_km]';
            obj.Result.valueMap=valueMap;
            obj.Result.maxRad=r;
            obj.Result.nEvents=nEv;
            obj.Grid=mygrid;
            
            
            function val = calculate_day_night_ratio(catalog)
                hrofday= hour(catalog.Date);
                nDay= sum(obj.inDaytime(hrofday+1));
                nNight = catalog.Count - nDay;
                val = (sum(nDay)/sum(nNight)) * daynight_hr_ratio;
            end
        end
        
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
            
            %axes('position',[0.18,  0.10, 0.7, 0.75])
            set(obj.ax,'position',[0.18,  0.10, 0.7, 0.75]);
            hold on
            pco1 = gridpcolor(obj.ax, obj.Grid.X, obj.Grid.Y, re4');
            
            axis(obj.ax, [ min(obj.Grid.X(:)) max(obj.Grid.X(:)) min(obj.Grid.Y(:)) max(obj.Grid.Y(:))])
            axis(obj.ax, 'image');
            hold(obj.ax, 'on');
            
            shading(obj.ax, obj.ZG.shading_style);
            
            fix_caxis(re4,'horiz',minc,maxc,false);
            fix_caxis.ApplyIfFrozen(obj.ax);
            
            title(obj.ax,[obj.RawCatalog.Name ';  '   char(min(obj.RawCatalog.Date)) ' to ' char(max(obj.RawCatalog.Date)) ],...
                'FontSize',ZmapGlobal.Data.fontsz.s,...
                'Interpreter','none','FontWeight','bold')
            
            xlabel(obj.ax,'Longitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
            ylabel(obj.ax,'Latitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
            
            % plot overlay
            %
            hold on
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
                uimenu(options,'Label','Refresh ', 'callback',@cb_refresh)
                uimenu(options,'Label','Edit Selection parameters','callback',@(~,~)obj.InteractiveSetup());
                uimenu(options,'Label','Histogram: EQ in Circle', 'callback',@cb_select_circle)
                uimenu(options,'Label','Histogram: EQ in Polygon ', 'callback',@cb_select_poly)
                uimenu(options,'Label','Info','callback',@cb_info);
                op1 = uimenu('Label',' Maps ');
                uimenu(op1,'Label','REVERT day/night value map',...
                    'callback',@callbackfun_005)
                
                
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
        
        function ModifyGlobals(obj)
            % change the ZmapGlobal variable, if appropriate
            % obj.ZG.SOMETHING = obj.Result.SOMETHING
        end
        
    end %methods
    
    methods(Static)
        function h=AddMenuItem(parent, catalogfn)
            % create a menu item that will be used to call this function/class
            
            h=uimenu(parent,'Label','Find Quarry Events',...
                'Callback', @(~,~)findquar(catalogfn())...
                );
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

