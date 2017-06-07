function clbvalpl(var1)
    %clbvalpl.m                      A.Allmann
    %
    %   Calculates Freq-Mag functions (b-value) for a catalog
    %   works on cluscat or newclcat

    % Last modification 8/95

    global newclcat cluscat mess bfig backcat
    global ttcat ttm text3 text4 newcat txt1 txt2 txt3


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
            figure_w_normalized_uicontrolunits(bfig);
            clf reset;
            set(bfig,'visible','off')
        else
            bfig=figure;                     %build figure for plot
        end
        set(bfig,'Units','normalized','NumberTitle','off','Name','b-value curve');
        set(gcf,'pos',[ 0.435  0.8 0.5 0.5])
        matdraw
        uicontrol('Style','Pushbutton',...
            'Callback','myprint',...
            'Units','normalized',...
            'String','Print','Position',[0.02 .68 .08 .05]);

        uicontrol('Style','Pushbutton',...
            'Callback','set(bfig,''visible'',''off'');welcome;done',...
            'Units','normalized',...
            'String','Close','Position',[0.02 .88 .08 .05]);
        uicontrol('Style','Pushbutton',...
            'Callback','clinfo(8)',...
            'Units','normalized',...
            'String','Info','Position',[0.02 .78 .08 .05]);


        set(gcf,'visible','on');
    end
    maxmag = max(newcat(:,6));

    % number of mag units
    nmagu = (maxmag*10)+1;

    bval = zeros(1,nmagu);
    % bvalsum = zeros(1,nmagu);
    bvalsum3 = zeros(1,nmagu);

    [bval,xt2] = hist(newcat(:,6),(0:0.1:maxmag));
    % bvalsum = cumsum(bval);                        % N for M <=
    bvalsum3 = cumsum(bval(length(bval):-1:1));    % N for M >= (counted backwards)
    xt3 = (maxmag:-0.1:0);

    % backg_be = log10(bvalsum);
    backg_ab = log10(bvalsum3);
    orient tall
    rect = [0.2,  0.3, 0.70, 0.6];           % plot Freq-Mag curves
    axes('position',rect);
    % semilogy(xt2,bvalsum,'om')
    % hold on
    % semilogy(xt2,bvalsum,'-.m')
    semilogy(xt3,bvalsum3,'-.m')
    hold on
    semilogy(xt3,bvalsum3,'om')
    if var1==1
        xlabel('Magnitude ')
        ylabel('Cumulative Number')
    end
    figure_w_normalized_uicontrolunits(mess);
    clf;
    str=['Please select two magnitudes \newlineto be used in the calculation \newlineof the straightline fit.\newlineWait to push Info or Close\newlineafter the selection'];
    te = text(0.01,0.9,str) ;

    set(te,'FontSize',14);
    set(gca,'visible','off');


    disp('Please select two magnitudes to be used in the caclulation of the straight   line fit')

    figure_w_normalized_uicontrolunits(bfig)
    if var1==2
        delete(ttm);delete(text3);delete(text4);delete(txt1);delete(txt2);delete(txt3);
    end
    seti = uicontrol('Units','normal',...
        'Position',[.4 .01 .2 .05],'String','Select Mag1 ');

    pause(1)

    par2 = 0.1 * max(bvalsum3);
    par3 = 0.12 * max(bvalsum3);
    M1b = [];
    M1b = ginput(1);
    tt3=num2str(fix(100*M1b(1))/100);
    text3=text( M1b(1),M1b(2),['|: M1=',tt3] );
    set(seti,'String','Select Mag2');

    pause(0.1)

    M2b = [];
    M2b = ginput(1);
    tt4=num2str(fix(100*M2b(1))/100);
    text4=text( M2b(1),M2b(2),['|: M2=',tt4] );

    pause(0.1)
    delete(seti)

    eqnumber=length(find(newcat(:,6)>M1b(1) & newcat(:,6)<M2b(1)));
    tt6=num2str(eqnumber);

    ll = xt3 > M1b(1) & xt3 < M2b(1);
    x = xt3(ll);
    y = backg_ab(ll);
    [p,s] = polyfit(x,y,1);                   % fit a line to background
    f = polyval(p,x);
    f = 10.^f;
    hold on
    ttm= semilogy(x,f,'b');                         % plot linear fit to backg
    set(ttm,'LineWidth',2)
    r = corrcoef(x,y);
    r = r(1,2);
    std_backg = std(y - polyval(p,x));      % standard deviation of fit

    p=-p(1,1);
    p=fix(100*p)/100;
    std_backg=fix(100*std_backg)/100;
    tt2=num2str(std_backg);
    tt1=num2str(p);

    rect=[0 0 1 1];
    h2=axes('position',rect);
    set(h2,'visible','off');
    txt1=text(.16, .18,['B-Value: ',tt1]);
    txt2=text(.16, .12,['Standard Deviation: ',tt2]);
    txt3=text(.16, .06,['Eqs in limits: ',tt6]);
    uicontrol('Style','Pushbutton',...
        'Callback','clbvalpl(2)',...
        'Units','normalized',...
        'String','Repeat','Position',[0.7 .1 .12 .08]);
    welcome;

