function sinclus(var1)
    %sinnclus.m              A.Allmann
    %function to load single cluster and make an interface to examine
    %the chosen cluster
    %
    %Last modification 11/95

    global dplo1_h dplo2_h dplo3_h dep1 dep2 dep3 histo
    global mess ccum bgevent equi file1 clust original cluslength newclcat
    global backcat ttcat cluscat
   global  sys minmag clu te1
    global freq_field1 freq_field2 go_button close_button
    global tmp1 tmp2 tmp3 tmp4 xt1
    global clu1 aftersh foresh mainsh
    global fore_button after_button clop1 clop2 clop3 clop4 clop5
    global after_h fore_h main_h bfig clsel pyy iwl3
    global new close_ti_button pplot cinfo p1 Info_p cplot par1
    global  freq_field3 freq_field4 Go_p_button
    global calll66 freq_field5
    global  tmm magn hpndl1 ctiplo
    global SizMenu TypMenu a backequi

    if var1==1      %interactive input of position by mouse
        figure_w_normalized_uicontrolunits(mess)
        clf
        set(gca,'visible','off')
        te=text(0.01, 0.90,'\newline \newlineClick with the left mouse button \newlinenext to the equivalent event \newlineof the cluster you want to examine');
        set(te,'FontSize',12);
        pause(.6)
        var1=5;

        figure_w_normalized_uicontrolunits(clmap)
        [tmp2,tmp1]=ginput(1);
        welcome;
    elseif var1==2             %coordinate input by windox
        figure_w_normalized_uicontrolunits(mess)
        clf
        set(gcf,'Name','Position Input')
        set(gcf,'visible','off')
        set(gca,'visible','off')
        tmp2=0;
        freq_field1 = uicontrol('Style','edit',...
            'Position',[.70 .60 .17 .10],...
            'Units','normalized','String',num2str(tmp2),...
            'Callback','tmp2=str2double(get(freq_field1,''String'')); set(freq_field1,''String'',num2str(tmp2));');

        tmp1=0;
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
            'Callback','welcome;done;sinclus(5);',...
            'String','Go');


        txt1 = text(...
            'Color',[0 0 0 ],...
            'EraseMode','normal',...
            'Position',[0. 0.65 0 ],...
            'Rotation',0 ,...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold' ,...
            'String','Longitude: ');

        txt2 = text(...
            'Color',[0 0 0 ],...
            'EraseMode','normal',...
            'Position',[0. 0.40 0 ],...
            'Rotation',0 ,...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold' ,...
            'String','Latitude: ');

        set(gcf,'visible','on')

    elseif var1==3              %input window for clusternumber
        figure_w_normalized_uicontrolunits(mess)
        clf
        set(gcf,'Name','Clusternumber Input')
        set(gcf,'visible','off')
        set(gca,'visible','off')
        tmp2=1;
        freq_field1 = uicontrol('Style','edit',...
            'Position',[.70 .60 .17 .10],...
            'Units','normalized','String',num2str(tmp2),...
            'Callback','tmp2=str2double(get(freq_field1,''String'')); set(freq_field1,''String'',num2str(tmp2));');

        close_button=uicontrol('Style','Pushbutton',...
            'Position', [.60 .05 .15 .15 ],...
            'Units','normalized','Callback','welcome;done','String','Cancel');
        go_button=uicontrol('Style','Pushbutton',...
            'Position',[.25 .05 .15 .15 ],...
            'Units','normalized',...
            'Callback','welcome;done;sinclus(4);',...
            'String','Go');

        txt1 = text(...
            'Color',[0 0 0 ],...
            'EraseMode','normal',...
            'Position',[0. 0.65 0 ],...
            'Rotation',0 ,...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold' ,...
            'String','Cluster Number');


        set(gcf,'visible','on')
    end
    if var1==4             %display of your choice in main window
        if isempty(backequi)
            new=equi(tmp2,:);
        else
            new=backequi(tmp2,:);
        end
        figure_w_normalized_uicontrolunits(clmap)
        mark1= plot(new(1,1),new(1,2),'xr','era','back');
        set(mark1,'MarkerSize',10,'LineWidth',1.5)
        pause(1);
        var1=6;
    elseif var1==5          %display of chosen equievent in main window
        x=tmp2;y=tmp1;
        figure_w_normalized_uicontrolunits(clmap);
        mark1 =    plot(x,y,'ko','era','back');
        set(mark1,'MarkerSize',7,'LineWidth',1.5)
        a=equi;
        l=sqrt(((a.Longitude-x)*cos(pi/180*y)*111).^2 + ((a.Latitude-y)*111).^2) ;
        [s,is] = sort(l);            % sort by distance
        new = a(is(1),:) ;
        mark2= plot(new(1,1),new(1,2),'xr','era','back');
        set(mark2,'MarkerSize',8,'LineWidth',1.5)
        pause(1)
        var1=6;
    end

    if var1==6              %build new catalog which contents all eqs that belong
        tt1cat=[]; aftersh=[]; foresh=[]; clsel=[];
        set(clu,'visible','off')
        tmpcat=clust(find(clust(:,new(1,10))),new(1,10));
        ttcat=original(tmpcat,:);
        [existFlag,figNumber]=figure_exists('Cluster',1);
        newClusterFlag=~existFlag;
        if newClusterFlag
            clu1=figure;
            set(gca,'visible','off');
            set(gcf,'NumberTitle','off','Name','Cluster','Position',[300 200 700 500]);

            %Menuline for options
            %
            %Workspace
            matdraw
            % Make the menu to change symbol size and type
            %
            symbolmenu = uimenu('Label',' Symbol ');
            SizMenu = uimenu(symbolmenu,'Label',' Symbol Size ');
            TypMenu = uimenu(symbolmenu,'Label',' Symbol Type ');
            uimenu(SizMenu,'Label','3','Callback','ms6 =6;eval(calll66)');
            uimenu(SizMenu,'Label','6','Callback','ms6 =9;eval(calll66)');
            uimenu(SizMenu,'Label','9','Callback','ms6 =9;eval(calll66)');
            uimenu(SizMenu,'Label','12','Callback','ms6 =12;eval(calll66)');
            uimenu(SizMenu,'Label','14','Callback','ms6 =14;eval(calll66)');
            uimenu(SizMenu,'Label','18','Callback','ms6 =18;eval(calll66)');
            uimenu(SizMenu,'Label','24','Callback','ms6 =24;eval(calll66)');

            uimenu(TypMenu,'Label','dot','Callback','ty =''.'';eval(calll66)');
            uimenu(TypMenu,'Label','+','Callback','ty=''+'';eval(calll66)');
            uimenu(TypMenu,'Label','o','Callback','ty=''o'';eval(calll66)');
            uimenu(TypMenu,'Label','x','Callback','ty=''x'';eval(calll66)');
            uimenu(TypMenu,'Label','*','Callback','ty=''*'';eval(calll66)');

            calll66 = ...
                [ 'if exist(''after_h'')set(after_h,''MarkerSize'',ms6,''LineStyle'',ty);end;',...
                'if exist(''fore_h'')set(fore_h,''MarkerSize'',ms6,''LineStyle'',ty);end;' ];

            %Select areas like in main program
            %
            clop2=uimenu('Label','Select');

            uimenu(clop2,'Label','Select EQ in Polygon -Menu',...
                'Callback','decc=3;clkeysel;');
            uimenu(clop2,'Label','Select EQ in Polygon',...
                'Callback','decc=3;clpickp(4);');
            uimenu(clop2,'Label','Select EQ in Circle -Menu',...
                'Callback','clcircle(2);');

            %Some tools
            %
            clop3=uimenu('Label','Tools');

            clop4=uimenu(clop3,'Label','Histogram');
            uimenu(clop4,'Label','Magnitude',...
                'Callback','hisgra(ttcat(:,6),''Magnitude '');');
            uimenu(clop4,'Label','Depth','Callback','hisgra(ttcat(:,7),''Depth '');');

            clopp3= uimenu(clop3,'Label','b-value');
            uimenu(clopp3,'label','manual','Callback','clbvalpl(1);');
            uimenu(clopp3,'label','automatic','Callback','clbdiff(1);');
            uimenu(clopp3,'label','with magnitude','Callback','global bcat nh ni dx dy;bvalmag(ttcat,1);');

            clopp1=uimenu(clop3,'Label','P-Value');
            uimenu(clopp1,'Label','manual','Callback','clpval(1);');
            %  uimenu(clopp1,'Label','automatic','Callback','clpval(4);');
            uimenu(clopp1,'label','with time', 'Callback','cltipval(2);');
            uimenu(clopp1,'label','with magnitude', 'Callback','cltipval(1);');

            uimenu(clop3,'Label','Plot Cumulative Number',...
                'Callback','cltiplot(2);');

            uimenu(clop3,'Label','Time-Magnitude Plot',...
                 'Callback','bcat=a;a=ttcat;TimeMagnitudePlotter.plot(newt2);a=bcat;bcat=[];');
            %Cut options
            %
            clop6=uimenu('Label','Cuts');

            uimenu(clop6,'Label','Magnitude Cut','Callback','clmagcut(2);');
            uimenu(clop6,'Label','Time Cut ','Callback','cluticut(2);');
            uimenu(clop6,'Label','Depth Cut','Callback','cldepcut(2);');


            %Display options
            %Parameters is output window with all important values of a cluster
            %
            clop5=uimenu('Label','Display');

            % uimenu(clop5,'Label','Parameters','Callback','clpara;');
            uimenu(clop5,'Label','Show Cluster Menu','Callback','set(clu,''visible'',''on'');');

            info_c=uicontrol('Units','normal',...
                'Position',[.01 .93 .06 .05],'String','Info',...
                'Style','Pushbutton','Callback','clinfo(3);');
            back_c=uicontrol('Units','normal',...
                'position',[.01 .85 .06 .05],'String','Back',...
                'Style','Pushbutton','Callback','if ~isempty(tt1cat),ttcat=tt1cat;clsel=[];cluoverl(8);set(fore_button,''value'',1);set(after_button,''value'',1);end;');
            close_c=uicontrol('Units','normal',...
                'position',[.01 .77 .06 .05],'String','Close',...
                'Style','Pushbutton','Callback','ttcat=[];tt1cat=[];aftersh=[];foresh=[];clsel=[];set(clu1,''visible'',''off'');set(clu,''visible'',''on'');figure_w_normalized_uicontrolunits(clu);');
            print_c=uicontrol('Units','normal',...
                'position',[.01 .69 .06 .05],'String','Print',...
                'Style','Pushbutton','Callback','myprint');


            fore_button = uicontrol('Units','normal',...
                'Position',[.9 .93 .08 .06],'String','Fore',...
                'Style','check',...
                'Callback','if isempty(clsel), if ~isempty(foresh),if get(fore_button,''value'')==1,,set(fore_h,''visible'',''on'');if get(after_button,''value'')==0,if isempty(tt1cat),tt1cat=ttcat;end;ttcat=foresh;else,if ~isempty(tt1cat),ttcat=tt1cat;tt1cat=[];end;end;else,if get(after_button,''value'')==1,if isempty(tt1cat),tt1cat=ttcat;end;ttcat=[mainsh;aftersh];else,if isempty(tt1cat),tt1cat=ttcat;end;ttcat=mainsh;end; set(fore_h,''visible'',''off'');end;end;end;');
            after_button =uicontrol('Units','normal',...
                'Position',[.8 .93 .08 .06],'String','After',...
                'Style','check','Callback','if isempty(clsel),if ~isempty(aftersh),if get(after_button,''value'')==1,set(after_h,''visible'',''on'');if get(fore_button,''value'')==0,if isempty(tt1cat),tt1cat=ttcat;end;ttcat=[mainsh;aftersh];else,if ~isempty(tt1cat),ttcat=tt1cat;tt1cat=[];end;end;else,if get(fore_button,''value'')==1,if isempty(tt1cat),tt1cat=ttcat;end;ttcat=foresh;else,if isempty(tt1cat),tt1cat=ttcat;end;ttcat=mainsh;end;set(after_h,''visible'',''off'');end;end;end;');
        else
            figure_w_normalized_uicontrolunits(clu1);
            set(clu1,'visible','on')
            cla
        end
        cluoverl(8);
        overlay_;
        par1= (ttcat(length(ttcat(:,1)),3)-ttcat(1,3))/100*365;
        if par1 < 0.5 & par1 >= 0.1
            par1=0.1;
        elseif par1 < 0.1
            par1 = 0.02;
        else
            par1 = round(par1);
        end

    end

