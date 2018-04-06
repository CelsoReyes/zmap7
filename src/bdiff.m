function  bdiff(mycat, holdplot)
    %  This routine estimates the b-value of a curve automatically
    %  The b-value curve is differenciated and the point
    %  of maximum curvature marked. The b-value will be calculated
    %  using this point and the point half way toward the high
    %  magnitude end of the b-value curve.
    
    %  Stefan Wiemer 1/95
    %
    global bfig  magsteps_desc bvalsum3  bval aw bw
    global  cua ew onesigma bvalsumhold
    global gBdiff % bdiff globals containing b1, b2, n1, n2
    ZG=ZmapGlobal.Data;
    
    if nargin==2
        ZG.hold_state=holdplot;
    end
    
    disp(ZmapGlobal.Data.hold_state)
    report_this_filefun(mfilename('fullpath'));
    %obsolate, replace
    bfig=findobj('Type','Figure','-and','Name','frequency-magnitude distribution');
    
    if isempty(bfig)
        bfig=figure_w_normalized_uicontrolunits(...   %build figure for plot
            'Units','normalized','NumberTitle','off',...
            'Name','frequency-magnitude distribution',...
            'visible','off',...
            'pos',[ 0.300  0.3 0.4 0.6]);
        ZG.hold_state=false;
        
        create_my_menu();
    end
    
    maxmag = ceil(10*max(mycat.Magnitude))/10;
    mima = min(mycat.Magnitude);
    if mima > 0 ; mima = 0 ; end
    
    % number of mag units
    nmagu = (maxmag*10)+1;
    
    bvalsum3 = zeros(1,nmagu);
    
    [bval,xt2] = hist(mycat.Magnitude,(mima:0.1:maxmag));
    bvalsum = cumsum(bval); % N for M <=
    bval2 = fliplr(bval); %reverse order
    bvalsum3 = cumsum(bval2);    % N for M >= (counted backwards)
    magsteps_desc = (maxmag:-0.1:mima);
    
    backg_ab = log10(bvalsum3);
    orient tall
    
    if ZG.hold_state
        axes(cua)
        disp('hold on')
        hold on
    else
        figure(bfig);
        delete(findobj(bfig,'Type','axes'));
        rect = [0.2,  0.3, 0.70, 0.6];           % plot Freq-Mag curves
        axes('position',rect);
    end
    
    pl =semilogy(magsteps_desc,bvalsum3,'sb',...
        'LineWidth',1.0,'MarkerSize',6,...
        'MarkerFaceColor','w',...
        'MarkerEdgeColor','k',...
        'DisplayName','M >= ');
    hold on
    
    difb = [0 diff(bvalsum3) ];
    
    % Marks the point of maximum curvature
    %
    i = find(difb == max(difb));
    i = max(i);
    
    % Estimate the b-value
    %
    i2 = 1 ;
    
    xlabel('Magnitude','FontWeight','normal','FontSize',ZG.fontsz.s)
    ylabel('Cumulative Number','FontWeight','normal','FontSize',ZG.fontsz.s)
    %set(gca,'Color',color_bg)
    set(gca,'visible','on','FontSize',ZG.fontsz.s,'FontWeight','normal',...
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
    [aw, bw,  ~, ew] = wls(x',y');
    p = [bw aw];
    
    f = polyval(p,x);
    
    f = 10.^f;
    hold on
    ttm= semilogy(x,f,'r','DisplayName','linear fit to background');  % plot linear fit to backg
    set(ttm,'LineWidth',1)
    
    if ishold
        set(ttm,'color','b')
    end
    
    set(gca,'XLim',[min(mycat.Magnitude)-0.5  max(mycat.Magnitude)+0.5])
    set(gca,'YLim',[1 (mycat.Count+20)*1.4]);
    
    set(gca,'FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','normal',...
        'LineWidth',1,'TickDir','out','Ticklength',[0.02 0.02])
    
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
    
    bvalue_wls_str = ['b-value (w LS, M  >= ', num2str(M1b(1)) '): ',tt1, ' ± ', tt2 ',  a-value = ' , num2str(aw) ];
    
    if ZG.hold_state
        set(pl,'LineWidth',1.0,'MarkerSize',6,...
            'MarkerFaceColor','k','MarkerEdgeColor','k','Marker','o');
        
        text(.16, .06, bvalue_wls_str,...
            'FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s,'Color','r')
    else
        text(.16, .14, bvalue_wls_str,...
            'FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s)
        bvalue_maxlik_str = ['b-value (max lik, M >= ', num2str(min(mycat.Magnitude)) '): ',tt4, ' ± ', tt5,',   a-value = ' , num2str(av)];
        text(.16, .10,bvalue_maxlik_str,'FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s)
        set(gcf,'PaperPosition',[0.5 0.5 4.0 5.5])
    end
    
    set(gcf,'visible','on');
    ZmapMessageCenter.set_info('  ','Done')
    
    
    if ZG.hold_state

        % calculate the probability that the two distributions are different
        
        %l = mycat.Magnitude >=  M1b(1);
        gBdiff.b2 = str2double(tt1); 
        gBdiff.n2 = M1b(2);
        n = gBdiff.n1+gBdiff.n2;
        da = -2*n*log(n) + 2*gBdiff.n1*log(gBdiff.n1+gBdiff.n2*gBdiff.b1/gBdiff.b2) + 2*gBdiff.n2*log(gBdiff.n1*gBdiff.b2/gBdiff.b1+gBdiff.n2) -2;
        pr = exp(-da/2-2);

        disp(['Probability: ',  num2str(pr)]);
        tx1=['p=  ', num2str(pr,2)];
        tx2=[ 'n1: ' num2str(gBdiff.n1) ', n2: '  num2str(gBdiff.n2) ', b1: ' num2str(gBdiff.b1)  ', b2: ' num2str(gBdiff.b2)];
        txt1=text(.60, .85,tx1);%['p=  ', num2str(pr,2)],'Units','normalized');
        set(txt1,'Units','normalized','FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s)
        txt1=text(.60, .80,tx2);
        set(txt1,'FontSize',8,'Units','normalized')
    else
        gBdiff.b1 = str2double(tt1); 
        gBdiff.n1 = M1b(2);
    end
    
    bvalsumhold = bvalsum3;
    %da = 10^(aw+bw*6.5);
    %db = 10^(aw+bw*6.5)*(-6.5);
    %dp = sqrt(da^2*ew^2+db^2*0.05^2);
    %dr = 1/dp;
    
    %whitebg(gcf,[0 0 0])
    %axes(cua)
    
    
    %% menu items
    function create_my_menu()
        add_menu_divider();
        options = uimenu('Label','ZTools');
        uimenu(options,'Label','Estimate recurrence time/probability',Futures.MenuSelectedFcn,@cb_est_recurr);
        uimenu(options,'Label','Plot time series',Futures.MenuSelectedFcn,@cb_plot_ts);
        uimenu(options,'Label','Examine Nonlinearity (optimize  Mc)',Futures.MenuSelectedFcn,@cb_nonlin_optimize);
        uimenu(options,'Label','Examine Nonlinearity (Keep Mc)',Futures.MenuSelectedFcn,@cb_nonlin_keepmc);
        uimenu(options,'Label','Do not show discrete',Futures.MenuSelectedFcn,@cb_nodiscrete);
        uimenu(options,'Label','Save values to file', 'Enable','off',Futures.MenuSelectedFcn,{@calSave9,magsteps_desc, bvalsum3}); %FIXME decide what actually gets saved
        addAboutMenuItem();
    end
    
    %% callbacks
    
    function cb_est_recurr(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        plorem(onesigma, aw, bw);
    end
    
    function cb_plot_ts(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.newt2=mycat;
        timeplot();
    end
    
    function cb_nonlin_optimize(mysrc, myevt)
        [Results.bestmc,Results.bestb,Results.result_flag] = nonlinearity_index(ZG.newt2, M1b(1), 'OptimizeMc');
        Results.functioncall = sprintf('nonlinearity_index(ZG.newt2,%.1f,''OptimizeMc'')',M1b(1));
        assignin('base','Results_NonlinearityAnalysis',Results);
    end
    function cb_nonlin_keepmc(mysrc, myevt)
        [Results.bestmc,Results.bestb,Results.result_flag]=nonlinearity_index(ZG.newt2, M1b(1), 'PreDefinedMc');
        Results.functioncall = sprintf('nonlinearity_index(ZG.newt2,%.1f,''PreDefinedMc'')',M1b(1));
        assignin('base','Results_NonlinearityAnalysis',Results);
    end
    
    function cb_nodiscrete(mysrc,~)
        isChecked = strcmp(mysrc.Checked,'on');
        mysrc.Checked = tf2onoff(~isChecked);
        pl.Visible = tf2onoff(isChecked);
    end
    
end