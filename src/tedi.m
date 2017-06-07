function bgui(state)

    report_this_filefun(mfilename('fullpath'));

    if nargin == 0  % Build the GUI
        % Create the Figure Window
        figure_w_normalized_uicontrolunits('Units','normal','Position',[.25 .25 .5 .5], ...
            'Name','BGUI Example','NumberTitle','off', ...
            'Color','w');
        % Set the default units for uicontrols to 'normal'.
        % This makes it easier to place the uicontrols, and
        % the increase/decrease in size if the figure is
        % resized.
        set(gcf,'DefaultUicontrolUnits','normal')
        % Add a static text uicontrol
        st = uicontrol('Style','text','String','Enter Command:', ...
            'Position',[.1 .8 .8 .1], ...
            'BackgroundColor','w','ForegroundColor','k', ...
            'HorizontalAlignment','left');
        % Add the edit uicontrol
        h = uicontrol('Style','edit','Position',[.1 .6 .8 .2], ...
            'min',0,'max',2)
        % Add the push button
        i = uicontrol('Style','push','Position',[.1 .2 .8 .3], ...
            'String','Evaluate Edit Block', ...
            'Callback','bgui(''evaluate'')');
        % Store the handle to the edit block in the figures
        % UserData propert.  This is done to avoid the use of
        % global variable.  See the UserData section in the
        % Building a Graphical User Interface Guide for more
        % information.
        set(gcf,'UserData',h)

    elseif strcmp(state,'evaluate') % Push button selected
        % Get the handle to the edit uicontrol
        h = get(gcf,'UserData');
        % Extract the command
        com = get(h,'String');
        % Evaluate the string using eval(try,catch)
        eval(com,'error(''Invalid MATLAB Command'')')

    end

