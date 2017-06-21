function  bdiffma(newcat)
    %  This routine etsimates the b-value of a curve automatically
    %  The b-valkue curve is differenciated and the point
    %  of maximum curvature marked. The b-value will be calculated
    %  using this point and the point half way toward the high
    %  magnitude end of the b-value curve.

    %  Stefan Wiemer 1/95
    %
    think
    %zmap_message_center.set_info('  ','Calculating b-value...')
    global cluscat mess bfig backcat fontsz ho xt3 bvalsum3
    global ttcat les n teb t0b cb1 cb2 cb3 cua b1 b2 n1 n2
    report_this_filefun(mfilename('fullpath'));

    [existFlag,figNumber]=figure_exists('frequency-magnitude distribution',1);
    if existFlag
        % figure_w_normalized_uicontrolunits(bfig);
        bfig = figNumber;
        %delete(gca)
        %set(bfig,'visible','off')
    else
        bfig=figure_w_normalized_uicontrolunits(...                  %build figure for plot
            'Units','normalized','NumberTitle','off',...
            'Name','frequency-magnitude distribution',...
            'MenuBar','none',...
            'visible','off',...
            'pos',[ 0.300  0.7 0.5 0.5]);


        
        uicontrol('Units','normal',...
            'Position',[.0 .85 .08 .06],'String','Info ',...
             'Callback','infoz(1)');
        uicontrol('Units','normal',...
            'Position',[.0 .55 .10 .06],'String','Manual ',...
             'Callback','bfitnew(newcat)');
        matdraw

        uicontrol('Units','normal',...
            'Position',[.0 .65 .08 .06],'String','Save ',...
             'Callback',{@calSave9,xt3, bvalsum3})


    end

    maxmag = max(newcat.Magnitude);
    mima = min(newcat.Magnitude);
    if mima > 0 ; mima = 0 ; end

    % number of mag units
    nmagu = (maxmag*10)+1;

    bval = zeros(1,nmagu);
    bvalsum = zeros(1,nmagu);
    bvalsum3 = zeros(1,nmagu);

    [bval,xt2] = hist(newcat.Magnitude,(mima:0.1:maxmag));
    bvalsum = cumsum(bval);                        % N for M <=
    bvalsum3 = cumsum(bval(length(bval):-1:1));    % N for M >= (counted backwards)
    xt3 = (maxmag:-0.1:mima);


    backg_be = log10(bvalsum);
    backg_ab = log10(bvalsum3);
    orient tall

    if ho(1:2) == 'ho'
        axes(cua)
        hold on
    else
        figure_w_normalized_uicontrolunits(bfig);delete(gca);delete(gca);delete(gca);delete(gca)
        rect = [0.2,  0.3, 0.70, 0.6];           % plot Freq-Mag curves
        axes('position',rect);
    end

    pl =semilogy(xt3,bvalsum3,'b');
    set(pl,'LineWidth',2.0)
    hold on
    %semilogy(xt3,bvalsum3,'om')
    difb = [0 diff(bvalsum3) ];
    %pl =semilogy(xt3,difb,'g');
    %set(pl,'LineWidth',2.0)
    %semilogy(xt3,difb,'g')
    grid

    % Marks the point of maximum curvature
    %
    i = find(difb == max(difb));
    i = max(i);
    %te = semilogy(xt3(i),difb(i),'xk');
    %set(te,'LineWidth',2,'MarkerSize',ms10)
    %te = semilogy(xt3(i),bvalsum3(i),'xk');
    %set(te,'LineWidth',2,'MarkerSize',ms10)

    % Estimate the b-value
    %
    i2 = 1 ;
    %te = semilogy(xt3(i2),difb(i2),'xk');
    %set(te,'LineWidth',2,'MarkerSize',ms10)
    %te = semilogy(xt3(i2),bvalsum3(i2),'xk');
    %set(te,'LineWidth',2,'MarkerSize',ms10)

    xlabel('Magnitude','FontWeight','bold','FontSize',fontsz.m)
    ylabel('Cumulative Number','FontWeight','bold','FontSize',fontsz.m)
    set(gca,'Color',[cb1 cb2 cb3])
    set(gca,'visible','on','FontSize',fontsz.m,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on')

    cua = gca;


    par2 = 0.1 * max(bvalsum3);
    par3 = 0.12 * max(bvalsum3);
    M1b = [];
    M1b = [xt3(i) bvalsum3(i)];
    tt3=num2str(fix(100*M1b(1))/100);
    text( M1b(1),M1b(2),['|: M1=',tt3],'Fontweight','bold' )

    M2b = [];
    M2b =  [xt3(i2) bvalsum3(i2)];
    tt4=num2str(fix(100*M2b(1))/100);
    %text( M2b(1),M2b(2),['|: M2=',tt4],'Fontweight','bold' )

    ll = xt3 >= M1b(1) & xt3 <= M2b(1);
    x = xt3(ll);

    %n   = ((M2b(1)+0.05) - (M1b(1)-0.05))/0.1;
    %les = (mean(newcat.Magnitude) - (min(newcat.Magnitude-0.05)))/0.1;
    %global n les
    %so = fzero('sofu',1.0);
    %bv = log(so)/(-2.3026*0.1);
    [ av,bv,si] = bmemag(newcat);

    pause(0.1)

    y = backg_ab(ll);
    %[p,s] = polyfit(x,y,1)                    % fit a line to background
    [aw bw,  ew] = wls(x',y');
    p = [bw aw];
    f = polyval(p,x);
    (teb-t0b)/(10.^ polyval(p,5))
    (teb-t0b)/(10.^ polyval(p,6))
    (teb-t0b)/(10.^ polyval(p,7))
    (teb-t0b)/(10.^ polyval(p,8))
    f = 10.^f;
    hold on
    ttm= semilogy(x,f,'r');                         % plot linear fit to backg
    set(ttm,'LineWidth',1)
    set(gca,'XLim',[min(newcat.Magnitude)-0.5  max(newcat.Magnitude)+1.0])
    r = corrcoef(x,y);
    r = r(1,2);
    std_backg = ew;      % standard deviation of fit

    p=-p(1,1);
    p=fix(100*p)/100;
    std_backg=fix(100*std_backg)/100;
    tt2=num2str(std_backg);
    tt1=num2str(p);
    tt4=num2str(bv,2);
    tt5=num2str(si,2);


    rect=[0 0 1 1];
    h2=axes('position',rect);
    set(h2,'visible','off');

    if ho(1:2) == 'no'
        txt1=text(.16, .18,['b-value (w LS, M  > ', num2str(M1b(1)) '): ',tt1, ' +/- ', tt2]);
        set(txt1,'FontWeight','bold','FontSize',fontsz.m)
        txt1=text(.16, .12,['b-value (max lik, M > ', num2str(min(newcat.Magnitude)) '): ',tt4, ' +/- ', tt5]);
        set(txt1,'FontWeight','bold','FontSize',fontsz.m)

    else
        txt1=text(.16, .06,['b-value (weighted least square): ',tt1, ' +/- ', tt2]);
        set(txt1,'FontWeight','bold','FontSize',fontsz.m,'Color','r')
    end
    set(gcf,'visible','on');
    zmap_message_center.set_info('  ','Done')
    done

    if ho(1:2) == 'ho'
        % calculate the probability that the two distributins are differnt
        b2 = str2double(tt1); n2 = newcat.Count;
        n = n1+n2;
        da = -2*n*log(n) + 2*n1*log(n1+n2*b1/b2) + 2*n2*log(n1*b2/b1+n2) -2;
        pr = exp(-da/2-2);
        disp(['Probability: ',  num2str(pr)]);
        txt1=text(.65, .85,['Utsu Test: ', num2str(pr)]);
        set(txt1,'FontWeight','bold','FontSize',fontsz.m)
    else
        b1 = str2double(tt1); n1 = newcat.Count;
    end




