function clpickp(but)
    %clpickp.m                          A.Allmann
    %subroutine for clkeysel.m to pick the data-points(locations)
    %and build new catalog whith earthquakes of clusters which equivalent events
    %are inside the selection area
    %original clustercatalog is in backcat,you can choose selection areas inside
    %older selection ares but if you hit back your working catalog becomes
    %the original clustercatalog again
    %
    %Last modification 6/95

    global clu newclcat mess equi_button fontsz backcat clu1 mapp
    global n x y xcordinate ycordinate equi bgevent backequi par1
    global typele dep1 dep2 dep3 ms6 ty1 ty2 ty3 fontsz name term
    global cb1 cb2 cb3
    global backbgevent original plot1_h plot2_h clust file1
    global ttcat tt1cat foresh aftersh mainsh clsel sys decc newccat

    if decc~=0
        if isempty(ttcat)
            figure_w_normalized_uicontrolunits(clu);
        else
            figure_w_normalized_uicontrolunits(clu1);
        end
    elseif decc==0
        figure_w_normalized_uicontrolunits(mapp)
    end
    if but == 1               %more option
        xi=xcordinate;
        yi=ycordinate;

        mark1 =    plot(xi,yi,'wo','era','back'); % doesn't matter what erase mode is
        % used so long as its not NORMAL
        set(mark1,'MarkerSize',10,'LineWidth',2.0)
        n = n + 1;
        % mark2 =     text(xi,yi,[' ' int2str(n)],'era','back');
        % set(mark2,'FontSize',15,'FontWeight','bold')

        x = [x; xi];
        y = [y; yi];
    elseif but==2               %last input of cordinates
        xi=xcordinate;
        yi=ycordinate;
        mark1 = plot(xi,yi,'wo','era','back');
        set(mark1,'MarkerSize',10,'LineWidth',2.0)
        n = n+1;
        x = [x; xi];
        y = [y; yi];
        but=5;
    elseif but==3
        [file2,path2] = uigetfile([ hodi fs 'eq_data' fs '*.mat'],'Cluster Datafile');

        load([path2 file2]);
        x=polcordinates(:,1);
        y=polcordinates(:,2);
        polcordinates
        n=length(x);
        for i=1:length(polcordinates(:,1))
            mark1 = plot(x(i),y(i),'wo','era','back');
            set(mark1,'MarkerSize',10,'LineWidth',2.0)
        end %for
        but=5;
    elseif but==4
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
            mark1 =    plot(xi,yi,'ko','era','back'); % doesn't matter what erase mode is
            % used so long as its not NORMAL
            set(mark1,'MarkerSize',10,'LineWidth',2.0)
            n = n + 1;
            x = [x; xi];
            y = [y; yi];
        end  %while
        but=5;
    end  %if

    if but==5
        if isempty(newclcat)        %first area selection
            if isempty(backcat)         %no selection of special clusters before
                backequi=equi;
                backbgevent=bgevent;
            end
        end
        if ~isempty(ttcat)
            clsel=1;
            if isempty(tt1cat)
                tt1cat=ttcat;
            end
        end
        disp('End of data entry')

        disp('Data is being processed - please wait...  ')
        if decc~=0
            if isempty(ttcat)
                a=equi;
            else
                a=ttcat;
            end
        elseif decc==0
            a=newccat;
        end
        x = [x ; x(1)];
        y = [y ; y(1)];      %  closes polygon

        if decc~=0
            if isempty(ttcat)
                figure_w_normalized_uicontrolunits(clu)
            else
                figure_w_normalized_uicontrolunits(clu1);
            end
        elseif decc==0
            figure_w_normalized_uicontrolunits(mapp)
        end
        plot(x,y,'b-','era','back');        % plot outline
        sum3 = 0.;
        pause(0.3)
        % calculate points with a polygon

        XI = a(:,1);          % this substitution just to make equation below simple
        YI = a(:,2);
    ll = polygon_filter(x,y, XI, YI, 'inside');
        if decc~=0
            if isempty(ttcat)
                equi = a(ll,:);       %all equievents inside selection area
            end
        elseif decc==0
            newccat=newccat(ll,:);
        end
        polcordinates = [x y ];
        save polcordinates.mat polcordinates
        disp(' The selected polygon was save in the file polcordinates.dat')
        if decc~=0
            if isempty(ttcat)
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
                ttcat=a(ll,:);
                cluoverl(8);
            end
        elseif decc==0
            csubcat;
        end
        strib=[' Polygon of  ' file1];
        hold on
        title2(strib,'FontWeight','bold',...
            'FontSize',fontsz.l,'Color','r')
        if decc~=0
            if isempty(ttcat)
                eval(st1);
            end
        end
        x=[];
        y=[];
        n=0;
        welcome;
    end

