function clpval(var1)
    % clpval function to calculate the parameters of the modified Omori Law
    %  A.Allmann
    %
    % this function is a modification of a program by Paul Raesenberg
    % that is based on Programs by Carl Kisslinger and Yoshi Ogata
    
    % function finds the maximum liklihood estimates of p,c and k, the
    % parameters of the modifies Omori equation
    % it also finds the standard deviations of these parameters
    %
    % Input: Earthquake Catalog of an Cluster Sequence
    %
    % Output: p c k values of the modified Omori Law with respective
    %         standard deviations
    %         A and B values of the Gutenberg Relation based on k
    %
    % Create an input window for magnitude thresholds and
    % plot cumulative number versus time to allow input of start and end
    % time
    
    
    global file1
    global mess bgevent clust original newclcat
    global backcat cluscat
    global  clu te1
    global clu1 pyy tmp1 tmp2 tmp3 tmp4 difp
    global xt cumu cumu2
    global close_p_button pplot
    global freq_field1 freq_field2 freq_field3 freq_field4 Go_p_button
    global h2 cplot Info_p close_p  print_p
    global p c dk tt pc loop nn pp nit t err1x err2x ieflag isflag
    global cstep pstep tmpcat ts tend eps1 eps2
    global sdc sdk sdp cof qp cog aa bb pcheck loopcheck
    global ppc  cplot2 hndl1
    global autop tmeqtime tmvar
    tmvar=[];
    %input of parameters(Magnitude,Time)
    if var1==1  | var1==3 | var1==4  | var1==5
        pplot=findobj('Type','Figure','-and','Name','P-Value Plot');
        if ~isempty(pplot)
            figure(pplot);
            clf
        else
            if var1==3 | var1==4
                ppc=1;
            end
            pplot=figure_w_normalized_uicontrolunits(...
                'Name','P-Value Plot',...
                'NumberTitle','off',...
                'NextPlot','new',...
                'visible','off',...
                'Units','normalized',...
                'Position',[ 0.435  0.8 0.5 0.8]);
            axis off
        end
        
        axis off
        
        ZG.newt2=ZG.ttcat;              %function operates with single cluster
        autop=0;
        if var1==4
            autop=1;
        end
        %calculate start -end time of overall catalog
        [t0b, teb] = ZG.newt2.DateRange() ;
        tdiff=days(teb-t0b);       %time difference in days
        
        par3=tdiff/100;
        
        par5=par3;
        if par5>.5
            par5=par5/5;
        end
        
        % calculate cumulative number versus time and bin it
        %
        n = ZG.newt2.Count;
        if par3>=1
            [cumu, xt] = hist(ZG.newt2.Date, t0b:days(par3):teb);
        else
            [cumu, xt] = hist(ZG.newt2.Date-min(ZG.newt2.Date), 0:par5:tdiff);
        end
        if var1==3 | var1==4
            difp= [0 diff(cumu)];
        end
        cumu2 = cumsum(cumu);
        
        % plot time series
        %
        orient tall
        axis off
        rect = [0.22,  0.5, 0.55, 0.45];
        cplot=axes('position',rect);
        hold on
        ctiplo = plot(xt,cumu2,'ob');
        set(gca,'visible','off')
        cplot2 = plot(xt,cumu2,'r');
        if var1==3  | var1==4
            plot(xt,difp/10,'g');
        end
        
        
        if exist('stri', 'var')
            v = axis;
            tea = text(v(1)+0.5,v(4)*0.9,stri) ;
            set(tea,'FontSize',ZmapGlobal.Data.fontsz.m,'Color','k','FontWeight','bold')
            %else
            % strib = [file1];
        end %% if stri
        
        %strib = [file1];
        
        %title(strib,'FontWeight','bold',...
        %'FontSize',14,...
        %'Color','r')
        
        grid
        if par3>=1
            xlabel('Time in years ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        else
            xlabel(['Time in days relative to ',num2str(t0b)],'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        end
        ylabel('Cumulative Number ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        
        % Make the figure visible
        %
        set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
            'FontWeight','bold','LineWidth',1.5,...
            'Box','on')
        
        gcf;
        rect=[0 0 1 1];
        h2=axes('Position',rect);
        set(h2,'visible','off');
        if var1==1
            str =  ['\newline \newline \newlinePlease select start and end time of the P-Value plot\newlineClick first with the left Mouse Button at your start position\newlineand then with the left Mouse Button at the end position'];
            te = text(0.2,0.37,str) ;
            
            set(te,'FontSize',14);
            set(pplot,'Visible','on');
            
            disp('Please select start and end time of the P-value plot. Click first with the left Mouse Button at your start position and then at the end position.')
            
            
            seti = uicontrol('Units','normal',...
                'Position',[.4 .01 .2 .05],'String','Select Time1 ');
            
            
            XLim=get(cplot,'XLim');
            
            
            M1b = [];
            M1b= ginput(1);
            tt3= M1b(1);
            tt4=num2str((tt3-0.22)*(1/.55)*(XLim(2)-XLim(1))+XLim(1));
            text( M1b(1),M1b(2),['|: T1=',tt4] )
            set(seti,'String','Select Time2');
            
            pause(0.1)
        else
            nn_=find(difp==max(difp));
            nnn=nn_(1,1)-2;
        end
        if var1==3
            tmvar=1;           %temperal variable
            if par3>=1
                tmp3=t0b+nnn*days(par3);
            else
                tmp3=nnn*par5;
            end
            str = ['\newline \newline \newlinePlease select the end time of the P-value plot.\newlineClick with the left Mouse Button at you end position'];
            te = text(0.15,0.37,str) ;
            set(te,'FontSize',14);
            set(pplot,'Visible','on');
            disp('Please select the end time of the P-value plot. Click with the left   mouse button at your end position.')
            XLim=get(cplot,'XLim');
        end
        if var1==1 | var1==3
            M2b = [];
            M2b = ginput(1);
            tt3= M2b(1);
            tt5=num2str((tt3-0.22)*(XLim(2)-XLim(1))*(1/.55)+XLim(1));
            text( M2b(1),M2b(2),['|: T2=',tt5] )
            
            pause(0.1)
            delete(seti)
            
            watchoff
            watchoff
            
            set(te,'visible','off');
            
            tmp2=min(ZG.ttcat(:,6));
            freq_field1= uicontrol('Style','edit',...
                'Position',[.70 .35 .1 .04],...
                'Units','normalized','String',num2str(tmp2),...
                'callback',@callbackfun_001);
            
            tmp1=max(ZG.ttcat(:,6));
            freq_field2=uicontrol('Style','edit',...
                'Position',[.70 .28 .1 .04],...
                'Units','normalized','String',num2str(tmp1),...
                'callback',@callbackfun_002);
            
            if var1==1
                tmp3=str2double(tt4);
                if tmp3 < 0
                    tmp3=0;
                end
            end
            freq_field3=uicontrol('Style','edit',...
                'Position',[.70 .21 .1 .04],...
                'Units','normalized','String',num2str(tmp3),...
                'callback',@callbackfun_003);
            
            tmp4=str2double(tt5);
            freq_field4=uicontrol('Style','edit',...
                'Position',[.70 .14 .1 .04],...
                'Units','normalized','String',num2str(tmp4),...
                'callback',@callbackfun_004);
            
            
            
            txt1 = text(...
                'Position',[0.15 0.37 h2 ],...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'FontWeight','bold' ,...
                'String','Minimum Magnitude used for P-Value:');
            
            txt2 = text(...
                'Position',[0.15 0.30 h2],...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'FontWeight','bold' ,...
                'String','Maximum Magnitude used for P-Value:');
            
            
            txt3 = text(...
                'Position',[0.15 0.23 h2 ],...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'FontWeight','bold' ,...
                'String','Minimum Time used for P-Value:');
            
            txt4 = text(...
                'Position',[0.15 0.16 h2],...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'FontWeight','bold' ,...
                'String','Maximum Time used for P-Value:');
            
            Info_p = uicontrol('Style','Pushbutton',...
                'String','Info ',...
                'Position',[.3 .05 .10 .06],...
                'Units','normalized','callback',@callbackfun_005);
            
            
            
            
            
            
            close_p =uicontrol('Style','Pushbutton',...
                'Position', [.45 .05 .10 .06 ],...
                'Units','normalized','callback',@callbackfun_006,...
                'String','Close');
            print_p = uicontrol('Style','Pushbutton',...
                'Position',[.15 .05 .1 .06],...
                'Units','normalized','Callback', 'myprint',...
                'String','Print');
            
            labelList=['Mainshock| Main-Input| Sequence' ];
            if var1==3
                labelList=['Sequence'];
            end
            labelPos= [.6 .05 .2 .06];
            hndl1 =uicontrol(...
                'style','popup',...
                'units','normalized',...
                'position',labelPos,...
                'string',labelList,...
                'callback',@callbackfun_007);
            
            figure(mess);
            clf;
            str =  ['\newline \newline \newlinePlease give in parameters in green fields\newlineThis parameters will be used as the threshold\newline for the P-Value.\newlineAfter input push GO to continue. '];
            te = text(0.01,0.9,str) ;
            
            set(te,'FontSize',12);
            set(gca,'visible','off');
        end
        if autop==1
            figure(pplot);
            Info_p = uicontrol('Style','Pushbutton',...
                'String','Info ',...
                'Position',[.3 .05 .10 .06],...
                'Units','normalized','callback',@callbackfun_008);
            
            close_p =uicontrol('Style','Pushbutton',...
                'Position', [.45 .05 .10 .06 ],...
                'Units','normalized','callback',@callbackfun_009,...
                'String','Close');
            print_p = uicontrol('Style','Pushbutton',...
                'Position',[.15 .05 .1 .06],...
                'Units','normalized','Callback', 'myprint',...
                'String','Print');
            
            
            clpval(8);
            
        end
        
        
        %cumputation part after parameter input
    elseif var1==8   ||  var1==6  ||  var1==7
        %set the error test values
        eps1=.0005;
        eps2=.0005;
        
        %set the parameter starting values
        PO=1.1;
        CO=0.1;
        
        %set the initial step size
        pstep=.05;
        cstep=.1;
        pp=PO;
        pc=CO;
        nit=0;
        ieflag=0;
        isflag=0;
        pcheck=false;
        err1x=0;
        err2x=0;
        ts=0.0000001;
        if autop ~= 1             %input was manual
            
            %Build timecatalog
            
            mains=find(ZG.ttcat(:,6)==max(ZG.ttcat(:,6)));
            mains=ZG.ttcat(mains(1),:);         %biggest shock in sequence
            if var1==7    %input of maintime of sequence(normally onset of high seismicity)
                figure(pplot);
                seti = uicontrol('Units','normal',...
                    'Position',[.4 .01 .2 .05],'String','Select Maintime');
                
                XLim=get(cplot,'XLim');
                M1b = [];
                M1b= ginput(1);
                tt3= M1b(1);
                tt4=num2str((tt3-0.22)*(1/.55)*(XLim(2)-XLim(1))+XLim(1));
                text( M1b(1),M1b(2),['|: T1=',tt4] )
                tt4=str2double(tt4);
                delete(seti);
                if tt4>tmp3
                    tt4=tmp3;
                    disp('maintime was set to starttime of estimate')
                end
            end
            if par3<1
                if var1==7
                    mains=find(ZG.ttcat(:,3)>(days(tt4)+ZG.ttcat(1,3)));
                    mains=ZG.ttcat(mains(1),:);
                end
                tmpcat=ZG.ttcat(find(ZG.ttcat(:,3)>=days(tmp3)+ZG.ttcat(1,3) &    ZG.ttcat(:,3)<=days(tmp4)+ZG.ttcat(1,3)),:);
                tmp6=days(tmp3)+ZG.ttcat(1,3);
            else
                if var1==7
                    mains=find(ZG.ttcat(:,3)>tt4);
                    mains=ZG.ttcat(mains(1),:);
                end
                tmpcat=ZG.ttcat(find(ZG.ttcat(:,3)>=tmp3 & ZG.ttcat(:,3)<=tmp4),:);
                tmp6=tmp3;
            end
            tmpcat=tmpcat(find(tmpcat(:,6)>=tmp2 & tmpcat(:,6)<=tmp1),:);
            if var1 ==6 | var1==7
                ttt=find(tmpcat(:,3)>mains(1,3));
                tmpcat=tmpcat(ttt,:);
                tmpcat=[mains; tmpcat];
                ts=(tmp6-mains(1,3))*365;
                if ts<=0
                    ts=0.0000001;
                end
            end
            tmeqtime=clustime(tmpcat);
            tmeqtime=tmeqtime-tmeqtime(1);     %time in days relative to first eq
            tmeqtime=tmeqtime(2:length(tmeqtime));
            
            %automatic estimate works with whole sequence
        else
            tmeqtime=clustime(ZG.ttcat);
            tmeqtime=tmeqtime-tmeqtime(1);
            tmeqtime=tmeqtime(2:length(tmeqtime));
            
        end
        tend=tmeqtime(length(tmeqtime)); %end time
        
        
        %Loop begins here
        nn=length(tmeqtime);
        loop=0;
        tt=tmeqtime(nn);
        t=tmeqtime;
        
        MIN_CSTEP = 0.000001;
        MIN_PSTEP = 0.00001;
        [loopcheck, c, p, dk, sdc, sdp, sdk]=ploop_c_and_p_calcs(MIN_CSTEP, MIN_PSTEP, true,'kpc');%call of function who calculates parameters
        % loopcheck=ploop_c_and_p_calcs(MIN_CSTEP, MIN_PSTEP, true,'kpc');%call of function who calculates parameters
        
        if autop~=1
            figure(pplot);
            delete(freq_field1);
            delete(freq_field2);
            delete(freq_field3);
            delete(freq_field4);
            delete(Go_p_button);
            cla;
        end
        if loopcheck<500
            %round values on two digits
            p=round(p, -2);
            sdp=round(sdp, -2);
            c=round(c, -3);
            sdc=round(sdc, -3);
            dk=round(dk, -2);
            sdk= round(sdk, -2);
            aa=round(aa, -2);
            bb=round(bb, -2);
            
            tt1=num2str(p);
            txt1 = text(...
                'Position',[0.15 0.37 h2 ],...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'FontWeight','bold' ,...
                'String',['P-Value: ',tt1]);
            
            tt1=num2str(sdp);
            txt1 = text(...
                'Position',[0.5 0.37 h2 ],...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'FontWeight','normal' ,...
                'String',['Standard Deviation: ',tt1]);
            
            
            tt1= num2str(c);
            txt1 = text(...
                'Position',[0.15 0.32 h2 ],...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'FontWeight','normal' ,...
                'String',['Constant c: ',tt1]);
            tt1=num2str(sdc);
            txt1 = text(...
                'Position',[0.5 0.32 h2 ],...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'FontWeight','normal' ,...
                'String',['Standard Deviation ',tt1]);
            
            
            tt1= num2str(dk);
            txt1 = text(...
                'Position',[0.15 0.27 h2 ],...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'FontWeight','normal' ,...
                'String',['Constant k: ',tt1]);
            tt1=num2str(sdk);
            txt1 = text(...
                'Position',[0.5 0.27 h2 ],...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'FontWeight','normal' ,...
                'String',['Standard Deviation: ',tt1]);
            
            tt2=num2str(cof);tt3=num2str(pc);tt4=num2str(qp);tt5=num2str(cog);
            tt1=['Integrated Omori Law: N(t) = ',tt2,'(t+',tt3,')^',tt4,' -   ',tt5];
            text1= text(...
                'Position',[0.1 0.21 h2 ],...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'FontWeight','normal' ,...
                'String',tt1);
            
            tt1=num2str(aa);
            text1= text(...
                'Position',[0.15 0.15 h2 ],...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'FontWeight','bold' ,...
                'String',['A-value: ',tt1]);
            
            
            tt1=num2str(bb);
            text1= text(...
                'Position',[0.55 0.15 h2 ],...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'FontWeight','bold' ,...
                'String',['B-value: ',tt1]);
            
            set(Info_p, 'callback',@callbackfun_010);
            
            if autop~=1
                tt1=num2str(tmp3);
                tt2=num2str(tmp4);
                tt3=num2str(tmp2);
                tt4=num2str(tmp1);
            else
                tt1=num2str(tmeqtime(1));
                tt2=num2str(tend);
                tt3=num2str(min(ZG.ttcat(:,6)));
                tt4=num2str(max(ZG.ttcat(:,6)));
            end
            tt5=[tt1,'<=t<=',tt2];
            tt6=[tt3,'<=mag<=',tt4];
            text1=text(0.5, .55,tt5);
            text2=text(0.5 ,.6,tt6);
            
            
        else    %if loopcheck
            
            
            str = ['\newline \newline \newlineThe P-Value evaluation leads to no stable result! \newlineTo avoid a segmentation fault the algorithm was shut down.\newlineFor more information hit the Info button.'];
            te = text(0.2,0.37,str) ;
            set(te,'FontSize',12);
            set(Info_p, 'callback',@callbackfun_011);
        end
        if autop~=1
            if par3>=1
                tdiff = round(tmpcat(length(tmpcat(:,1)),3)-tmpcat(1,3));
            else
                tdiff = (tmpcat(length(tmpcat(:,1)),3)-tmpcat(1,3))*365;
            end
            % set arrays to zero
            %
            if par3>=1
                cumu = 0:1:(tdiff/days(par3))+1;
                cumu2 = 0:1:(tdiff/days(par3))-1;
            else
                par5=par3/5;
                cumu = 0:par5:tdiff+2*par3;
                cumu2 =  0:par5:tdiff-1;
            end
            cumu = cumu * 0;
            cumu2 = cumu2 * 0;
            %
            % calculate cumulative number versus time and bin it
            %
            %  n = length(tmpcat(:,1));
            if par3>=1
                [cumu, xt] = hist(tmpcat(:,3),(tmpcat(1,3):days(par3):tmpcat(length(tmpcat(:,1)),3)));
            else
                [cumu, xt] = hist((tmpcat(:,3)-tmpcat(1,3))*365,(0:par5:tdiff));
            end
            if exist('ppc')
                difp= [0 diff(cumu)];
            end
            cumu2 = cumsum(cumu);
            
            % plot time series
            %
            delete(cplot)
            orient tall
            rect = [0.22,  0.5, 0.55, 0.45];
            cplot=axes('position',rect);
            hold on
            tiplo = plot(xt,cumu2,'ob');
            set(gca,'visible','off')
            plot(xt,cumu2,'r','Tag','tiplo2');
            if exist('ppc')
                plot(xt,difp,'g');
            end
            
            if exist('stri', 'var')
                v = axis;
                tea = text(v(1)+0.5,v(4)*0.9,stri) ;
                set(tea,'FontSize',ZmapGlobal.Data.fontsz.m,'Color','k','FontWeight','bold')
            else
                strib = [file1];
            end %% if stri
            
            strib = [file1];
            
            %  title(strib,'FontWeight','bold',...
            %     'FontSize',ZmapGlobal.Data.fontsz.l,...
            %    'Color','r')
            
            grid
            if par3>=1
                xlabel('Time in years ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
            else
                xlabel(['Time in days relative to ',num2str(tmpcat(1,3))],'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
            end
            ylabel('Cumulative Number ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
            
            % Make the figure visible
            %
            set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
                'FontWeight','bold','LineWidth',1.5,...
                'Box','on')
        end;  %if autop~=1
        ZmapMessageCenter();
        tmvar=[];
        if ~isempty(hndl1)
            delete(hndl1);
            hndl1=[];
        end
    end
    
    function callbackfun_001(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        tmp2=str2double(freq_field1.String);
        freq_field1.String=num2str(tmp2);
    end
    
    function callbackfun_002(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        tmp1=str2double(freq_field2.String);
        freq_field2.String=num2str(tmp1);
    end
    
    function callbackfun_003(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        tmp3=str2double(freq_field3.String);
        freq_field3.String=num2str(tmp3);
    end
    
    function callbackfun_004(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        tmp4=str2double(freq_field4.String);
        freq_field4.String=num2str(tmp4);
    end
    
    function callbackfun_005(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        clinfo(1);
    end
    
    function callbackfun_006(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        set(pplot,'visible','off');
    end
    
    function callbackfun_007(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        if ~isempty(tmvar);
            clpval(8);
        else;
            in2 = get(hndl1,'Value')+5;
            clpval(in2);
        end;
    end
    
    function callbackfun_008(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        clinfo(1);
    end
    
    function callbackfun_009(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        set(pplot,'visible','off');
    end
    
    function callbackfun_010(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        clinfo(2);
    end
    
    function callbackfun_011(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        clinfo(10);
    end
end
