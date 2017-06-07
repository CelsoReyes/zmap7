function pageset(command,subcommand,comnum)


    if(nargin<1)
        ShrinkFactor = 3.5;
        Background = 'b';
        Foreground = 'w';
        fig = gcf;
        PSFigure = figure_w_normalized_uicontrolunits('Name','Page Setup',...
            'Position',[100 40 350 400],...
            'NextPlot','Add',...
            'Color',Background);
        PaperPosition = get(fig,'PaperPosition');
        PaperSize = get(fig,'PaperSize');
        %set(gca,'Visible','Off');
        uicontrol(PSFigure,'Style','Text',...
            'BackgroundColor',Background,...
            'ForegroundColor',Foreground,...
            'String','Margins',...
            'Position',[25 380 60 20]);
        uicontrol(PSFigure,'Style','Text',...
            'BackgroundColor',Background,...
            'ForegroundColor',Foreground,...
            'String','Bottom',...
            'HorizontalAlignment','Right',...
            'Position',[5 360 60 20]);
        uicontrol(PSFigure,'Style','Edit',...
            'BackgroundColor',Background,...
            'ForegroundColor',Foreground,...
            'String',num2str(PaperPosition(2)),...
            'Position',[70 360 60 20],...
            'Tag','Bottom',...
            'Callback','pageset(''Margins'',''Bottom'')');
        uicontrol(PSFigure,'Style','Text',...
            'BackgroundColor',Background,...
            'ForegroundColor',Foreground,...
            'String','Left',...
            'HorizontalAlignment','Right',...
            'Position',[5 335 60 20]);
        uicontrol(PSFigure,'Style','Edit',...
            'BackgroundColor',Background,...
            'ForegroundColor',Foreground,...
            'String',num2str(PaperPosition(1)),...
            'Position',[70 335 60 20],...
            'Tag','Left',...
            'Callback','pageset(''Margins'',''Left'')');
        uicontrol(PSFigure,'Style','Text',...
            'BackgroundColor',Background,...
            'ForegroundColor',Foreground,...
            'String','Top',...
            'HorizontalAlignment','Right',...
            'Position',[5 310 60 20]);
        uicontrol(PSFigure,'Style','Edit',...
            'BackgroundColor',Background,...
            'ForegroundColor',Foreground,...
            'String',num2str(PaperSize(2)-PaperPosition(2)-PaperPosition(4)),...
            'Position',[70 310 60 20],...
            'Tag','Top',...
            'Callback','pageset(''Margins'',''Top'')');
        uicontrol(PSFigure,'Style','Text',...
            'BackgroundColor',Background,...
            'ForegroundColor',Foreground,...
            'String','Right',...
            'HorizontalAlignment','Right',...
            'Position',[5 285 60 20]);
        uicontrol(PSFigure,'Style','Edit',...
            'BackgroundColor',Background,...
            'ForegroundColor',Foreground,...
            'String',num2str(PaperSize(1)-PaperPosition(1)-PaperPosition(3)),...
            'Position',[70 285 60 20],...
            'Tag','Right',...
            'Callback','pageset(''Margins'',''Right'')');


        uicontrol(PSFigure,'Style','Text',...
            'BackgroundColor',Background,...
            'ForegroundColor',Foreground,...
            'String','Paper Type',...
            'HorizontalAlignment','Left',...
            'Position',[150 380 90 20]);
        PaperType = get(fig,'PaperType');
        if(strcmp(PaperType,'usletter'))
            val = 1;
        elseif(strcmp(PaperType,'uslegal'))
            val = 2;
        elseif(strcmp(PaperType,'a3'))
            val = 3;
        elseif(strcmp(PaperType,'a4letter'))
            val = 4;
        elseif(strcmp(PaperType,'a5'))
            val = 5;
        elseif(strcmp(PaperType,'b4'))
            val = 6;
        else
            val = 7;
        end
        uicontrol(PSFigure,'Style','popupmenu',...
            'BackgroundColor',Background,...
            'ForegroundColor',Foreground,...
            'String','usletter|uslegal|a3|a4letter|a5|b4|tabloid',...
            'Value',val,...
            'Tag','PaperType',...
            'Callback','pageset(''PaperType'')',...
            'Position',[150 360 90 20]);
        uicontrol(PSFigure,'Style','Text',...
            'BackgroundColor',Background,...
            'ForegroundColor',Foreground,...
            'String','Orientation',...
            'Position',[150 335 90 20]);
        Orient = get(fig,'PaperOrientation');
        if(strcmp(Orient,'portrait'))
            val = 1;
        elseif(strcmp(Orient,'landscape'))
            val = 2;
        else
            val = 3;
        end
        uicontrol(PSFigure,'Style','popupmenu',...
            'BackgroundColor',Background,...
            'ForegroundColor',Foreground,...
            'String','Portrait|Landscape|Tall',...
            'Tag','Orient',...
            'Value',val,...
            'Callback','pageset(''Orient'')',...
            'Position',[150 315 90 20]);
        uicontrol(PSFigure,'Style','checkbox',...
            'BackgroundColor',Background,...
            'ForegroundColor',Foreground,...
            'String','Invert Hardcopy',...
            'Tag','Invert',...
            'Value',strcmp(get(fig,'InvertHardCopy'),'on'),...
            'Callback','pageset(''Invert'')',...
            'Position',[150 285 100 20]);
        uicontrol(PSFigure,'Style','Text',...
            'BackgroundColor',Background,...
            'ForegroundColor',Foreground,...
            'String','PaperUnits',...
            'HorizontalAlignment','Left',...
            'Position',[250 380 90 20]);

        PaperUnits = get(fig,'PaperUnits');
        if(strcmp(PaperUnits,'inches'))
            val = 1;
        elseif(strcmp(PaperUnits,'centimeters'))
            val = 2;
        elseif(strcmp(PaperUnits,'normalized'))
            val = 3;
        else
            val = 4;
        end

        uicontrol(PSFigure,'Style','popupmenu',...
            'BackgroundColor',Background,...
            'ForegroundColor',Foreground,...
            'String','inches|centimeters|normalized|points',...
            'Tag','PaperUnits',...
            'Value',val,...
            'Callback','pageset(''PaperUnits'')',...
            'Position',[250 360 90 20]);
        uicontrol(PSFigure,'Style','pushbutton',...
            'BackgroundColor',Background,...
            'ForegroundColor',Foreground,...
            'String','OK',...
            'Tag','OK',...
            'Callback','pageset(''OK'')',...
            'Position',[260 320 80 25]);
        uicontrol(PSFigure,'Style','pushbutton',...
            'BackgroundColor',Background,...
            'ForegroundColor',Foreground,...
            'String','Cancel',...
            'Tag','Cancel',...
            'Callback','pageset(''Cancel'')',...
            'Position',[260 285 80 25]);

        axes('Units',PaperUnits,...
            'Position',[.7 .25 PaperSize(1)/ShrinkFactor PaperSize(2)/ShrinkFactor],...
            'box','on')
        axis('equal');
        axis([0 PaperSize(1) 0 PaperSize(2)]);
        PlotRect = [PaperPosition(1) PaperPosition(2);
            PaperPosition(1)+PaperPosition(3) PaperPosition(2);
            PaperPosition(1)+PaperPosition(3) PaperPosition(2)+PaperPosition(4);
            PaperPosition(1) PaperPosition(2)+PaperPosition(4)];
        PatchObj = patch('XData',PlotRect(:,1),...
            'YData',PlotRect(:,2),...
            'EdgeColor','w',...
            'FaceColor',Background);
        set(PatchObj,'ButtonDownFcn','pageset(''Resize'')');
        UserData = [fig;PatchObj;ShrinkFactor];
        set(gcf,'UserData',UserData);
        set(gcf,'PaperPosition',PaperPosition,...
            'PaperType',PaperType,...
            'PaperOrientation',Orient,...
            'PaperUnits',PaperUnits);
        axis(axis);
        hold on;

    elseif(strcmp(command,'DrawPage'))

        UserData = get(gcf,'UserData');
        PatchObj = UserData(2);
        ShrinkFactor = UserData(3);

        PaperPosition = get(gcf,'PaperPosition');
        PaperUnits = get(gcf,'PaperUnits');
        if(strcmp(get(gca,'Units'),'normalized'))
            set(gca,'units',PaperUnits);
        else
            set(gcf,'PaperUnits',get(gca,'Units'));
        end
        PaperSize = get(gcf,'PaperSize');
        set(gcf,'PaperUnits',PaperUnits);
        AxPos = get(gca,'Position');
        set(gca,'Position',[AxPos(1) AxPos(2) PaperSize(1)/ShrinkFactor PaperSize(2)/ShrinkFactor]);
        set(gca,'Units',PaperUnits);
        if(strcmp(PaperUnits,'normalized'))
            axis('normal');
            axis([0 1 0 1]);
        else
            axis('equal');
            PaperSize = get(gcf,'PaperSize');
            axis([0 PaperSize(1) 0 PaperSize(2)]);
        end
        PlotRect = [PaperPosition(1) PaperPosition(2);
            PaperPosition(1)+PaperPosition(3) PaperPosition(2);
            PaperPosition(1)+PaperPosition(3) PaperPosition(2)+PaperPosition(4);
            PaperPosition(1) PaperPosition(2)+PaperPosition(4)];

        set(PatchObj,'EraseMode','Xor',...
            'XData',PlotRect(:,1),...
            'YData',PlotRect(:,2));
        set(PatchObj,'EraseMode','Normal');
        axis(axis);
        hold on;
    elseif(strcmp(command,'Resize'))
        UserData = get(gcf,'UserData');
        PatchObj = UserData(2);
        if(nargin<2)
            cp = get(gca,'CurrentPoint');
            XData = get(PatchObj,'XData');
            YData = get(PatchObj,'YData');
            minx = min(XData);
            miny = min(YData);
            ext = [minx miny max(XData)-minx max(YData)-miny];
            set(PatchObj,'UserData',ext);
            if(cp(1,1)<ext(1)+.2*ext(3))
                if(cp(1,2)<ext(2)+.2*ext(4)) 		% Lower Left Corner
                    set(gcf,'WindowButtonMotionFcn','pageset(''Resize'',''Corner'',1)');
                elseif(cp(1,2)>ext(2)+.8*ext(4)) 	% Upper Left Corner
                    set(gcf,'WindowButtonMotionFcn','pageset(''Resize'',''Corner'',2)');
                else								% Left Side
                    set(gcf,'WindowButtonMotionFcn','pageset(''Resize'',''Side'',1)');
                end
            elseif(cp(1,1)>ext(1)+.8*ext(3))
                if(cp(1,2)<ext(2)+.2*ext(4)) 		% Lower Right Corner
                    set(gcf,'WindowButtonMotionFcn','pageset(''Resize'',''Corner'',4)');
                elseif(cp(1,2)>ext(2)+.8*ext(4)) 	% Upper Right Corner
                    set(gcf,'WindowButtonMotionFcn','pageset(''Resize'',''Corner'',3)');
                else								% Right Side
                    set(gcf,'WindowButtonMotionFcn','pageset(''Resize'',''Side'',3)');
                end
            elseif(cp(1,2)>ext(2)+.8*ext(4))		% Top Side
                set(gcf,'WindowButtonMotionFcn','pageset(''Resize'',''Side'',2)')
            elseif(cp(1,2)<ext(2)+.2*ext(4))		% Bottom Side
                set(gcf,'WindowButtonMotionFcn','pageset(''Resize'',''Side'',4)')
            else									% Center
                set(gca,'UserData',cp);
                set(gcf,'WindowButtonMotionFcn','pageset(''Resize'',''Move'')');
            end
            set(PatchObj,'erasemode','xor');
            set(gcf,'WindowButtonUpFcn','pageset(''Resize'',''Up'')');
        elseif(strcmp(subcommand,'Corner'))
            cp = get(gca,'CurrentPoint');
            ext = get(PatchObj,'UserData');
            if(comnum == 1)
                ext = [cp(1,1:2) ext(1:2)+ext(3:4)-cp(1,1:2)];
            elseif(comnum == 2)
                ext = [cp(1,1) ext(2) ext(1)+ext(3)-cp(1,1) cp(1,2)-ext(2)];
            elseif(comnum == 3)
                ext(3:4) = cp(1,1:2)-ext(1:2);
            else
                ext(2:4) = [cp(1,2) cp(1,1)-ext(1) ext(2)+ext(4)-cp(1,2)];
            end
            XData = ext(1)+[0 ext(3) ext(3) 0];
            YData = ext(2)+[0 0 ext(4) ext(4)];
            set(PatchObj,'XData',XData,'YData',YData);
        elseif(strcmp(subcommand,'Side'))
            cp = get(gca,'CurrentPoint');
            ext = get(PatchObj,'UserData');
            if(comnum == 1)
                ext = [cp(1,1) ext(2) ext(1)+ext(3)-cp(1,1) ext(4)];
            elseif(comnum == 2)
                ext = [ext(1) ext(2) ext(3) cp(1,2)-ext(2)];
            elseif(comnum == 3)
                ext = [ext(1) ext(2) cp(1,1)-ext(1) ext(4)];
            else
                ext = [ext(1) cp(1,2) ext(3) ext(2)+ext(4)-cp(1,2)];
            end
            XData = ext(1)+[0 ext(3) ext(3) 0];
            YData = ext(2)+[0 0 ext(4) ext(4)];
            set(PatchObj,'XData',XData,'YData',YData);
        elseif(strcmp(subcommand,'Move'))
            startpoint = get(gca,'UserData');
            cp = get(gca,'CurrentPoint');
            XData = get(PatchObj,'XData');
            YData = get(PatchObj,'YData');
            XData = XData+cp(1,1)-startpoint(1,1);
            YData = YData+cp(1,2)-startpoint(1,2);
            set(PatchObj,'XData',XData,'YData',YData);
            set(gca,'UserData',cp);
        else
            PaperSize = get(gcf,'PaperSize');
            set(PatchObj,'EraseMode','normal');
            set(gcf,'WindowButtonMotionFcn','',...
                'WindowButtonUpFcn','');
            XData = get(PatchObj,'XData');
            YData = get(PatchObj,'YData');
            ext = [XData(1) YData(1) XData(2)-XData(1) YData(3)-YData(2)];
            set(gcf,'PaperPosition',ext);
            set(findobj(gcf,'Tag','Bottom'),'String',num2str(ext(1)));
            set(findobj(gcf,'Tag','Left'),'String',num2str(ext(2)));
            set(findobj(gcf,'Tag','Top'),'String',num2str(PaperSize(2)-ext(2)-ext(4)));
            set(findobj(gcf,'Tag','Right'),'String',num2str(PaperSize(1)-ext(1)-ext(3)));
            set(PatchObj,'UserData',ext);
        end
    elseif(strcmp(command,'Margins'))
        PaperPosition = get(gcf,'PaperPosition');
        PaperSize = get(gcf,'PaperSize');
        Bottom = str2double(get(findobj(gcf,'Tag','Bottom'),'String'));
        Left = str2double(get(findobj(gcf,'Tag','Left'),'String'));
        Top = str2double(get(findobj(gcf,'Tag','Top'),'String'));
        Right = str2double(get(findobj(gcf,'Tag','Right'),'String'));
        set(gcf,'PaperPosition',[Left ...
            Bottom ...
            PaperSize(1)-Left-Right ...
            PaperSize(2)-Bottom-Top]);
        pageset('DrawPage');
    elseif(strcmp(command,'Invert'))
        if(get(findobj(gcf,'Tag','Invert'),'Value'))
            set(gcf,'InvertHardCopy','on');
        else
            set(gcf,'InvertHardCopy','off');
        end
    elseif(strcmp(command,'PaperUnits'))
        units = get(findobj(gcf,'Tag','PaperUnits'),'Value');
        if(units == 1)
            set(gcf,'PaperUnits','Inches');
        elseif(units == 2)
            set(gcf,'PaperUnits','Centimeters');
        elseif(units == 3)
            set(gcf,'PaperUnits','Normalized');
        elseif(units == 4)
            set(gcf,'PaperUnits','Points');
        end
        PaperSize = get(gcf,'PaperSize');
        PaperPosition = get(gcf,'PaperPosition');
        set(findobj(gcf,'Tag','Left'),'String',...
            num2str(PaperPosition(1)));
        set(findobj(gcf,'Tag','Right'),'String',...
            num2str(PaperSize(1)-PaperPosition(1)-PaperPosition(3)));
        set(findobj(gcf,'Tag','Top'),'String',...
            num2str(PaperSize(2)-PaperPosition(2)-PaperPosition(4)));
        set(findobj(gcf,'Tag','Bottom'),'String',...
            num2str(PaperPosition(2)));
        pageset('DrawPage');
    elseif(strcmp(command,'PaperType'))
        UserData = get(gcf,'UserData');
        val = get(findobj(gcf,'Tag','PaperType'),'Value');
        if(val == 1)
            set(gcf,'PaperType','usletter');
            UserData(3) = 3.5;
            set(gcf,'UserData',UserData);
        elseif(val == 2)
            set(gcf,'PaperType','uslegal');
            UserData(3) = 4;
            set(gcf,'UserData',UserData);
        elseif(val == 3)
            set(gcf,'PaperType','a3');
            UserData(3) = 5;
            set(gcf,'UserData',UserData);
        elseif(val == 4)
            set(gcf,'PaperType','a4letter');
            UserData(3) = 3.5;
            set(gcf,'UserData',UserData);
        elseif(val == 5)
            set(gcf,'PaperType','a5');
            UserData(3) = 2.5;
            set(gcf,'UserData',UserData);
        elseif(val == 6)
            set(gcf,'PaperType','b4');
            UserData(3) = 4;
            set(gcf,'UserData',UserData);
        else
            set(gcf,'PaperType','tabloid');
            UserData(3) = 5;
            set(gcf,'UserData',UserData);
        end
        pageset('Margins');
    elseif(strcmp(command,'Orient'))
        val = get(findobj(gcf,'Tag','Orient'),'Value');
        if(val == 1)
            orient portrait;
        elseif(val == 2)
            orient landscape;
        else
            orient tall;
        end
        ext = get(gcf,'PaperPosition');
        PaperSize = get(gcf,'PaperSize');
        set(findobj(gcf,'Tag','Bottom'),'String',num2str(ext(1)));
        set(findobj(gcf,'Tag','Left'),'String',num2str(ext(2)));
        set(findobj(gcf,'Tag','Top'),'String',num2str(PaperSize(2)-ext(2)-ext(4)));
        set(findobj(gcf,'Tag','Right'),'String',num2str(PaperSize(1)-ext(1)-ext(3)));
        pageset('DrawPage');
    elseif(strcmp(command,'OK'))
        UserData = get(gcf,'UserData');
        fig = UserData(1);
        set(fig,'PaperUnits',get(gcf,'PaperUnits'));
        set(fig,'PaperType',get(gcf,'PaperType'));
        set(fig,'PaperOrientation',get(gcf,'PaperOrientation'));
        set(fig,'PaperPosition',get(gcf,'PaperPosition'));
        set(fig,'InvertHardCopy',get(gcf,'InvertHardCopy'));
        delete(gcf);
    elseif(strcmp(command,'Cancel'))
        delete(gcf);
    end
