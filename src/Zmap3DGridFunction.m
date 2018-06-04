classdef Zmap3DGridFunction < ZmapGridFunction
    % ZMAP3DGRIDFUNCTION is a ZmapFunction that produces a grid of volumetric results
    %
    % see also ZMAPGRIDFUNCTION
    
    properties
        features={'borders'}; % features to show on the map, such as 'borders','lakes','coast',etc.
    end
    
    methods
        
        function obj=Zmap3DGridFunction(varargin)
            error('Not yet implemented')
            obj@ZmapGridFunction(varargin{:});
        end
        
        function plot(obj,choice, varargin)
            % plots the results on the provided axes.
            if ~exist('choice','var')
                choice=obj.active_col;
            end
            if ~isnumeric(choice)
                choice = find(strcmp(obj.Result.values.Properties.VariableNames,choice));
            end
            
            mydesc = obj.Result.values.Properties.VariableDescriptions{choice};
            myname = obj.Result.values.Properties.VariableNames{choice};
            
            f=findobj(groot,'Tag',obj.PlotTag,'-and','Type','figure');
            if isempty(f)
                f=figure('Tag',obj.PlotTag);
            end
            figure(f);
            set(f,'name',['results from bvalgrid : ', myname])
            delete(findobj(f,'Type','axes'));
            
            % this is to show the data
            obj.Grid.pcolor([],obj.Result.values.(myname), mydesc);
            set(gca,'NextPlot','add');
            
            % the imagesc exists is to enable data cursor browsing.
            obj.plot_image_for_cursor_browsing(myname, mydesc, choice);
            
            shading(obj.ZG.shading_style);
            set(gca,'NextPlot','add')
            
            obj.add_grid_centers();
            
            ax=gca;
            for n=1:numel(obj.features)
                ft=obj.ZG.features(obj.features{n});
                copyobj(ft,ax);
            end
            
            colorbar
            title(mydesc)
            xlabel('Longitude')
            ylabel('Latitude')
            
            dcm_obj=datacursormode(gcf);
            dcm_obj.Updatefcn=@ZmapGridFunction.mydatacursor;
            if isempty(findobj(gcf,'Tag','lookmenu'))
                add_menu_divider();
                lookmenu=uimenu(gcf,'label','graphics','Tag','lookmenu');
                shademenu=uimenu(lookmenu,'Label','shading','Tag','shading');
                
                % TODO: combine mapdata_viewer with this function
                exploremenu=uimenu(gcf,'label','explore');
                uimenu(exploremenu,'label','explore',Futures.MenuSelectedFcn,@(src,ev)mapdata_viewer(obj.Result,obj.RawCatalog,gcf));
                
                uimenu(shademenu,'Label','interpolated',Futures.MenuSelectedFcn,@(~,~)shading('interp'));
                uimenu(shademenu,'Label','flat',Futures.MenuSelectedFcn,@(~,~)shading('flat'));
                
                plottype=uimenu(lookmenu,'Label','plot type');
                uimenu(plottype,'Label','Pcolor plot','Tag','plot_pcolor',...
                    Futures.MenuSelectedFcn,@(src,~)obj.plot(choice),'Checked','on');
                
                % countour-related menu items
                
                uimenu(plottype,'Label','Plot Contours','Tag','plot_contour',...
                    'Enable','off',...not fully unimplmented
                    Futures.MenuSelectedFcn,@(src,~)obj.contour(choice));
                uimenu(plottype,'Label','Plot filled Contours','Tag','plot_contourf',...
                    'Enable','off',...not fully unimplmented
                    Futures.MenuSelectedFcn,@(src,~)contourf(choice));
                uimenu(lookmenu,'Label','change contour interval',...
                    'Enable','off',...
                    Futures.MenuSelectedFcn,@(src,~)changecontours_cb(src));
                
                % display overlay menu items
                
                uimenu(lookmenu,'Label','Show grid centerpoints','Checked',char(obj.showgridcenters),...
                    Futures.MenuSelectedFcn,@obj.togglegrid_cb);
                uimenu(lookmenu,'Label',['Show ', obj.RawCatalog.Name, ' events'],...
                    Futures.MenuSelectedFcn,{@addquakes_cb,obj.RawCatalog});
                
                uimenu(lookmenu,'Separator','on',...
                    'Label','brighten',...
                    Futures.MenuSelectedFcn,@(~,~)colormap(ax,brighten(colormap,0.4)));
                uimenu(lookmenu,'Label','darken',...
                    Futures.MenuSelectedFcn,@(~,~)colormap(ax,brighten(colormap,-0.4)));
                
            end
            
            update_layermenu(obj,myname);
        end % plot function
       
    end % Public methods
    
    methods(Access=protected)
        function plot_image_for_cursor_browsing(obj, myname, mydesc, choice)
            h=obj.Grid.imagesc([],obj.Result.values.(myname), mydesc);
            h.AlphaData=zeros(size(h.AlphaData))+0.0;
            
            % add some details that can be picked up by the interactive data cursor
            h.UserData.vals= obj.Result.values;
            h.UserData.choice=choice;
            h.UserData.myname=myname;
            h.UserData.myunit=obj.Result.values.Properties.VariableUnits{choice};
            h.UserData.mydesc=obj.Result.values.Properties.VariableDescriptions{choice};
        end
        
        
        function addquakes_cb(src,~,catalog)
            qtag=findobj(gcf,'tag','quakes');
            if isempty(qtag)
                set(gca,'NextPlot','add')
                plot(catalog.Longitude, catalog.Latitude, 'o',...
                    'MarkerSize',3,...
                    'markeredgecolor',[.2 .2 .2],...
                    'tag','quakes');
                set(gca,'NextPlot','replace')
            else
                ison=qtag.Visible == "on";
                qtag.Visible=tf2onoff(~ison);
                src.Checked=tf2onoff(~ison);
                drawnow
            end
        end
        
        function update_layermenu(obj, myname)
            if isempty(findobj(gcf,'Tag','layermenu'))
                layermenu=uimenu(gcf,'Label','layer','Tag','layermenu');
                for i=1:width(obj.Result.values)
                    tmpdesc=obj.Result.values.Properties.VariableDescriptions{i};
                    tmpname=obj.Result.values.Properties.VariableNames{i};
                    uimenu(layermenu,'Label',tmpdesc,'Tag',tmpname,...
                        'Enable',tf2onoff(~all(isnan(obj.Result.values.(tmpname)))),...
                        Futures.MenuSelectedFcn,@(~,~)plot_cb(tmpname));
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
        
        function add_grid_centers(obj)
            % show grid centers, but don't make them clickable
            gph=obj.Grid.plot(gca,'ActiveOnly');
            gph.Tag='pointgrid';
            gph.PickableParts='none';
            gph.Visible=char(obj.showgridcenters);
        end
        
    end % Protected methods
end

function changecontours_cb()
    % CHANGECONTOURS_CB doesn't depend on this obj at all.
    dlgtitle='Contour interval';
    s.prompt='Enter interval';
    contr= findobj(gca,'Type','Contour');
    s.value=get(contr,'LevelList');
    if all(abs(diff(s.value)-diff(s.value(1:2))<=eps)) % eps is floating-point number spacing
        s.toChar = @(x)sprintf('%g:%g:%g',x(1),diff(x(1:2)),x(end));
    end
    s.toValue = @mystr2vec;
    answer = smart_inputdlg(dlgtitle,s);
    set(contr,'LevelList',answer.value);
    
    function x=mystr2vec(x)
        % ensures only valid characters for the upcoming eval statement
        if ~all(ismember(x,'(),:[]01234567890.- '))
            x = str2num(x); %#ok<ST2NM>
        else
            x = eval(x);
        end
    end
end