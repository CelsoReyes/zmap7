function zoom(direction)
    % This function is meant to be called only from
    % the zoom menu in makemenus.
    %
    % Keith Rogers 11/30/93

    UserData = get(get(gcm2,'Parent'),'UserData');

    % Zoom by a factor of maglevel
    % direction = 1 -> Zoom in
    % direction = 2 -> Zoom out


    maglevel = UserData(4);
    ZoomAxes = UserData(1:3);

    plotobjs = get(gca,'Children');
    if (length(plotobjs) ~= 0)
        currax = axis;
        newax = zeros(size(currax));
        if (currax(1) == -inf)
            minx = inf;
        else
            minx = currax(1);
        end
        if (currax(2) == inf)
            maxx = -inf;
        else
            maxx = currax(2);
        end
        if (currax(3) == -inf)
            miny = inf;
        else
            miny = currax(3);
        end
        if (currax(4) == inf)
            maxy = -inf;
        else
            maxy = currax(4);
        end
        for i = 1:length(plotobjs)
            if(strcmp(get(plotobjs(i),'Type'),'line') | ...
                    strcmp(get(plotobjs(i),'Type'),'surface'))
                minx = min(minx,min(min(get(plotobjs(i),'Xdata'))));
                maxx = max(maxx,max(max(get(plotobjs(i),'Xdata'))));
                miny = min(miny,min(min(get(plotobjs(i),'Ydata'))));
                maxy = max(maxy,max(max(get(plotobjs(i),'Ydata'))));
            end
        end
        [zpx,zpy] = ginput(1);

        %%%%%  Adjust Z Axis %%%%%

        if (length(currax) > 4)		% If 3-D plot
            zp = get(gca,'Currentpoint');
            zpx = mean(zp(:,1));
            zpy = mean(zp(:,2));
            zpz = mean(zp(:,3));
            minz = currax(5);
            maxz = currax(6);
            for i = 1:length(plotobjs)
                if(strcmp(get(plotobjs(i),'Type'),'line') | ...
                        strcmp(get(plotobjs(i),'Type'),'surface'))
                    minz = min(minz,min(min(get(plotobjs(i),'Zdata'))));
                    maxz = max(maxz,max(max(get(plotobjs(i),'Zdata'))));
                end
            end
            if (ZoomAxes(3))	% Z Axis Zoom active
                if (direction == 1)
                    newzsize = (min(maxz,currax(6))-max(minz,currax(5)))...
                        /maglevel;
                else
                    newzsize = (min(maxz,currax(6))-max(minz,currax(5)))...
                        *maglevel;
                end
            else
                newzsize = currax(6)-currax(5);
            end
            if ((zpz-.5*newzsize) < minz)
                newax(5:6) = [minz minz+newzsize];
            elseif (zpz+.5*newzsize > maxz)
                newax(5:6) = [maxz-newzsize maxz];
            else
                newax(5:6) = [(zpz-.5*newzsize) (zpz+.5*newzsize)];
            end
        end

        %%%%%  Adjust X Axis   %%%%%

        if (ZoomAxes(1))				% X Axis Zoom active
            if (direction == 1)			% Zoom in
                newxsize = (min(maxx,currax(2))-max(minx,currax(1)))...
                    /maglevel;
            else						% Zoom out
                newxsize = (min(maxx,currax(2))-max(minx,currax(1)))...
                    *maglevel;
            end
        else
            newxsize = currax(2)-currax(1);
        end
        if ((zpx-.5*newxsize) < minx)
            newax(1:2) = [minx minx+newxsize];
        elseif (zpx+.5*newxsize > maxx)
            newax(1:2) = [maxx-newxsize maxx];
        else
            newax(1:2) = [(zpx-.5*newxsize) (zpx+.5*newxsize)];
        end

        %%%%%  Adjust Y Axis   %%%%%

        if (ZoomAxes(2))	% Y Axis Zoom active
            if (direction == 1)			% Zoom in
                newysize = (min(maxy,currax(4))-max(miny,currax(3)))...
                    /maglevel;
            else						% Zoom out
                newysize = (min(maxy,currax(4))-max(miny,currax(3)))...
                    *maglevel;
            end
        else
            newysize = currax(4)-currax(3);
        end
        if ((zpy-.5*newysize) < miny)
            newax(3:4) = [miny miny+newysize];
        elseif (zpy+.5*newysize > maxy)
            newax(3:4) = [maxy-newysize maxy];
        else
            newax(3:4) = [(zpy-.5*newysize) (zpy+.5*newysize)];
        end
        axis(newax);
    end
