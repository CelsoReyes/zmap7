function bigclu(var1)
    %bigclu.m                     A.Allmann
    %function to select only clusters with spezial number values
    %
    % Last modification 8/95
   global mess te1  sys
    global tmp1 tmp2 cluslength
    global freq_field1 freq_field2 close_button go_button
    global backbgevent original equi bgevent backequi clu newclcat backcat
    global equi_button bg_button
    global plot1_h plot2_h file1 clust


    if var1==1
        figure_w_normalized_uicontrolunits(mess)
        clf
        set(gca,'visible','off');
        set(gcf,'visible','off');
        set(gcf,'Name','Number Selection');
        cltemp=cluslength(equi(:,10));
        tmp2=min(cltemp);
        freq_field1= uicontrol('Style','edit',...
            'Position',[.70 .60 .17 .10],...
            'Units','normalized','String',num2str(tmp2),...
            'Callback','tmp2=str2double(get(freq_field1,''String'')); set(freq_field1,''String'',num2str(tmp2));');

        tmp1=max(cltemp);
        freq_field2=uicontrol('Style','edit',...
            'Position',[.70 .40 .17 .10],...
            'Units','normalized','String',num2str(tmp1),...
            'Callback','tmp1=str2double(get(freq_field2,''String'')); set(freq_field2,''String'',num2str(tmp1));');

        close_button=uicontrol('Style','Pushbutton',...
            'Position', [.60 .05 .15 .15 ],...
            'Units','normalized','Callback','welcome;done','String','Cancel');
        go_button=uicontrol('Style','Pushbutton',...
            'Position',[.25 .05 .15 .15 ],...
            'Units','normalized',...
            'Callback','welcome;done;bigclu(3);',...
            'String','Go');


        txt1 = text(...
            'Color',[0 0 0 ],...
            'EraseMode','normal',...
            'Position',[0. 0.65 0 ],...
            'Rotation',0 ,...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold' ,...
            'String','Minimum Events in Cluster:');

        txt2 = text(...
            'Color',[0 0 0 ],...
            'EraseMode','normal',...
            'Position',[0. 0.40 0 ],...
            'Rotation',0 ,...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold' ,...
            'String','Maximum Events in Cluster:');

        set(gcf,'visible','on')

    elseif var1==3
        figure_w_normalized_uicontrolunits(clu);
        if isempty(newclcat)  &&  isempty(backcat)   %no selection before
            backequi=equi;
            backbgevent=bgevent;
        end
        tt= find(cluslength>=tmp2 & cluslength<=tmp1);
        for j= tt
            tt1=find(equi(:,10)==j);
            if isempty(tt1)
                tt1=0;
            end
            tt2(j)=tt1;
        end
        tmp=find(tt2);
        equi=backequi(tmp,:);
        bgevent=backbgevent(tmp,:);

        set(equi_button,'value',1)
        st1=get(equi_button,'Callback');
        eval(st1);
        pause(2);
        tmpcat=clust(:,tmp);
        newclcat=original(tmpcat(find(clust(:,tmp))),:);
        plot1_h=[];plot2_h=[];
        cluoverl(7);

        strib=[' Polygon of  ' file1];
        hold on
        title(strib,'FontWeight','bold',...
            'FontSize',ZmapGlobal.Data.fontsz.l,'Color','r')

    end

