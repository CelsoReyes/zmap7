function cltipval(var1)
    % cltipvla.m                            A.Allmann
    % function to calculate P-values for different time or magnitude windows
    %

    % this function is a modification of a program by Paul Raesenberg
    % that is based on Programs by Carl Kisslinger and Yoshi Ogata

    % function finds the maximum liklihood estimates of p,c and k, the
    % parameters of the modifies Omori equation
    % it also finds the standard deviations of these parameters
    % all values are calculated for different time or magnitude windows

    % Input: Earthquake Catalog of an Cluster Sequence

    % Output: p c k values of the modified Omori Law with respective
    %         standard deviations
    %         A and B values of the Gutenberg Relation based on k
    %         Plots to compare different magnitude or time windows

    % Create an input window for magnitude thresholds and
    % plot cumulative number versus time to allow input of start and end
    % time


    global file1             
    global mess ccum bgevent clust original newclcat
    global backcat ttcat cluscat
   global  sys clu te1
    global xt par3 cumu cumu2
    global freq_field1 freq_field2 freq_field3 freq_field4 Go_p_button
    global p c dk tt pc loop nn pp nit t err1x err2x ieflag isflag
    global cstep pstep tmpcat ts tend eps1 eps2
    global sdc sdk sdp qp aa bb pcheck loopcheck
    global callcheck mtpl tmm
    global freq_field5
    global magn mp mc mk msdk msdp msdc ctiplo
    global tmp1 tmp2 tmp3 tmp4 omori hpndl1


    if var1==1 | var1==2              %magnitude or time estimate
        [existFlag,figNumber]=figure_exists('P-Value Estimate');
        if existFlag
            figure_w_normalized_uicontrolunits(mtpl);
            clf
        else
            mtpl=figure_w_normalized_uicontrolunits(...
                'Name','P-Value Estimate',...
                'NumberTitle','off',...
                ...
                'NextPlot','new',...
                'visible','off',...
                'Units','normalized',...
                'Position',[ 0.435  0.8 0.5 0.8]);
        end
        
        ZG.newt2=ttcat;
        %calculate start -end time of overall catalog
        t0b = min(ZG.newt2.Date);
        teb = max(ZG.newt2.Date);
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
            [cumu, xt] = hist(ZG.newt2.Date,(t0b:days(par3):teb));
        else
            [cumu, xt] = hist((ZG.newt2.Date-ZG.newt2(1,3))*365,(0:par5:tdiff));
        end
        cumu2 = cumsum(cumu);

        % plot time series
        %
        orient tall
        rect = [0.22,  0.5, 0.55, 0.45];
        ctiplo=axes('position',rect);
        hold on
        cplot = plot(xt,cumu2,'ob');
        set(gca,'visible','off')
        ctiplo2 = plot(xt,cumu2,'r');
        if exist('stri', 'var')
            v = axis;
            tea = text(v(1)+0.5,v(4)*0.9,stri) ;
            set(tea,'FontSize',ZmapGlobal.Data.fontsz.m,'Color','k','FontWeight','bold');
        end

        strib = [file1];

        title(strib,'FontWeight','bold',...
            'FontSize',ZmapGlobal.Data.fontsz.l,...
            'Color','r')

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

        str =  ['\newline \newline \newlinePlease select start and end time of the P-Value plot\newlineClick first with the left Mouse Button at your start position\newlineand then with the left Mouse Button at the end position'];
        te = text(0.2,0.37,str) ;

        set(te,'FontSize',14);
        set(mtpl,'Visible','on');

        disp('Please select start and end time of the P-value plot. Click first with the left Mouse Button at your start position and then at the end position.')


        seti = uicontrol('Units','normal',...
            'Position',[.4 .01 .2 .05],'String','Select Time1 ');


        XLim=get(ctiplo,'XLim');
        M1b = [];
        M1b= ginput(1);
        tt3= M1b(1);
        tt4=num2str((tt3-0.22)*(1/.55)*(XLim(2)-XLim(1))+XLim(1));
        text( M1b(1),M1b(2),['|: T1=',tt4] )
        set(seti,'String','Select Time2');

        pause(0.1)
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

        tmp2=min(ttcat(:,6));
        freq_field1= uicontrol('Style','edit',...
            'Position',[.43 .35 .1 .04],...
            'Units','normalized','String',num2str(tmp2),...
            'callback',@callbackfun_001);

        tmp1=max(ttcat(:,6));
        freq_field2=uicontrol('Style','edit',...
            'Position',[.76 .35 .1 .04],...
            'Units','normalized','String',num2str(tmp1),...
            'callback',@callbackfun_002);
        tmp3=str2double(tt4);
        if tmp3 < 0
            tmp3=0;
        end

        freq_field3=uicontrol('Style','edit',...
            'Position',[.43 .28 .1 .04],...
            'Units','normalized','String',num2str(tmp3),...
            'callback',@callbackfun_003);

        tmp4=str2double(tt5);
        freq_field4=uicontrol('Style','edit',...
            'Position',[.76 .28 .1 .04],...
            'Units','normalized','String',num2str(tmp4),...
            'callback',@callbackfun_004);


        txt1 = text(...
            'Color',[0 0 0 ],...
            'EraseMode','normal',...
            'Position',[0.1 0.37   ],...
            'Rotation',0 ,...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold' ,...
            'String','Magnitude:    Min: ');

        txt2 = text(...
            'Color',[0 0 0 ],...
            'EraseMode','normal',...
            'Position',[0.6 0.37  ],...
            'Rotation',0 ,...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold' ,...
            'String','Max :');


        txt3 = text(...
            'Color',[0 0 0 ],...
            'EraseMode','normal',...
            'Position',[0.1 0.3 ],...
            'Rotation',0 ,...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold' ,...
            'String','Time:             Min:');

        txt4 = text(...
            'Color',[0 0 0 ],...
            'EraseMode','normal',...
            'Position',[0.6 0.3 ],...
            'Rotation',0 ,...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold' ,...
            'String','Max :');


        if var1==1                        %magnitude window

            txt5 = text(...
                'Color',[0 0 0 ],...
                'EraseMode','normal',...
                'Position',[0.2 0.22 ],...
                'Rotation',0 ,...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'FontWeight','bold' ,...
                'String','Magnitude Steps: ');
            magn=tmp2;
            freq_field5=uicontrol('Style','edit',...
                'Position',[.55 .2 .2 .04],...
                'Units','normalized','String',num2str(magn),...
                'callback',@callbackfun_005);
            set(freq_field5,'String',num2str(magn));
            tmm=0;
            text(0.54,0.17,'Vector (e.g. 1: 0.1: 3): ');
        elseif var1==2            %time windows
            txt5 = text(...
                'Color',[0 0 0 ],...
                'EraseMode','normal',...
                'Position',[0.2 0.22 ],...
                'Rotation',0 ,...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'FontWeight','bold' ,...
                'String','End Times : ');

            magn=tmp4;
            freq_field5=uicontrol('Style','edit',...
                'Position',[.55 .2 .2 .04],...
                'Units','normalized','String',num2str(magn),...
                'callback',@callbackfun_006);
            set(freq_field5,'String',num2str(magn));
            tmm=3;
            text(0.54,0.17,'Vector (e.g. 1: 0.5: 7): ');
        end

        Info_p = uicontrol('Style','Pushbutton',...
            'String','Info ',...
            'Position',[.3 .05 .10 .06],...
            'Units','normalized','callback',@callbackfun_007);
        if var1==2
            set(Info_p, 'callback',@callbackfun_008);
        end
        close_p =uicontrol('Style','Pushbutton',...
            'Position', [.45 .05 .10 .06 ],...
            'Units','normalized','callback',@callbackfun_009,...
            'String','Close');
        print_p = uicontrol('Style','Pushbutton',...
            'Position',[.15 .05 .1 .06],...
            'Units','normalized','Callback', 'myprint',...
            'String','Print');
        labelPos= [.6 .05 .2 .06];
        labelList=['Mainshock| Main-Input| Sequence' ];
        hpndl1 =uicontrol(...
            'style','popup',...
            'units','normalized',...
            'position',labelPos,...
            'string', labelList,...
            'callback',@callbackfun_010);
        figure_w_normalized_uicontrolunits(mess);
        clf;
        str =  ['\newline \newline \newlinePlease give in parameters in green fields\newlineThis parameters will be used as the threshold\newline for the P-Value.\newlineAfter input push GO to continue. '];
        te = text(0.01,0.9,str) ;

        set(te,'FontSize',12);
        set(gca,'visible','off');

    elseif var1==3  ||  var1==4  ||  var1==5  %Mainshock/Maininput/Sequence

        mp=zeros(length(magn),1);mc=mp;mk=mp;msdp=mp;msdc=mp;msdk=mp;

        wai=waitbar(0,' Please Wait ...  ');
        set(wai,'NumberTitle','off','Name','Omori-Parameters - Percent done');
        drawnow

        for i=1:length(magn)       %different magnitude steps
            waitbar(i/length(magn))
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

            %Build timecatalog

            mains=find(ttcat(:,6)==max(ttcat(:,6)));
            mains=ttcat(mains(1),:);         %biggest shock in sequence
            if var1==4  %input of maintime of sequence(normally onset of high seismicity)
                if i==1
                    figure_w_normalized_uicontrolunits(mtpl)
                    seti = uicontrol('Units','normal',...
                        'Position',[.4 .01 .2 .05],'String','Select Maintime');
                    XLim=get(ctiplo,'XLim');
                    M1b = [];
                    M1b= ginput(1);
                    tt3= M1b(1);
                    tt4=num2str((tt3-0.22)*(1/.55)*(XLim(2)-XLim(1))+XLim(1));
                    text( M1b(1),M1b(2),['|: T1=',tt4] )
                    tt4=str2double(tt4);
                    delete(seti);


                    if tt4>tmp3          %maintime after selected starttime of sequence
                        tt4=tmp3;
                        disp('maintime was set to starttime of estimate')
                    end
                    figure_w_normalized_uicontrolunits(wai)
                end
            end                   %end of input maintime

            if par3<1             %if cumulative number curve is in days

                if var1==4        %first event in sequence is mainevent if maininput
                    mains=find(ttcat(:,3)>(days(tt4)+ttcat(1,3)));
                    mains=ttcat(mains(1),:);
                end

                tmpcat=ttcat(find(ttcat(:,3)>=days(tmp3)+ttcat(1,3) &    ttcat(:,3)<=days(tmp4)+ttcat(1,3)),:);
                tmp6=days(tmp3)+ttcat(1,3);

            else                 %cumulative number curve is in  years

                if var1==4           %first event in sequence in mainevent if maininput
                    mains=find(ttcat(:,3)>tt4);
                    mains=ttcat(mains(1),:);
                end

                tmpcat=ttcat(find(ttcat(:,3)>=tmp3 & ttcat(:,3)<=tmp4),:);
                tmp6=tmp3;
            end
            tmp2=magn(i);
            tmpcat=tmpcat(find(tmpcat(:,6)>=tmp2 & tmpcat(:,6)<=tmp1),:);

            if var1 ==3 | var1==4
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

            tend=tmeqtime(length(tmeqtime)); %end time
            %Loop begins here
            nn=length(tmeqtime);
            loop=0;
            loopcheck=0;
            tt=tmeqtime(nn);
            t=tmeqtime;

            MIN_CSTEP = 0.000001;
            MIN_PSTEP = 0.00001;
    
            ploop_c_and_p_calcs(MIN_CSTEP, MIN_PSTEP, true,'kpc');  % call of function who calculates parameters

            if loopcheck<499
                mp(i)=p;              %storage of p,k,c +standard deviations
                msdp(i)=sdp;
                mk(i)=dk;
                msdk(i)=sdk;
                mc(i)=c;
                msdc(i)=sdc;
            else
                mp(i)=NaN;
                msdp(i)=NaN;
                mk(i)=NaN;
                msdk(i)=NaN;
                mc(i)=NaN;
                msdc(i)=NaN;
            end
            if msdp>mp
                msdp=mp;
            elseif msdk>mk
                msdk=mk;
            elseif msdc>mc
                msdc=mc;
            end
        end                    %end for

        delete(wai)
        cltipval(9);
    elseif var1==6  ||  var1==7  ||  var1==8

        mp=zeros(length(magn),1);mc=mp;mk=mp;msdp=mp;msdc=mp;msdk=mp;
        wai=waitbar(0,' Please Wait ...  ');
        set(wai,'NumberTitle','off','Name','Omori-Parameters - Percent done');
        drawnow
        for i=1:length(magn)       %different magnitude steps
            waitbar(i/length(magn))
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

            %Build timecatalog

            mains=find(ttcat(:,6)==max(ttcat(:,6)));
            mains=ttcat(mains(1),:);         %biggest shock in sequence
            if var1==7  %input of maintime of sequence(normally onset of high seismicity)
                if i==1
                    figure_w_normalized_uicontrolunits(mtpl)
                    seti = uicontrol('Units','normal',...
                        'Position',[.4 .01 .2 .05],'String','Select Maintime');
                    XLim=get(ctiplo,'XLim');
                    M1b = [];
                    M1b= ginput(1);
                    tt3= M1b(1);
                    tt4=num2str((tt3-0.22)*(1/.55)*(XLim(2)-XLim(1))+XLim(1));
                    text( M1b(1),M1b(2),['|: T1=',tt4] )
                    tt4=str2double(tt4);
                    delete(seti);

                    if tt4>tmp3          %maintime after selected starttime of sequence
                        tt4=tmp3;
                        disp('maintime was set to starttime of estimate')
                    end
                    figure_w_normalized_uicontrolunits(wai);
                end
            end                   %end of input maintime

            if par3<1             %if cumulative number curve is in days

                if var1==7        %first event in sequence is mainevent if maininput
                    mains=find(ttcat(:,3)>(days(tt4)+ttcat(1,3)));
                    mains=ttcat(mains(1),:);
                end

                tmpcat=ttcat(find(ttcat(:,3)>=days(tmp3)+ttcat(1,3) &    ttcat(:,3)<=magn(i)/365+ttcat(1,3)),:);
                tmp6=days(tmp3)+ttcat(1,3);

            else                 %cumulative number curve is in  years

                if var1==7           %first event in sequence in mainevent if maininput
                    mains=find(ttcat(:,3)>tt4);
                    mains=ttcat(mains(1),:);
                end

                tmpcat=ttcat(find(ttcat(:,3)>=tmp3 & ttcat(:,3)<=magn(i)),:);
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

            tend=tmeqtime(length(tmeqtime)); %end time
            %Loop begins here
            nn=length(tmeqtime);
            loop=0;
            loopcheck=0;
            tt=tmeqtime(nn);
            t=tmeqtime;
            
            MIN_CSTEP = 0.000001;
            MIN_PSTEP = 0.00001;
            ploop_c_and_p_calcs(MIN_CSTEP, MIN_PSTEP, true,'kpc');%call of function who calculates parameters

            if loopcheck<499
                mp(i)=p;              %storage of p,k,c +standard deviations
                msdp(i)=sdp;
                mk(i)=dk;
                msdk(i)=sdk;
                mc(i)=c;
                msdc(i)=sdc;
            else
                mp(i)=NaN;
                msdp(i)=NaN;
                mk(i)=NaN;
                msdk(i)=NaN;
                mc(i)=NaN;
                msdc(i)=NaN;
            end
            if msdp>mp
                msdp=mp;
            elseif msdk>mk
                msdk=mk;
            elseif msdc>mc
                msdc=mc;
            end
        end                    %end for
        delete(wai)
        cltipval(9);


    elseif var1==9              %plot the results

        [existFlag,figNumber]=figure_exists('Omori-Parameters');

        if existFlag
            figure_w_normalized_uicontrolunits(omori);
            clf;
        else
            omori=figure_w_normalized_uicontrolunits(....
                'Name','Omori-Parameters',...
                'NumberTitle','off',...
                ...
                'NextPlot','new',...
                'visible','off',...
                'Units','normalized',...
                'Position',[ 0.435  0.8 0.5 0.8]);
        end
        
        %plot p-value + standard deviation
        rect = [0.15,  0.7, 0.65, 0.26];
        mpplot=axes('position',rect,'box','on');
        hold on
        plot(magn,mp,'ob')
        if tmm==0
            xlabel('Minimum Magnitude ');
        else
            xlabel('End Time of Estimate');
        end
        ylabel('p-value');
        errorbar(magn,mp,msdp);
        grid;

        %plot  k-value + standard deviation
        rect= [0.15,  0.38, 0.65, 0.26];
        mkplot=axes('position',rect,'box','on');
        hold on
        plot(magn,mk,'ob')
        if tmm==0
            xlabel('Minimum Magnitude ');
        else
            xlabel('End Time of Estimate');
        end
        ylabel('k-value');
        errorbar(magn,mk,msdk)
        grid


        %plot c-value +  standard deviation
        rect=[0.15,  0.06, 0.65, 0.26];
        mctiplo=axes('position',rect,'box','on');
        hold on
        plot(magn,mc,'ob');
        if tmm==0
            xlabel('Minimum Magnitude ');
        else
            xlabel('End Time of Estimate');
        end
        ylabel('c-value');
        errorbar(magn,mc,msdc)
        grid
    end






end


function callbackfun_001(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_001');
  tmp2=str2double(freq_field1.String);
       freq_field1.String=num2str(tmp2);
end
 
function callbackfun_002(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_002');
  tmp1=str2double(freq_field2.String);
     freq_field2.String=num2str(tmp1);
end
 
function callbackfun_003(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_003');
  tmp3=str2double(freq_field3.String);
    freq_field3.String=num2str(tmp3);
end
 
function callbackfun_004(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_004');
  tmp4=str2double(freq_field4.String);
   freq_field4.String=num2str(tmp4);
end
 
function callbackfun_005(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_005');
  magn=freq_field5.String;
  magn=eval(magn);
end
 
function callbackfun_006(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_006');
  magn=freq_field5.String;
  magn=eval(magn);
end
 
function callbackfun_007(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_007');
  clinfo(18);
end
 
function callbackfun_008(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_008');
  clinfo(19);
end
 
function callbackfun_009(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_009');
  set(mtpl,'visible','off');
end
 
function callbackfun_010(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_010');
  in2=get(hpndl1,'Value')+2+tmm;
  cltipval(in2);
end
 
