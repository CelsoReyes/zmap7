function h=gridpcolor(ax,xs, ys, values, mask)
    % plots values, sampled at the intersection of xcenters and ycenters
    %
    % h=gridpcolor(ax,xs, ys, values, mask)
    %
    % Pcolor typically uses the points as edges, and ignores the last values.
    % 
    if isempty(ax)
        ax=gca;
    end
    
    INCLUDENUMBERS=false;
    INCLUDECOORDS=false;
    
    dx=diff(xs);
    dy=diff(ys);
    dx=[dx dx(end)];
    dy=[dy dy(end)];
    xlist= [xs-(dx/2) xs(end)+dx(end)/2];
    ylist= [ys-(dy/2) ys(end)+dy(end)/2];
    if exist('mask','var')
        values(~mask)=nan;
    else
        mask=true(numel(xs),numel(ys));
    end
    values(end+1,:)=nan;
    values(:,end+1)=nan;
    whos xlist ylist values
    h=pcolor(ax,xlist, ylist, values);
    if INCLUDENUMBERS
        for m=1:numel(ys) %row
            for n=1:numel(xs) %col
                v=values(m,n);
                if ~isnan(v) && mask(n,m)
                    if INCLUDECOORDS
                        text(ax,xs(n),ys(m),sprintf('(%.2f, %.2f)\n%s',xs(n),ys(m),num2str(v)));
                    else
                    text(ax,xs(n),ys(m),num2str(v));
                    end
                end
            end
        end
    end