classdef ZmapHGridFunction < ZmapGridFunction
    % ZMAPHGRIDFUNCTION is a ZmapFunction that produces a grid of results plottable on map (horiz slice)
    %
    % see also ZMAPGRIDFUNCTION
    
    properties
        features cell ={'borders'}; % features to show on the map, such as 'borders','lakes','coast',etc.
    end
    
    methods
        
        function obj=ZmapHGridFunction(varargin)
            obj@ZmapGridFunction(varargin{:});
        end
        
        function showInTab(obj, ax, choice)
            % plots the results on the provided axes.
            
            if exist('choice','var')
                [choice, myname, mydesc, myunits] = obj.ActiveDataColumnDetails(choice);
            else
                [choice, myname, mydesc, myunits] = obj.ActiveDataColumnDetails();
            end
            
            ax.NextPlot='add';
            delete(findobj(ax,'Tag','result overlay'));
            
            % this is to show the data
            if islogical(obj.Result.values.(myname)(1))
                p=double(obj.Result.values.(myname));
                p(p==0)=nan;
                h=obj.Grid.pcolor(ax,p, mydesc);
            else
                h=obj.Grid.pcolor(ax,obj.Result.values.(myname), mydesc);
            end
            h.Tag = 'result overlay';
            shading(obj.ZG.shading_style);
            
            if isempty(findobj(gcf,'Tag','lookmenu'))
                add_menus(obj,choice);
            end
            
            update_layermenu(obj,myname, ax);
            
            mapdata_viewer(obj,obj.RawCatalog,findobj(gcf,'Tag','mainmap_ax'));
            ax.Title.String=sprintf('%s : [ %s ]',obj.RawCatalog.Name, mydesc);
            ax.Title.Interpreter='none';
        end

        function overlay(obj, resTab, choice)
            % plots the results in the provided Tab.
            % expects that tab is empty
            
            report_this_filefun();
            
            [choice, myname, mydesc, myunits] = obj.ActiveDataColumnDetails(choice);
            
            tabGroup = resTab.Parent;
            
            ax=findobj(resTab,'Type','axes','-and','Tag','result_map');
            
            if isempty(ax)
                copyobj(findobj(tabGroup,'Tag','mainmap_ax'),resTab);
                ax=findobj(resTab,'Tag','mainmap_ax');
                ax.Tag='result_map';
                ax.Units='normalized';
                ax.Position=[0.025 0.05 .95 .90];
                set(findobj(ax,'Type','scatter'),'MarkerEdgeAlpha',0.4);
                lineobjs=findobj(ax,'Type','Line');
                for n=1:numel(lineobjs)
                    set(lineobjs(n),'Color', (lineobjs(n).Color + [3 3 3]) ./ 4);
                end
            else
                ax=findobj(resTab,'Tag','result_map');
            end
                
            ax.NextPlot='add';
            delete(findobj(ax,'Tag','result overlay'));
            
            % delete existing grid points
            delete(findobj(ax,'-regexp','Tag','grid_\w.*'));
            
            % this is to show the data
            if islogical(obj.Result.values.(myname)(1))
                p=double(obj.Result.values.(myname));
                p(p==0)=nan;
                h=obj.Grid.pcolor(ax,p, mydesc);
            else
                [~,h]=obj.Grid.contourf(ax,obj.Result.values.(myname),mydesc, ZmapGlobal.Data.ResultOptions.ContourCount);
                
                %[~,h]=contourf(ax,obj.Grid.X, obj.Grid.Y, ...
                 %   reshape(obj.Result.values.(myname),...
                 %   size(obj.Grid.X)));
                % set the title
                %h.LineStyle='none';
                %h.LevelList=linspace(floor(min(h.ZData(:))),ceil(max(h.ZData(:))),100);
                
                %h=obj.Grid.pcolor(ax,obj.Result.values.(myname), mydesc);
            end
            ax.Children=circshift(ax.Children,-1); % move the contour to the bottom layer
            %gx = obj.Grid.X;
            %gy = obj.Grid.Y;
            val = obj.Result.values.(myname);
            s=scatter(ax,obj.Result.values.x,obj.Result.values.y,10,val,'+','Tag',obj.Grid.Name);
            %s.MarkerEdgeColor=[0.1 0.1 0.1];
            %s.MarkerEdgeAlpha=[0.3];
            s.MarkerFaceAlpha=[0.5];
            
            h.Tag = 'result overlay';
            %shading(ax,obj.ZG.shading_style);
            
            if isempty(findobj(gcf,'Tag','lookmenu'))
                add_menus(obj,choice);
            end
            
            % add a menu to choose which layer / variable to examine
            c=findobj(gcf,'Type','uicontextmenu','-and','Tag',obj.PlotTag);
            delete(c); % avoid replotting old data.
            
            c=uicontextmenu('Tag',obj.PlotTag);
            resTab.UIContextMenu=c;
            
            update_layermenu(obj,myname, c);
            
            uimenu(c,'Separator','on','Label','Close tab',...
                Futures.MenuSelectedFcn,@(~,~)delete(resTab));
            % mapdata_viewer(obj,obj.RawCatalog,ax);
            title(ax,sprintf('%s : [ %s ]',obj.RawCatalog.Name, mydesc),'Interpreter','None');
            % shading(ax,obj.ZG.shading_style);
            
            tabGroup.SelectedTab = resTab;
            pretty_colorbar(ax,mydesc,myunits);
            obj.interact(ax, myname)
        end
        
        function plot(obj, choice)
            % plots the results
            % obj.PLOT( choice, ...) where choice is the name or number of the table column to plot.
            % if not provided, it will default to OBJ.active_col
            %
            % called by the ZmapGridFunction's doit() method
            
            report_this_filefun();
            if ~exist('choice','var')
                choice = obj.active_col;
            end
            
            if get(gcf,'Tag') == "Zmap Main Window"
                theTab=obj.recreateExistingResultsTab(gcf);
                obj.overlay(theTab, choice)
                return
            end
            
            %% plotting into some window other than the Main ZMAP window
            
            [choice, myname, mydesc, myunits] = obj.ActiveDataColumnDetails(choice);
                
            f=findobj(groot,'Tag',obj.PlotTag,'-and','Type','figure');
            if isempty(f)
                f=figure('Tag',obj.PlotTag);
            end
            figure(f);
            set(f,'name',['results : ', myname])
            delete(findobj(f,'Type','axes'));
            
            % this is to show the data
            if islogical(obj.Result.values.(myname)(1))
                p=double(obj.Result.values.(myname));
                p(p==0)=nan;
                obj.Grid.pcolor([],p, mydesc);
            else
                obj.Grid.pcolor([],obj.Result.values.(myname), mydesc);
            end
            set(gca,'NextPlot','add');
            
            % the imagesc exists is to enable data cursor browsing.
            % obj.plot_image_for_cursor_browsing(myname, mydesc, choice);
            
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
            
            %dcm_obj=datacursormode(gcf);
            %dcm_obj.UpdateFcn=@ZmapGridFunction.mydatacursor;
            %dcm_obj.SnapToDataVertex='on';
            
            if isempty(findobj(gcf,'Tag','lookmenu'))
                obj.add_menus(choice);
            end
            
            obj.update_layermenu(myname,gcf);
            
            mapdata_viewer(obj,obj.RawCatalog,f);
            

            
        end % plot function
        
        function add_menus(obj,choice)
            
            add_menu_divider();
            lookmenu=uimenu(gcf,'label','graphics','Tag','lookmenu');
            shademenu=uimenu(lookmenu,'Label','shading','Tag','shading');
            activeTab=get(findobj(gcf,'Tag','main plots'),'SelectedTab');
            activeax=findobj(activeTab.Children,'Type','axes');
            
            uimenu(shademenu,'Label','interpolated',Futures.MenuSelectedFcn,@(~,~)cb_shading('interp'));
            uimenu(shademenu,'Label','flat',Futures.MenuSelectedFcn,@(~,~)cb_shading('flat'));
            
            plottype=uimenu(lookmenu,'Label','plot type');
            %uimenu(plottype,'Label','Pcolor plot','Tag','plot_pcolor',...
            %    Futures.MenuSelectedFcn,@(src,~)obj.plot(choice),'Checked','on');
            
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
            %{
            uimenu(lookmenu,'Label','Show grid centerpoints','Checked',char(obj.showgridcenters),...
                Futures.MenuSelectedFcn,@obj.togglegrid_cb);
            uimenu(lookmenu,'Label',['Show ', obj.RawCatalog.Name, ' events'],...
                Futures.MenuSelectedFcn,{@obj.addquakes_cb, obj.RawCatalog});
            %}
            uimenu(lookmenu,'Separator','on',...
                'Label','brighten active map',...
                Futures.MenuSelectedFcn,@(~,~)cb_brighten(0.4));
            uimenu(lookmenu,'Label','darken active map',...
                Futures.MenuSelectedFcn,@(~,~)cb_brighten(-0.4));
            
            uimenu(lookmenu,'Separator','on',...
                'Label','increase alpha ( +0.2 )',...
                Futures.MenuSelectedFcn, @(~,~)cb_alpha( 0.2));
            uimenu(lookmenu,'Label','decrease alpha ( -0.2 )',...
                Futures.MenuSelectedFcn, @(~,~)cb_alpha( - 0.2));
            function cb_shading(val)
                % must be in function because ax must be evaluated in real-time
                activeTab=get(findobj(gcf,'Tag','main plots'),'SelectedTab');
                ax=findobj(activeTab.Children,'Type','axes');
                shading(ax,val)
            end
            function cb_brighten(val)
                activeTab=get(findobj(gcf,'Tag','main plots'),'SelectedTab');
                ax=findobj(activeTab.Children,'Type','axes');
                cm=colormap(ax);
                colormap(ax,brighten(cm,val));
            end
            function cb_alpha(val)
                activeTab=get(findobj(gcf,'Tag','main plots'),'SelectedTab');
                ax=findobj(activeTab.Children,'Type','axes');
                ss = findobj(ax.Children,'Tag','result overlay');
                newAlpha = ss.FaceAlpha + val;
                if newAlpha < 0; newAlpha = 0; end
                if newAlpha > 1; newAlpha = 1; end
                alpha(ss,newAlpha);
            end
                
        end
    end % Public methods
    
    methods(Access=protected)
        function plot_image_for_cursor_browsing(obj, myname, mydesc, choice)
            report_this_filefun();
            
            h=obj.Grid.imagesc([],obj.Result.values.(myname), mydesc);
            h.AlphaData=zeros(size(h.AlphaData))+0.0;
            
            % add some details that can be picked up by the interactive data cursor
            h.UserData.vals= obj.Result.values;
            h.UserData.choice=choice;
            h.UserData.myname=myname;
            h.UserData.myunit=obj.Result.values.Properties.VariableUnits{choice};
            h.UserData.mydesc=obj.Result.values.Properties.VariableDescriptions{choice};
        end
        
        
        function addquakes_cb(obj,src,~,catalog)
            report_this_filefun();
            
            qtag=findobj(gcf,'tag','quakes');
            if isempty(qtag)
                set(gca,'NextPlot','add')
                line(catalog.Longitude, catalog.Latitude, 'Marker','o',...
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
        
        function update_layermenu(obj, myname, container)
            % updates the layers associated with some container. usually the context menu for a tab.
            report_this_filefun();
            if ~exist('container','var')
                container=uimenu(gcf,'Label','layer');
            end
            
            
            % UPDATE_LAYERMENU
            if isempty(container.Children)  % TODO: change to plotTag_layermeu
                %layermenu=uimenu(gcf,'Label','layer','Tag','layermenu');
                import callbacks.copytab
                uimenu(container,'Label','Copy Contents to new figure (static)','Callback',@copytab);
                for i=1:width(obj.Result.values)
                    tmpdesc=obj.Result.values.Properties.VariableDescriptions{i};
                    tmpname=obj.Result.values.Properties.VariableNames{i};
                    uimenu(container,'Label',tmpdesc,'Tag',tmpname,...
                        'Enable',tf2onoff(~all(isnan(obj.Result.values.(tmpname)))),...
                        Futures.MenuSelectedFcn,@(~,~)overlay_cb(tmpname));
                        %Futures.MenuSelectedFcn,@(~,~)plot_cb(tmpname)); %TOFIX just replot the layer
                end
                container.Children(end-1).Separator='on';
            end
            
            % make sure the correct option is checked
            %layermenu=findobj(container,'Tag','layermenu');
            set(findobj(container,'Tag',myname),'Checked','on');
            
            % plot here
            function plot_cb(name)
                report_this_filefun();
                set(findobj(container,'type','uimenu'),'Checked','off');
                obj.plot(name);
            end
            
            function overlay_cb(name)
                report_this_filefun();
                set(findobj(container,'type','uimenu'),'Checked','off');
                theTabHolder = findobj(gcf,'Tag','main plots','-and','Type','uitabgroup');
                theTab=findobj(theTabHolder,'Tag', obj.PlotTag);
                obj.overlay(theTab,name);
            end
        end
        
        function add_grid_centers(obj)
            % show grid centers, but don't make them clickable
            report_this_filefun();
            dbk=dbstack(1);disp(dbk(1).name);
            
            gph=obj.Grid.plot(gca,'ActiveOnly');
            gph.Tag='pointgrid';
            gph.PickableParts='none';
            gph.Visible=char(obj.showgridcenters);
        end
        
        function theTab = recreateExistingResultsTab(obj, f)
            % delete existing tab from main window
            theTabHolder = findobj(f, 'Tag','main plots','-and','Type','uitabgroup');
            theTab=findobj(theTabHolder,'Tag',obj.PlotTag);
            if ~isempty(theTab)
                delete(theTab)
            end
            
            theTab=uitab(theTabHolder,'Title',[obj.PlotTag ' Results'],'Tag',obj.PlotTag);
        end
        
        function interact(obj,ax, myname)
            f=ancestor(ax,'figure');
            mytab=ax.Parent;
            mytabholder=mytab.Parent;
            ax.NextPlot='add';
            delete(findobj(ax,'Tag','thisresulttext'));
            delete(findobj(ax,'Tag','thisresulthilight'));
            delete(findobj(ax,'Tag','thisradius'));
            TX = text(ax,nan,nan,'','FontWeight','bold','BackgroundColor','w','Interpreter','none','Tag','thisresulttext');
            HL = scatter(ax,nan,nan,'+','CData',[0 0 0],'Tag','thisresulthilight');
            CR = line(ax,nan,nan,'LineStyle',':','Color','k','Tag','thisradius','LineWidth',2);
            f.WindowButtonMotionFcn=@update;
            lastNearest=0;
            
            function update(src,ev)
                if mytabholder.SelectedTab~=mytab
                    return
                end
                axX=ax.XLim;
                axY=ax.YLim;
                pt=ax.CurrentPoint(1,1:2);
                if pt(1)<=axX(2) && pt(1)>=axX(1) && pt(2)<=axY(2) && pt(2) >=axY(1)
                    mx=pt(1); my=pt(2);
                    [~,nearest]=min((mx-obj.Result.values.x).^2 + (my-obj.Result.values.y).^2);
                    if nearest ~= lastNearest
                        lastNearest=nearest;
                        x=obj.Result.values.x(nearest);
                        y=obj.Result.values.y(nearest);
                        % update hilight
                        HL.XData=x;
                        HL.YData=y;
                        
                        % update text
                        TX.Position=[x, y,0];
                        valstr=string(obj.Result.values.(myname)(nearest));
                        if ismissing(valstr)
                            TX.String="  "+myname + " : <missing>";
                        else
                            TX.String="  "+myname + " : "+ valstr;
                        end
                        
                        % update samplecircle
                        [La,Lo]=reckon(y, x, km2deg(obj.Result.values.Radius_km(nearest)), 0:2:360);
                        set(CR,'XData',Lo,'YData',La,'LineStyle','--');
                        
                        
                    end
                end
            end
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

function pretty_colorbar(ax, cb_title, cb_units)
    h=colorbar('peer',ax, 'location','EastOutside');
    if isempty(cb_units)
    h.Label.String = cb_title;
    else
        h.Label.String =  sprintf('%s [%s]',cb_title,cb_units);
    end
    
end