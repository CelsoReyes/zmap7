%pickpoint.m
%subroutine for keyselect.m to pick the data-points(locations)
%                                                              A.A

report_this_filefun(mfilename('fullpath'));

newcat.Count;
figure(getobj('Tag','main_map_ax'));
if but == 1               %more option
    xi=xcordinate;
    yi=ycordinate;

    mark1 =    plot(ax,xi,yi,'wo');
    set(mark1,'MarkerSize',8,'LineWidth',2.0)
    n = n + 1;
    % mark2 =     text(xi,yi,[' ' int2str(n)],'era','normal');
    % set(mark2,'FontSize',15,'FontWeight','bold')

    x = [x; xi];
    y = [y; yi];

else

    xi=xcordinate;
    yi=ycordinate;
    if but==2               %last input of cordinates
        mark1 = plot(xi,yi,'wo','era','back');
        set(mark1,'MarkerSize',10,'LineWidth',2.0)
        n = n+1;
        x = [x; xi];
        y = [y; yi];
    end   % if

    if but==3

        [file1,path1] = uigetfile([hodo '*'],'Polygon Datafile');

        if length(path1) > 1
            think
            %lofi = ['!cat  ' path1 file1 ' > poltmp.m '  ];
            %eval(lofi)
            %bullshit again
            %lofi = ['load ' path1 file1 ];
            %eval(lofi)
            loadedPoly=load([path1 file1]);
            %dopo = find(file1 == '.');
            %lofi = ['poltmp = ' file1(1:dopo-1) ];
            %eval(lofi)
            %poltmp = file1(dopo-1);
        else
            return
        end

        %x=poltmp(:,1);
        %y=poltmp(:,2);
        x=loadedPoly(:,1);
        y=loadedPoly(:,2);
        n=length(x);
        for i=1:length(loadedPoly(:,1))
            mark1 = plot(x(i),y(i),'ro','era','back');
            set(mark1,'MarkerSize',10,'LineWidth',2.0)
        end %for
    end %if
    if but==4
        echo on
        % ___________________________________________________________
        %  Please use the left mouse button or the cursor to select
        %  the polygon vertexes.
        %
        %  Use the right mouse button to select the final point.
        %_____________________________________________________________
        echo off
        te = text(0.01,0.90,'# #To select events inside a polygon. #Please use the LEFT mouse button or the cursor to select # the polygon vertexes. Use the RIGHT mouse button# for the final point.# # Operates on the original catalogue producing a reduced #subset which in turn the other routines operate on.');
        set(te,'FontSize',12);
        click = 1;
        while click == 1
            [xi,y1,click] = ginput(1);
            mark1 =    plot(ax,xi,yi,'ko'); % doesn't matter what erase mode is
            % used so long as its not NORMAL
            set(mark1,'MarkerSize',10,'LineWidth',2.0)
            n = n + 1;
            x = [x; xi];
            y = [y; yi];
        end  %while
    end  %if

    disp('End of data entry')

    welcome
    think
    wai = uicontrol('Units','normal','Position',[.4 .50 .2 .06],'String','Wait ... ')
    disp('Data is being processed - please wait...  ')
    x = [x ; x(1)];
    y = [y ; y(1)];      %  closes polygon

    figure_w_normalized_uicontrolunits(map)
    plot(x,y,'b-','era','back');        % plot outline
    sum3 = 0.;
    pause(0.3)
    % calculate points with a polygon

    XI = a.Longitude;          % this substitution just to make equation below simple
    YI = a.Latitude;
    ll = polygon_filter(x,y, XI, YI, 'inside');
    newcat = a.subset(ll);                % newcat is created
    % a = newcat;                      % a and newcat now equal to reduced catalogue
    newt2 = newcat;                  % resets newt2

    clear XI YI l ll;
    %
    % Plot of new catalog
    %
    disp('Done!')
    delete(wai)
    if isempty(newcat) ; disp('Catalog is empty!'); return;end
    plot(newcat.Longitude,newcat.Latitude,'.g','era','back')

    timeplot
    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %
    %   The new catalog (newcat) with points only within the
    %   selected Polygon is created and resets the original
    %   "a" .
    %
    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    xy = [x y ];
    save polcor.dat xy -ascii
    messtext = [' The selected polygon has been saved '
        ' in the file polcor.dat              '];
    zmap_message_center.set_message('Message',messtext)
    disp(' The selected polygon has been saved in the file polcor.dat')

end
