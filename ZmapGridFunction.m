classdef ZmapGridFunction < ZmapFunction
    % ZMAPGRIDFUNCTION is a ZmapFunction that produces a grid of 1 or more results as output
    properties
        plotfeatures='borders';
        plotcolumn %
        showgridcenters=true
    end
    
    methods
        
        function plot(obj,choice, varargin)
            % plots the results on the provided axes.
            if ~exist('choice','var')
                choice=obj.plotcolumn;
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
            obj.Grid.pcolor([],obj.Result.values.(myname), mydesc);hold on;
            
            % the imagesc exists is to enable data cursor browsing.
            h=obj.Grid.imagesc([],obj.Result.values.(myname), mydesc);
            h.AlphaData=zeros(size(h.AlphaData))+0.0;
            
            % add some details that can be picked up by the interactive data cursor
            h.UserData.vals= obj.Result.values;
            h.UserData.choice=choice;
            h.UserData.myname=myname;
            h.UserData.myunit=obj.Result.values.Properties.VariableUnits{choice};
            h.UserData.mydesc=obj.Result.values.Properties.VariableDescriptions{choice};
            
            shading(obj.ZG.shading_style);
            hold on
            
            % show grid centers, but don't make them clickable
            gph=obj.Grid.plot();
            gph.PickableParts='none';
            gph.Visible=logical2onoff(obj.showgridcenters);
            
            ft=obj.ZG.features(obj.plotfeatures);
            copyobj(ft,gca);
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
                uimenu(shademenu,'Label','interpolated','Callback',@(~,~)shading('interp'));
                uimenu(shademenu,'Label','flat','Callback',@(~,~)shading('flat'));
                plottype=uimenu(lookmenu,'Label','plot type');
                uimenu(plottype,'Label','Pcolor plot','Tag','plot_pcolor',...
                    'Callback',@(src,~)obj.plot(choice),'Checked','on');
                uimenu(plottype,'Label','Plot Contours','Tag','plot_contour',...
                    'enable','off',...not fully unimplmented
                    'Callback',@(src,~)obj.contour_cb(choice));
                uimenu(plottype,'Label','Plot filled Contours','Tag','plot_contourf',...
                    'enable','off',...not fully unimplmented
                    'Callback',@(src,~)contourf_cb(choice));
                uimenu(lookmenu,'Label','change contour interval','Enable','off',...
                    'callback',@(src,~)changecontours_cb(src));
                uimenu(lookmenu,'Label','Show grid centerpoints','Checked',logical2onoff(obj.showgridcenters),...
                    'callback',@togglegrid_cb);
            end
            if isempty(findobj(gcf,'Tag','layermenu'))
                layermenu=uimenu(gcf,'Label','layer','Tag','layermenu');
                for i=1:width(obj.Result.values)
                    tmpdesc=obj.Result.values.Properties.VariableDescriptions{i};
                    tmpname=obj.Result.values.Properties.VariableNames{i};
                    uimenu(layermenu,'Label',tmpdesc,'Tag',tmpname,...
                        'Enable',logical2onoff(~all(isnan(obj.Result.values.(tmpname)))),...
                        'callback',@(~,~)plot_cb(tmpname));
                end
            end
            % make sure the correct option is checked
            layermenu=findobj(gcf,'Tag','layermenu');
            set(findobj(layermenu,'Tag',myname),'checked','on');
            
            % plot here
            function plot_cb(name)
                set(findobj(layermenu,'type','uimenu'),'Checked','off');
                obj.plot(name);
            end
            
            function contour_cb(obj,name)
                % like plot, except with contours!
                [C,h]=contour(unique(xx),unique(yy),reshaper(zz),'LevelList',[floor(min(zz)):.1:ceil(max(zz))]);
                clabel(C,h)
            end
            function contourf_cb(obj,name)
                % like plot, except with contours!
                [C,h]=contourf(unique(xx),unique(yy),reshaper(zz),'LevelList',[floor(min(zz)):.1:ceil(max(zz))]);
                clabel(C,h)
            end
            
            function togglegrid_cb(src,~)
                switch src.Checked
                    case 'on'
                        src.Checked='off';
                        gph.Visible='off';
                        obj.showgridcenters=false;
                    case 'off'
                        src.Checked='on';
                        gph.Visible='on';
                        obj.showgridcenters=true;
                end
            end
            function changecontours_cb()
                dlgtitle='Contour interval';
                s.prompt='Enter interval';
                contr= findobj(gca,'Type','Contour');
                s.value=get(contr,'LevelList');
                if all(abs(diff(s.value)-diff(s.value(1:2))<=eps))
                    s.toChar = @(x)[num2str(x(1)),':',num2str(diff(x(1:2))),':',num2str(x(end))];
                end
                s.toValue = @mystr2vec;
                answer = smart_inputdlg(dlgtitle,s);
                set(contr,'LevelList',answer.value);
                
                function x=mystr2vec(x)
                    % ensures only valid charaters for the upcoming eval statement
                    if ~all(ismember(x,'(),:[]01234567890.- '))
                        x = str2num(x); %#ok<ST2NM>
                    else
                        x = eval(x);
                    end
                end
            end
            
            
        end
        function contour(obj,choice,intervals)
            % like plot, except with contours!
            if ~exist('intervals','var')
                intervals=[floor(min(zz)):.1:ceil(max(zz))];
            end
            [C,h]=contour(unique(xx),unique(yy),reshaper(zz),'LevelList',[floor(min(zz)):.1:ceil(max(zz))]);
            clabel(C,h)
        end
        function contourf(obj,choice,intervals)
            % like plot, except with contours!
            if ~exist('intervals','var')
                intervals=[floor(min(zz)):.1:ceil(max(zz))];
            end
            [C,h]=contourf(unique(xx),unique(yy),reshaper(zz),'LevelList',[floor(min(zz)):.1:ceil(max(zz))]);
            clabel(C,h)
        end
        
        
    end
    methods(Access=protected, Static)
        function txt = mydatacursor(~,event_obj)
            try
                % wrapped in Try-Catch because the datacursor routines fail relatively quietly on
                % errors. They simply mention that they couldn't update the datatip.
                
                pos=get(event_obj,'Position');
                
                im=event_obj.Target;
                details=im.UserData.vals(abs(im.UserData.vals.x - pos(1))<=.0001 & abs(im.UserData.vals.y-pos(2))<=.0001,:)
            catch ME
                
                disp(ME.message)
                ME
            end
            try
                mymapval=details.(im.UserData.myname);
                if isnumeric(mymapval)
                    trans=@(x)num2str(mymapval);
                elseif isa('datetime','val') || isa('duration','val')
                    trans=@(x)char(mymapval);
                else
                    trans=@(x)x;
                end
                txt={sprintf('Map Value [%s] : %s %s\n%s\n-------------',...
                    im.UserData.myname, trans(mymapval), im.UserData.myunit, im.UserData.mydesc)};
                for n=1:width(details)
                    fld=details.Properties.VariableNames{n};
                    val=details.(fld);
                    units=details.Properties.VariableUnits{n};
                    if isnumeric(val)
                        trans=@(x)num2str(val);
                    elseif isa('datetime','val') || isa('duration','val')
                        trans=@(x)char(val);
                    else
                        trans=@(x)x;
                    end
                    txt=[txt,{sprintf('%-10s : %s %s',fld, trans(val), units)}];
                end
                
            catch ME
                ME
                disp(ME.message)
            end
        end
        
    end
end