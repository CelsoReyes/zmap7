function clcirc(var1)
    % clcirc.m                           A.Allmann
    %   "clcirc.m"  selects events by :
    %   the Ni closest earthquakes to the center
    %   the maximum radius of a circle.
    %   the center point can be interactively selected or fixed by given
    %   coordinates (as given by incircle).
    %   Resets newclcat      Operates on cluscat in Cluster Menu
    %
    % Last modification 6/95
    global mess clu rad ni newt2 newclcat equi backequi bgevent backbgevent
    global original clust h5 xa0 ya0 backcat
    global button1 button2 button3 action_button
    global winx winy sys fontsz minmag par1 ccum file1
    global freq_field3 freq_field4 freq_field2 freq_field1

    disp('Please use the LEFT mouse button or the cursor to #select the center point. The coordinates of the center will be displayed on the control window.Operates on the main subset of the catalogue. Events selected form the new subset to operate on (newclcat).');
    figure_w_normalized_uicontrolunits(clu)
    axes(h5)
    a=equi;

    ni=str2double(get(freq_field1,'String'));
    rad=str2double(get(freq_field2,'String'));

    %Input of center of circle with mouse
    %
    if var1==7 | var1==8
        tt=2;
    else
        tt=1;
    end
    if var1==1 | var1==7
        [xa0,ya0]  = ginput(1);
        stri1 = [ 'Circle: lon = ' num2str(xa0) '; lat= ' num2str(ya0)];
        stri = stri1;
        pause(0.1)
        set(gcf,'Pointer','arrow')
        plot(xa0,ya0,'+c','EraseMode','back');
        set(freq_field3,'String',num2str(ya0));       %display in freq_fields of
        set(freq_field4,'String',num2str(xa0))         %chosen coordinates
        if get(button2,'value')==1
            var1=3;
            set(button3,'value',0)
        elseif  get(button3,'value')==0
            set(button2,'value',1);
            var1=3;
        else
            var1=4;
        end
    elseif var1==2   ||  var1==8
        xa0=str2double(get(freq_field4,'String'));
        ya0=str2double(get(freq_field3,'String'));
        if get(button2,'value')==1
            var1=3;
            set(button3,'value',0)
        elseif get(button3,'value')==0
            set(button2,'value',1);
            var1=3;
        else
            var1=4;
        end
    end
    %  calculate distance for each earthquake from center point
    %  and sort by distance
    %
    if var1==3
        ll = sqrt(((a.Longitude-xa0)*cos(pi/180*ya0)*111).^2 + ((a.Latitude-ya0)*111).^2) ;

        l = ll < rad;
        newt2 = a.subset(l);
        %
        % plot events on map as 'x':

        hold on
        if ~isempty(newt2)
            plos1 = plot(newt2.Longitude,newt2.Latitude,'xk','EraseMode','back');
            set(gcf,'Pointer','arrow')
        else
            var1==6;
        end


        %  calculate distance for each earthquake from center point
        %  and sort by distance   fixed ni
        %
    elseif var1==4
        l = sqrt(((a.Longitude-xa0)*cos(pi/180*ya0)*111).^2 + ((a.Latitude-ya0)*111).^2) ;

        [s,is] = sort(l);            % sort by distance
        new = a(is(:,1),:) ;

        newt = new(1:ni,:);          % take first ni and sort by time
        [st,ist] = sort(newt);
        newt2 = newt(ist(:,3),:);
        %
        % plot events on map as 'x':

        hold on
        if ~isempty(newt2);
            plos1 = plot(newt2.Longitude,newt2.Latitude,'xk','EraseMode','back');
        else
            var1==6;
        end
        set(gcf,'Pointer','arrow')

    end      % if var1=3 or 4

    if var1==6
        disp('There is no cluster in specified area')
    else
        if isempty(newclcat)  &&  isempty(backcat)
            backequi=equi;
            backbgevent=bgevent;
        end
        tmp=newt2(:,10)';
        tmpcat=clust(:,tmp);
        newclcat=original(tmpcat(find(clust(:,tmp))),:);
        bgevent=backbgevent(tmp',:);
        equi=backequi(tmp',:);
        cluoverl(7);
        if tt==1
            cltiplot(1);
        elseif tt==2
            cltiplot(2);
        end
    end
