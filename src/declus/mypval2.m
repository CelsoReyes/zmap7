function [p,sdp,c,sdc,dk,sdk,aa,bb]=mypval2(var1, mati)
    % clpvla.m                            A.Allmann
    % function to calculate the parameters of the modified Omori Law
    %
    %

    % this function is a modification of a program by Paul Raesenberg
    % that is based on Programs by Carl Kisslinger and Yoshi Ogata

    % function finds the maximum liklihood estimates of p,c and k, the
    % parameters of the modifies Omori equation
    % it also finds the standard deviations of these parameters

    % Input: Earthquake Catalog of an Cluster Sequence

    % Output: p c k values of the modified Omori Law with respective
    %         standard deviations
    %         A and B values of the Gutenberg Relation based on k

    % Create an input window for magnitude thresholds and
    % plot cumulative number versus time to allow input of start and end
    % time


    global file1             
    global mess ccum bgevent clust original newclcat
    global backcat ttcat cluscat
   global  sys clu te1
    global clu1 pyy tmp1 tmp2 tmp3 tmp4 difp
    global xt par3 cumu cumu2
    global close_p_button pplot
    global freq_field1 freq_field2 freq_field3 freq_field4 Go_p_button
    global h2 cplot Info_p close_p print_p
    global tt pc loop nn pp nit t err1x err2x ieflag isflag
    global cstep pstep tmpcat ts tend eps1 eps2
    global qp pcheck loopcheck
    global ppc cplot2 hndl1
    global autop tmeqtime tmvar
    %if var1 == 3
    tmvar=[];
    %input of parameters(Magnitude,Time)
    ZG.newt2=ttcat;              %function operates with single cluster
    autop=0;
    if var1==4
        autop=1;
    end
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
    [cumu, xt] = hist(ZG.newt2.Date,(t0b:days(par3):teb));
    [cumu, xt] = hist((ZG.newt2.Date-t0b,(0:par5:tdiff));
    difp= [0 diff(cumu)];
    cumu2 = cumsum(cumu);

    % find start time of time series
    %
    nn=find(cumu==max(cumu));
    nnn=nn(1,1)-2;
    tmvar=1;           %temperal variable
    if par3>=1
        tmp3=t0b+nnn*days(par3);
    else
        tmp3=nnn*par5;
    end
    tmp3 = mati;
    tmp2=min(ttcat(:,6));
    tmp1=max(ttcat(:,6));

    if tmp3 < 0
        tmp3=0;
    end

    tmp4=teb;


    %cumputation part after parameter input
    %elseif var1==8  | var1==6 | var1==7
    %set the error test values
    eps1=.0005;
    eps2=.0005;

    %set the parameter starting values
    PO=1.1;
    CO=0.1;

    %set the initial step size
    pstep=.05;
    cstep=.05;
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

        mains=find(ttcat(:,6)==max(ttcat(:,6)));
        mains=ttcat(mains(1),:);         %biggest shock in sequence
        if par3<0.001
            tmpcat=ttcat(find(ttcat(:,3)>=days(tmp3)+ttcat(1,3) &    ttcat(:,3)<=days(tmp4)+ttcat(1,3)),:);
            tmp6=days(tmp3)+ttcat(1,3);
        else
            tmpcat=ttcat(find(ttcat(:,3)>=tmp3 & ttcat(:,3)<=tmp4),:);
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
        tmeqtime=clustime(ttcat);
        tmeqtime=tmeqtime-tmeqtime(1);
        tmeqtime=tmeqtime(2:length(tmeqtime));

    end

    tp1 = input('tp1=   ')
    tp2 = input('tp2=    ')
    ts = tp1;
    l = tmeqtime >= tp1 & tmeqtime <= tp2;
    tmeqtime = tmeqtime(l);


    tend=tmeqtime(length(tmeqtime)); %end time


    %Loop begins here
    nn=length(tmeqtime);
    loop=0;
    loopcheck=0;
    tt=tmeqtime(nn)+1;
    t=tmeqtime;
    if pc < 0 ; pc = 0.0; end
    if pc <= ts; pc = ts + 0.05;end

    MIN_CSTEP = 0.000001;
    MIN_PSTEP = 0.00001;
    ploop_c_and_p_calcs(MIN_CSTEP, MIN_PSTEP, true,'kpc');%call of function who calculates parameters

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


        disp(['p = ' num2str(p)  ' +/- ' num2str(sdp)]);
        disp(['c = ' num2str(c)  ' +/- ' num2str(sdc)]);
        disp(['k = ' num2str(dk)  ' +/- ' num2str(sdk)]);
        disp(['b = ' num2str(bb)  ' +/- ' num2str(sdp)]);
        disp(['a = ' num2str(aa)  ' +/- ' num2str(sdp)]);
    else    %if loopcheck
        disp(['No result']);
        %p = nan;
        %c = nan;
        %k = nan;
        %bb = nan;
        %aa = nan;

        % p = nan; sdp = nan;
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

        %
    end  %if autop~=1
    tmvar=[];
    %end
