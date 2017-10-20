function axiscall(command,ax)
    % This function is a callback for makemenus.
    % it should not be called from the command line.
    %
    % Keith Rogers 11/30/93
    % modified by R. Cobb 11/94
    global YControl
    if (command == 1)
        if (ax == 'X')
            if(strcmp(get(gcm2,'Label'),'Log'))
                set(gca,'Xscale','log');
                set(gcm2,'Label','Linear');
            else
                set(gca,'Xscale','linear');
                set(gcm2,'Label','Log');
            end
        elseif (ax == 'Y')
            if(strcmp(get(gcm2,'Label'),'Log'))
                set(gca,'Yscale','log');
                set(gcm2,'Label','Linear');
            else
                set(gca,'Yscale','linear');
                set(gcm2,'Label','Log');
            end
        elseif (ax == 'Z')
            if(strcmp(get(gcm2,'Label'),'Log'))
                set(gca,'Zscale','log');
                set(gcm2,'Label','Linear');
            else
                set(gca,'Zscale','linear');
                set(gcm2,'Label','Log');
            end
        end
    elseif (command == 2)
        if (ax == 'X')
            minmax = get(gca,'XLim');
            set(gca,'XLim',[-inf minmax(2)]);
        elseif (ax == 'Y')
            minmax = get(gca,'YLim');
            set(gca,'YLim',[-inf minmax(2)]);
        elseif (ax == 'Z')
            minmax = get(gca,'ZLim');
            set(gca,'ZLim',[-inf minmax(2)]);
        end
    elseif (command == 3)
        if (ax == 'X')
            minmax = get(gca,'XLim');
            set(gca,'XLim',[minmax(1) inf]);
        elseif (ax == 'Y')
            minmax = get(gca,'YLim');
            set(gca,'YLim',[minmax(1) inf]);
        elseif (ax == 'Z')
            minmax = get(gca,'ZLim');
            set(gca,'ZLim',[minmax(1) inf]);
        end
    elseif (command == 4)
        if (ishold)
            hold off;
            set(gcm2,'Label','Hold on');
        else
            hold on;
            set(gcm2,'Label','Hold off');
        end
    elseif (command == 5)
        if(strcmp(get(gcm2,'Label'),'Freeze'))
            axis(axis);
            set(gcm2,'Label','Auto');
        else
            axis('auto');
            set(gcm2,'Label','Freeze');
        end
    elseif command == 6
        menuhandle = get(gcm2,'Parent');
        UserData = get(menuhandle,'UserData');
        if ax == 'X'
            if UserData(1)
                set(gcm2,'Checked','off');
                UserData(1)=0;
            else
                set(gcm2,'Checked','on');
                UserData(1)=1;
            end
        elseif ax == 'Y'
            if UserData(2)
                set(gcm2,'Checked','off');
                UserData(2)=0;
            else
                set(gcm2,'Checked','on');
                UserData(2)=1;
            end
        elseif ax == 'Z'
            if UserData(3)
                set(gcm2,'Checked','off');
                UserData(3)=0;
            else
                set(gcm2,'Checked','on');
                UserData(3)=1;
            end
        end
        set(menuhandle,'UserData',UserData);

    elseif (command == 7)
        UserData=get(get(gcm2,'Parent'),'UserData');
        UserData(4)=input2('Magnification Level? ',UserData(4));
        set(gcm2,'Label',['Mag Level -' num2str(UserData(4)) '-']);
        set(get(gcm2,'Parent'),'UserData',UserData);

    elseif (command == 12)
        if(strcmp(get(gca,'Visible'),'off'))
            set(gca,'Visible','on');
        else
            set(gca,'Visible','off');
        end


    elseif (command == 8)
        currax=axis;
        if length(currax) > 4
            disp('Use 3d zoom')
            return
        end
        if(strcmp(get(gcm2,'Checked'),'off'))
            set(gcm2,'Checked','on');
            zoomrb;
        else
            set(gcm2,'Checked','off');
            ;
        end
    elseif (command == 9)
        if(strcmp(get(gcm2,'Checked'),'off'))
            set(gcm2,'Checked','on');
            OLDAXIS=axis;
            if length(OLDAXIS) == 4
                OLDAXIS=[OLDAXIS,0,0];
            end
            YControl=uicontrol('style','slider','units','normal','pos',[.95 .5 .035 .35], ...
                'min',0.0001,'max',1,'val',.5, ...
                'Callback','sliderca(2)');
            set(YControl,'UserData',[OLDAXIS,.5,.5]);
            uicontrol('style','text','units','normal','pos',[.95,.90,.035,.035], ...
                'string','Y','fore','white','back','black');

            uicontrol('style','slider','units','normal','pos',[.95 .05 .035 .35], ...
                'min',0.0001,'max',1,'val',.5, ...
                'Callback','sliderca(1)');
            uicontrol('style','text','units','normal','pos',[.95,.43,.035,.035], ...
                'string','X','fore','white','back','black');

        else
            set(gcm2,'Checked','off');
            sibs=get(gcf,'Children');
            for i=1:length(sibs)
                if strcmp(get(sibs(i),'Type'),'uicontrol')
                    if strcmp(get(sibs(i),'Style'),'slider') ...
                            | strcmp(get(sibs(i),'Style'),'text')
                        delete(sibs(i));
                    end
                end
            end
        end

    end
