function cldepcut(var1)
    %cldepcut.m                             A.Allmann
    %function to select onsy clusters which equivalen events belong to a
    %certain depth range
    %or eqs of a single cluster in a certain depth range
    %
    %Last modification 6/95

   global mess te1  sys
    global tmp1 tmp2 cluslength ttcat tt1cat clu1
    global freq_field1 freq_field2 close_button go_button
    global backbgevent original equi bgevent backequi clu newclcat backcat
    global equi_button bg_button
    global plot1_h plot2_h file1 clust new


    if var1==1  | var1==2
        figure_w_normalized_uicontrolunits(mess)
        clf
        set(gca,'visible','off');
        set(gcf,'visible','off');
        set(gcf,'Name','Depth Selection');

        if var1==1
            tmp2=min(equi(:,7));
        else
            tmp2=min(ttcat(:,7));
        end
        freq_field1= uicontrol('Style','edit',...
            'Position',[.70 .60 .17 .10],...
            'Units','normalized','String',num2str(tmp2),...
            'Callback','tmp2=str2double(get(freq_field1,''String'')); set(freq_field1,''String'',num2str(tmp2));');

        if var1==1
            tmp1=max(equi(:,7));
        else
            tmp1=max(ttcat(:,7));
        end
        freq_field2=uicontrol('Style','edit',...
            'Position',[.70 .40 .17 .10],...
            'Units','normalized','String',num2str(tmp1),...
            'Callback','tmp1=str2double(get(freq_field2,''String'')); set(freq_field2,''String'',num2str(tmp1));');


        close_button=uicontrol('Style','Pushbutton',...
            'Position', [.60 .05 .15 .15 ],...
            'Units','normalized','Callback','welcome;done','String','Cancel');

        if var1==1
            go_button=uicontrol('Style','Pushbutton',...
                'Position',[.25 .05 .15 .15 ],...
                'Units','normalized',...
                'Callback','welcome;done;cldepcut(3);',...
                'String','Go');
        else
            go_button=uicontrol('Style','Pushbutton',...
                'Position',[.25 .05 .15 .15 ],...
                'Units','normalized',...
                'Callback','welcome;done;cldepcut(4);',...
                'String','Go');
        end

        txt1 = text(...
            'Color',[0 0 0 ],...
            'EraseMode','normal',...
            'Position',[0. 0.65 0 ],...
            'Rotation',0 ,...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold' ,...
            'String','Minimum Depth in Cluster:');

        txt2 = text(...
            'Color',[0 0 0 ],...
            'EraseMode','normal',...
            'Position',[0. 0.40 0 ],...
            'Rotation',0 ,...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold' ,...
            'String','Maximum Depth in Cluster:');

        set(gcf,'visible','on')

    elseif var1==3
        figure_w_normalized_uicontrolunits(clu);
        if isempty(newclcat)  &&  isempty(backcat)   %no selection before
            backequi=equi;
            backbgevent=bgevent;
        end
        tt=find(equi(:,7)>=tmp2 & equi(:,7)<=tmp1);
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
        ttcat=ttcat(find(ttcat(:,7)>=tmp2 & ttcat(:,7)<=tmp1),:);
        cluoverl(8);
        strib=[' Polygon of  ' file1 ' #' num2str(new(10))];
        hold on
        title(strib,'FontWeight','bold',...
            'FontSize',ZmapGlobal.Data.fontsz.l,'Color','r')

    end



