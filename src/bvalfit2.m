% TODO: Delete this file. it is obviously broken and isn't referenced in ZMAP any more -CGR

%
%   Calculates Freq-Mag functions (b-value) for two time-segments
%   finds best fit to the foreground for a modified background
%   assuming a change in time of the following types:
%   Mnew = Mold + d     , i.e. Simple magnitude shift
%   Mnew = c*Mold + d   , i.e. Mag stretch plus shift
%   Nnew = fac*Nold     , i.e. Rate change (N = number of events)
%                                         R. Zuniga IGF-UNAM/GI-UAF  6/94

report_this_filefun(mfilename('fullpath'));

if ic == 0
    global p
    backg = [ ] ;
    foreg = [ ] ;
    format short;

    figure
    bvfig = gcf;
    set(bvfig,'Units','normalized','NumberTitle','off','Name','b-value curves');
    set(gcf,'pos',[ 0.435  0.8 0.6 0.9])
    maxmag = max(newcat.Magnitude);
    t0b = min(newcat.Date);
    teb = max(newcat.Date);
    n = newcat.Count;
    tdiff = round(teb - t0b);

    % number of mag units
    nmagu = (maxmag*10)+1;

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
    backg = [ ];
    foreg = [ ];
    backg_beN = [ ];
    backg_abN = [ ];
    td12 = t2p(1) - t1p(1);
    td34 = t4p(1) - t3p(1);

    l = newcat.Date > t1p(1) & newcat.Date < t2p(1) ;
    backg =  newcat.subset(l);
    [bval,xt2] = hist(backg(:,6),(0:0.1:maxmag));
    bval = bval *  td34/td12;                      % normalization
    bvalsum = cumsum(bval);                        % N for M <=
    bvalsum3 = cumsum(bval(length(bval):-1:1));    % N for M >= (counted backwards)
    xt3 = (maxmag:-0.1:0);
    [cumux, xt] = hist(newcat(l,3),t1p(1):par1/365:t2p(1));

    l = newcat.Date > t3p(1) & newcat.Date < t4p(1) ;
    foreg = newcat.subset(l);
    bval2 = histogram(foreg(:,6),(0:0.1:maxmag));
    bvalsum2 = cumsum(bval2);
    bvalsum4 = cumsum(bval2(length(bval2):-1:1));
    [cumux2, xt] = hist(newcat(l,3),t3p(1):par1/365:t4p(1));
    mean1 = mean(cumux);
    mean2 = mean(cumux2);
    var1 = cov(cumux);
    var2 = cov(cumux2);
    zscore = (mean1 - mean2)/(sqrt(var1/length(cumux)+var2/length(cumux2)));

    backg_be = log10(bvalsum);
    backg_ab = log10(bvalsum3);
    foreg_be = log10(bvalsum2);
    foreg_ab = log10(bvalsum4);
    orient tall
    rect = [0.2,  0.7, 0.60, 0.25];           % plot Freq-Mag curves
    axes('position',rect)
    semilogy(xt2,bvalsum,'om')
    hold on
    semilogy(xt2,bvalsum2,'xb')
    semilogy(xt2,bvalsum,'-.m')
    semilogy(xt2,bvalsum2,'b')
    semilogy(xt3,bvalsum4,'xb')
    semilogy(xt3,bvalsum4,'b')
    semilogy(xt3,bvalsum3,'-.m')
    semilogy(xt3,bvalsum3,'om')
    te1 = max([bvalsum  bvalsum2 bvalsum4 bvalsum3]);
    te1 = te1 - 0.2*te1;
    title(['o: ' num2str(t1p(1)) ' - ' num2str(t2p(1)) '     x: ' num2str(t3p(1)) ' - '  num2str(t4p(1)) ])

    xlabel('Magnitude ')
    ylabel('Cumulative Number -normalized')
    %  find b-values;
    figure_w_normalized_uicontrolunits(mess)
    clf
    set(gca,'visible','off')
    str =  ['\newline \newline \newlinePlease select two magnitudes to be used \newline in the calculation of straight line fit \newline i.e.  b value of BACKGROUND (O''s)'];
    te = text(0.01,0.90,str) ;

    set(te,'FontSize',12) ;

    figure_w_normalized_uicontrolunits(bvfig)
    seti = uicontrol('Units','normal','Position',[.4 .01 .2 .05],'String','Select Mag1 ');

    pause(1)

    par2 = 0.1 * max(bvalsum3);
    par3 = 0.12 * max(bvalsum3);
    M1b = [];
    M1b = ginput(1);
    text( M1b(1),M1b(2),['|: M1'] )
    set(seti','String','Select Mag2');

    pause(0.1)

    M2b = [];
    M2b = ginput(1);
    text( M2b(1),M2b(2),['|: M2'] )

    pause(0.1)
    delete(seti)

    ll = xt3 > M1b(1) & xt3 < M2b(1);
    x = xt3(ll);
    y = backg_ab(ll);
    [p,s] = polyfit(x,y,1);                   % fit a line to background
    f = polyval(p,x);
    f = 10.^f;
    hold on
    semilogy(x,f,'y')                         % plot linear fit to backg
    r = corrcoef(x,y);
    r = r(1,2);
    std_backg = std(y - polyval(p,x));      % standard deviation of fit

    figure_w_normalized_uicontrolunits(mess)
    clf
    set(gca,'visible','off')
    str =  ['\newline \newline \newlinePlease select two magnitudes to be used \newline in the calculation of straight line fit \newline i.e.  b value of FOREGROUND (X''s)'];
    te = text(0.01,0.90,str) ;
    set(te,'FontSize',12) ;

    figure_w_normalized_uicontrolunits(bvfig)
    seti = uicontrol('Units','normal','Position',[.4 .01 .2 .05],'String','Select Mag1 ');

    pause(1)

    par2 = 0.1 * max(bvalsum3);
    par3 = 0.12 * max(bvalsum3);
    M1f = [];
    M1f = ginput(1);
    text( M1f(1),M1f(2),['|: M1'] )
    set(seti','String','Select Mag2');

    pause(0.1)

    M2f = [];
    M2f = ginput(1);
    text( M2f(1),M2f(2),['|: M2'] )

    pause(0.1)
    delete(seti)

    l = xt3 > M1f(1) & xt3 < M2f(1);
    x = xt3(l);
    y = foreg_ab(l);
    [pp,s] = polyfit(x,y,1);             % fit a line to foreground
    f = polyval(pp,x);
    f = 10.^f;
    semilogy(x,f,'y')                   % plot fit to foreg
    rr = corrcoef(x,y);
    rr = rr(1,2);
    std_foreg = std(y - polyval(pp,x));      % standard deviation of fit

    figure_w_normalized_uicontrolunits(mess)
    clf
    set(gca,'visible','off')
    set(gcf,'pos',[ 0.01  0.9 0.4 0.7])
    set(gcf,'Name','Compare Results');
    te = text(0.,0.99, ['   Catalogue : ' file1]) ;
    set(te,'FontSize',12);
    stri = [ 'Background:   ' num2str(t1p(1)) '  to  ' num2str(t2p(1)) ];
    te = text(0.01,0.93, stri) ;
    aa = p(2) *1000.0;
    aa = round(aa);
    aa = aa/1000.0;
    bb = p(1) *1000.0;
    bb = round(bb);
    bb = bb/1000.0;          % round to 0.001
    stri = [' Log N = ' num2str(aa)  num2str(bb) '*M ' ];
    te = text(0.01,0.88, stri) ;
    stri = [ 'Foreground:   ' num2str(t3p(1)) '  to  ' num2str(t4p(1)) ];
    te = text(0.01,0.83, stri) ;
    aa = pp(2) *1000.0;
    aa = round(aa);
    aa = aa/1000.0;
    bb = pp(1) *1000.0;
    bb = round(bb);
    bb = bb/1000.0;          % round to 0.001
    stri = [' Log N = ' num2str(aa) num2str(bb) '*M '];
    te = text(0.01,0.78, stri) ;
    disp([' Correlation coefficient for background = ', num2str(r) ]);                                disp([' Correlation coefficient for foreground = ', num2str(rr) ]);
    %clear aa bb;
    %%dM = sum(backg_ab(ll) - foreg_ab(ll))/(length(backg_ab(ll))*p(1)) ;
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
    stri = [ 'Minimum magnitude for Foreground = ' num2str(min_foreg) ];
    te = text(0.01,0.68, stri) ;
    stri = ['Z score (Cumulative No. vs time rate comparison) : '];
    te = text(0.01,0.63, stri) ;
    stri = [' Z = ' num2str(zscore) ];
    te = text(0.01,0.58, stri) ;

    figure_w_normalized_uicontrolunits(bvfig)
    backg_new = [backg(:,1:5), backg(:,6)+dM, backg(:,7)];    %  add shift
    [bvalN,xt2] = hist(backg_new(:,6),(0:0.1:maxmag));
    bvalN = bvalN *  td34/td12;                               % normalize
    bvalsumN = cumsum(bvalN);
    bvalsum3N = cumsum(bvalN(length(bvalN):-1:1));
    backg_beN = log10(bvalsumN);
    backg_abN = log10(bvalsum3N);
    ld = [ ];                        % calculate residual in b-value curves
    ld = xt2 <= magi;
    res1 = abs(foreg_be(ld) - backg_beN(ld));     % absolute residuals
    ld = 1 - (isnan(res1) + isinf(res1));     % avoid no information in logarthmic
    res1 = sum(res1(ld))/length(res1(ld));
    ld = [ ];
    ld = xt3 >= min_foreg;
    res2 = abs(foreg_ab(ld) - backg_abN(ld));
    ld = 1 - (isnan(res2) + isinf(res2));
    res2 = sum(res2(ld))/length(res2(ld));
    res = (res1 + res2)/2;
    % residual in histograms
    %res =  (sum((bvalN - bval2).^2)/length(bval2))^0.5 ;
    disp(['Average residual of simple shift = ', num2str(res)]);
    semilogy(xt2,bvalsumN,'+g')                 % plot synthetic b value curve
    semilogy(xt2,bvalsumN,'-.g')
    semilogy(xt3,bvalsum3N,'+g')
    semilogy(xt3,bvalsum3N,'-.g')
    v = axis;
    p1 = [0.1 , 1. ];
    p2 = [ .5 , .5 ];
    semilogy(p1,p2,'-.g')
    p1 = [0.5 , 0.8 ];
    semilogy(p1,p2,'+g')
    text( p1(2)+0.1,p2(2),['   after simple Mag shift'] )
    %text(maxmag, max(max(bvalsum),max(bvalsum2))*10.0,['res = ' num2str(res)])
    text(v(2)+0.25, v(4),['res = ' num2str(res)])
    dM = dM *10.0;
    dM = round(dM);
    dM = dM/10.0;          % round to 0.1
    figure_w_normalized_uicontrolunits(mess)
    stri = [ 'For a simple magnitude shift   Mnew = Mold + d: \newline d = ' num2str(dM)];
    te = text(0.01,0.50, stri) ;
    set(te,'FontSize',12);
    %  compute magnitude stretch and shift
    pause(0.1)

    mf = p(1)/pp(1);            % factor is calculated from ratio of b values
    mf = mf *100.0;
    mf = round(mf);
    mf = mf/100.0;               % round to 0.01
    dM = -mf*(pp(2) - p(2))/p(1);  %  find shift by diff of zero ordinates
    dM = dM *100.0;
    dM = round(dM);
    dM = dM/100.0;               % round to 0.01
    stri = [ 'For a Mag correction (stretch)  Mnew = c*Mold + d : \newline d = ' num2str(dM) ',  c = ' num2str(mf)];
    te = text(0.01,0.38, stri) ;
    set(te,'FontSize',12);
    figure
    hisfg = gcf;
    set(hisfg,'Units','normalized','NumberTitle','off','Name','Histograms of Last Correction');
    %set(hisfg,'pos',[ 0.4  0.01 0.45 0.55])
end   % if ic

if ic == 0 | ic == 2 

    figure_w_normalized_uicontrolunits(bvfig)
    if ic == 2, clf, end
    rect = [0.2,  0.37 0.60, 0.25];
    axes('position',rect)
    bvalsumN = [ ];
    bvalsum3N = [ ];
    % Modify Magnitudes
    backg_new = [backg(:,1:5), (mf*backg(:,6))+dM, backg(:,7)];
    [bvalN,xt2] = hist(backg_new(:,6),(0:0.1:maxmag));
    bvalN = bvalN *  td34/td12;                              % normalize
    bvalsumN = cumsum(bvalN);
    bvalsum3N = cumsum(bvalN(length(bvalN):-1:1));
    backg_beN = log10(bvalsumN);
    backg_abN = log10(bvalsum3N);
    ld = [ ];                        % calculate residual in b-value curves
    ld = xt2 <= magi;
    res1 = abs(foreg_be(ld) - backg_beN(ld));
    ld = 1 - (isnan(res1) + isinf(res1));
    res1 = sum(res1(ld))/length(res1(ld));
    ld = [ ];
    ld = xt3 >= min_foreg;
    res2 = abs(foreg_ab(ld) - backg_abN(ld));
    ld = 1 - (isnan(res2) + isinf(res2));
    res2 = sum(res2(ld))/length(res2(ld));
    res = (res1 + res2)/2;
    % residual in histograms
    %res =  (sum((bvalN - bval2).^2)/length(bval2))^0.5 ;
    disp(['Average residual of shift and stretch = ', num2str(res)]);
    semilogy(xt2,bvalsum,'om')
    hold on
    semilogy(xt2,bvalsum,'-.m')
    semilogy(xt3,bvalsum3,'-.m')
    semilogy(xt3,bvalsum3,'om')
    semilogy(xt2,bvalsum2,'xb')
    semilogy(xt2,bvalsum2,'b')
    semilogy(xt3,bvalsum4,'xb')
    semilogy(xt3,bvalsum4,'b')
    semilogy(xt2,bvalsumN,'+g')                 % plot synthetic b value curve
    hold on
    semilogy(xt2,bvalsumN,'-.g')
    semilogy(xt3,bvalsum3N,'+g')
    semilogy(xt3,bvalsum3N,'-g')
    p1 = [0.1 , 1. ];
    p2 = [ .5 , .5 ];
    semilogy(p1,p2,'-.g')
    p1 = [0.5 , 0.8 ];
    semilogy(p1,p2,'+g')
    text( p1(2)+0.1,p2(2),['  after Mag stretch'] )
    text(v(2)+0.25, v(4),['res = ' num2str(res)])
    % find rate increase_decrease
    if ic ==0 | ic ==1
        %fac = max(bvalsum2)/max(bvalsum) ; % by diff in total cumulative number
        %fac1 = 10^(pp(2) - p(2)) ;           % by zero ordinates
        %fac = foreg_be - backg_be;
        %l = 1 - (isnan(fac) + isinf(fac));
        ll = xt2 <= magi;
        rat = [ ];
        rat = bval2(ll)./bvalN(ll);            % by mean of ratios
        l = 1 - (isnan(rat) + isinf(rat));
        fac1 = mean(rat(l));
        fac1 = fac1 *100.0;
        fac1 = round(fac1);
        fac1 = fac1/100.0;               % round to 0.01
        fac = fac1;
    end

    ind = 0;                      %  find minimum magnitude for the rate change
    resm = [ ];
    for magx = minma:0.1:magi      % start from min mag of catalogue
        bvalNN = bvalN;
        l = xt2 <= magx;
        ind = ind +1;
        ind2 = length(bvalNN(l));
        bvalNN(1:ind2) = bvalN(1:ind2)*fac ;    % apply rate correction up to magx
        bvalsumN = cumsum(bvalNN);
        l = xt2 <= magi;
        %resm(ind) = (sum((bvalsumN - bvalsum2).^2)/length(bvalsum2))^0.5  ;
        resm(ind) = (sum((bvalNN - bval2).^2)/length(bvalNN))^0.5 ;
        disp(['magnitud = ', num2str(magx), ' residual =  ',num2str(resm(ind))]);
    end     % for magx
    magx = minma:0.1:magi;

    [res,ll] = min(resm);
    l = xt2 <= magx(ll);
    ind2 = length(bvalN(l));
    bvalN(1:ind2) = bvalN(1:ind2)*fac ;  % apply rate correction to previous data
    % up to magnitude found bove
    bvalsumN = cumsum(bvalN);
    bvalsum3N = cumsum(bvalN(length(bvalN):-1:1));
    backg_beN = log10(bvalsumN);
    backg_abN = log10(bvalsum3N);
    ld = [ ];;                        % calculate residual in b-value curves
    ld = xt2 <= magi;
    res1 = abs(foreg_be(ld) - backg_beN(ld));
    ld = 1 - (isnan(res1) + isinf(res1));
    res1 = sum(res1(ld))/length(res1(ld));
    ld = [ ];
    ld = xt3 >= min_foreg;
    res2 = abs(foreg_ab(ld) - backg_abN(ld));
    ld = 1 - (isnan(res2) + isinf(res2));
    res2 = sum(res2(ld))/length(res2(ld));
    res = (res1 + res2)/2;
    magi = magi *10.0;
    magi = round(magi);
    magi = magi/10.0;               % round to 0.1
    % residual in histograms
    %res =  (sum((bvalN - bval2).^2)/length(bval2))^0.5 ;
    disp(['Average residual of simple rate change ']);
    disp(['plus mag correction = ', num2str(res)]);
    disp(' (Residuals are an average of absolute values ');
    disp('  in b-value plots for Mag and above and Mag and below) ');
    disp(['Maximum Magnitude up to which rate change ']);
    disp(['can be applied = ' num2str(magi) ]);
    disp(['Magnitude up to which last rate change ']);
    disp(['was applied = ' num2str(magx(ll)) ]);
    rect = [0.2, 0.05, 0.60, 0.25];
    axes('position',rect)
    semilogy(xt2,bvalsum,'om')
    hold on
    semilogy(xt2,bvalsum,'-.m')
    semilogy(xt3,bvalsum3,'-.m')
    semilogy(xt3,bvalsum3,'om')
    semilogy(xt2,bvalsum2,'xb')
    semilogy(xt2,bvalsum2,'b')
    semilogy(xt3,bvalsum4,'xb')
    semilogy(xt3,bvalsum4,'b')
    semilogy(xt2,bvalsumN,'+g')                 % plot synthetic b value curve
    hold on
    semilogy(xt2,bvalsumN,'-.g')
    semilogy(xt3,bvalsum3N,'+g')
    semilogy(xt3,bvalsum3N,'-g')
    p1 = [0.1 , 1. ];
    p2 = [ .5 , .5 ];
    semilogy(p1,p2,'-.g')
    p1 = [0.5 , 0.8 ];
    semilogy(p1,p2,'+g')
    text( p1(2)+0.1,p2(2),['  after rate change and Mag stretch'] )
    text(v(2)+0.25, v(4),['res = ' num2str(res)])
    uicontrol(,'Units','normal','Position',[.01 .01 .10 .05],'String','Print  ', 'Callback','print')

    uicontrol('Units','normal','Position',[.90 .01 .10 .05],'String','Back  ', 'Callback','close,ic = 0; dispma2')

    figure_w_normalized_uicontrolunits(mess)
    if ic == 0 | ic == 1
        magix = magx(ll) *10.0;
        magix = round(magix);
        magix = magix/10.0;               % round to 0.1
        stri = [ 'For a constant rate change (Nnew = fac*Nold) plus stretch: \newline fac = ' num2str(fac1) ' , Mmax for rate change = ' num2str(magix) ]; clear magix;
        te = text(0.01,0.27, stri) ;
        set(te,'FontSize',12,'Visible','on');
        stri = 'Change: ';
        te = text(0.01,0.17, stri) ;
    end   % if ic
    magis = magx(ll) *10.0;           %   save last magnitude found
    magis = round(magis);
    magis = magis/10.0;               % round to 0.1

    uicontrol(,'Units','normal','Position',[.88 .9 .11 .06],'String','Print  ', 'Callback','print')

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

    freq_field4=uicontrol('Style','edit',...
        'Position',[.75 .05 .13 .07],...
        'Units','normalized','String',num2str(magi),...
        'Callback','magi=str2double(get(freq_field4,''String'')); set(freq_field4,''String'',num2str(magi));');



    txt1 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[.01 0.11 0 ],...
        'Rotation',0 ,...
        'FontSize',12 ,...
        'String','Shift (d)');

    txt2 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[.44 0.11 0 ],...
        'Rotation',0 ,...
        'FontSize',12 ,...
        'String','  Stretch factor (c)');

    txt3 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[.01 0.0 0 ],...
        'Rotation',0 ,...
        'FontSize',12 ,...
        'String','Rate factor');

    txt4 = text(...
        'Color',[0 0 0 ],...
        'EraseMode','normal',...
        'Position',[.67 0.0 0 ],...
        'Rotation',0 ,...
        'FontSize',12 ,...
        'String','Mmax');

    go_button=uicontrol('Style','Pushbutton',...
        'Position',[.52 .01 .10 .07 ],...
        'Units','normalized',...
        'Callback','ic = 2, bvalfit',...
        'String','Go');

    figure_w_normalized_uicontrolunits(hisfg)
    clf                                        % this plots histograms
    set(gca,'visible','off')
    set(hisfg,'pos',[ 0.43  0.63 0.6 0.9])
    rect = [0.2,  0.70 0.60, 0.25];
    axes('position',rect)
    plot(xt2,bval2,'xb')
    hold on
    plot(xt2,bval,'om')
    plot(xt2,bval,'-.m')
    plot(xt2,bval2,'b')
    plot(xt2,bvalN,'+g')
    plot(xt2,bvalN,'g')
    v = axis;
    xlabel('Magnitude ')
    ylabel('Number')
    title([file1 f   ile1 '   o: ' num2str(t1p(1)) ' - ' num2str(t2p(1)) '     x: ' num2str(t3p(1)) ' - '  num2str(t4p(1)) ])
    % residuals in histograms
    res = bval2 - bvalN ;
    rect = [0.2,  0.40 0.60, 0.25];
    axes('position',rect)
    hold on
    bar(xt2,res,'r')
    %res = bvalN - bval2 ;
    %bar(xt2,res,'g')
    v(4) = max(max(bval2),max(bvalN));
    axis([v(1) v(2) -v(4) v(4)]);
    xlabel('Magnitude ')
    ylabel('Nobs - Nsyn')
    text(v(2)-1.0, v(4),['Mag shift = ' num2str(dM)]);
    text(v(2)-1.0, v(4)*0.8,['Stretch fac = ' num2
