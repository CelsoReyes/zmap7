function plot_strike_dip(catalog,ax)
    % plot strike and dip for a catalog using DipDirection and Dip
    % specify the axes
    
    dipdir=catalog.DipDirection;
    dip=catalog.Dip;
    x0=catalog.Longitude;
    y0=catalog.Latitude;
    
    strikescale=0.5;
    dipscale=0.3;
    linecolor = [1 0 0];
    limit_to_axes = true;
    
    % figure out some scaling stuff
    axun = get(ax,'Units');
    set(ax,'Units','pixels')
    p=fix(get(ax,'Position'));
    set(ax,'Units',axun);
    
    % TODO: do something with p and the xlim to come up with an appropriately sized symbol
    
    
    delete(findobj(gcf,'Tag','diptest'))
    
    
    strike = wrapTo360(dipdir-90);
    scaling = ax.DataAspectRatio;
    labels = cellstr( num2str(dip) );
    labels="  "+labels;
    
    is_horiz = dip==0;
    is_vert = dip==90;
    
    dx = cosd(strike) .* strikescale ./scaling(2);
    dy = sind(strike) .* strikescale ./ scaling(1);
    xx = ([x0,x0,x0] + [-dx, dx, nan(size(x0))])';
    yy = ([y0,y0,y0] + [-dy, dy, nan(size(y0))])';
    xx=xx(:);
    yy=yy(:);
    
    hold on;
    plot(ax,xx,yy,'r','linewidth',1,'Tag','diptest','DisplayName','Strikes')
    
    dipx=cosd(dipdir(:))* dipscale./scaling(2);
    dipy=sind(dipdir(:))* dipscale./scaling(1);
    xdx = ([x0,x0,x0] + [zeros(size(x0)) - is_vert .* dipx, dipx, nan(size(x0))])';
    ydy = ([y0,y0,y0] + [zeros(size(y0)) - is_vert .* dipy, dipy, nan(size(y0))])';
    
    xdx=xdx(:);
    ydy=ydy(:);
    plot(ax,xdx,ydy,'Color',linecolor,'linewidth',1.5,'Tag','diptest','DisplayName','Dips')
    if any(is_horiz)
        plot(ax,x0(is_horiz),y0(is_horiz),'o','Color',linecolor,'linewidth',1.5,'Tag','diptest','DisplayName','HorizDips')
    end
    if limit_to_axes
        rangeidx=in_range(x0,xlim) & in_range(y0,ylim);
        text(ax,x0(rangeidx), y0(rangeidx), labels(rangeidx), 'VerticalAlignment','top',...
            'HorizontalAlignment','left',...
            'Tag','diptest',...
            'Color',linecolor .* 0.66);
        
    else
        text(ax,x0, y0, labels, 'VerticalAlignment','top',...
            'HorizontalAlignment','left',...
            'Tag','diptest',...
            'Color',linecolor .* 0.66);
    end
end