function h=gridpcolor(ax,xs, ys, values, mask, name)
    % GRIDPCOLOR plots values, sampled at the intersection of xcenters and ycenters
    %
    % h=GRIDPCOLOR(ax,xs, ys, values, mask) where XS and YS are the same sized matrices of points.
    % and MASK is 
    %
    % Pcolor typically uses the points as edges, and ignores the last values.
    % 
    if isempty(ax)
        ax=gca;
    end
    if ~exist('name','var')
        name='';
    end
    name(name=='_')=' ';
    
    INCLUDENUMBERS=false;
    INCLUDECOORDS=false;
    
    
    if exist('mask','var')
        values(~mask)=nan;
    else
        mask=true(size(xs)+[1,1]);
    end
    
    [xs,ys, values]=centers2edges(xs,ys,values);
    hold(ax,'on');
    h=pcolor(ax,xs, ys, values);
    %if ~isempty('name')
    set(h,'DisplayName',name);
    %end
    if INCLUDENUMBERS
        for n=1:numel(xs)
            v=values(n);
            if ~isnan(v) && mask(n)
                if INCLUDECOORDS
                    text(ax,xs(n),ys(n),sprintf('(%.2f, %.2f)\n%s',xs(n),ys(n),num2str(v)));
                else
                    text(ax,xs(n),ys(mn),num2str(v));
                end
            end
        end
    end