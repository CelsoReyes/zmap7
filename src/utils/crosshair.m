function crosshair(action)
    %  The new crosshair function for zmap based on the matlab internal
    %  function ginput, however this ginput is not necessary for this function.
    %  The new crosshair function can be used like the old one.
    %
    global xhr_plot xhr_xdata xhr_ydata xhr_plot_data xhr_button_data state fig_units pt keydown

    %init the gui and all other variables
    if nargin == 0
        xhr_plot=gcf;
        xhrx_axis=gca;
        figure_w_normalized_uicontrolunits(gcf);

        %The GUI
        xhr_button_data=get(xhr_plot,'WindowButtonDownFcn');
        set(xhr_plot,'WindowButtonDownFcn','crosshair(''down'');');


        xaxis_text=uicontrol('Style','edit','Units','Normalized',...
            'Position',[.2 .96 .2 .045],...
            'String','X value',...
            'BackGroundColor',[.7 .7 .7]);
        x_num=uicontrol('Style','edit','Units','Normalized',...
            'Position',[.4 .96 .2 .045],...
            'String',' ',...
            'BackGroundColor',[0 .7 .7]);
        y_text=uicontrol('Style','edit','Units','Normalized',...
            'Position',[.6 .96 .2 .045],...
            'String','Y value',...
            'BackGroundColor',[.7 .7 .7]);
        y_num=uicontrol('Style','edit','Units','Normalized',...
            'Position',[.8 .96 .2 .045],...
            'String',' ',...
            'BackGroundColor',[0 .7 .7]);

        %The Button 'Done'
        closer=uicontrol('Style','Push','Units','Normalized',...
            'Position',[.92 0 .08 .04],...
            'String','Done',...
            'Callback','crosshair(''close'')',...
            'Visible','on');
        xhr_plot_data=[  ...
            xhrx_axis   xaxis_text x_num...
            y_text y_num  ...
            closer ];


        %state = uisuspend(fig);
        pointer = get(gcf,'pointer');
        set(gcf,'pointer','crosshair');
        fig_units = get(xhr_plot,'units');
        char = 0;

    elseif strcmp(action,'down')
        %do every time the mouse button is pressed
        handles=xhr_plot_data;
        xhrx_axis=handles(1);
        xaxis_text=handles(2);
        x_num=handles(3);
        y_text=handles(4);
        y_num=handles(5);
        closer=handles(6);


        ptr_fig = get(groot,'CurrentFigure');

        if(ptr_fig == xhr_plot)
            if keydown
                char = get(xhr_plot, 'CurrentCharacter');
                button = abs(get(xhr_plot, 'CurrentCharacter'));
                scrn_pt = get(groot, 'PointerLocation');
                set(xhr_plot,'units','pixels')
                loc = get(xhr_plot, 'Position');
                pt = [scrn_pt(1) - loc(1), scrn_pt(2) - loc(2)];
                set(xhr_plot,'CurrentPoint',pt);


            end
            %get coordinate
            pt = get(gca, 'CurrentPoint');

            %write the coordinates to the gui
            set(x_num,'String',num2str(pt(1,1),6));
            set(y_num,'String',num2str(pt(1,2),6));

        end


    elseif strcmp(action,'close')
        %restore the view
        handles=xhr_plot_data;

        %gui stuff
        xhrx_axis=handles(1);
        xaxis_text=handles(2);
        x_num=handles(3);
        y_text=handles(4);
        y_num=handles(5);
        closer=handles(6);

        %delete gui
        delete(xaxis_text);
        delete(x_num);
        delete(y_text);
        delete(y_num);
        delete(closer);

        %uirestore(state);
        set(xhr_plot,'units',fig_units);
        set(xhr_plot,'pointer', 'arrow');
        set(xhr_plot,'WindowButtonUpFcn','');
        set(xhr_plot,'WindowButtonMotionFcn','');
        set(xhr_plot,'WindowButtonDownFcn',xhr_button_data);
        refresh(xhr_plot)
        clear xhr_plot  xhr_plot_data xhr_button_data
    end

