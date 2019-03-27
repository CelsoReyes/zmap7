classdef ZmapVGridFunction < ZmapGridFunction
    % ZMAPVGRIDFUNCTION is a ZmapFunction that produces a grid of results plottable in x-section (horiz slice)
    %
    % see also ZMAPGRIDFUNCTION
    
    properties(SetObservable, AbortSet)
        % features={'borders'}; % features to show on the map, such as 'borders','lakes','coast',etc.
        
        features cell = {}%{'borders'}; % features to show on the map, such as 'borders','lakes','coast',etc.
        
        nearestSample   = 0         % current index (where user clicked) within the result table
        pointChoice (1,1) char   {mustBeMember(pointChoice,{'A','B','-'})}   = 'A' % choose points for comparison. 'A', or 'B'
        samplePoints = containers.Map() % track individual points
    end
    properties(Constant)
        Type  = GridTypes.XZ;
    end
    
    
    properties(Dependent)
        resultsForThisPoint      % table row corresponding to closest grid point
        resultsForThisPointNoNan % table row corresponding to closest grid point, excluding NAN columns
        selectionForThisPoint    % mask for catalog, true for events used in this point's calculations
        catalogForThisPoint      % events used in calculating values for this point
    end
    
    methods
        
        function obj=ZmapVGridFunction(varargin)
            obj@ZmapGridFunction(varargin{:});
            obj.ResultDisplayer = ResultsDisplay.Vdisplay;
            obj.ResultDisplayer.Parent = obj;
            obj.addlistener('nearestSample','PostSet', @obj.update);
            
        end
        
        function plot_deprecated(obj,choice, varargin)
            % plots the results on the provided axes.
            if ~exist('choice','var')
                choice=obj.active_col;
            end
            if ~isnumeric(choice)
                choice = find(strcmp(obj.Result.values.Properties.VariableNames,choice));
            end
            try
            mydesc = obj.Result.values.Properties.VariableDescriptions{choice};
            myname = obj.Result.values.Properties.VariableNames{choice};
            catch
                warning('ZMAP:missingField','did not find expected field %s',obj.active_col);
                mydesc = obj.Result.values.Properties.VariableDescriptions{1};
                myname = obj.Result.values.Properties.VariableNames{1};
            end
            f=findobj(groot,'Tag',obj.PlotTag,'-and','Type','figure');
            if isempty(f)
                f=figure('Tag',obj.PlotTag);
            end
            figure(f);
            set(f,'name',['results : ', myname])
            delete(findobj(f,'Type','axes'));
            
            % this is to show the data
            obj.Grid.pcolor([],obj.Result.values.(myname), mydesc);
            set(gca,'NextPlot','add');
            
            % the imagesc exists is to enable data cursor browsing.
            obj.plot_image_for_cursor_browsing(myname, mydesc, choice);
            
            shading(obj.ZG.shading_style);
            set(gca,'NextPlot','add')
            
            obj.add_grid_centers();
            
            %ft=obj.ZG.features(obj.features);
            ax=gca;
            %copyobj(ft,ax);
            
            colorbar
            ax.Title.String=mydesc;
            ax.XLabel.String = 'Distance along Strike (km)';
            ax.YLabel.String = 'Depth';
            ax.YDir = 'reverse';
            ax.XLim = [0 obj.RawCatalog.CurveLength];
            ax.YLim = [max(0,min(obj.Grid.Z)) max(obj.Grid.Z)];

            dcm_obj = datacursormode(gcf);
            dcm_obj.Updatefcn = @ZmapGridFunction.mydatacursor;
            if isempty(findobj(gcf,'Tag','lookmenu'))
                add_menu_divider();
                lookmenu = uimenu(gcf,'label','graphics','Tag','lookmenu');
                shademenu = uimenu(lookmenu,'Label','shading','Tag','shading');
                
                % TODO: combine mapdata_viewer with this function
                exploremenu = uimenu(gcf,'label','explore');
                uimenu(exploremenu,'label','explore',MenuSelectedField(),@(src,ev)mapdata_viewer(obj.Result,obj.RawCatalog,gcf));
                
                uimenu(shademenu,'Label','interpolated',MenuSelectedField(),@(~,~)shading('interp'));
                uimenu(shademenu,'Label','flat',MenuSelectedField(),@(~,~)shading('flat'));
                
                plottype=uimenu(lookmenu,'Label','plot type');
                uimenu(plottype,'Label','Pcolor plot','Tag','plot_pcolor',...
                    MenuSelectedField(),@(src,~)obj.plot(choice),'Checked','on');
                
                % countour-related menu items
                
                uimenu(plottype,'Label','Plot Contours','Tag','plot_contour',...
                    'Enable','off',...not fully unimplmented
                    MenuSelectedField(),@(src,~)obj.contour(choice));
                uimenu(plottype,'Label','Plot filled Contours','Tag','plot_contourf',...
                    'Enable','off',...not fully unimplmented
                    MenuSelectedField(),@(src,~)contourf(choice));
                uimenu(lookmenu,'Label','change contour interval',...
                    'Enable','off',...
                    MenuSelectedField(),@(src,~)changecontours());
                
                % display overlay menu items
                
                uimenu(lookmenu,'Label','Show grid centerpoints','Checked',char(obj.showgridcenters),...
                    MenuSelectedField(),@obj.togglegrid_cb);
                uimenu(lookmenu,'Label',['Show ', obj.RawCatalog.Name, ' events'],...
                    MenuSelectedField(),{@obj.addquakes_cb, obj.RawCatalog});
                
                uimenu(lookmenu,'Separator','on',...
                    'Label','brighten',...
                    MenuSelectedField(),@(~,~)colormap(ax,brighten(colormap,0.4)));
                uimenu(lookmenu,'Label','darken',...
                    MenuSelectedField(),@(~,~)colormap(ax,brighten(colormap,-0.4)));
                
            end
            
            update_layermenu(obj,myname);
        end % plot function
       
              %% dependent properties
        
        function tb = get.resultsForThisPoint(obj)
            if obj.nearestSample ~= 0
                tb = obj.Result.values(obj.samplePoints(obj.pointChoice).idx,:);
            else
                tb = obj.Result.values([],:);
            end
        end
        
        function tb = get.resultsForThisPointNoNan(obj)
            tb = obj.Result.values(obj.samplePoints(obj.pointChoice).idx,:);
            OK = ~cellfun(@(x)isnumeric(x)&&isnan(x),table2cell(tb));
            tb = tb(:,OK);
        end
        
        function mask = get.selectionForThisPoint(obj)
            if obj.nearestSample == 0
                mask=[];
                return
            end
            tb = obj.resultsForThisPoint;
            if isempty(tb)
                mask=[];
                return; 
            end
            % evsel = obj.EventSelector;
            dists = obj.RawCatalog.epicentralDistanceTo(tb.y,tb.x);
            mask = dists <= tb.RadiusKm;
            nFoundEvents = sum(mask);
            if sum(mask) > tb.Number_of_Events
                msg.dbfprintf("<strong>Note:</strong>Selection doesn't exactly match results" + ...
                    " (<strong>%d</strong> found, expected <strong>%d</strong>)" + newline + ...
                    "  This happens when sampling requests N closest events," + newline + ...
                    "  but multiple events occur at same (farthest) distance\n",...
                    nFoundEvents, tb.Number_of_Events);
            end
            
        end
        
        function c = get.catalogForThisPoint(obj)
            c=obj.RawCatalog.subset(obj.selectionForThisPoint);
        end
        
        
        function save(obj, ~,~)
            co = class(obj);
            if any(co == '.')
                co=extractAfter(co, '.');
            end
            saveFileOptions = {...
                '*.csv','Results as a ASCII file';...
                '*.mat', [co ' object'];...
                '*.fig','Entire figure';...
                '*.fig','Result Axes only';...
                '*.mat','Results as a table';...
                '*.txt','X, Y, VAL ASCII table'};
            defaultSaveName = fullfile(ZmapGlobal.Data.Directories.output, co + "_results");
            [fn,pn,fmt] = uiputfile(...
                saveFileOptions,...
                'Save as', defaultSaveName);
            ff = fullfile(pn, fn);
            switch fmt
                case 1
                    writetable(obj.Result.Data, ff, 'FileType', 'text');
                case 2
                    save(ff,'obj');
                case 3
                    saveas(gcf, ff, 'fig');
                case 4
                    f = figure();
                    copyobj(obj.ax,f);
                    saveas(f,ff,'fig');
                    delete(f);
                case 5
                    myresults = obj.Data; %#ok<NASGU>
                    save(ff, 'myresults');
                case 6
                    minitable = table;
                    minitable.x = obj.Result.Data.x ;
                    minitable.y = obj.Result.Data.y ;
                    minitable.(obj.active_col) = obj.Result.Data.(obj.active_col);
                    writetable(minitable, ff, 'filetype', 'text');
                    
                otherwise
                    disp('do not yet know how to export to :');
            end
            
        end
    
    end % Public methods
    
    methods(Access=protected)
        
        function update(obj, varargin)
            obj.ResultDisplayer.update(varargin{:})
        end
        
        function plot_image_for_cursor_browsing_deprecated(obj, myname, mydesc, choice)
            h=obj.Grid.imagesc([],obj.Result.values.(myname));
            h.AlphaData=zeros(size(h.AlphaData))+0.0;
            
            % add some details that can be picked up by the interactive data cursor
            h.UserData.vals= obj.Result.values;
            h.UserData.choice=choice;
            h.UserData.myname=myname;
            h.UserData.myunit=obj.Result.values.Properties.VariableUnits{choice};
            h.UserData.mydesc=obj.Result.values.Properties.VariableDescriptions{choice};
        end
        
        
        function addquakes_cb_deprecated(obj,src,~,catalog)
            qtag=findobj(gcf,'tag','quakes');
            if isempty(qtag)
                set(gca,'NextPlot','add')
                line(catalog.DistAlongStrike, catalog.Z, 'Marker','o',...
                    'MarkerSize',3,...
                    'MarkerEdgeColor',[.2 .2 .2],...
                    'LineStyle','none',...
                    'Tag','quakes');
                set(gca,'NextPlot','replace')
            else
                ison=qtag.Visible == "on";
                qtag.Visible=tf2onoff(~ison);
                src.Checked=tf2onoff(~ison);
                drawnow
            end
        end
        
        function update_layermenu_deprecated(obj, myname)
            if isempty(findobj(gcf,'Tag','layermenu'))
                layermenu=uimenu(gcf,'Label','layer','Tag','layermenu');
                for i=1:width(obj.Result.values)
                    tmpdesc=obj.Result.values.Properties.VariableDescriptions{i};
                    tmpname=obj.Result.values.Properties.VariableNames{i};
                    uimenu(layermenu,'Label',tmpdesc,'Tag',tmpname,...
                        'Enable',tf2onoff(~all(isnan(obj.Result.values.(tmpname)))),...
                        MenuSelectedField(),@(~,~)plot_cb(tmpname));
                end
            end
            
            % make sure the correct option is checked
            layermenu=findobj(gcf,'Tag','layermenu');
            set(findobj(layermenu,'Tag',myname),'Checked','on');
            
            % plot here
            function plot_cb(name)
                set(findobj(layermenu,'type','uimenu'),'Checked','off');
                obj.plot(name);
            end
        end
        
    end % Protected methods
end