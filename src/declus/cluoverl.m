function cluoverl(var1)
    %cluoverl option to display equivalent events or biggest events or clear cluster events
    %                           A.Allmann
    
    %

    global bgevent plot1_h plot2_h  
    global equi %[IN]
    global cluscat backequi newclcat a
    global dplo1_h dplo2_h dplo3_h dep1 dep2 dep3
    global  file1 clu h5
    global ty stri2 strib
    global after_h fore_h main_h after_button fore_button
    global foresh aftersh mainsh calll66
    global mainfault main faults clus_button coastline
    global SizMenu TypMenu new
    ZG=ZmapGlobal.Data;


    if var1==1                            %hide biggest events
        set(plot1_h,'Visible','off')
    elseif var1==2                         %plot biggest evens
        if isempty(plot1_h)                 %first time
            plot1_h=plot(bgevent(:,1),bgevent(:,2),'xm');
            set(plot1_h,'MarkerSize',5)
            set(plot1_h,'LineWidth',2)
        else
            set(plot1_h,'Visible','on')     %show plot that already exists(biggest events)
        end
    elseif var1==3                    %plot equivalent events
        if isempty(plot2_h)
            plot2_h=plot(equi(:,1),equi(:,2),'xg');
            set(plot2_h,'MarkerSize',5)
            set(plot2_h,'LineWidth',2)
        else
            set(plot2_h,'Visible','on')
        end
    elseif var1==4                  %hide equivalent events
        set(plot2_h,'Visible','off')
    elseif var1==5                  %hide clustered events
        set(dplo1_h,'Visible','off')
        set(dplo2_h,'Visible','off')
        set(dplo3_h,'Visible','off')
    elseif var1==6                  %show clustered events
        set(dplo1_h,'Visible','on')
        set(dplo2_h,'Visible','on')
        set(dplo3_h,'Visible','on')

    elseif var1==7                  %plot clusters and faults for the first time
        set(clus_button,'Value',1)
        if isempty(newclcat)
            replaceMainCatalog(cluscat);
        else
            replaceMainCatalog(newclcat);
        end
        cla
        set(gca,'Visible','off')
        set(gca,'NextPlot','replace')
        minde = 0.;
        maxde = max(ZG.primeCatalog.Depth);

        dep1 = round(0.333*maxde);
        dep2 = round(0.666*maxde);
        dep3 = maxde;

        stri1 = [file1];


        % find min and Maximum axes points
        s1_east = max(ZG.primeCatalog.Longitude);
        s2_west = min(ZG.primeCatalog.Longitude);
        s3_north = max(ZG.primeCatalog.Latitude);
        s4_south = min(ZG.primeCatalog.Latitude);
        ni = ZG.ni;
        orient landscape
        rect = [0.15,  0.12, 0.75, 0.75];
        axes('position',rect)
        %
        % find start and end time of catalogue "primeCatalog"
        %
        [t0b, teb] = bounds(ZG.primeCatalog.Date) ;
        n = ZG.primeCatalog.Count;
        tdiff = round(teb - t0b)/days(ZG.bin_dur);


        n = ZG.primeCatalog.Count;

        % plot earthquakes (differnt colors for varous depth layers) as
        % defined in "startzmap"
        %
        set(gca,'NextPlot','add')
        dplo1_h =plot(...
            ZG.primeCatalog.Longitude(ZG.primeCatalog.Depth<=dep1),...
            ZG.primeCatalog.Latitude(ZG.primeCatalog.Depth<=dep1),'.b');
        set(dplo1_h,'MarkerSize',ZG.ms6,'Marker',ty)
        dplo2_h =plot(...
            ZG.primeCatalog.Longitude(ZG.primeCatalog.Depth<=dep2&ZG.primeCatalog.Depth>dep1),...
            ZG.primeCatalog.Latitude(ZG.primeCatalog.Depth<=dep2&ZG.primeCatalog.Depth>dep1),'.y');
        set(dplo2_h,'MarkerSize',ZG.ms6,'Marker',ty);
        dplo3_h =plot(...
            ZG.primeCatalog.Longitude(ZG.primeCatalog.Depth<=dep3&ZG.primeCatalog.Depth>dep2),...
            ZG.primeCatalog.Latitude(ZG.primeCatalog.Depth<=dep3&ZG.primeCatalog.Depth>dep2),'.r');
        set(dplo3_h,'MarkerSize',ZG.ms6,'Marker',ty)

        axis([ s2_west s1_east s4_south s3_north])
        xlabel('Longitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        ylabel('Latitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        if isempty(backequi)
            strib = [  ' Map of   '  file1 ];
            %ti2 =  title(strib,'FontWeight','bold',...
            %             'FontSize',ZmapGlobal.Data.fontsz.l,'Color','r')
        else
            delete ti2;
        end
        %make depth legend
        %
        s = sprintf('Depth < %3.1f km',dep1);
        text('Color','b','units','normalized', 'Position',[0.05 0.15 0 ],...
            'FontSize',ZmapGlobal.Data.fontsz.m,'String',s);
        s = sprintf('Depth < %3.1f km',dep2);
        text('Color','y','units','normalized', 'Position',[0.05 0.10 0 ],...
            'FontSize',ZmapGlobal.Data.fontsz.m,'String',s);
        s = sprintf('Depth < %3.1f km',dep3);
        text('Color','r','units','normalized', 'Position',[0.05 0.05 0 ],...
            'FontSize',ZmapGlobal.Data.fontsz.m,'String',s);

        %  h5 is the graphic handle to the main figure in window 1
        %
        h5 = gca;
        set(gca,'box','on',...
            'SortMethod','childorder','TickDir','out','FontWeight',...
            'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)

        %
        %  Plots epicenters  and faults

        overlay

        % Make the figure visible
        %
    elseif var1==8
        replaceMainCatalog(ZG.ttcat);
        cla
        set(gca,'visible','off')
        set(gca,'NextPlot','replace')
        s1_east = max(ZG.primeCatalog.Longitude);       %limits for area plot
        s2_west = min(ZG.primeCatalog.Longitude);
        s3_north = max(ZG.primeCatalog.Latitude);
        s4_south = min(ZG.primeCatalog.Latitude);
        if s1_east==s2_west                %to avoid error when all earthquakes have
            s1_east=s1_east+0.05;              %same longitude and/or latitude
            s2_west=s2_west-0.05;
        end
        if s3_north==s4_south
            s3_north=s3_north+0.05;
            s4_south=s4_south-0.05;
        end
        orient landscape
        rect = [0.15,  0.12, 0.75, 0.75];
        axes('position',rect)
        %
        % find start and end time of catalogue "primeCatalog"
        %
        [t0b, teb] = bounds(ZG.primeCatalog.Date) ;
        n = ZG.primeCatalog.Count;
        tdiff = round(teb - t0b)/days(ZG.bin_dur);
        %define fore and aftershocks
        %
        tmp = find(ZG.primeCatalog.Magnitude==max(ZG.primeCatalog.Magnitude));     %index in a of first mainshock
        if length(tmp)>1
            tmp=tmp(1,1);
        end
        overlay;
        %plot fore and aftershocks in different colors
        %
        set(gca,'NextPlot','add')
        if tmp-1>=1
            fore_h=plot(ZG.primeCatalogLongitude(1:tmp-1),ZG.primeCatalog.Latitude(1:tmp-1),'.b');
            if isempty(aftersh)                           %only at first call
                foresh=aZG.primeCatalog.subset(1:tmp-1);
            end
        else
            if exist('fore_h')
                fore_h=[];
            end
        end
        main_h=plot(ZG.primeCatalog.Longitude(tmp),ZG.primeCatalog.Latitude(tmp),'xm');
        mainsh=ZG.primeCatalog.subset(tmp);
        set(main_h,'MarkerSize',10);
        set(main_h,'LineWidth',2);
        if tmp+1<=n
            after_h=plot(ZG.primeCatalog.Longitude(tmp+1:n),ZG.primeCatalog.Latitude(tmp+1:n),'.r');
            if isempty(aftersh)
                aftersh=ZG.primeCatalog.subset(tmp+1:n);
            end
        else
            if exist('after_h')
                after_h=[];
            end
        end
        set(after_button,'value',1);
        set(fore_button,'value',1);
        axis([ s2_west s1_east s4_south s3_north])
        xlabel('Longitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        ylabel('Latitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        strib = [  ' Map of   '  file1 ' #' num2str(new(10))];
        title(strib,'FontWeight','bold',...
            'FontSize',ZmapGlobal.Data.fontsz.l,'Color','r')
        set(gca,'box','on',...
            'SortMethod','childorder','TickDir','out','FontWeight',...
            'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)


        set(gca,'visible','on')
    end




