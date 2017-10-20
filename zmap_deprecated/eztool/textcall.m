function textcall(command,data)
    % This function is a callback for makemenus.
    % It should not be called from the command line
    %
    % Keith Rogers 11/30/93
    % modified R. Cobb 11/94
    global TXTCNTRL
    if(command == 9)
        if(strcmp(get(gcm2,'Checked'),'off'))
            set(gcm2,'Checked','on');
            TXTCNTRL=uicontrol('Style','Edit','Callback','textinpu');
        else
            set(gcm2,'Checked','off');
            sibs=get(gcf,'Children');
            for i=1:length(sibs)
                if strcmp(get(sibs(i),'Type'),'uicontrol')
                    if strcmp(get(sibs(i),'Style'),'edit')
                        delete(sibs(i));
                    end
                end
            end
        end
        return
    end
    if(command == 10)
        set(gco,'Rotation',90);
        return
    end
    if(command == 11)
        set(gco,'Rotation',0);
        return
    end

    if command == 12
        plotobjs=get(gca,'Children');
        for i = 1:length(plotobjs)
            if strcmp(get(plotobjs(i),'Type'),'line')
                if size(get(plotobjs(i),'Xdata'),2) == 6
                    delete(plotobjs(i));
                end
            end
        end
        return
    end
    obj = gco;
    if(command == 6)
        TextData = get(get(gcm2,'Parent'),'UserData');
        if(strcmp(get(gcm2,'Checked'),'off'))
            if(strcmp(get(TextData(2),'Checked'),'off'))
                set(gcm2,'UserData',get(gcf,'WindowButtonDownFcn'));
            end
            set(gcm2,'Checked','on');
            set(gcf,'WindowButtonDownFcn','movetext(1)');
            set(TextData(2),'Checked','off');
        else
            set(gcf,'WindowButtonDownFcn',get(gcm2,'UserData'));
            set(gcm2,'Checked','off');
        end
    elseif(command == 7)
        TextData = get(get(gcm2,'Parent'),'UserData');
        if(strcmp(get(gcm2,'Checked'),'off'))
            if(strcmp(get(TextData(1),'Checked'),'off'))
                set(TextData(1),'UserData',get(gcf,'WindowButtonDownFcn'));
            end
            set(gcm2,'Checked','on');
            set(gcf,'WindowButtonDownFcn','movetext(2)');
            set(TextData(1),'Checked','off');
        else
            set(gcf,'WindowButtonDownFcn',get(TextData(1),'UserData'));
            set(gcm2,'Checked','off');
        end

    elseif(strcmp(get(obj,'Type'),'text') & obj ~= [])
        if(command == 1)
            set(obj,'FontName',data);
        elseif(command == 2)
            set(obj,'FontAngle',data);
        elseif(command == 3)
            set(obj,'FontWeight',data);
        elseif(command == 4)
            set(obj,'FontAngle','normal','FontWeight','normal');
        elseif(command == 5)
            if(data == 0)
                set(obj,'FontSize',input('Text Size?'));
            else
                set(obj,'FontSize',data);
            end
        elseif(command == 8)
            delete(obj);
        end
    else
        disp('Text item not selected!');
    end

