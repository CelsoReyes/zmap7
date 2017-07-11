%
%   Calculates Freq-Mag functions (b-value) for two time-segments
%   finds best fit to the foreground for a modified background
%   assuming a change in time of the following types:
%   Mnew = Mold + d     , i.e. Simple magnitude shift
%   Mnew = c*Mold + d   , i.e. Mag stretch plus shift
%   Nnew = fac*Nold     , i.e. Rate change (N = number of events)
%                                      R. Zuniga IGF-UNAM/GI-UAF  6/94
%                                      Rev. 4/2001

%TODO DELETE THIS -> Z TOOL REMOVE COMPARE TWO RATES(FIT)


global p

report_this_filefun(mfilename('fullpath'));

% This is the info window text
%
ttlStr='Comparing Seismicity rates ';
hlpStr1map= ...
    ['                                                '
    ' To be Implemented                              '
    '                                                '];


if ic == 0
    format short;
    fac = 1.0;

    bvfig = figure;
    set(bvfig,'Units','normalized','NumberTitle','off','Name','b-value curves');
    set(bvfig,'pos',[ 0.435  0.3 0.5 0.5])

    if isempty(ZG.newcat)
        ZG.newcat = a;
    end
    maxmag = max(ZG.newcat.Magnitude);
    mima = min(ZG.newcat.Magnitude);
    if mima > 0
        mima = 0 ;
    end
    t0b = min(ZG.newcat.Date);
    teb = max(ZG.newcat.Date);
    n = ZG.newcat.Count;
    tdiff = round(teb - t0b);

    % number of mag units
    nmagu = (maxmag-mima*10)+1;

    bval = zeros(1,nmagu);
    bval2 = zeros(1,nmagu);
    bvalsum = zeros(1,nmagu);
    bvalsum2 = zeros(1,nmagu);
    bvalsum3 = zeros(1,nmagu);
    bvalsum4 = zeros(1,nmagu);
    backg_ab = [ ];
    foreg_ab = [ ];
    backg_be = [ ];
    foreg_be = [ ];
    foreg = [ ];
    backg_beN = [ ];
    backg_abN = [ ];
    td12 = t2p(1) - t1p(1);
    td34 = t4p(1) - t3p(1);

    l = ZG.newcat.Date > t1p(1) & ZG.newcat.Date < t2p(1) ;
    backg =  ZG.newcat.subset(l);
    [bval,xt2] = hist(backg(:,6),(mima:0.1:maxmag));
    bval = bval/td12;                      % normalization
    bvalsum = cumsum(bval);                        % N for M <=
    bvalsum3 = cumsum(bval(length(bval):-1:1));    % N for M >= (counted backwards)
    xt3 = (maxmag:-0.1:mima);
    [cumux, xt] = hist(ZG.newcat(l,3),t1p(1):par1/365:t2p(1));

    l = ZG.newcat.Date > t3p(1) & ZG.newcat.Date < t4p(1) ;
    foreg = ZG.newcat.subset(l);
    bval2 = histogram(foreg(:,6),(mima:0.1:maxmag));
    bval2 = bval2/td34;                     % normallization
    bvalsum2 = cumsum(bval2);
    bvalsum4 = cumsum(bval2(length(bval2):-1:1));
    [cumux2, xt] = hist(ZG.newcat(l,3),t3p(1):par1/365:t4p(1));
    mean1 = mean(cumux);
    mean2 = mean(cumux2);
    var1 = cov(cumux);
    var2 = cov(cumux2);
    zscore = (mean1 - mean2)/(sqrt(var1/length(cumux)+var2/length(cumux2)));

    backg_be = log10(bvalsum);
    backg_ab = log10(bvalsum3);
    foreg_be = log10(bvalsum2);
    foreg_ab = log10(bvalsum4);

    orient landscape
    rect = [0.2,  0.2, 0.70, 0.70];           % plot Freq-Mag curves
    axes('position',rect)
    semilogy(xt3,bvalsum3,'om')
    hold on
    semilogy(xt3,bvalsum4,'xb')

    te1 = max([bvalsum  bvalsum2 bvalsum4 bvalsum3]);
    te1 = te1 - 0.2*te1;
    title2([file1 '   o: ' num2str(t1p(1)) ' - ' num2str(t2p(1)) '     x: ' num2str(t3p(1)) ' - '  num2str(t4p(1)) ],'FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold')

    xlabel('Magnitude','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold')
    ylabel('Cum. Number -normalized','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold')
    %  find b-values;
    set(gca,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.s,'Linewidth',1.2)

    figure_w_normalized_uicontrolunits(mess)
    clf;
    cla;
    set(gcf,'Name','Magnitude selection ');
    set(gca,'visible','off');
    txt5 = text(...
        'EraseMode','normal',...
        'Position',[.01 0.99 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Please select two magnitudes to be used');
    txt1 = text('Position',[.01 0.84 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','in the calculation of straight line fit i.e.');
    txt2 = text('Position',[.01 0.66 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','b value of BACKGROUND (o)');

    figure_w_normalized_uicontrolunits(bvfig)
    seti = uicontrol(...
        'Units','normal','Position',[.4 .01 .2 .05],...
        'String','Select Mag1 ');

    pause(1)

    par2 = 0.1 * max(bvalsum3);
    par3 = 0.12 * max(bvalsum3);
    M1b = [];
    M1b = ginput(1);
    tx1 = text( M1b(1),M1b(2),['M1'] );
    set(seti,'String','Select Mag2');

    pause(0.1)

    M2b = [];
    M2b = ginput(1);
    tx2 = text( M2b(1),M2b(2),['M2'] );

    pause(0.1)
    delete(seti)

    ll = xt3 > M1b(1) & xt3 < M2b(1);
    x = xt3(ll);
    y = backg_ab(ll);
    p  = polyfit(x,y,1);                  % fit a line to background
    f = polyval(p,x);
    f = 10.^f;
    hold on
    semilogy(x,f,'r')                         % plot linear fit to backg
    r = corrcoef(x,y);
    r = r(1,2);
    std_backg = std(y - polyval(p,x));      % standard deviation of fit

    figure_w_normalized_uicontrolunits(mess)
    clf;
    cla;
    set(gcf,'Name','Magnitude selection ');
    set(gca,'visible','off');
    txt5 = text(...
        'EraseMode','normal',...
        'Position',[.01 0.99 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Please select two magnitudes to be used');
    txt1 = text('Position',[.01 0.84 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','in the calculation of straight line fit i.e.');
    txt2 = text(...
        'Position',[.01 0.66 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','b value of FOREGROUND (x)');

    figure_w_normalized_uicontrolunits(bvfig)
    seti = uicontrol('Units','normal',...
        'Position',[.4 .01 .2 .05],'String','Select Mag1 ');

    pause(1)

    par2 = 0.1 * max(bvalsum3);
    par3 = 0.12 * max(bvalsum3);
    M1f = [];
    M1f = ginput(1);
    tx3 = text( M1f(1),M1f(2),['M1'] )
    set(seti','String','Select Mag2');

    pause(0.1)

    M2f = [];
    M2f = ginput(1);
    tx4 = text( M2f(1),M2f(2),['M2'] )

    pause(0.1)
    delete(seti)

    l = xt3 > M1f(1) & xt3 < M2f(1);
    x = xt3(l);
    y = foreg_ab(l);
    pp = polyfit(x,y,1);
    % fit a line to foreground
    f = polyval(pp,x);
    f = 10.^f;
    semilogy(x,f,'r')                   % plot fit to foreg
    rr = corrcoef(x,y);
    rr = rr(1,2);
    std_foreg = std(y - polyval(pp,x));      % standard deviation of fit

    figure_w_normalized_uicontrolunits(mess)
    clf
    set(gca,'visible','off')
    set(gcf,'Units','normalized','pos',[ 0.03  0.1 0.4 0.7])
    set(gcf,'Name','Compare Results');
    orient tall
    te = text(0.,0.99, ['   Catalogue : ' file1]) ;
    set(te,'FontSize',ZmapGlobal.Data.fontsz.s);
    stri = [ 'Background (o):   ' num2str(t1p(1)) '  to  ' num2str(t2p(1)) ];
    te = text(0.01,0.93, stri) ;
    set(te,'FontSize',ZmapGlobal.Data.fontsz.s);
    aa = p(2) *1000.0;
    aa = round(aa);
    aa = aa/1000.0;
    bb = p(1) *1000.0;
    bb = round(bb);
    bb = bb/1000.0;          % round to 0.001
    stri = [' Log N = ' num2str(aa)  num2str(bb) '*M ' ];
    te = text(0.01,0.88, stri) ;
    set(te,'FontSize',ZmapGlobal.Data.fontsz.s);
    stri = [ 'Foreground (x):   ' num2str(t3p(1)) '  to  ' num2str(t4p(1)) ];
    te = text(0.01,0.83, stri) ;
    set(te,'FontSize',ZmapGlobal.Data.fontsz.s);
    aa = pp(2) *1000.0;
    aa = round(aa);
    aa = aa/1000.0;
    bb = pp(1) *1000.0;
    bb = round(bb);
    bb = bb/1000.0;          % round to 0.001
    stri = [' Log N = ' num2str(aa) num2str(bb) '*M '];
    te = text(0.01,0.78, stri) ;
    set(te,'FontSize',ZmapGlobal.Data.fontsz.s);
    disp([' Correlation coefficient for background = ', num2str(r) ]);                                disp([' Correlation coefficient for foreground = ', num2str(rr) ]);
    %  find simple shift
    % first find Mmin ( M for which the background relation
    % departs from straight line by more than std )
    ld = abs(backg_ab - polyval(p,xt3)) <= std_backg;
    [min_backg, ldb] = min(xt3(ld));        % Mmin of background
    n1 = backg_ab(ld);
    n1 = n1(ldb);                           % Cum number for Mmin background
    magi = (n1 - pp(2))/pp(1)  % magi is intercept of n1 with foreground linear fit
    dM = magi - min_backg;        % magnitude shift
    ld = abs(foreg_ab - polyval(pp,xt3)) <= std_foreg;
    [min_foreg, ldf] = min(xt3(ld));        % min_foreg is Mmin of foreground
    disp([' Mmin for background = ', num2str(min_backg) ]);                                disp([' Mmin for foreground = ', num2str(min_foreg) ]);
    stri = [ 'Minimum magnitude for Background = ' num2str(min_backg) ];
    te = text(0.01,0.73, stri) ;
    set(te,'FontSize',ZmapGlobal.Data.fontsz.s);
    stri = [ 'Minimum magnitude for Foreground = ' num2str(min_foreg) ];
    te = text(0.01,0.68, stri) ;
    set(te,'FontSize',ZmapGlobal.Data.fontsz.s);
    stri = ['Z score between both rates: '];
    te = text(0.01,0.63, stri) ;
    set(te,'FontSize',ZmapGlobal.Data.fontsz.s);
    stri = [' Z = ' num2str(zscore) ];
    te = text(0.01,0.58, stri) ;
    set(te,'FontSize',ZmapGlobal.Data.fontsz.s);
    dM = (round(dM *10.0))/10;     % round to 0.1
    backg_new = [backg(:,1:5), backg(:,6)+dM, backg(:,7)];    %  add shift

    [bvalN,xt2] = hist(backg_new(:,6),(mima:0.1:maxmag));
    bvalN = bvalN/td12;                               % normalize
    bvalsumN = cumsum(bvalN);
    bvalsum3N = cumsum(bvalN(length(bvalN):-1:1));
    backg_beN = log10(bvalsumN);
    backg_abN = log10(bvalsum3N);

    res =  (sum((bvalN - bval2).^2)/length(bval2))^0.5 ; % residual in histograms
    %%disp(['Average residual of simple shift = ', num2str(res)]);

    figure_w_normalized_uicontrolunits(mess)
    stri = [ 'Suggested single magnitude shift (d):']
    te = text(0.01,0.50, stri) ;
    set(te,'FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold');
    stri = ['Mx = Mo + (', num2str(dM),')']
    te = text(0.01,0.45, stri) ;
    set(te,'FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold');
    %  compute magnitude stretch and shift
    pause(0.1)

    mf = p(1)/pp(1);            % factor is calculated from ratio of b values
    mf = (round(mf *100.0))/100.0;    % round to 0.01
    dM = -mf*(pp(2) - p(2))/p(1);   %  find shift by diff of zero ordinates
    dM = (round(dM *100.0))/100.0;    % round to 0.01
    stri = [ 'Linear Mag correction (stretch, c, and shift, d):' ];
    te = text(0.01,0.38, stri) ;
    set(te,'FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold');
    stri = [ 'Mx = ',num2str(mf), '* Mo + (', num2str(dM),')' ];
    te = text(0.01,0.33, stri) ;
    set(te,'FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold');
    hold on
end   % if ic

if ic == 0 | ic == 2 

    figure_w_normalized_uicontrolunits(bvfig)
    if ic == 2, clf, end
    bvalsumN = [ ];
    bvalsum3N = [ ];
    % Modify Magnitudes
    backg_new = [backg(:,1:5), (mf*backg(:,6))+dM, backg(:,7)];

    [bvalN,xt2] = hist(backg_new(:,6),(mima:0.1:maxmag));
    bvalN = bvalN/td12;                              % normalize
    bvalsumN = cumsum(bvalN);
    bvalsum3N = cumsum(bvalN(length(bvalN):-1:1));
    backg_beN = log10(bvalsumN);
    backg_abN = log10(bvalsum3N);

    % residual in histograms
    res =  (sum((bvalN - bval2).^2)/length(bval2))^0.5 ;

    % find rate increase_decrease
    if ic ==0 |ic ==1
        rat = [ ];
        rat = bval2/bvalN;            % by mean of ratios
        l = 1 - (isnan(rat) + isinf(rat));
        fac1 = mean(rat(l));
        fac1 = fac1 *100.0;
        fac1 = round(fac1);
        fac1 = fac1/100.0;               % round to 0.01
        fac = fac1;
    end     % if ic

    ind = 0;                      %  find minimum magnitude for the rate change
    resm = [ ];
    if ic ==0; 
        fac = 1.0 ; 
    end
    bvalN = bvalN*fac ;    % apply rate to all data

    bvalsumN = cumsum(bvalN);
    bvalsum3N = cumsum(bvalN(length(bvalN):-1:1));
    backg_beN = log10(bvalsumN);
    backg_abN = log10(bvalsum3N);

    magi = magi *10.0;
    magi = round(magi);
    magi = magi/10.0;               % round to 0.1
    % residual in histograms
    res =  (sum((bvalN - bval2).^2)/length(bval2))^0.5 ;

    figure_w_normalized_uicontrolunits(mess)
    if ic == 0 | ic == 1
        stri = [ 'Suggested rate change (Nx = fac*No): \newline fac = ' num2str(fac1) ];
        te = text(0.01,0.27, stri) ;
        set(te,'FontSize',ZmapGlobal.Data.fontsz.s,'Visible','on');
    end   % if ic
    magis = maxmag;

    uicontrol('Units','normal','Position',[.88 .9 .11 .06],'String','Print  ', 'Callback','myprint')
    uicontrol('Units','normal','Position',[.88 .80 .11 .06],'String','Close  ', 'Callback','welcome;done')

    freq_field1=uicontrol('Style','edit',...
        'Position',[.30 .16 .13 .07],...
        'Units','normalized','String',num2str(dM),...
        'Callback','dM=str2double(get(freq_field1,''String'')); set(freq_field1,''String'',num2str(dM));');

    freq_field2=uicontrol('Style','edit',...
        'Position',[.75 .16 .13 .07],...
        'Units','normalized','String',num2str(mf),...
        'Callback','mf=str2double(get(freq_field2,''String'')); set(freq_field2,''String'',num2str(mf));');

    freq_field3=uicontrol('Style','edit',...
        'Position',[.30 .05 .13 .07],...
        'Units','normalized','String',num2str(fac),...
        'Callback','fac=str2double(get(freq_field3,''String'')); set(freq_field3,''String'',num2str(fac));');

    txt1 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[.01 0.11 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.s ,...
        'String','Shift (d)');

    txt2 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[.44 0.11 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.s ,...
        'String','  Stretch factor (c)');

    txt3 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[.01 0.0 0 ],...
        'Rotation',0 ,...
        'FontSize',ZmapGlobal.Data.fontsz.s ,...
        'String','Rate factor');

    go_button=uicontrol('Style','Pushbutton',...
        'Position',[.52 .01 .10 .07 ],...
        'Units','normalized',...
        'Callback','ic = 2, bvalfit',...
        'String','Go');
    res = bval2 - bvalN ;

    close(bvfig)
    % Find out of figure already exists and plot results of fit
    %
    [existFlag,figNumber]=figure_exists('Compare and fit two rates',1);
    newCompWindowFlag=~existFlag;
    ms3 = 5;

    %if newCompWindowFlag
    bvfig= figure_w_normalized_uicontrolunits( ...
        'Name','Compare and fit two rates',...
        'NumberTitle','off', ...
        'backingstore','on',...
        'Visible','on', ...
        'Position',[ (fipo(3:4) - [600 600]) (ZmapGlobal.Data.map_len + [0 200])]);


    uicontrol('Units','normal',...
        'Position',[.0 .93 .08 .06],'String','Print ',...
         'Callback','myprint')

    uicontrol('Units','normal',...
        'Position',[.0 .75 .08 .06],'String','Close ',...
         'Callback','f1=gcf; f2=gpf;set(f1,''Visible'',''off'');if f1~=f2, welcome;done; end')

    uicontrol('Units','normal',...
        'Position',[.0 .85 .08 .06],'String','Info ',...
         'Callback','zmaphelp(ttlStr,hlpStr1map,hlpStr2map,hlpStr3map)')
    axis off
    matdraw

    %end % if figure exits

    %%figure_w_normalized_uicontrolunits(bvfig)
    delete(gca)
    delete(gca)
    delete(gca)
    delete(gca)
    delete(gca)
    delete(gca)
    delete(gca)
    delete(gca)
    delete(gca)
    delete(gca)
    % plot b-value plot
    %
    orient tall
    set(gcf,'PaperPosition',[2 1 5.5 7.5])
    rect = [0.20,  0.7, 0.70, 0.25];           % plot Freq-Mag curves
    axes('position',rect)
    hold on
    figure_w_normalized_uicontrolunits(bvfig)
    hold on
    pl = semilogy(xt3,bvalsum4,'xb');
    set(gca,'Yscale','log')
    hold on
    set(pl,'MarkerSize',ms3)
    semilogy(xt3,bvalsum4,'-.b')
    pl = semilogy(xt3,bvalsum3N,'om');
    set(pl,'MarkerSize',ms3)
    semilogy(xt3,bvalsum3N,'m')
    te1 = max([bvalsum  bvalsum2 bvalsum4 bvalsum3]);
    te1 = te1 - 0.2*te1;

    ylabel('Cum. rate/year','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold')
    str = [ '   o: ' num2str(t1p(1),6) ' - ' num2str(t2p(1),4) '     x: ' num2str(t3p(1),6) ' - '  num2str(t4p(1),6) ];

    title(str,'FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold')
    %  find b-values;
    set(gca,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.s,'Linewidth',1.0)
    p1 = gca;


    % Plot histogram
    %

    rect = [0.20,  0.40 0.70, 0.25];
    axes('position',rect)
    pl = plot(xt2,bvalN,'om');
    set(pl,'MarkerSize',ms3,'LineWidth',1.0)
    hold on
    pl = plot(xt2,bval2,'xb');
    set(pl,'MarkerSize',ms3,'LineWidth',1.0)
    pl = plot(xt2,bval2,'-.b');
    set(pl,'MarkerSize',ms3,'LineWidth',1.0)
    pl = plot(xt2,bvalN,'m');
    set(pl,'MarkerSize',ms3,'LineWidth',1.0)
    disp([' Summation: ' num2str(sum(bval-bval2))])
    v = axis;
    xlabel('Magnitude ','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold')
    ylabel('rate/year','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold')
    set(gca,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.s,'Linewidth',1.0)

    uic = uicontrol('Units','normal','Position',[.35 .15 .30 .07],'String','Magnitude Signature? ', 'Callback','delete(uic);synsig');

end   % if ic

clear rat bvalNN mean1 mean2 ld l ll txt1 txt2 txt3 txt4 M1b M2b M1f M2f tx1 tx2 tx3 tx4;
ic = 0;
format;

