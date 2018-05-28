function  bdiff_bdepth(mycat)
    %  This routine etsimates the b-value of a curve automatically
    %  The b-valkue curve is differenciated and the point
    %  of maximum curvature marked. The b-value will be calculated
    %  using this point and the point half way toward the high
    %  magnitude end of the b-value curve.
    
    %  originally, "mycat" was "newcat"
    %  Stefan Wiemer 1/95
    %
    global cluscat mess bfig backcat magsteps_desc bvalsum3  bval aw bw t1 t2 t3 t4 dloop leg1 leg2
    global les teb t0b cua  ew onesigma mrt bvalsumhold
    global gBdiff % contains b1, n1, b2, n2
    global mxlkbt lsbt ni
    ZG=ZmapGlobal.Data;
    
    report_this_filefun();
    
    bfig=findobj('Type','Figure','-and','Name','frequency-magnitude distribution');
    if ~isempty(bfig)
        if dloop == 2
            ZG.hold_state=true;
        end
    else
        bfig=figure_w_normalized_uicontrolunits(...                  %build figure for plot
            'Units','normalized','NumberTitle','off',...
            'Name','frequency-magnitude distribution',...
            'visible','off',...
            'pos',[ 0.300  0.3 0.4 0.6]);
        ZG.hold_state=false;
        
        uicontrol('Units','normal',...
            'Position',[.0 .85 .08 .06],'String','Info ',...
            'callback',@callbackfun_001);
        uicontrol('Units','normal',...
            'Position',[.0 .45 .10 .06],'String','Manual ',...
            'callback',@callbackfun_002);
        
        uicontrol('Units','normal',...
            'Position',[.0 .35 .10 .06],'String','RecTime ',...
            'callback',@callbackfun_003);
        
        uicontrol('Units','normal',...
            'Position',[.0 .25 .10 .06],'String','TimePlot ',...
            'callback',@cb_timeplot);
        
        uicontrol('Units','normal',...
            'Position',[.0 .65 .08 .06],'String','Save ',...
            'Callback',{@calSave9,magsteps_desc, bvalsum3});
    end
    
    maxmag = ceil(10*max(mycat.Magnitude))/10;
    mima = min(mycat.Magnitude);
    mima = min(mima, 0);
    
    % number of mag units
    nmagu = (maxmag*10)+1;
    
    [bval,xt2] = hist(mycat.Magnitude,(mima:0.1:maxmag));
    bvalsum = cumsum(bval); % N for M <=
    bval2 = bval(end:-1:1);
    bvalsum3 = cumsum(bval(end:-1:1));    % N for M >= (counted backwards)
    magsteps_desc = (maxmag:-0.1:mima);
    
    
    backg_ab = log10(bvalsum3);
    orient tall
    
    if ZG.hold_state
        axes(cua)
        disp('hold on')
        hold on
    else
        figure(bfig);delete(findobj(bfig,'Type','axes'));
        rect = [0.2,  0.3, 0.70, 0.6];           % plot Freq-Mag curves
        axes('position',rect);
    end
    
    pldepth =semilogy(magsteps_desc,bvalsum3,'sb');
    set(pldepth,'LineWidth',1.0,'MarkerSize',6,...
        'MarkerFaceColor','r','MarkerEdgeColor','b');
    hold on
    difb = [0 diff(bvalsum3) ];
    
    % Marks the point of maximum curvature
    %
    i = find(difb == max(difb));
    i = max(i);
    te = semilogy(magsteps_desc(i),bvalsum3(i),'xk');
    set(te,'LineWidth',1.5,'MarkerSize',ms10)
    
    % Estimate the b-value
    %
    i2 = 1 ;
    te = semilogy(magsteps_desc(i2),difb(i2),'xk');
    set(te,'LineWidth',1.5,'MarkerSize',ms10)
    te = semilogy(magsteps_desc(i2),bvalsum3(i2),'xk');
    set(te,'LineWidth',1.5,'MarkerSize',ms10)
    
    xlabel('Magnitude','FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s)
    ylabel('Cumulative Number','FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s)
    %set(gca,'Color',color_bg)
    set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','normal',...
        'FontWeight','normal','LineWidth',1.0,...
        'Box','on','Tag','cufi')
    
    cua = gca;
    
    M1b = [];
    M1b = [magsteps_desc(i) bvalsum3(i)];
    tt3=num2str(fix(100*M1b(1))/100);
    
    M2b = [];
    M2b =  [magsteps_desc(i2) bvalsum3(i2)];
    tt4=num2str(fix(100*M2b(1))/100);
    
    ll = magsteps_desc >= M1b(1)-0.05  & magsteps_desc <= M2b(1) +0.05;
    x = magsteps_desc(ll);
    
    l2 = mycat.Magnitude >= M1b(1)- 0.05  & mycat.Magnitude <= M2b(1)+ 0.05;
    [ bv, onesigma, av] = calc_bmemag(mycat.Magnitude(l2)) ;
    
    bv = -bv;
    
    
    pause(0.1)
    
    y = backg_ab(ll);
    [aw bw,  S, ew] = wls(x',y');
    p = [bw aw];
    %[p,S] = polyfit(x,y,1)                    % fit a line to background
    p2 = [bw+onesigma aw];
    p3 = [bw-onesigma aw];
    x2 = 1:0.1:6;
    f = polyval(p,x);
    f2 = polyval(p2,x);
    f3 = polyval(p3,x);
    [f4,delta] = polyval(p,x,S);
    Tr  = (teb-t0b)/(10.^ polyval(p,mrt));
    disp(['Recurrence time Tr(M' num2str(mrt) ') = ' num2str(Tr) ' years']);
    f = 10.^f;
    f2 = 10.^f2;
    f3 = 10.^f3;
    f4 = 10.^f4;
    delta = 10.^delta;
    hold on
    ttm= semilogy(x,f,'r');                         % plot linear fit to backg
    set(ttm,'LineWidth',1)
    ttm= semilogy(x,f2,'k');                         % plot linear fit to backg
    set(ttm,'LineWidth',1)
    ttm= semilogy(x,f3,'k');                         % plot linear fit to backg
    set(ttm,'LineWidth',1)
    ttm= semilogy(x,f4-delta,'k-.');                         % plot linear fit to backg
    set(ttm,'LineWidth',1)
    ttm= semilogy(x,f4+delta,'k-.');
    set(ttm,'LineWidth',1)
    set(gca,'XLim',[min(mycat.Magnitude)-0.5  max(mycat.Magnitude)+0.5])
    set(gca,'YLim',[1 (mycat.Count+20)*1.4]);
    
    r = corrcoef(x,y);
    r = r(1,2);
    %std_backg = std(y - polyval(p,x));      % standard deviation of fit
    std_backg = ew;      % standard deviation of fit
    
    p=-p(1,1);
    p=fix(100*p)/100;
    std_backg=fix(100*std_backg)/100;
    tt1=num2str(bw,3);
    tt2=num2str(std_backg);
    tt4=num2str(bv,3);
    tt5=num2str(onesigma,2);
    
    
    
    rect=[0 0 1 1];
    h2=axes('position',rect);
    set(h2,'visible','off');
    
    %if ZG.hold_state
    if dloop == 2
        set(pldepth,'LineWidth',1.0,'MarkerSize',6,...
            'MarkerFaceColor','y','MarkerEdgeColor','g','Marker','o');
        set(cua,'Ylim',[ 1   ni ] );
        
        txt1=text(.10, .08,['Bottom Zone b-value (w LS, M  >= ', num2str(M1b(1)) '): ',tt1, ' +/- ', tt2 ',a-value = ' , num2str(aw) ]);
        set(txt1,'FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s,'Color','r')
        txt1=text(.10, .04,['Bottom Zone b-value (max lik, M >= ', num2str(min(mycat.Magnitude)) '): ',tt4, ' +/- ', tt5,',a-value = ' , num2str(av)]);
        set(txt1,'FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s, 'Color', 'r')
        lsbb = bw; mxlkbb = bv;
        
        lsb = lsbt/lsbb; mxlkb = mxlkbt/mxlkbb;
        slsb = num2str(lsb);
        smxlkb = num2str(mxlkb);
        txt3 = text(.25, .94,['LS b ratio = ', slsb,'           max lik b ratio = ',smxlkb]);
        set(txt3,'FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s,'Color','b')
        %  leg(2)=pldepth
    else
        txt1=text(.10, .18,['Top Zone b-value (w LS, M  >= ', num2str(M1b(1)) '): ',tt1, ' +/- ', tt2, ',a-value = ' , num2str(aw) ]);
        set(txt1,'FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s)
        txt1=text(.10, .14,['Top Zone b-value (max lik, M >= ', num2str(min(mycat.Magnitude)) '): ',tt4, ' +/- ', tt5,',a-value = ' , num2str(av)]);
        set(txt1,'FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s)
        set(gcf,'PaperPosition',[0.5 0.5 4.0 5.5])
        lsbt = bw; mxlkbt = bv;
    end
    
    if dloop == 1
        leg1 = pldepth;
    end
    if dloop == 2
        leg2 = pldepth;
        legend([leg1,leg2],'Top depth zone','Bottom depth zone');
    end
    set(gcf,'visible','on');
    
    if ZG.hold_state
        % calculate the probability that the two distributins are differnt
        l = mycat.Magnitude >=  M1b(1);
        gBdiff.b2 = str2double(tt1); gBdiff.n2 = M1b(2);
        n = gBdiff.n1+gBdiff.n2;
        da = -2*n*log(n) + 2*gBdiff.n1*log(gBdiff.n1+gBdiff.n2*gBdiff.b1/gBdiff.b2) + 2*gBdiff.n2*log(gBdiff.n1*gBdiff.b2/gBdiff.b1+gBdiff.n2) -2;
        pr = exp(-da/2-2);
        disp(['Probability: ',  num2str(pr)]);
        txt1=text(.60, .75,['p=  ', num2str(pr,2)],'Units','normalized');
        set(txt1,'FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s)
        txt1=text(.60, .70,[ 'gBdiff.n1: ' num2str(gBdiff.n1) ', gBdiff.n2: '  num2str(gBdiff.n2) ', gBdiff.b1: ' num2str(gBdiff.b1)  ', gBdiff.b2: ' num2str(gBdiff.b2)]);
        set(txt1,'FontSize',8,'Units','normalized')
    else
        gBdiff.b1 = str2double(tt1); gBdiff.n1 = M1b(2);
    end
    
    
    bvalsumhold = bvalsum3;
    da = 10^(aw+bw*6.5);
    db = 10^(aw+bw*6.5)*(-6.5);
    dp = sqrt(da^2*ew^2+db^2*0.05^2);
    dr = 1/dp;
    
    hold off;
    
    function callbackfun_001(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        infoz(1);
    end
    
    function callbackfun_002(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        bfitnew(mycat);
    end
    
    function callbackfun_003(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        plorem(onesigma, aw, bw);
    end
    
    function cb_timeplot(mysrc,myevt)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG=ZmapGlobal.Data;
        ZG.newt2 = mycat;
        CumTimePlot(mycat);
    end
end
