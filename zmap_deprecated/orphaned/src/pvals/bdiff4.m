%  This routine etsimates the b-value of a curve automatically
%  The b-valkue curve is differenciated and the point
%  of maximum curvature marked.

%  Stefan Wiemer 1/95
%
global mess bfig backcat xt3 bvalsum3  bval aw bw t1 t2 t3 t4;
global  ttcat les n teb t0b cua b1 n1 b2 n2  ew si  S mrt bvalsumhold b;
global selt magco bvml avml bvls avls bv;
global hndl2 inpr1;
think
%zmap_message_center.set_info('  ','Calculating b-value...')
report_this_filefun(mfilename('fullpath'));

%%
%
% Create the input interface
%
% when run from timeplot.m selt=in and it an input menu is created
% this initiates a call back, where selt =  ca, and we go directly
% to the calculations, skipping the in put menu
%
%%

if selt == 'in'
    figure_w_normalized_uicontrolunits(...
        'Name','Mc Input Parameter',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','new', ...
        'units','points',...
        'Visible','off', ...
        'Position',[ 200 200 650 250]);
    axis off
    labelList2=[' Automatic Mcomp (max curvature) | Fixed Mc (Mc = Mmin) | Automatic Mcomp (90% probability) | Automatic Mcomp (95% probability) | Best (?) combination (Mc95 - Mc90 - max curvature)'];
    labelPos = [0.2 0.7  0.6  0.08];
    hndl2=uicontrol(...
        'Style','popup',...
        'Position',labelPos,...
        'Units','normalized',...
        'String',labelList2,...
        'Callback','inb2 =get(hndl2,''Value''); ');

    set(hndl2,'value',5);


    wls_button = uicontrol('Style','checkbox',...
        'string','Weighted least Squares',...
        'Position',[.05 .50 .2 .10], 'Callback','set(ml_button,''value'',0)',...
        'Units','normalized');


    ml_button =  uicontrol('Style','checkbox',...
        'string','Maximum Likelihood',...
        'Position',[.47 .50 .2 .10], 'Callback','set(wls_button,''value'',0)',...
        'Units','normalized');

    set(ml_button,'value',1);

    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.60 .05 .15 .12 ],...
        'Units','normalized','Callback','close;done','String','Cancel');

    go_button1=uicontrol('Style','Pushbutton',...
        'Position',[.20 .05 .15 .12 ],...
        'Units','normalized',...
        'Callback',' inpr1 =get(hndl2,''Value'');wls_button =get(wls_button,''Value'');ml_button =get(ml_button,''Value'');close,selt =''ca'';, bdiff4',...
        'String','Go');



    set(gcf,'visible','on');
    watchoff
end

%%
% selt = ca after input menu is run and parameters have been set
%%

if selt == 'ca'

    %%
    %
    % check to see if figure exists
    % if does -- draw over
    % if it does not, create the window
    %
    %%

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
            'pos',[ 0.300  0.3 0.4 0.6]);
        ho=false;
        
        uicontrol('Units','normal',...
            'Position',[.0 .85 .08 .06],'String','Info ',...
             'Callback','infoz(1)');
        uicontrol('Units','normal',...
            'Position',[.0 .45 .10 .06],'String','Manual ',...
             'Callback','bfitnew(newt2)');

        uicontrol('Units','normal',...
            'Position',[.0 .35 .10 .06],'String','RecTime ',...
             'Callback','plorem');

        uicontrol('Units','normal',...
            'Position',[.0 .25 .10 .06],'String','TimePlot ',...
             'Callback','timeplot');

        matdraw




        uicontrol('Units','normal',...
            'Position',[.0 .65 .08 .06],'String','Save ',...
             'Callback',{@calSave9,xt3, bvalsum3})


    end

    maxmag = ceil(10*max(newt2.Magnitude))/10;
    mima = min(newt2.Magnitude);
    if mima > 0 ; mima = 0 ; end

    % number of mag units
    nmagu = (maxmag*10)+1;

    bval = zeros(1,nmagu);
    bvalsum = zeros(1,nmagu);
    bvalsum3 = zeros(1,nmagu);

    %%
    %
    % bval contains the number of events in each bin
    % bvalsum is the cum. sum in each bin
    % bval2 is number events in each bin, in reverse order
    % bvalsum3 is reverse order cum. sum.
    % xt3 is the step in magnitude for the bins == .1
    %
    %%

    [bval,xt2] = hist(newt2.Magnitude,(mima:0.1:maxmag));
    bvalsum = cumsum(bval); % N for M <=
    bval2 = bval(length(bval):-1:1);
    bvalsum3 = cumsum(bval(length(bval):-1:1));    % N for M >= (counted backwards)
    xt3 = (maxmag:-0.1:mima);

    backg_ab = log10(bvalsum3);

    if hold_state
        axes(cua)
        disp('hold on')
        hold on
    else
        figure_w_normalized_uicontrolunits(bfig);delete(gca);delete(gca); delete(gca); delete(gca)
        rect = [0.22,  0.3, 0.65, 0.6];           % plot Freq-Mag curves
        axes('position',rect);
    end

    %%
    % plot the cum. sum in each bin  %%
    %%

    pl =semilogy(xt3,bvalsum3,'sb');
    set(pl,'LineWidth',1.0,'MarkerSize',6,...
        'MarkerFaceColor','w','MarkerEdgeColor','k');
    hold on

    %%
    % CALCULATE the diff in cum sum from the previous biin
    %%


    xlabel('Magnitude','FontWeight','normal','FontSize',14)
    ylabel('Cumulative Number','FontWeight','normal','FontSize',14)
    set(gca,'visible','on','FontSize',12,'FontWeight','normal',...
        'FontWeight','bold','LineWidth',1.0,'TickDir','out',...
        'Box','on','Tag','cufi')

    cua = gca;

    %%
    % Estimate the b value -- based on one of 5 methods
    %
    % calculates max likelihood b value(bvml) && WLS(bvls)
    %
    %%

    %% SET A DEFAULT VALUE FOR Nmin.
    %TO BE CHANGED IF NEEDED.
    Nmin = 50;

    bvs=newt2;
    b=newt2;


    %% enough events??
    if length(bvs(:,6)) >= Nmin

        %%
        % calculation based on 90% probability
        %%
        if inpr1 == 3
            mcperc_ca3;
            l = bvs(:,6) >= Mc90-0.05;
            magco = Mc90;
            if length(b(l)) >= Nmin
                [bvls magco0 stanls avls me mer me2,  pr] =  bvalca3(b(l,:),2,2);
                [mea bvml stanml avml ] =  bmemag(b(l,:));

            else
                bvls = nan; bvml = nan, magco = nan; avls = nan; avml = nan; stanml = nan; stanls = nan;
            end

            %%
            % calculation based on 95% probability
            %%
        elseif inpr1 == 4
            mcperc_ca3;
            l = bvs(:,6) >= Mc95-0.05;
            magco = Mc95;
            if length(b(l)) >= Nmin
                [bvls magco0 stanls avls me mer me2,  pr] =  bvalca3(b(l,:),2,2);
                [mea bvml stanml avml ] =  bmemag(b(l,:));
            else
                bvls = nan; bvml = nan, magco = nan; avls = nan; avml = nan; stanml = nan; stanls = nan;
            end
            %%
            % calculation based on best combination of 90% and 95% probability -- default
            %%

        elseif inpr1 == 5
            mcperc_ca3;
            if isnan(Mc95) == 0 
                magco = Mc95;
            elseif isnan(Mc90) == 0 
                magco = Mc90;
            else
                [bv magco stan av me mer me2,  pr] =  bvalca3(bvs,1,1);
            end
            l = bvs(:,6) >= magco-0.05;
            if length(bvs(l)) >= Nmin
                [bvls magco0 stanls avls me mer me2,  pr] =  bvalca3(bvs(l,:),2,2);
                [mea bvml stanml avml ] =  bmemag(b(l,:));
            else
                bvls = nan; bvml = nan, magco = nan; avls = nan; avml = nan; stanml = nan; stanls = nan;
            end

            %%
            % calculation based on MAX CURVATURE
            %%
        elseif inpr1 == 1
            [bvls magco stanls avls me mer me2,  pr] =  bvalca3(b,1,1);
            l = bvs(:,6) >= magco-0.05;
            if length(b(l,:)) >= Nmin
                [mea bvml stanml avml ] =  bmemag(b(l,:));
            else
                bvls = nan; bvml = nan, magco = nan; avls = nan; avml = nan; stanml = nan; stanls = nan;
            end

            %%
            % calculation based on FIXED Mc
            %%
        elseif inpr1 == 2
            [bvls magco stanls avls me mer me2,  pr] =  bvalca3(b,2,2);
            [mea bvml stanml avml ] =  bmemag(b);
            magco = min(newt2.Magnitude);
        end

    else
        bvls = nan; bvml = nan, magco = nan; avls = nan; avml = nan; stanml = nan; stanls = nan;
    end


    %%
    % calculate limits of line to plot for b value line
    %%

    index_low=find(xt3 < magco+.05 & xt3 > magco-.05);
    mag_hi = xt3(1);
    index_hi = 1;
    mz = xt3 <= mag_hi & xt3 >= magco-.0001;
    mag_zone=xt3(mz);

    y = backg_ab(mz);

    %%
    % PLOTS an 'x' in the point of Mc
    %%

    te = semilogy(xt3(index_low),bvalsum3(index_low),'xk');
    set(te,'LineWidth',2.5,'MarkerSize',6)

    te = text(xt3(index_low+2),bvalsum3(index_low-3),'Mc');
    set(te,'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m,'Color','k')


    %%
    % Plots an 'x' in the last square (first bin)
    %%

    te = semilogy(xt3(1),bvalsum3(1),'xk');
    set(te,'LineWidth',1.5,'MarkerSize',6)
    te = semilogy(xt3(index_hi),bvalsum3(index_hi),'xk');
    set(te,'LineWidth',1.5,'MarkerSize',6)


    %%
    % Plotting of error lines, and b value line
    %%

    pause(0.1)


    %%
    % Set to correct method, maximum like or least squares
    %%

    if wls_button == 1
        sol_type='Weighted Least Squares Solution';
        bw=bvls;
        aw=avls;
        ew=stanls;
    else
        sol_type = 'Maximum Likelihood Solution';
        bw=bvml;
        aw=avml;
        ew=stanml;
    end

    M1b = [];
    M1b = [xt3(index_low) bvalsum3(index_low)];

    M2b = [];
    M2b =  [xt3(index_hi) bvalsum3(index_hi)];


    %%
    % create and draw a line corresponding to the b value
    %%

    p = [ -1*bw aw];
    %[p,S] = polyfit(mag_zone,y,1);
    f = polyval(p,mag_zone);
    f = 10.^f;
    hold on
    ttm= semilogy(mag_zone,f,'k');                         % plot linear fit to backg
    set(ttm,'LineWidth',2.0)

    std_backg = ew;      % standard deviation of fit

    %%
    % Error Bar Calculation -- call to pdf_calc.m
    %%

    %pdf_calc;
    set(gca,'XLim',[min(b(:,6))-0.5  max(b(:,6))+0.5])
    set(gca,'YLim',[1 length(b(:,3)+20)*1.8]);


    p=-p(1,1);
    p=fix(100*p)/100;
    tt1=num2str(bw,3);
    tt2=num2str(std_backg,2);


    tmc=num2str(xt3(index_low));

    rect=[0 0 1 1];
    h2=axes('position',rect);
    set(h2,'visible','off');

    if hold_state
        set(pl,'LineWidth',1.0,'MarkerSize',6,...
            'MarkerFaceColor','k','MarkerEdgeColor','k','Marker','^');
        txt1=text(.16, .10,['b-value = ',tt1, ' +/- ', tt2 ',a-value = ' , num2str(aw) ]);
        set(txt1,'FontWeight','normal','FontSize',12,'Color','r');
        txt1=text(.16, .06,['Magnitude of Completeness = ',tmc]);
        set(txt1,'FontWeight','normal','FontSize',12,'Color','r');
    else
        txt1=text(.16, .18,['b value = ',tt1,' +/- ',tt2,',  a value = ',num2str(aw) ]);
        set(txt1,'FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.m);
        set(gcf,'PaperPosition',[0.5 0.5 4.0 5.5]);
        txt1=text(.16, .22,sol_type );
        set(txt1,'FontWeight','bold','FontSize',14,'Color','k')
        txt1=text(.16, .14,['Magnitude of Completeness = ',tmc]);
        set(txt1,'FontWeight','normal','FontSize',12,'Color','k')
    end

    set(gcf,'visible','on');
    zmap_message_center.set_info('  ','Done')
    done

    if hold_state
        % calculate the probability that the two distributions are different
        %l = newt2.Magnitude >=  M1b(1);
        b2 = str2double(tt1); n2 = M1b(2);
        n = n1+n2;
        da = -2*n*log(n) + 2*n1*log(n1+n2*b1/b2) + 2*n2*log(n1*b2/b1+n2) -2;
        pr = exp(-da/2-2);
        disp(['Probability: ',  num2str(pr)]);
        txt1=text(.60, .85,['p=  ', num2str(pr,2)],'Units','normalized');
        set(txt1,'FontWeight','normal','FontSize',12)
        txt1=text(.60, .80,[ 'n1: ' num2str(n1) ', n2: '  num2str(n2) ', b1: ' num2str(b1)  ', b2: ' num2str(b2)]);
        set(txt1,'FontSize',12,'Units','normalized')
    else
        b1 = str2double(tt1); n1 = M1b(2);
    end

end
