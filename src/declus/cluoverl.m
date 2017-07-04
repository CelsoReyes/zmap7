function cluoverl(var1)
    %cluoverl.m                             A.Allmann
    %orption to display equivalent events or biggest events or clear cluster events
    %Last modification 9/95

    global bgevent plot1_h plot2_h  equi cluscat backequi newclcat a
    global dplo1_h dplo2_h dplo3_h dep1 dep2 dep3
    global par1 file1 clu h5
    global ms6 ty stri2 strib
    global after_h fore_h main_h ttcat after_button fore_button
    global foresh aftersh mainsh calll66
    global mainfault main faults clus_button coastline maepi
    global SizMenu TypMenu new



    if var1==1                            %hide biggest events
        set(plot1_h,'Visible','off')
    elseif var1==2                         %plot biggest evens
        if isempty(plot1_h)>0                 %first time
            plot1_h=plot(bgevent(:,1),bgevent(:,2),'xm');
            set(plot1_h,'MarkerSize',5)
            set(plot1_h,'LineWidth',2)
        else
            set(plot1_h,'Visible','on')     %show plot that already exists(biggest events)
        end
    elseif var1==3                    %plot equivalent events
        if isempty(plot2_h)>0
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
        if isempty(newclcat);
            a=cluscat;
        else
            a=newclcat;
        end
        cla
        set(gca,'Visible','off')
        hold off
        minde = 0.;
        maxde = max(a.Depth);

        dep1 = round(0.333*maxde);
        dep2 = round(0.666*maxde);
        dep3 = maxde;

        stri1 = [file1];


        % find min and Maximum axes points
        s1 = max(a.Longitude);
        s2 = min(a.Longitude);
        s3 = max(a.Latitude);
        s4 = min(a.Latitude);
        ni = 100;
        orient landscape
        rect = [0.15,  0.12, 0.75, 0.75];
        axes('position',rect)
        %
        % find start and end time of catalogue "a"
        %
        t0b = min(a.Date);
        n = a.Count;
        teb = a(n,3) ;
        tdiff = round(teb - t0b)*365/par1;


        n = length(a);

        % plot earthquakes (differnt colors for varous depth layers) as
        % defined in "startzmap"
        %
        hold on
        dplo1_h =plot(a(a.Depth<=dep1,1),a(a.Depth<=dep1,2),'.b');
        set(dplo1_h,'MarkerSize',ms6,'Marker',ty)
        dplo2_h =plot(a(a.Depth<=dep2&a.Depth>dep1,1),a(a.Depth<=dep2&a.Depth>dep1,2),'.y');
        set(dplo2_h,'MarkerSize',ms6,'Marker',ty);
        dplo3_h =plot(a(a.Depth<=dep3&a.Depth>dep2,1),a(a.Depth<=dep3&a.Depth>dep2,2),'.r');set(dplo3_h,'MarkerSize',ms6,'Marker',ty)

        axis([ s2 s1 s4 s3])
        xlabel('Longitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        ylabel('Latitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        if isempty(backequi)
            strib = [  ' Map of   '  file1 ];
            %ti2 =  title2(strib,'FontWeight','bold',...
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
        a=ttcat;
        cla
        set(gca,'visible','off')
        hold off
        s1 = max(a.Longitude);       %limits for area plot
        s2 = min(a.Longitude);
        s3 = max(a.Latitude);
        s4 = min(a.Latitude);
        if s1==s2                %to avoid error when all earthquakes have
            s1=s1+0.05;              %same longitude and/or latitude
            s2=s2-0.05;
        end
        if s3==s4
            s3=s3+0.05;
            s4=s4-0.05;
        end
        orient landscape
        rect = [0.15,  0.12, 0.75, 0.75];
        axes('position',rect)
        %
        % find start and end time of catalogue "a"
        %
        t0b = min(a.Date);
        n = a.Count;
        teb = a(n,3) ;
        tdiff = round(teb - t0b)*365/par1;
        %define fore and aftershocks
        %
        tmp = find(a.Magnitude==max(a.Magnitude));     %index in a of first mainshock
        if length(tmp)>1
            tmp=tmp(1,1);
        end
        overlay;
        %plot fore and aftershocks in different colors
        %
        hold on
        if tmp-1>=1
            fore_h=plot(a(1:tmp-1,1),a(1:tmp-1,2),'.b');
            if isempty(aftersh)                           %only at first call
                foresh=a(1:tmp-1,:);
            end
        else
            if exist('fore_h')
                fore_h=[];
            end
        end
        main_h=plot(a(tmp,1),a(tmp,2),'xm');
        mainsh=a.subset(tmp);
        set(main_h,'MarkerSize',10);
        set(main_h,'LineWidth',2);
        if tmp+1<=n
            after_h=plot(a(tmp+1:n,1),a(tmp+1:n,2),'.r');
            if isempty(aftersh)
                aftersh=a(tmp+1:n,:);
            end
        else
            if exist('after_h')
                after_h=[];
            end
        end
        set(after_button,'value',1);
        set(fore_button,'value',1);
        axis([ s2 s1 s4 s3])
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



