function viewer()
    %function viewer()
    %Creates a new figure containing 3 slide bars
    %which can be used to control the view orientation
    %for the figure currently selected. A popup menu
    %allows control of the system used to determine
    %the point of view. The system can be
    %
    %'xyz' in which case the sliders control fixed-axis
    %rotations about the x, y, and z axes in that order,
    %
    %'El-Az' in which case the standard MATLAB elevation
    % and azimuth controls are used, or
    %
    %'pyr' in which case the sliders control body-axis
    %rotations about the pitch, yaw, and roll (y-z-x)
    %axes in that order.
    %
    % Keith Rogers 11/30/93
    % Mods:
    %    preview capability - 12/29/93 Patrick Marchand
    %                          (pmarchan@motown.ge.com)
    %    09/16/94 Set viewer 'NextPlot' to 'new'
    %    12/02/94 Shorten Callback function names to appease DOS Users

    global viewerfig;
    allfigs = get(groot,'children');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % If the viewer figure exists, bring it to the foreground.
    % If it does not exist,create it.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    viewerfig = findfig('3-D Viewer');
    if(viewerfig)
        figure_w_normalized_uicontrolunits(viewerfig);
    else
        set(gcf,'units','normalized')
        pfig=get(gcf,'Position');
        viewerfig = figure_w_normalized_uicontrolunits('Units','normalized',...
            'Position',[pfig(1) pfig(2)-.14 .34 .11],...
            'Name','3-D Viewer',...
            'ButtonDownFcn','vwrcback(11)');
        viewerax = axes('Position',[0 0 1 1],'Visible','off');
        widgetax = axes('Position',[.75 .1 .2 .8]);
        plot3([0 1],[0 0],[0 0],'linewidth',3);hold on
        plot3([0 0],[0 1],[0 0],'linewidth',3);hold on
        plot3([0 0],[0 0],[0 1],'linewidth',3);axis([0 1 0 1 0 1]);
        text(0,0,1,'z');text(0,1,0,'y');text(1,0,0,'x');
        set(widgetax,'box','on','xtick',[],'ytick',[],'ztick',[]);
        set(viewerfig,'NextPlot','new');
        axes(viewerax);

        view_button = uicontrol('Style','Popup',...
            'Units','normalized',...
            'String','XYZ|El-Az|PYR',...
            'Position',[.05 .76 .3 .24],...
            'Callback','vwrcback(10)',...
            'Value',1);
        set(view_button,'UserData',0);

        apply_button = uicontrol('Style','Pushbutton',...
            'Units','normalized',...
            'Position',[.35 .76 .3 .23],...
            'Callback','vwrcback(11)','String','Apply');


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % UserData(1) = handle of slider #1
        % UserData(2) = handle of slider #2
        % UserData(3) = handle of slider #3
        % UserData(4) = handle of text for slider #1
        % UserData(5) = handle of text for slider #2
        % UserData(6) = handle of text for slider #3
        % UserData(7) = handle of text for slider #3
        % UserData(8) = handle of text for slider #3
        % UserData(9) = handle of text for slider #3
        % UserData(10) = handle of view_button
        % UserData(11) = handle of apply_button
        % UserData(12) = handle of figure being viewed
        % UserData(13) = handle of axis containing sliders
        % UserData(14) = handle of axis containing display figure
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        UserData = zeros(14,1);
        UserData(10) = view_button;
        UserData(13) = viewerax;
        UserData(14) = widgetax;

        set(viewerfig,'UserData',UserData);
        vwrcback(10);
    end
