function tsel(command)
    % This function, called with no arguments
    % is meant to be installed as a WindowButtonDownFcn.
    % It will select text objects when they are clicked on
    % and deselect them when another object is subsequently
    % clicked on.  Also, if a text object is double-clicked
    % on, it will create an editable text uicontrol for
    % editing the text object's string.  Note that some
    % problems with registering the double-click have been
    % encountered on the Mac, but we haven't been able to
    % pin down the exact circumstances that cause the
    % problem.  If you are using a Mac and the double-click
    % doesn't seem to do anything, change the selection type
    % in the code below to 'extended' instead of 'open'
    % and let me (kerog@athena.mit.edu) know by e-mail.
    %
    % Keith Rogers 11/30/93


    global oldtextobj;
    if isempty('oldtextobj') == 0; return; end
    if(nargin == 0)
        if(oldtextobj ~= gco & isobj(oldtextobj))
            set(oldtextobj,'Selected','off');
        end
        if(strcmp(get(gco,'Type'),'text'))
            set(gco,'Selected','on');
            oldtextobj = gco;
        end
        if(strcmp(get(gcf,'SelectionType'),'open'))
            axpos = get(gca,'position');
            units = get(gco,'units');
            set(gco,'units','normalized');
            txtpos = get(gco,'extent');
            set(gco,'units',units);
            uipos = [axpos(1)+axpos(3)*txtpos(1),...
                axpos(2)+axpos(4)*txtpos(2),...
                2*axpos(3)*txtpos(3) 2*axpos(4)*txtpos(4)];
            textedit = uicontrol('style','edit',...
                'string',get(gco,'string'),...
                'units','normalized',...
                'position',uipos,...
                 'Callback','tsel(1)');
            obj = [gco;textedit];
            set(textedit,'UserData',obj);
        end
    elseif (command == 1)
        obj = get(gco,'UserData');
        set(obj(1),'string',get(obj(2),'string'));
        delete(obj(2));
    end
