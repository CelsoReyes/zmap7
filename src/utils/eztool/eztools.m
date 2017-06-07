function eztools()
    %  put up eztools menu on current plot
    %
    %
    %  Richard G. Cobb  3/96


    %%%%%%%%%%%%%%%%%% Begin Figure Menu %%%%%%%%%%%%

    FigMenu = uimenu('Label','Figure');

    uimenu(FigMenu,'Label','Page Setup','Callback','pageset');
    uimenu(FigMenu,'Label','Labels','Separator','on','Callback','ezlabels');
    uimenu(FigMenu,'Label','Legend/Lines','Separator','on','Callback','ezlegend');

    uimenu(FigMenu,'Label','XY Locator','Separator','on','Callback','crosshair');
    uimenu(FigMenu,'Label','Add Arrows','Callback','ezarrow','Separator','on');

    % Colormap

    ColorEdit = uimenu(FigMenu,'Label','Edit ColorMap','Separator','on','Callback','makecmap(gcf,''fig'')');

    ColorMenu = uimenu(FigMenu,'Label','ColorMap','Separator','on');

    uimenu(ColorMenu,'Label','Default','Callback',...
        'colormap(''default'')');
    uimenu(ColorMenu,'Label','HSV','Callback',...
        'colormap(''hsv'')');
    uimenu(ColorMenu,'Label','summer','Callback',...
        'colormap(''summer'')');
    uimenu(ColorMenu,'Label','Gray','Callback',...
        'colormap(''gray'')');
    uimenu(ColorMenu,'Label','Hot','Callback',...
        'colormap(''hot'')');
    uimenu(ColorMenu,'Label','Cool','Callback',...
        'colormap(''cool'')');
    uimenu(ColorMenu,'Label','Copper','Callback',...
        'colormap(''copper'')');
    uimenu(ColorMenu,'Label','Pink','Callback',...
        'colormap(''pink'')');
    uimenu(ColorMenu,'Label','Jet','Callback',...
        'colormap(''jet'')');

    uimenu(FigMenu,'Label','Refresh','Separator','on','Callback','refresh');
    uimenu(FigMenu,'Label','WYSIWYG','Separator','on','Callback','wysiwyg');

    uimenu(FigMenu,'Label','Clear Figure',...
        'Callback','delete(findobj(''type'',''axes''))');



    %%%%%%%%%%%%%%%%%% Begin AXIS Menu %%%%%%%%%%%%

    AxMenu = uimenu('Label','Axis');
    uimenu(AxMenu,'Label','EZ-Axes','Callback','ezaxes');

    uimenu(AxMenu,'Label','Clear','Callback','cla');
    uimenu(AxMenu,'Label','Grid','Callback','grid');
    if(strcmp(axis('state'),'manual'))
        uimenu(AxMenu,'Label','Auto',...
            'Callback','axiscall(5,0)');
    else
        uimenu(AxMenu,'Label','Freeze',...
            'Callback','axiscall(5,0)');
    end
    AspectMenu = uimenu(AxMenu,'Label','Aspect');
    uimenu(AspectMenu,'Label','Normal','Callback','axis(''normal'')');
    uimenu(AspectMenu,'Label','Square','Callback','axis(''square'')');
    uimenu(AspectMenu,'Label','Image','Callback','axis(''image'')');
    uimenu(AspectMenu,'Label','Equal','Callback','axis(''equal'')');

    Xaxis = uimenu(AxMenu,'Label','X Opts');
    Yaxis = uimenu(AxMenu,'Label','Y Opts');
    Zaxis = uimenu(AxMenu,'Label','Z Opts');

    if(strcmp(get(gca,'XScale'),'linear'))
        uimenu(Xaxis,'Label','Log','Callback','axiscall(1,''X'')');
    else
        uimenu(Xaxis,'Label','Linear','Callback','axiscall(1,''X'')');
    end
    uimenu(Xaxis,'Label','Auto Min','Callback','axiscall(2,''X'')');
    uimenu(Xaxis,'Label','Auto Max','Callback','axiscall(3,''X'')');
    if(strcmp(get(gca,'YScale'),'linear'))
        uimenu(Yaxis,'Label','Log','Callback','axiscall(1,''Y'')');
    else
        uimenu(Yaxis,'Label','Linear','Callback','axiscall(1,''Y'')');
    end
    uimenu(Yaxis,'Label','Auto Min','Callback','axiscall(2,''Y'')');
    uimenu(Yaxis,'Label','Auto Max','Callback','axiscall(3,''Y'')');
    if(strcmp(get(gca,'ZScale'),'linear'))
        uimenu(Zaxis,'Label','Log','Callback','axiscall(1,''Z'')');
    else
        uimenu(Zaxis,'Label','Linear','Callback','axiscall(1,''Z'')');
    end
    uimenu(Zaxis,'Label','Auto Min','Callback','axiscall(2,''Z'')');
    uimenu(Zaxis,'Label','Auto Max','Callback','axiscall(3,''Z'')');


    if(ishold)
        uimenu(AxMenu,'Label','Hold off','Callback','axiscall(4,0)');
    else
        uimenu(AxMenu,'Label','Hold on','Callback','axiscall(4,0)');
    end

    uimenu(AxMenu,'Label','Axes Vis','Callback','axiscall(12,[])');

    %  Zoom Menu

    %uimenu(AxMenu,'Label','Zoom Box','Callback','subzoom');

    uimenu(AxMenu,'Label','Zoom ON','Callback','zoomrb on','Checked','off');
    uimenu(AxMenu,'Label','Zoom OFF','Callback','zoomrb off','Checked','off');

    uimenu(AxMenu,'Label','X-Y Sliders','Callback','axiscall(9,[])',...
        'Checked','off');

    uimenu(AxMenu,'Label','3-D Viewer','Callback','viewer','Separator','on');
    %New Zoom InteractiveMouse
    %uimenu(AxMenu,'Label','Mouse Zoom','Separator','on','Callback','interactivemouse');

    Zoom3d = uimenu(AxMenu,'Label','3-D Zoom');
    maglevel = 2;
    set(Zoom3d,'UserData',[1;1;1;maglevel]);
    uimenu(Zoom3d,'Label','Zoom in','Callback','zoom3d(1)');
    uimenu(Zoom3d,'Label','Zoom out','Callback','zoom3d(2)');
    uimenu(Zoom3d,'Label','X Axis','Checked','on','Callback',...
        'axiscall(6,''X'')','Separator','on');
    uimenu(Zoom3d,'Label','Y Axis','Checked','on','Callback',...
        'axiscall(6,''Y'')');
    uimenu(Zoom3d,'Label','Z Axis','Checked','on','Callback',...
        'axiscall(6,''Z'')');
    uimenu(Zoom3d,'Label',['Mag Level -' num2str(maglevel) '-'],'Callback',...
        'axiscall(7,0)','Separator','on');
    set(gcf,'WindowButtonDownFcn','tsel');
