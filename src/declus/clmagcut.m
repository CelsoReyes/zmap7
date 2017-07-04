function clmagcut(var1)
    %clmagcut.m                                 A.Allmann
    %function to select only clusters which equivalent events belong to a
    %certain magnitude range
    %or eqs of a single cluster in a certain depth range
    %
    %Last modification 6/95


   global mess te1  sys
    global tmp1 tmp2 cluslength clsel ttcat tt1cat
    global freq_field1 freq_field2 close_button go_button
    global backbgevent original equi bgevent backequi clu newclcat backcat
    global equi_button bg_button
    global plot1_h plot2_h file1 clust clu1 new


    if var1==1 | var1==2
        figure_w_normalized_uicontrolunits(mess)
        clf
        set(gca,'visible','off');
        set(gcf,'visible','off');
        set(gcf,'Name','Magnitude Selection');

        if var1==1
            tmp2=min(equi(:,6));
        else
            tmp2=min(ttcat(:,6));
        end
        freq_field1= uicontrol('Style','edit',...
            'Position',[.80 .60 .17 .10],...
            'Units','normalized','String',num2str(tmp2),...
            'Callback','tmp2=str2double(get(freq_field1,''String'')); set(freq_field1,''String'',num2str(tmp2));');

        if var1==1
            tmp1=max(equi(:,6));
        else
            tmp1=max(ttcat(:,6));
        end
        freq_field2=uicontrol('Style','edit',...
            'Position',[.80 .40 .17 .10],...
            'Units','normalized','String',num2str(tmp1),...
            'Callback','tmp1=str2double(get(freq_field2,''String'')); set(freq_field2,''String'',num2str(tmp1));');


        close_button=uicontrol('Style','Pushbutton',...
            'Position', [.60 .05 .15 .15 ],...
            'Units','normalized','Callback','welcome;done','String','Cancel');

        if var1==1
            go_button=uicontrol('Style','Pushbutton',...
                'Position',[.25 .05 .15 .15 ],...
                'Units','normalized',...
                'Callback','welcome;done;clmagcut(3);',...
                'String','Go');

        else
            go_button=uicontrol('Style','Pushbutton',...
                'Position',[.25 .05 .15 .15 ],...
                'Units','normalized',...
                'Callback','welcome;done;clmagcut(4);',...
                'String','Go');

        end

        txt1 = text(...
            'Color',[0 0 0 ],...
            'EraseMode','normal',...
            'Position',[0. 0.65 0 ],...
            'Rotation',0 ,...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold' ,...
            'String','Minimum Magnitude in Cluster:');

        txt2 = text(...
            'Color',[0 0 0 ],...
            'EraseMode','normal',...
            'Position',[0. 0.40 0 ],...
            'Rotation',0 ,...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold' ,...
            'String','Maximum Magnitude in Cluster:');
        set(gcf,'visible','on')

    elseif var1==3
        figure_w_normalized_uicontrolunits(clu);
        if isempty(newclcat)  &&  isempty(backcat)   %no selection before
            backequi=equi;
            backbgevent=bgevent;
        end
        tt=find(equi(:,6)>=tmp2 & equi(:,6)<=tmp1);
        equi=equi(tt,:);
        bgevent=bgevent(tt,:);

        set(equi_button,'value',1)
        st1=get(equi_button,'Callback');
        eval(st1);
        pause(2);
        tmp=equi(:,10)';
        tmpcat=clust(:,tmp);
        newclcat=original(tmpcat(find(clust(:,tmp))),:);
        plot1_h=[];plot2_h=[];
        cluoverl(7);

        strib=[' Polygon of  ' file1];
        hold on
        title(strib,'FontWeight','bold',...
            'FontSize',ZmapGlobal.Data.fontsz.l,'Color','r')

    elseif var1==4
        figure_w_normalized_uicontrolunits(clu1);
        clsel=1;
        if isempty(tt1cat)
            tt1cat=ttcat;
        end
        ttcat=ttcat(find(ttcat(:,6)>=tmp2 & ttcat(:,6)<=tmp1),:);
        cluoverl(8);
        strib=[' Polygon of  ' file1 ' #' num2str(new(10))];
        hold on
        title(strib,'FontWeight','bold',...
            'FontSize',ZmapGlobal.Data.fontsz.l,'Color','r')

    end


