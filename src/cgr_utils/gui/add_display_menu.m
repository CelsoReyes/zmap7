function add_display_menu(version)
    % adds a display menu to the current figure
    %
    % appently mostly used by the view_  functions
    
    % when called, hzma is the current axes;
    ZG=ZmapGlobal.Data;
    
    op2e = uimenu('Label','Display');
    switch version
        case 1
            circlefun=@plotci2;
            fixscalefun=@(data)fix_caxis(data,'horiz');
            uimenu(op2e,'Label','Plot Map in lambert projection using m_map ', 'Callback','plotmap ');
            %overlayfun=@overlay;
        case 2
            circlefun=@plotci2;
            fixscalefun=@(data)fix_caxis(data,'');
            uimenu(op2e,'Label','Plot Map in lambert projection using m_map ', 'Callback','plotmap ');
            %overlayfun=@overlay;
        case 3
            circlefun=@plotci3;
            fixscalefun=@(data)fix_caxis(data,'horiz');
            %overlayfun=@()zmap_update_displays();
        case 4
            circlefun=@plotci2;
            fixscalefun=@(data)fix_caxis(data,'horiz');
            uimenu(op2e,'Label','Plot Map in lambert projection using m_map ', 'Callback','plotmap ')
            uimenu(op2e,'Label','Plot map on top of topography (white background)',...
                'Callback','colback = 1; dramap2_z'); % this is different from case #1
            uimenu(op2e,'Label','Plot map on top of topography (black background)',...
                'Callback','colback = 2; dramap2_z'); % this is different from case #1
            %overlayfun=@overlay;
        case 5
            circlefun=@plotci2;
            fixscalefun=@(data)fix_caxis(data,'horiz');
            add_colormap_section(op2e);
            add_shading_section(op2e);
            add_brighten_section(op2e);
            %overlayfun=@overlay;
    end
    
    uimenu(op2e,'Label','Fix color (z) scale', 'Callback',@(~,~)fixscalefun(ZGvalueMap));
    uimenu(op2e,'Label','Show Grid', 'Callback',@callback_showgrid);
    uimenu(op2e,'Label','Show Circles', 'Callback',@(~,~)circlefun);
    add_colormap_section(op2e);
    add_shading_section(op2e);
    add_brighten_section(op2e);
    uimenu(op2e,'Label','Redraw Overlay',...
        'Callback','hold on;zmap_update_displays();'); % this is different from case #1
    
    function callback_shader(style)
        % set default shading style and apply to current axes
        axes(gca);
        ZG.shading_style=style;
        shading(ZG.shading_style);
    end
    
    function callback_showgrid(src,~)
        hold on;
        plot(newgri(:,1),newgri(:,2),'+k')
    end
    function callback_brighten(src,~,val)
        % axes(hzma); 
        brighten(val);
    end
    function add_brighten_section(parent)
        uimenu(parent,'Label','Brighten +0.4','Callback',{@callback_brighten, 0.4});
        uimenu(parent,'Label','Brighten -0.4','Callback',{@callback_brighten,-0.4})
    end
    function add_colormap_section(parent)
        uimenu(parent,'Label','Colormap InvertGray',...
            'Callback','g=gray; g = g(64:-1:1,:);colormap(g);brighten(.4)');
        uimenu(parent,'Label','Colormap Invertjet',...
            'Callback','g=jet; g = g(64:-1:1,:);colormap(g)');
    end
    function add_shading_section(parent)
        %TODO make this 1 option, simple inputdlg box, or flip the names
        uimenu(parent,'Label','shading flat',...
            'Callback',@(~,~)callback_shader('flat'))
        uimenu(parent,'Label','shading interpolated',...
            'Callback',@(~,~)callback_shader('interp'))
    end
    
end