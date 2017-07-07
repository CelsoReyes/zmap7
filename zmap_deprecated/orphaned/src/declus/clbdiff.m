function clbdiff(var1)
    %  This routine etsimates the b-value of a curve automatically
    %  The b-value curve is differenciated and the point
    %  of maximum curvature marked. The b-value will be calculated
    %  using this point and the point half way toward the high
    %  magnitude end of the b-value curve.

    %  Stefan Wiemer 1/95
    %
    % last modification 10/95 Alexander Allmann

    report_this_filefun(mfilename('fullpath'));



    global newclcat cluscat mess bfig backcat
    global ttcat ttm text3 text4 newcat txt1 txt2 txt3
    global color_bg teb t0b

    if var1==1
        if isempty(ttcat)
            if ~isempty(newclcat)  &&  ~isempty(backcat)
                if length(newclcat(:,1))>length(backcat(:,1))
                    newcat=cluscat;
                else
                    newcat=newclcat;
                end
            elseif isempty(newclcat)              %set catalog for bvalue-plot
                newcat=cluscat;
            else
                newcat=newclcat;
            end
        else
            newcat=ttcat;
        end

        [existFlag,figNumber]=figure_exists('b-value curve',1);
        if existFlag
            %figure_w_normalized_uicontrolunits(bfig);
            %delete(gca)
            %set(bfig,'visible','off')
        else
            bfig=figure_w_normalized_uicontrolunits(...                  %build figure for plot
                'Units','normalized','NumberTitle','off',...
                'Name','b-value curve',...
                'MenuBar','none',...
                'visible','off',...
                'pos',[ 0.300  0.7 0.5 0.5]);
            ho=false;
            
            matdraw

        end

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

    if hold_state
        axes(cua)
        hold on
    else
        figure_w_normalized_uicontrolunits(bfig);delete(gca);delete(gca)
        rect = [0.2,  0.3, 0.70, 0.6];           % plot Freq-Mag curves
        axes('position',rect);
    end

    pl =semilogy(xt3,bvalsum3,'b');
    set(pl,'LineWidth',2.0)
    hold on
    %semilogy(xt3,bvalsum3,'om')
    difb = [0 diff(bvalsum3) ];
    pl =semilogy(xt3,difb,'g');
    set(pl,'LineWidth',2.0)
    %semilogy(xt3,difb,'g')
    grid

    % Marks the point of maximum curvature
    %
    i = find(difb == max(difb));
    i = max(i);
    te = semilogy(xt3(i),difb(i),'xk');
    set(te,'LineWidth',2,'MarkerSize',ms10)
    te = semilogy(xt3(i),bvalsum3(i),'xk');
    set(te,'LineWidth',2,'MarkerSize',ms10)

    % Estimate the b-value
    %
    i2 = 1 ;
    te = semilogy(xt3(i2),difb(i2),'xk');
    set(te,'LineWidth',2,'MarkerSize',ms10)
    te = semilogy(xt3(i2),bvalsum3(i2),'xk');
    set(te,'LineWidth',2,'MarkerSize',ms10)

    xlabel('Magnitude','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    ylabel('Cumulative Number','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    set(gca,'Color',color_bg)
    set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
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
    text( M2b(1),M2b(2),['|: M2=',tt4],'Fontweight','bold' )

    ll = xt3 >= M1b(1) & xt3 <= M2b(1);
    x = xt3(ll);


    % n   = ((M2b(1)+0.05) - (M1b(1)-0.05))/0.1;
    %les = (mean(newcat.Magnitude) - (min(newcat.Magnitude-0.05)))/0.1;
    %global n les
    %so = fzero('sofu',1.0);
    %bv = log(so)/(-2.3026*0.1);
    [ av, bv, si] = bmemag(newcat)  ;


    pause(0.1)

    y = backg_ab(ll);
    %[p,s] = polyfit(x,y,1)                    % fit a line to background
    [aw bw,  ew] = wls(x',y');
    p = [bw aw];
    f = polyval(p,x);
    (teb-t0b)/(10.^ polyval(p,6.0))
    disp('test')
    f = 10.^f;
    hold on
    ttm= semilogy(x,f,'r');                         % plot linear fit to backg
    set(ttm,'LineWidth',1)
    set(gca,'XLim',[min(newcat.Magnitude)-0.5  max(newcat.Magnitude)+0.3])
    r = corrcoef(x,y);
    r = r(1,2);
    %std_backg = std(y - polyval(p,x));      % standard deviation of fit
    std_backg = ew;      % standard deviation of fit

    p=-p(1,1);
    p=fix(100*p)/100;
    std_backg=fix(100*std_backg)/100;
    tt1=num2str(p);
    tt2=num2str(std_backg);
    tt4=num2str(bv,2);
    tt5=num2str(si,2);



    rect=[0 0 1 1];
    h2=axes('position',rect);
    set(h2,'visible','off');

    txt1=text(.16, .18,['b-value (w LS, M  > ', num2str(M1b(1)) '): ',tt1, ' +/- ', tt2]);
    set(txt1,'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    txt1=text(.16, .12,['b-value (max lik, M > ', num2str(min(newcat.Magnitude)) '): ',tt4, ' +/- ', tt5]);
    set(txt1,'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)


    set(gcf,'visible','on');
    zmap_message_center.set_info('  ','Done')
    done


