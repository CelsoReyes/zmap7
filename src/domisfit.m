function domisfit(catalog,sig,plu,az,phi,R)
    % domisfit calculates the misfit for each EQ to a given stress tensor orientation.
    % The actual calculation is done using a call to a fortran program.
    %
    % Stefan Wiemer 07/95
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    
    global mi mif1 mif2 newcat2 mi2
    global cumu2
    report_this_filefun();
    
    
    hodis = fullfile(ZG.hodi, 'external');
    cd(hodis);
    
    % prepare the focal; mechnism in Gephard format ...
    tmp = [catalog(:,10:12) ];
    tmp(tmp(:,2) >89.999,2) = 89.;
    
    try
        save data.inp tmp -ascii
    catch ME
        error_handler(ME, ['Error - could not save file ' ZmapGlobal.Data.Directories.output 'data.inp - permission?']);
    end
    
    infi =  'data.inp';
    outfi = 'tmpin.dat';
    fid = fopen('inmifi.dat','w');
    fprintf(fid,'%s\n',infi);
    fprintf(fid,'%s\n',outfi);
    fclose(fid);
    
    delete(outfi)
    
    [status, result] = system('datasetupDD < inmifi.dat');
    
    fid = ('tmpin.dat');
    format = '%f%f%f%f%f';
    %[d1, d2, d3, d4, d5] = textread(fid,format,'headerlines',1);
    C = textscan(fid,format,'HeaderLines',1); %Problem: "Errorlines" cause crashes.
    dall=[C{:}];
    
    %dall = [d1, d2, d3, d4, d5];
    save tmpin.dat dall -ascii
    
    
    infi = 'tmpin.dat';
    outfi = 'tmpout.dat';
    
    fid = fopen('inmifi.dat','w');
    
    fprintf(fid,'%s\n',infi);
    fprintf(fid,'%s\n',outfi);
    fprintf(fid,'%2.0f\n',sig);
    fprintf(fid,'%6.2f\n',plu);
    fprintf(fid,'%6.2f\n',az);
    fprintf(fid,'%6.2f\n',phi);
    fprintf(fid,'%3.2f\n',R);
    le = catalog.Count;
    fprintf(fid,'%6i\n',le);
    
    fclose(fid);
    try
        delete outfi
    catch ME
        warning(ME.message);
    end
    
    comm = 'testfm < inmifi.dat'
    [status,result]=system(comm)
    try
        % CGR: it looks like the format will be:
        % line 1: ndata kdata  [where ndata is # of data, kdata is # of fault planes]
        % lines 2-end : az1 dip1 az2 dip2 wt
        % load('tmpout.dat')
        s=importdata('../external/tmpout.dat', ' ', 1); 
        
        headernumbers=str2num(s.textdata{1});
        nData=headernumbers(1);
        kData=headernumbers(2);
        
        mi = s.data; % probably as [az1, dip1, az2, dip2, wt ; ...]
    catch ME
        warning(ME.message)
    end
    
    % mi = tmpout; % mi gets results from the fortran progarm
    
    misfitAngle=mi(:,2);
    
    
    
    mif1=findobj('Type','Figure','-and','Name','Misfit Map');
    
    if isempty(mif1)
        mif1 = figure_w_normalized_uicontrolunits( ...
            'Name','Misfit Map',...
            'NumberTitle','off', ...
            'backingstore','on',...
            'NextPlot','add', ...
            'Visible','off', ...
            'Position',position_in_current_monitor(ZG.map_len(1), ZG.map_len(2)));
        
        create_my_menu_1();
        
        
        labelList=['Size | Size + Thickness | Size +Thickness +color  '];
        labelPos = [0.2 0.93 0.35 0.05];
        hndl2=uicontrol(...
            'Style','popup',...
            'Units','normalized',...
            'Position',labelPos,...
            'String',labelList,...
            'BackgroundColor',[0.7 0.7 0.7]',...
            'callback',@callbackfun_005);
        
        decimationList=['1 | 1/2 | 1/3 | 1/4 | 1/5 | 1/6| 1/7| 1/8 | 1/9 | 1/10'];
        labelPos = [0.9 0.93 0.10 0.05];
        uicontrol(...
            'Style','popup',...
            'Units','normalized',...
            'Position',labelPos,...
            'Value',4,...
            'String',decimationList,...
            'BackgroundColor',[0.7 0.7 0.7]',...
            'callback',@store_decimation_cb);
        
        uicontrol(...
            'Style','pushbutton',...
            'Units','normalized',...
            'Position',[0.9 0.6 0.08 0.08],...
            'String','X-sec',...
            'callback',@callbackfun_007);
        set(gca,'NextPlot','add')
        %end killed
        uicontrol(...
            'Style','pushbutton',...
            'Units','normalized',...
            'Position',[0.9 0.7 0.08 0.08],...
            'String','Map',...
            'callback',@callbackfun_008);
        set(gca,'NextPlot','add')
    end
    
    figure(mif1)
    
    plotmima(4, mi)
    
    mif2=findobj('Type','Figure','-and','Name','Misfit ');
    
    
    
    if isempty(mif2)
        mif2 = figure_w_normalized_uicontrolunits( ...
            'Name','Misfit ',...
            'NumberTitle','off', ...
            'backingstore','on',...
            'NextPlot','add', ...
            'Visible','off', ...
            'Position',position_in_current_monitor(ZG.map_len(1), ZG.map_len(2)));
        
        create_my_menu_2();
        listFields={'Longitude','Latitude','Time','Magnitude','Depth','Strike','Default'};
        labelPos = [0.7 0.9 0.25 0.08];
        hFieldChoice=uicontrol(...
            'Style','popup',...
            'Units','normalized',...
            'Position',labelPos,...
            'String',listFields,...
            'BackgroundColor',[0.7 0.7 0.7]',...
            'callback',@callbackfun_012);
        set(gca,'NextPlot','add')
    end
    
    figure(mif2)
    delete(findobj(mif2,'Type','axes'));
    
    plotmi(listFields{1}, catalog, mi)
    
    
    %% ui functions
    function create_my_menu_1() %TODO rename to something more intelligent
        add_menu_divider();    %
        omp2= uimenu('Label','Tools');
        uimenu(omp2,'label','Misfit-Magnitude',...
            'MenuSelectedFcn',@cb_misfitmag);
        uimenu(omp2,'label','Misfit-Depth',...
            'MenuSelectedFcn',@cb_misfitdep);
        uimenu(omp2,'label','Earthquake-Depth',...
            'MenuSelectedFcn',@cb_eqdep);
        uimenu(omp2,'label','Earthquake-Strike',...
            'MenuSelectedFcn',@cb_eqstrike);
        %
    end
    
    function create_my_menu_2() %TODO rename to something more intelligent
        add_menu_divider();
        omp1= uimenu('Label','Tools');
        uimenu(omp1,'label','Save sorted catalog',...
            'MenuSelectedFcn',@callbackfun_009);
        uimenu(omp1,'label','AS Function',...
            'MenuSelectedFcn',@cb_astmisfit);
        uimenu(omp1,'label','Compare',...
            'MenuSelectedFcn',@cb_comparemisfit);
    end
    
    %% callback functions
    function cb_misfitmag(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        mi_ma(misfitAngle);
    end
    
    function cb_misfitdep(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        mi_dep(misfitAngle);
    end
    
    function cb_eqdep(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        eq_dep(misfitAngle);
    end
    
    function cb_eqstrike(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        earthquake_strike();
    end
    
    function callbackfun_005(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        in2=hndl2.Value;
        plotmima(in2, mi);
    end
    
    function store_decimation_cb(mysrc,myevt)
        global oneOfHowManyPopupIdx
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        in3=mysrc.Value;
        oneOfHowManyPopupIdx=in3;
        in2=hndl2.Value;
        plotmima(in2, mi) ;
    end
    
    function callbackfun_007(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        var1 = 3;
        plotmimac(mi, inde); % No idea what inde is or where it comes from
    end
    
    function callbackfun_008(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        var1 = 1;
        mifigrid(var1,mi);
    end
    
    function callbackfun_009(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        save_sortpere;
    end
    
    function cb_astmisfit(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ast_misfit();
    end
    
    function cb_comparemisfit(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        compare_misfit();
    end
    
    function callbackfun_012(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        in2=hFieldChoice.Value;
        plotmi(listfields{in2}, catalog, mi);
    end
    
end

function earthquake_strike()
    % plot the earthquake number along the strike on the map view
    %	August 1995 by Zhong Lu
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    report_this_filefun();
    myFigName='Earthquake Number Map';
    mif55=findobj('Type','Figure','-and','Name',myFigName);
    
    
    
    if isempty(mif55)
        mif55 = figure_w_normalized_uicontrolunits( ...
            'Name',myFigName,...
            'NumberTitle','off', ...
            'backingstore','on',...
            'NextPlot','add', ...
            'Visible','off', ...
            'Position',position_in_current_monitor(ZG.map_len(1), ZG.map_len(2)));
    end
    figure(mif55)
    
    set(gca,'NextPlot','add')
    
    tt = newcat2;
    [ts,ti] = sort(tt(:,15));
    tt = tt(ti(:,1),:);
    
    for i = 1:length(tt)
        pt = plot(tt(i,1),tt(i,2),'o');
        set(gca,'NextPlot','add')
    end
    
end

function eq_dep(misfitAngle) 
    %  earthquake_depth
    % August 95 by Zhong Lu
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    report_this_filefun();
    myFigName='Depth vs Earthquake Number';
    
    mif66=findobj('Type','Figure','-and','Name',myFigName);
    
    if isempty(mif66)
        mif66 = figure_w_normalized_uicontrolunits( ...
            'Name',myFigName,...
            'NumberTitle','off', ...
            'backingstore','on',...
            'NextPlot','add', ...
            'Visible','off', ...
            'Position',position_in_current_monitor(ZG.map_len(1), ZG.map_len(2)));
    end
    figure(mif66)
    set(gca,'NextPlot','add')
    
    x = [1:length(mmi)]';
    [ss,ssi]=sort(catalog.Depth);
    plot(x,ss,'go');
    
    grid on
    
    ylabel('Depth of Earthquake','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m);
    xlabel('Earthquake Number','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m);
    set(gca,'NextPlot','replace');
end

function mi_dep(misfitAngle)
    %  misfit_magnitude
    % August 95 by Zhong Lu
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    report_this_filefun();
    
    mif77=findobj('Type','Figure','-and','Name','Misfit as a Function of Depth');
    
    
    
    if isempty(mif77)
        mif77 = figure_w_normalized_uicontrolunits( ...
            'Name','Misfit as a Function of Depth',...
            'NumberTitle','off', ...
            'backingstore','on',...
            'NextPlot','add', ...
            'Visible','off', ...
            'Position',position_in_current_monitor(ZG.map_len(1), ZG.map_len(2)));
        
        
        
        set(gca,'NextPlot','add')
        
    end
    figure_w_normalized_uicontrolunits(mif77)
    set(gca,'NextPlot','add')
    
    
    plot(catalog.Depth,misfitAngle,'go');
    
    grid
    %set(gca,'box','on',...
    %        'SortMethod','childorder','TickDir','out','FontWeight',...
    %        'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2);
    
    xlabel('Depth of Earthquake','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m);
    ylabel('Misfit Angle ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m);
    set(gca,'NextPlot','replace');
end

function mi_ma(misfitAngle)
    %  misfit_magnitude
    % August 95 by Zhong Lu
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    report_this_filefun();
    
    mif88=findobj('Type','Figure','-and','Name','Misfit as a Function of Magnitude');
    
    
    
    if isempty(mif88)
        mif88 = figure_w_normalized_uicontrolunits( ...
            'Name','Misfit as a Function of Magnitude',...
            'NumberTitle','off', ...
            'backingstore','on',...
            'NextPlot','add', ...
            'Visible','off', ...
            'Position',position_in_current_monitor(ZG.map_len(1), ZG.map_len(2)));
        
        set(gca,'NextPlot','add')
        
    end
    figure(mif88)
    set(gca,'NextPlot','add')
    
    
    plot(catalog.Magnitude,misfitAngle,'go');
    
    grid
    %set(gca,'box','on',...
    %        'SortMethod','childorder','TickDir','out','FontWeight',...
    %        'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2);
    
    xlabel('Magnitude of Earthquake','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m);
    ylabel('Misfit Angle ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m);
    set(gca,'NextPlot','replace');
end

function ast_misfit()
    %  ast_misfit calculates A as(t) value for a cumulative number curve and displayed in the plot.
    %
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    report_this_filefun();
    
    dat(:,2)=mi2(:,2);
    dat(:,1)=[1:length(mi2(:,1))]';
    cumu = dat(:,2);
    xt = dat(:,1);
    cumu2 = cumsum(cumu);
    
    %  winlen_days is the cutoff at the beginning and end of the analyses
    %  to avoid spikes at the end
    winlen_days = 5;
    
    %
    % calculate mean and z value
    ncu = length(xt);
    as = zeros(1,ncu);
    
    t0b = dat(1,1);
    n = length(dat(:,1));
    teb = dat(n,1);
    tdiff = ncu;
    
    
    
    for i = winlen_days+1:tdiff-winlen_days
        mean1 = mean(cumu(1:i));
        mean2 = mean(cumu(i+1:ncu));
        var1 = cov(cumu(1:i));
        var2 = cov(cumu(i+1:ncu));
        as(i) = (mean1 - mean2)/(sqrt(var1/i+var2/(tdiff-i)));
    end     % for i
    
    %  Plot the as(t)
    %clf
    figure;
    orient landscape
    % orient tall
    rect = [0.1,  0.10, 0.8, 0.7];
    axes('position',rect);
    pyy = plotyy(xt,as,xt,cumu2);
    xlabel('Event');
    ylabel('z-value');
    grid
    
    set(gca,'NextPlot','add');
    
    %  show option from here
    %
    uicontrol('Units','normal','Position',[.9 .86 .10 .05],'String','Close', 'callback',@(~,~)close())
    
    str2 = 'AS of Earthquake Number';
    title(str2);
end

function compare_misfit() 
    % Compare is used to compare the significance of two segments
    % in the plot of cumulative misfit as a function of earthquake number.
    %  --- Zhong Lu, June 1994.
    %
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    report_this_filefun();
    
    dat(:,2)=mi2(:,2);
    dat(:,1)=[1:length(mi2(:,1))]';
    cumu = dat(:,2);
    xt = dat(:,1);
    cumu2 = cumsum(cumu);
    
    set(gca,'NextPlot','add');
    ZG.bin_dur = days(0.5);
    par2 = 1.0;
    choice = input('type 1 to select range with cursor, 2 to input event numbers  ');
    if choice == 1
        t1 = [];
        t1 = ginput(1);
        t1(1)=round(t1(1));
        t1p = [  t1 ; t1(1) t1(2)-ZG.bin_dur];
        plot(t1p(:,1),t1p(:,2),'r');
        text( t1(1),t1(2)-par2,['t1: ', num2str(t1p(1))] );
        
        t2 = [];
        t2 = ginput(1);
        t2(1)=round(t2(1));
        t2p = [  t2 ; t2(1) t2(2)-ZG.bin_dur];
        plot(t2p(:,1),t2p(:,2),'r');
        text( t2(1),t2(2)-par2,['t2: ', num2str(t2p(1))] );
        
        t3 = [];
        t3 = ginput(1);
        t3(1)=round(t3(1));
        t3p = [  t3 ; t3(1) t3(2)+ZG.bin_dur];
        plot(t3p(:,1),t3p(:,2),'r');
        text( t3(1),t3(2)+par2,['t3: ', num2str(t3p(1))] );
        
        t4 = [];
        t4 = ginput(1);
        t4(1)=round(t4(1));
        t4p = [  t4 ; t4(1) t4(2)+ZG.bin_dur];
        plot(t4p(:,1),t4p(:,2),'r');
        text( t4(1),t4(2)+par2,['t4: ', num2str(t4p(1))] );
    else
        %tmp = 't1(1),t2(1),t3(1),t4(1)';
        t1(1) = str2double(input('type the 1st event number, then return    ','s'));
        t2(1) = str2double(input('type the 2nd event number, then return    ','s'));
        t3(1) = str2double(input('type the 3rd event number, then return    ','s'));
        t4(1) = str2double(input('type the last event number, then return    ','s'));
    end  % if
    set(gca,'NextPlot','add');
    
    mean1 = mean(cumu(t1(1):t2(1)));
    mean2 = mean(cumu(t3(1):t4(1)));
    var1  = cov(cumu(t1(1):t2(1)));
    var2  = cov(cumu(t3(1):t4(1)));
    zvalue = (mean1 - mean2)/(sqrt(var1/(t2(1)-t1(1)+1)+var2/(t4(1)-t3(1)+1)))
    
    if abs(zvalue) >= 2.58 %99%
        S = sprintf('Significant at 99%% ');
        disp(S);
    elseif abs(zvalue) >= 1.96 %95%
        S = sprintf('Significant at 95%% ');
        disp(S);
    elseif abs(zvalue) >= 1.64 %90%
        S = sprintf('Significant at 90%% ');
        disp(S);
    elseif abs(zvalue) >= 1.44 %85%
        S = sprintf('Significant at 85%% ');
        disp(S);
    else
        S = sprintf('May Significant below 85%% ');
        disp(S);
    end % if
    
    % use the t-test
    tvalue=(mean1 - mean2) * sqrt(t2(1)-t1(1)+t4(1)-t3(1)) / sqrt((t2(1)-t1(1)) * var1+(t4(1)-t3(1))*var2) / sqrt(1.0/(t2(1)-t1(1)+1)+1.0/(t4(1)-t3(1)+1))
    
    N=t2(1)-t1(1)+t4(1)-t3(1)
    disp('N=n1+n2-2');
    
end

function plotmima(var1, mi)
    report_this_filefun();
    
    ZG=ZmapGlobal.Data;
    global mif1
    global oneOfHowManyPopupIdx
    
    sc = oneOfHowManyPopupIdx;
    angMisfit = mi(:,2)+1; % added 1 because it's used as sizes
    figure(mif1) %TODO figure out where mif1 comes from
    delete(findobj(mif1,'Type','axes'));
    rect = [0.15,  0.20, 0.75, 0.65];
    axes('position',rect)
    watchon
    
    
    if var1 == 1
        
        for i = 1:catalog.Count
            pl =  plot(catalog.Longitude(i),catalog.Latitude(i),'ro');
            set(gca,'NextPlot','add')
            set(pl,'MarkerSize',angMisfit(i)/sc)
        end
        
    elseif var1 == 2
        
        for i = 1:catalog.Count
            pl =  plot(catalog.Longitude(i),catalog.Latitude(i),'bx');
            set(gca,'NextPlot','add')
            set(pl,'MarkerSize',angMisfit(i)/sc,'LineWidth',angMisfit(i)/sc)
        end
        
    elseif var1 == 3
        
        for i = 1:catalog.Count
            pl =  plot(catalog.Longitude(i),catalog.Latitude(i),'bx');
            set(gca,'NextPlot','add')
            c = angMisfit(i)/max(angMisfit);
            set(pl,'MarkerSize',angMisfit(i)/sc,'LineWidth',angMisfit(i)/sc,'Color',[ c c c ] )
        end
        
    elseif var1 == 4
        pl =  plot(catalog.Longitude,catalog.Latitude,'bx');
    end
    
    set(gca,'NextPlot','add')
    %axis([ s2_west s1_east s4_south s3_north])
    %zmap_update_displays();
    
    xlabel('Longitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    ylabel('Latitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    strib = 'Misfit Map ';
    title(strib,'FontWeight','bold',...
        'FontSize',ZmapGlobal.Data.fontsz.m,'Color','k')
    
    set(gca,'Color',color_bg);
    set(gca,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
    watchoff
end

function plotmimac(mi,inde)
    
    % TODO maybe move into domisfit
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    report_this_filefun();
    
    global mif2 mif1
    global oneOfHowManyPopupIdx
    
    %var1 = 4;
    sc = oneOfHowManyPopupIdx;
    figure(UNK) % FIXME: really? this figure? unsure
    delete(findobj(UNK,'Type','axes'));
    rect = [0.15,  0.20, 0.75, 0.65];
    axes('position',rect)
    watchon
    
    % check if cross-section exists
    figNumber=findobj('Type','Figure','-and','Name','Cross -Section');
    
    if isempty(figNumber)
        errordlg('Please create a cross-section first, then rerun the last selection');
        nlammap
        return
    end
    
    
    % check if cross-section is still current
    if max(mi(:,1)) > length(mi(:,1))
        errordlg('Please rerun the cross-section first, then rerun the last selection');
        nlammap
        return
    end
    
    
    mic = mi(inde,:);
    le = size(newa,2); %FIXME where does newa come from? ZG.newa? input parameter?  Needs to be treated like a ZmapCatalog
    
    if var1 == 1
        for i = 1:length(newa(:,6))
            pl =  plot(newa(i,le),-newa(i,7),'ro');
            set(gca,'NextPlot','add')
            set(pl,'MarkerSize',mic(i,2)/sc)
        end
        
    elseif var1 == 2
        
        for i = 1:length(newa(:,6))
            pl =  plot(newa(i,le),-newa(i,7),'bx');
            set(gca,'NextPlot','add')
            set(pl,'MarkerSize',mic(i,2)/sc,'LineWidth',mic(i,2)/sc)
        end
        
    elseif var1 == 3
        
        for i = 1:length(newa(:,6))
            pl =  plot(newa(i,le),-newa(i,7),'bx');
            set(gca,'NextPlot','add')
            c = mic(i,2)/max(mic(:,2));
            %c = newa(i,15)*10;
            set(pl,'MarkerSize',mic(i,2)/sc+3,'LineWidth',mic(i,2)/sc+0.5,'Color',[ c c c ] )
        end
        
    elseif var1 == 4
        
        g = jet;
        for i = 1:length(newa(:,6))
            pl =  plot(newa(i,le),-newa(i,7),'bx');
            set(gca,'NextPlot','add')
            c = floor(mic(i,2)/max(mic(:,2))*63+1);
            set(pl,'MarkerSize',4,'LineWidth',2,'Color',[ g(c,:) ] )
        end
        colorbar
        colormap(jet)
    end
    
    if exist('maex', 'var')
        set(gca,'NextPlot','add')
        pl = plot(maex,-maey,'*m');
        set(pl,'MarkerSize',8,'LineWidth',2)
    end
    
    if exist('maex', 'var')
        set(gca,'NextPlot','add')
        pl = plot(maex,-maey,'*m');
        set(pl,'MarkerSize',8,'LineWidth',2)
    end
    
    xlabel('Distance [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    ylabel('Depth [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    strib = [  'Misfit '];
    title(strib,'FontWeight','bold',...
        'FontSize',ZmapGlobal.Data.fontsz.m,'Color','k')
    
    set(gca,'Color',color_bg);
    set(gca,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
    uicontrol(...
        'Style','pushbutton',...
        'Units','normalized',...
        'Position',[0.9 0.7 0.08 0.08],...
        'String','Grid',...
        'callback',@(~,~)mificrgr(mi,inde));
    
    uicontrol(...
        'Style','pushbutton',...
        'Units','normalized',...
        'Position',[0.9 0.6 0.08 0.08],...
        'String','Sel EQ',...
        'callback',@cb_pickinv);
    
    watchoff
    
    function cb_pickinv(~,~)
        newa2=crosssel(newa);
        ZG.newt2=newa2;
        ZG.newcat=newa2;
        ctp=CumTimePlot(ZG.newt2);
        ctp.plot();
    end
end

function newcat2=plotmi(var1, newcat2, mi)
    %plot misfit (?)
    % TODO make this work with the new catalogs
    report_this_filefun();
    
    global  mif2 mif1
    global tmp % REALLY? global tmp?  "tmp" is 1:nEvents
    % cumu2 mi2
    figNumber=findobj('Type','Figure','-and','Name','Misfit ');
    figure(figNumber);
    delete(findobj(figNumber,'Type','axes'));
    rect = [0.15,  0.15, 0.75, 0.65];
    axes('position',rect)
    ax=gca;
    nEvents=newcat2.Count;
    tmp=1:nEvents;
    sixSlices=round(0 : nEvents/5 : nEvents);
    sixSlices(1)=1;
    
    var2=var1;
    
    misfitAngle = mi(:,2);
    X = 1:nEvents;
    xtitle=sprintf('Number of Eqs (sorted by %s)',lower(var1));
    switch (var1)
        case {'Longitude','Latitude','Magnitude','Depth'}
            % plot_by_lon(); %by lon
            plot_by_field(var1);
        case 'Time'
            plot_by_time(); % by date
        case 'Strike'
            plot_by_strike(); % along strike
        case 'Default'
            option_7(); %unsorted
        otherwise
            error('unknown choice for plotmi');
    end
    
    grid('on')
    set(ax,'Color',color_bg);
    set(ax,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
    ylabel('Cumulative Misfit ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m);
    xlabel(xtitle,'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    
    if var1 ~= "Default"
        set(gca,'NextPlot','add')
        for i=1:6
            plot(ax,tmp(sixSlices(i)),cumu2(sixSlices(i)),'xr');
            str=['  ',num2str(newcat2(sixSlices(i),var2))];
            te=text(tmp(sixSlices(i)),cumu2(sixSlices(i)),str);
            set(te,'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
        end
    else
        
    end
    
    
    function plot_by_field(name)
        % assumes that misfit matrix (mi) has same number of rows as 
        % number of earthquakes in catalog
        [~,is] = sort(newcat2.(name));
        newcat2.sort(name); % sort the catalog itself by this field
        
        cumu2=cumsum(misfitAngle(is));
        plot(1:nEvents , cumu2 , 'o');
        xtitle=sprintf('Number of Eqs (sorted by %s)',lower(name));
    end
    
    
    function plot_by_time()
        [~,is] = sort(newcat2.Date);
        newcat2.sort(Date);
        cumu2=cumsum(misfitAngle(is));
        pl = plot(tmp,cumu2,'o');
        xtitle='Number of Eqs (sorted by time)';
    end
    
    function plot_by_strike()
        % [~,is] = sort(newcat2(:,15));
        [~,is] = sort(newcat2(:,end));
        newa2 = newcat2.subset(is) ;
        cumu2=cumsum(misfitAngle(is));
        pl = plot(newa2(:,16)-18.6,cumu2,'o');
        xtitle='Number of Eqs (sorted along strike)';
        var2=15;
    end
    
    function option_7()
        mi2 = mi ;
        cumu2=cumsum(mi2(:,2));
        pl = plot(tmp,cumu2,'o');
        xtitle='Number of Eqs ';
    end
end

function mifigrid(var1,mi) 
    
    % This function creates a grid with spacing dx, dy (in degrees)
    % The size is selected interactively in an input window.
    % The relative quiescence will be calculated for every grid point
    % for a specific time and plotted in a Seismolap-Quiescence map
    %
    % turned into function by Celso G Reyes 2017
    %
    %MIFIGRID(var1,mi)
    % 
    % Alexander Allmann
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    report_this_filefun();
    
    global  ni me1 va1
    global a h1 map dx dy Mmin lap1 seismap
    global normlap1 normlap2 mif1 mifmap
    
    if var1==1
        
        
        %input window
        %
        %default parameters
        dx= .5;                      %grid spacing east-west
        dy= .5;                      %grid spacing north-south
        % ldx=100;                     %side length of interaction zone in km (for seislap)
        % tlap=300;                    %interaction time in days (for seislap)
        Mmin=3;                      %minimum magnitude
        
        
        %create a input window
        figure_w_normalized_uicontrolunits(...
            'Name','Grid Input Parameter',...
            'NumberTitle','off', ...
            'NextPlot','new', ...
            'units','points',...
            'Visible','off', ...
            'Position',[ ZG.welcome_pos + [200, -200], 450, 250]);
        axis off
        
        %create a dialog box for the input
        freq_field1=uicontrol('Style','edit',...
            'Position',[.60 .36 .15 .08],...
            'Units','normalized','String',num2str(dx),...
            'callback',@callbackfun_001);
        
        freq_field2=uicontrol('Style','edit',...
            'Position',[.60 .27 .15 .08],...
            'Units','normalized','String',num2str(dy),...
            'callback',@callbackfun_002);
        
        freq_field3=uicontrol('Style','edit',...
            'Position',[.60 .48 .15 .08],...
            'Units','normalized','String',num2str(ni),...
            'callback',@callbackfun_003);
        
        close_button=uicontrol('Style','Pushbutton',...
            'Position',[.70 .05 .15 .12 ],...
            'Units','normalized', 'Callback', @callbackfun_004,'String','Cancel');
        
        
        go_button1=uicontrol('Style','Pushbutton',...
            'Position',[.20 .05 .15 .12 ],...
            'Units','normalized',...
            'callback',@callbackfun_005,...
            'String','Go');
        
        txt4 = text(...
            'Position',[0.50 0.74 0 ],...
            'FontSize',ZmapGlobal.Data.fontsz.l ,...
            'FontWeight','bold',...
            'String',' Grid Parameter');
        txt5 = text(...
            'Position',[0. 0.35 0 ],...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold',...
            'String','Spacing in x (dx) in deg:');
        
        txt6 = text(...
            'Position',[0. 0.25 0 ],...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold',...
            'String','Spacing in y (dy) in deg:');
        
        txt2 = text(...
            'Position',[0. 0.5 0 ],...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold',...
            'String',' # of EQ Ni:');
        
        set(gcf,'visible','on');
        watchoff
        
    elseif var1==2           %area selection
        
        figure(map);
        set(gca,'NextPlot','add')
        ax=findobj(gcf,'Tag','mainmap_ax');
        [x,y, mouse_points_overlay] = select_polygon(ax);
        
        
        %figure_w_normalized_uicontrolunits(mif1)
        
        plos2 = plot(x,y,'b-');        % plot outline
        sum3 = 0.;
        pause(0.3)
        
        %create a rectangular grid
        xvect=[min(x):dx:max(x)];
        yvect=[min(y):dy:max(y)];
        tmpgri=zeros((length(xvect)*length(yvect)),2);
        n=0;
        for i=1:length(xvect)
            for j=1:length(yvect)
                n=n+1;
                tmpgri(n,:)=[xvect(i) yvect(j)];
            end
        end
        %extract all gridpoints in chosen polygon
        XI=tmpgri(:,1);
        YI=tmpgri(:,2);
        ll = polygon_filter(x,y, XI, YI, 'inside');
        %grid points in polygon
        newgri=tmpgri(ll,:);
        
        % Plot all grid points
        gcf
        plot(newgri(:,1),newgri(:,2),'+k')
        drawnow
        
        
        if length(xvect) < 2  ||  length(yvect) < 2
            errordlg('Selection too small! (not a matrix)');
            return
        end
        
        %calculate lap1(relative quiescence) at every grid point
        %
        ZG.newcat=a;                   %ZG.newcat is only a local variable
        bcat=ZG.newcat;
        
        me1=zeros(length(newgri(:,1)),1);
        va1=zeros(length(newgri(:,1)),1);
        
        wai = waitbar(0,' Please Wait ...  ');
        set(wai,'NumberTitle','off','Name','Makegrid - Percent completed');
        drawnow
        
        
        
        for i= 1:length(me1)   %all eqs which are in spacewindow in east-west direction
            l = sqrt(((ZG.newcat.Longitude-newgri(i,1))*cosd(newgri(i,2))*111).^2 +...
                ((ZG.newcat.Latitude-newgri(i,2))*111).^2) ;
            [s,is] = sort(l);
            b = ZG.newcat.subset(is) ;       % re-orders matrix to agree row-wise
            mi2 = mi(is(:,1),2);    % take first ni points
            mi2 = mi2(1:ni);
            me1(i) = mean(mi2);
            va1(i) = std(mi2);
            if rem(i,20)==0;  waitbar(i/length(me1));end
            
        end
        
        
        close(wai)
        %make a color map
        % Find out if figure already exists
        %
        mifmap=findobj('Type','Figure','-and','Name','Misfit-Map 2');
        
        % Set up the Seismicity Map window Enviroment
        %
        if isempty(mifmap)
            mifmap = figure_w_normalized_uicontrolunits( ...
                'Name','Misfit-Map 2',...
                'NumberTitle','off', ...
                'NextPlot','replace', ...
                'backingstore','on',...
                'Visible','off', ...
                'Position',[ 600 400 500 650]);
            % make menu bar
            
            
            
            set(gca,'NextPlot','add')
        end
        figure(mifmap)
        delete(findobj(mifmap,'Type','axes'));
        
        set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
            'FontWeight','bold','LineWidth',1.5,...
            'Box','on','SortMethod','childorder')
        
        %minimum and maximum of normlap2 for automatic scaling
        ZG.maxc = max(normlap2);
        ZG.minc = min(normlap2);
        
        %construct a matrix for the color plot
        normlap1=ones(length(tmpgri(:,1)),1);
        normlap2=nan(length(tmpgri(:,1)),1)
        normlap3=nan(length(tmpgri(:,1)),1)
        normlap1(ll)=me1;
        normlap2(ll)=normlap1(ll);
        normlap1(ll)=va1;
        normlap3(ll)=normlap1(ll);
        
        normlap2=reshape(normlap2,length(yvect),length(xvect));
        normlap3=reshape(normlap3,length(yvect),length(xvect));
        
        %plot color image
        orient tall
        memifig2
        
        return
        
        rect = [0.25,  0.60, 0.7, 0.35];
        axes('position',rect)
        set(gca,'NextPlot','add')
        pco1 = pcolor(xvect,yvect,normlap2);
        shading interp
        colormap(jet)
        axis([ s2_west s1_east s4_south s3_north])
        set(gca,'NextPlot','add')
        colorbar
        overlay
        title('Mean of the Misfit','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        xlabel('Longitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        ylabel('Latitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        
        set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
            'FontWeight','bold','LineWidth',1.5,...
            'Box','on','TickDir','out')
        
        rect = [0.25,  0.10, 0.7, 0.35];
        axes('position',rect)
        set(gca,'NextPlot','add')
        pco1 = pcolor(xvect,yvect,normlap3);
        axis([ s2_west s1_east s4_south s3_north])
        set(gca,'NextPlot','add')
        shading interp
        colormap(jet)
        set(gca,'NextPlot','add')
        colorbar
        title(' Variance of the Misfit','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        xlabel('Longitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        ylabel('Latitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        
        set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
            'FontWeight','bold','LineWidth',1.5,...
            'Box','on','TickDir','out')
        
        overlay
        memifig2
    end
    
    function callbackfun_001(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        dx=str2double(freq_field1.String);
        freq_field1.String=num2str(dx);
    end
    
    function callbackfun_002(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        dy=str2double(freq_field2.String);
        freq_field2.String=num2str(dy);
    end
    
    function callbackfun_003(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ni=str2double(freq_field3.String);
        freq_field3.String=num2str(ni);
    end
    
    function callbackfun_004(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close;
        
    end
    
    function callbackfun_005(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close;
        var1 = 2;
        mifigrid(var1, mi);
    end
    
end

function memifig2() 
    % Misfitmap 2 (?)
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    report_this_filefun();
    
    
    %input window
    %
    %default parameters
    
    %make a color map
    % Find out if figure already exists
    %
    mifmap=findobj('Type','Figure','-and','Name','Misfit-Map 2');
    
    % Set up the Seismicity Map window Enviroment
    %
    if isempty(mifmap)
        mifmap = figure_w_normalized_uicontrolunits( ...
            'Name','Misfit-Map 2',...
            'NumberTitle','off', ...
            'NextPlot','replace', ...
            'backingstore','on',...
            'Visible','off', ...
            'Position',[ 600 400 500 350]);
        % make menu bar
        set(gca,'NextPlot','add')
    end
    
    figure(mifmap);
    delete(findobj(mifmap,'Type','axes'));
    
    set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','SortMethod','childorder')
    
    %minimum and maximum of normlap2 for automatic scaling
    ZG.maxc = max(normlap2);
    ZG.minc = min(normlap2);
    
    %construct a matrix for the color plot
    normlap1=ones(length(tmpgri(:,1)),1);
    normlap2=nan(length(tmpgri(:,1)),1)
    normlap3=nan(length(tmpgri(:,1)),1)
    normlap1(ll)=me1;
    normlap2(ll)=normlap1(ll);
    normlap1(ll)=va1;
    normlap3(ll)=normlap1(ll);
    
    normlap2=reshape(normlap2,length(yvect),length(xvect));
    normlap3=reshape(normlap3,length(yvect),length(xvect));
    
    %plot color image
    orient tall
    gx = xvect; gy = yvect;
    
    set(gca,'NextPlot','add')
    pco1 = pcolor(xvect,yvect,normlap2);
    shading interp
    colormap(flipud(jet(10)));
    axis([ min(gx) max(gx) min(gy) max(gy)])
    axis image
    
    set(gca,'NextPlot','add')
    h5 = colorbar('vert');
    set(h5,'Pos',[0.82 0.46 0.02 0.20],...
        'FontSize',12)
    
    
    
    if exist('maex', 'var')
        set(gca,'NextPlot','add')
        pl = plot(maex,-maey,'*k');
        set(pl,'MarkerSize',6,'LineWidth',2)
    end
    
    overlay
    title(['Mean of the Misfit (' num2str(sig) '/' num2str(az)  '/' num2str(plu) '/' num2str(phi) '/' num2str(R) ')'] ,'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
    xlabel('Longitude in [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
    ylabel('latitude in [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
    
    set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','TickDir','out')
end

function mificrgr( mi, inde) 
    % This function creates a grid with spacing dx, dy (in degrees)
    % The size is selected interactively in an input window.
    % The relative quiescence will be calculated for every grid point
    % for a specific time and plotted in a Seismolap-Quiescence map
    %  Alexander Allmann
    %
    % turned into function by Celso G Reyes 2017
    
    
    %global freq_field1 freq_field2 freq_field3 freq_field4 freq_field5
    %global freq_field6 ni me1 va1
    %global h1 map dx dy Mmin lap1 seismap
    %global normlap1 normlap2 mif1 mifmap
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    report_this_filefun();
    
    %input window
    %
    %default parameters
    dx= .5;                      %grid spacing east-west
    dy= .5;                      %grid spacing north-south
    %ldx=100;                     %side length of interaction zone in km (for seislap)
    %tlap=300;                    %interaction time in days (for seislap)
    Mmin=3;                      %minimum magnitude
    ni=100; % number of events
    
    %create a input window
    fig=figure_w_normalized_uicontrolunits(...
        'Name','Grid Input Parameter',...
        'NumberTitle','off', ...
        'NextPlot','new', ...
        'units','points',...
        'Visible','off', ...
        'MenuBar','none',...
        'Position',[ ZG.welcome_pos + [200, -200], 700, 250]);
    axis off
    
    gridOpts = ZG.gridopt;
    esp = EventSelectionParameters('NumClosestEvents',ni);
    selOpts = EventSelectionChoice(fig,'evsel',esp);
    
    
    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.70 .05 .15 .12 ],...
        'Units','normalized', 'Callback', @callbackfun_cancel,'String','Cancel');
    
    
    go_button1=uicontrol('Style','Pushbutton',...
        'Position',[.20 .05 .15 .12 ],...
        'Units','normalized',...
        'callback',@callbackfun_go,...
        'String','Go');
    
    set(gcf,'visible','on');
    watchoff
    
    function my_calculate()
        
        xsec_h=xsec_fig();
        
        if isempty(xsec_h) % best guess at figure handle variable
            nlammap
        else
            figure(xsec_h);
        end
        
        set(gca,'NextPlot','add')
        ax=findobj(gcf,'Tag','mainmap_ax');
        [x,y, mouse_points_overlay] = select_polygon(ax);
        
        
        figure(xsec_h)
        
        plos2 = plot(x,y,'b-');        % plot outline
        sum3 = 0.;
        pause(0.3)
        
        %create a rectangular grid
        xvect=[min(x):dx:max(x)];
        yvect=[min(y):dy:max(y)];
        tmpgri=zeros((length(xvect)*length(yvect)),2);
        n=0;
        for i=1:length(xvect)
            for j=1:length(yvect)
                n=n+1;
                tmpgri(n,:)=[xvect(i) yvect(j)];
            end
        end
        %extract all gridpoints in chosen polygon
        XI=tmpgri(:,1);
        YI=tmpgri(:,2);
        
        ll = polygon_filter(x,y, XI, YI, 'inside');
        %grid points in polygon
        newgri=tmpgri(ll,:);
        
        % Plot all grid points
        gcf
        plot(newgri(:,1),newgri(:,2),'+k')
        drawnow
        
        if length(xvect) < 2  ||  length(yvect) < 2
            errordlg('Selection too small! (not a matrix)');
            return
        end
        
        
        
        %
        ZG.newcat=a;                   %ZG.newcat is only a local variable
        bcat=ZG.newcat;
        
        me1=zeros(length(newgri(:,1)),1);
        va1=zeros(length(newgri(:,1)),1);
        mic = mi(inde,:);
        
        wai = waitbar(0,' Please Wait ...  ');
        set(wai,'NumberTitle','off','Name','Makegrid - Percent completed');
        drawnow
        
        for i= 1:length(me1)   %all eqs which are in spacewindow in east-west direction
            x = newgri(i,1);y = newgri(i,2);
            
            l = sqrt(((xsecx' - x)).^2 + ((xsecy + y)).^2) ;
            [s,is] = sort(l);
            b = ZG.newcat.subset(is) ;       % re-orders matrix to agree row-wise
            mi2 = mic(is(:,1),2);    % take first ni points
            mi2 = mi2(1:ni);
            me1(i) = mean(mi2);
            va1(i) = std(mi2);
            if rem(i,20)==0;  waitbar(i/length(me1));end
        end
        
        
        close(wai)
        %make a color map
        % Find out if figure already exists
        %
        mifmap=findobj('Type','Figure','-and','Name','Misfit-Map 2');
        
        % Set up the Seismicity Map window Enviroment
        %
        if isempty(mifmap)
            mifmap = figure_w_normalized_uicontrolunits( ...
                'Name','Misfit-Map 2',...
                'NumberTitle','off', ...
                'NextPlot','replace', ...
                'backingstore','on',...
                'Visible','off', ...
                'Position',[ 600 400 500 650]);
            % make menu bar
            
            
            
            set(gca,'NextPlot','add')
        end
        
        figure(mifmap);
        delete(findobj(mifmap,'Type','axes'));
        
        set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
            'FontWeight','bold','LineWidth',1.5,...
            'Box','on','SortMethod','childorder')
        
        %minimum and maximum of normlap2 for automatic scaling
        ZG.maxc = max(normlap2);
        ZG.minc = min(normlap2);
        
        %construct a matrix for the color plot
        normlap1=ones(length(tmpgri(:,1)),1);
        normlap2=nan(length(tmpgri(:,1)),1)
        normlap3=nan(length(tmpgri(:,1)),1)
        normlap1(ll)=me1;
        normlap2(ll)=normlap1(ll);
        normlap1(ll)=va1;
        normlap3(ll)=normlap1(ll);
        
        normlap2=reshape(normlap2,length(yvect),length(xvect));
        normlap3=reshape(normlap3,length(yvect),length(xvect));
        
        %plot color image
        orient tall
        gx = xvect; 
        gy = yvect;
        memifig
        
        return
        
        rect = [0.25,  0.60, 0.7, 0.35];
        axes('position',rect)
        set(gca,'NextPlot','add')
        pco1 = pcolor(xvect,yvect,normlap2);
        shading interp
        colormap(jet)
        %axis([ s2_west s1_east s4_south s3_north])
        axis([ min(gx) max(gx) min(gy) max(gy)])
        axis image
        
        set(gca,'NextPlot','add')
        colorbar
        if exist('maex', 'var')
            set(gca,'NextPlot','add')
            pl = plot(maex,-maey,'*m');
            set(pl,'MarkerSize',8,'LineWidth',2)
        end
        
        %overlay
        title('Mean of the Misfit','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        xlabel('Distance in [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        ylabel('Depth in [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        
        set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
            'FontWeight','bold','LineWidth',1.5,...
            'Box','on','TickDir','out')
        
        rect = [0.25,  0.10, 0.7, 0.35];
        axes('position',rect)
        set(gca,'NextPlot','add')
        pco1 = pcolor(xvect,yvect,normlap3);
        axis([ min(gx) max(gx) min(gy) max(gy)])
        axis image
        
        if exist('maex', 'var')
            set(gca,'NextPlot','add')
            pl = plot(maex,-maey,'*w');
            set(pl,'MarkerSize',8,'LineWidth',2)
        end
        
        
        set(gca,'NextPlot','add')
        shading interp
        colormap(jet)
        set(gca,'NextPlot','add')
        colorbar
        title(' Variance of the Misfit','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        xlabel('Distance in [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        ylabel('Depth in [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
        
        set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
            'FontWeight','bold','LineWidth',1.5,...
            'Box','on','TickDir','out')
        
    end
    
    function callbackfun_cancel(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close;
        
    end
    
    function callbackfun_go(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        dx=gridOpts.dx;
        dy=gridOpts.dy;
        ni=selOpts.ni;
        delete(selOpts);
        close;
        my_calculate();
    end
    
end

function memifig() 
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    report_this_filefun();
    
    
    %input window
    %
    %default parameters
    
    %make a color map
    % Find out if figure already exists
    %
    mifmap=findobj('Type','Figure','-and','Name','Misfit-Map 2');
    
    % Set up the Seismicity Map window Enviroment
    %
    if isempty(mifmap)
        mifmap = figure_w_normalized_uicontrolunits( ...
            'Name','Misfit-Map 2',...
            'NumberTitle','off', ...
            'NextPlot','replace', ...
            'backingstore','on',...
            'Visible','off', ...
            'Position',[ 600 400 500 350]);
        % make menu bar
        
        
        
        set(gca,'NextPlot','add')
    end
    figure(mifmap);
    delete(findobj(mifmap,'Type','axes'));
    
    set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','SortMethod','childorder')
    
    %minimum and maximum of normlap2 for automatic scaling
    ZG.maxc = max(normlap2);
    ZG.minc = min(normlap2);
    
    %construct a matrix for the color plot
    normlap1=ones(length(tmpgri(:,1)),1);
    normlap2=nan(length(tmpgri(:,1)),1)
    normlap3=nan(length(tmpgri(:,1)),1)
    normlap1(ll)=me1;
    normlap2(ll)=normlap1(ll);
    normlap1(ll)=va1;
    normlap3(ll)=normlap1(ll);
    
    normlap2=reshape(normlap2,length(yvect),length(xvect));
    normlap3=reshape(normlap3,length(yvect),length(xvect));
    
    %plot color image
    orient tall
    gx = xvect; gy = yvect;
    
    set(gca,'NextPlot','add')
    pco1 = pcolor(xvect,yvect,normlap2);
    shading interp
    colormap( flipud(jet(64)) );
    axis([ min(gx) max(gx) min(gy) max(gy)])
    axis image
    
    set(gca,'NextPlot','add')
    h5 = colorbar('vert');
    set(h5,'Pos',[0.82 0.46 0.03 0.10],...
        'FontSize',2)
    
    
    
    if exist('maex', 'var')
        set(gca,'NextPlot','add')
        pl = plot(maex,-maey,'*w');
        set(pl,'MarkerSize',6,'LineWidth',1)
    end
    
    %overlay
    title('Mean of the Misfit','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
    xlabel('Distance in [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
    ylabel('Depth in [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
    
    set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','TickDir','out')
end

