function clpickp(choice)
    %subroutine for clkeysel.m to pick the data-points(locations)
    %and build new catalog whith earthquakes of clusters which equivalent events
    %are inside the selection area
    %original clustercatalog is in backcat,you can choose selection areas inside
    %older selection ares choice if you hit back your working catalog becomes
    %the original clustercatalog again
    %
    %clpickp.m                          A.Allmann
    
    global clu newclcat equi_button backcat clu1
    global n x y xcordinate ycordinate
    global equi %[IN/OUT]
    global bgevent backequi
    global backbgevent original plot1_h plot2_h clust file1
    global tt1cat clsel decc
    
    proceed=false;
    
    ZG=ZmapGlobal.Data;
    if decc~=0
        if isempty(ZG.ttcat)
            figure(clu);
        else
            figure(clu1);
        end
    elseif decc==0
        figure(findobj('Tag','mapp'))
    end
    switch choice
        case 'MORE'
            xi=xcordinate;
            yi=ycordinate;
            
            mark1 =    plot(xi,yi,'wo'); % doesn't matter what erase mode is
            % used so long as its not NORMAL
            set(mark1,'MarkerSize',10,'LineWidth',2.0)
            n = n + 1;
            
            x = [x; xi];
            y = [y; yi];
        case 'LAST'               %last input of cordinates
            xi=xcordinate;
            yi=ycordinate;
            mark1 = plot(xi,yi,'wo');
            set(mark1,'MarkerSize',10,'LineWidth',2.0)
            n = n+1;
            x = [x; xi];
            y = [y; yi];
            proceed=true;
        case 'LOAD'
            [file2,path2] = uigetfile(fullfile(ZmapGlobal.Data.data_dir, '*.mat'),'Cluster Datafile');
            
            load([path2 file2]);
            x=polcordinates(:,1);
            y=polcordinates(:,2);
            polcordinates
            n=length(x);
            for i=1:length(polcordinates(:,1))
                mark1 = plot(x(i),y(i),'wo');
                set(mark1,'MarkerSize',10,'LineWidth',2.0)
            end
            proceed=true;
        case 'MOUSE'
            echo on
            % ___________________________________________________________
            %  Please use the left mouse button or the cursor to select
            %  the polygon vertexes.
            %
            %  Use the right mouse button to select the final point.
            %_____________________________________________________________
            echo off
            te = text(0.01,0.90,'\newline \newlineTo select events inside a polygon. \newlinePlease use the LEFT mouse button or the cursor to select \newline the polygon vertexes. Use the RIGHT mouse button\newline for the final point.\newline \newline Operates on the original catalogue producing a reduced \newlinesubset which in turn the other routines operate on.');
            set(te,'FontSize',12);
            click = 1;
            while click == 1
                [xi,yi,click] = ginput(1);
                check1=xi
                check2=yi
                mark1 =    plot(xi,yi,'ko'); % doesn't matter what erase mode is
                % used so long as its not NORMAL
                set(mark1,'MarkerSize',10,'LineWidth',2.0)
                n = n + 1;
                x = [x; xi];
                y = [y; yi];
            end  %while
            proceed=true;
        otherwise
            error('invalid choice')
    end
    
    if proceed
        if isempty(newclcat)        %first area selection
            if isempty(backcat)         %no selection of special clusters before
                backequi=equi;
                backbgevent=bgevent;
            end
        end
        if ~isempty(ZG.ttcat)
            clsel=1;
            if isempty(tt1cat)
                tt1cat=ZG.ttcat;
            end
        end
        disp('End of data entry')
        
        disp('Data is being processed - please wait...  ')
        if decc~=0
            if isempty(ZG.ttcat)
                replaceMainCatalog(equi);
            else
                replaceMainCatalog(ZG.ttcat);
            end
        elseif decc==0
            replaceMainCatalog(ZG.newccat);
        end
        x = [x ; x(1)];
        y = [y ; y(1)];      %  closes polygon
        
        if decc~=0
            if isempty(ZG.ttcat)
                figure(clu);
            else
                figure(clu1);
            end
        elseif decc==0
            figure(findobj('Tag','mapp'));
        end
        plot(x,y,'b-');        % plot outline
        sum3 = 0.;
        pause(0.3)
        % calculate points with a polygon
        
        XI = ZG.primeCatalog.Longitude;          % this substitution just to make equation below simple
        YI = ZG.primeCatalog.Latitude;
        ll = polygon_filter(x,y, XI, YI, 'inside');
        if decc~=0
            if isempty(ZG.ttcat)
                equi = ZG.primeCatalog.subset(ll);       %all equievents inside selection area
            end
        elseif decc==0
            ZG.newccat=ZG.newccat.subset(ll);
        end
        polcordinates = [x y ];
        save polcordinates.mat polcordinates
        disp(' The selected polygon was save in the file polcordinates.dat')
        if decc~=0
            if isempty(ZG.ttcat)
                set(equi_button,'value',1)
                st1=get(equi_button,'Callback');
                eval(st1);
                pause(2);
                tmp=equi(:,10)';
                tmpcat=clust(:,tmp);
                newclcat=original(tmpcat(find(clust(:,tmp))),:);
                plot1_h=[];plot2_h=[];
                bgevent=backbgevent(tmp',:);
                cluoverl(7);
            else
                ZG.ttcat=ZG.primeCatalog.subset(ll);
                cluoverl(8);
            end
        elseif decc==0
            csubcat;
        end
        strib=[' Polygon of  ' file1];
        set(gca,'NextPlot','add')
        title(strib,'FontWeight','bold',...
            'FontSize',ZmapGlobal.Data.fontsz.l,'Color','r')
        if decc~=0
            if isempty(ZG.ttcat)
                eval(st1);
            end
        end
        x=[];
        y=[];
        n=0;
        ZmapMessageCenter();
    end
end

