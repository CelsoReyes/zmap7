% Matlab Script: Cum_timeplot.m
% Modified timeplot-script of ZMAP
% ---------------------------------
% Removed buttons "Reset"  and " "Keep as new catalog"
% Author: J. Woessner
%
% This .m file "timeplot" plots the events select by "circle"
% or by other selection button as a cummultive number versus
% time plot in window 2.
% Time of events with a Magnitude greater than minmag will
% be shown on the curve.  Operates on newt2, resets  b  to newt2,
%     newcat is reset to:
%                       - "a" if either "Back" button or "Close" button is         %                          pressed.
%                       - newt2 if "Save as Newcat" button is pressed.
%Last modification 11/95

report_this_filefun(mfilename('fullpath'));

global tmvar                      %for P-Value
global par1 pplot tmp1 tmp2 tmp3 tmp4 difp loopcheck Info_p
global cplot mess til plo2 cum newt2 statime
global magco selt hndl2 wls_button ml_button;;


zmap_message_center.set_info(' ','Plotting cumulative number plot...');

if ~exist('nosort', 'var') ; nosort = 'of'  ; end

if nosort == 'of'
    [s,is] = sort(newt2.Date);
    newt2 = newt2(is(:,1),:) ;
else  % f
    if t3>t2
        l = min(find(newt2.Date > t2))-1;
        newt2 = [newt2(1:l,:) ; newt2(1,:)*nan ; newt2(l+1:newt2.Count,:) ];
    end

end

if ~exist('xt','var')
xt=[]; % time series that will be used
end
if ~exist('as','var')
    as=[]; % z values, maybe? used by the save callback.
end

think
report_this_filefun(mfilename('fullpath'));

% This is the info window text
%
ttlStr='The Cumulative Number Window                  ';
hlpStr1= ...
    ['                                                     '
    ' This window displays the seismicity in the sel-     '
    ' ected area as a cumulative number plot.             '
    ' Options from the Tools menu:                        '
    ' Cuts in magnitude and  depth: Opens input para-     '
    '    meter window                                     '
    ' Decluster the catalog: Will ask for declustering    '
    '     input parameter and decluster the catalog.      '
    ' AS(t): Evaluates significance of seismicity rate    '
    '      changes using the AS(t) function. See the      '
    '      Users Guide for details                        '
    ' LTA(t), Rubberband: dito                            '
    ' Overlay another curve (hold): Allows you to plot    '
    '       one or several more curves in the same plot.  '
    '       select "Overlay..." and then selext a new     '
    '       subset of data in the map window              '
    ' Compare two rates: start a comparison and moddeling '
    '       of two seimicity rates based on the assumption'
    '       of a constant b-value. Will calculate         '
    '       Magnitude Signature. Will ask you for four    '
    '       times.                                        '
    '                                                     '];
hlpStr2= ...
    ['                                                      '
    ' b-value estimation:    just that                     '
    ' p-value plot: Lets you estimate the p-value of an    '
    ' aftershock sequence.                                 '
    ' Save cumulative number cure: Will save the curve in  '
    '        an ASCII file                                 '
    '                                                      '
    ' The "Keep as newcat" button in the lower right corner'
    ' will make the currently selected subset of eartquakes'
    ' in space, magnitude and depth the current one. This  '
    ' will also redraw the Map window!                     '
    '                                                      '
    ' The "Back" button will plot the original cumulative  '
    ' number curve without statistics again.               '
    '                                                      '];


% Find out of figure already exists
%
[existFlag,figNumber]=figure_exists('Cumulative Number',1);
newCumWindowFlag=~existFlag;
cum = figNumber;

% Set up the Cumulative Number window

if newCumWindowFlag
    cum = figure_w_normalized_uicontrolunits( ...
        'Name','Cumulative Number',...
        'NumberTitle','off', ...
        'NextPlot','replace', ...
        'backingstore','on',...
        'Visible','off', ...
        'Position',[ 100 100 (ZmapGlobal.Data.map_len - [100 20]) ]);

    matdraw

    selt='in';
    add_menu_divider();
    options = uimenu('Label','ZTools');

    uimenu(options,'Label','Cuts in time, magnitude and depth', 'Callback','inpu2')
    uimenu(options,'Label','Cut in Time (cursor) ', 'Callback','timesel(4);timeplot;');
    uimenu(options,'Label','Date Ticks in different format', 'Callback','newtimetick');

    uimenu (options,'Label','Decluster the catalog', 'Callback','inpudenew;')
    iwl = iwl2*365/par1;
    uimenu(options,'Label','Overlay another curve (hold)', 'Callback','ho2=true; ')
    uimenu(options,'Label','Compare two rates (fit)', 'Callback','dispma2')
    uimenu(options,'Label','Compare two rates ( No fit)', 'Callback','ic=0;dispma3')
    %uimenu(options,'Label','Day/Night split ', 'Callback','daynigt')

    op3D  =   uimenu(options,'Label','Time series ');
    uimenu(op3D,'Label','Time-depth plot ',...
        'Callback',@(~,~)TimeDepthPlotter.plot(newt2));
    uimenu(op3D,'Label','Time magnitude plot ',...
        'Callback',@(~,~)TimeMagnitudePlotter.plot(newt2));




    op4B = uimenu(options,'Label','Rate changes (beta and z-values) ');

    uimenu(op4B, 'Label', 'beta values: LTA(t) function',...
         'Callback', 'sta = ''bet'',newsta')
    uimenu(op4B, 'Label', 'beta values: "Triangle" Plot',...
         'Callback', ';betatriangle')
    uimenu(op4B,'Label','z-values: AS(t)function',...
         'Callback','set(gcf,''Pointer'',''watch'');sta = ''ast'';newsta')
    uimenu(op4B,'Label','z-values: Rubberband function',...
         'Callback','set(gcf,''Pointer'',''watch'');sta = ''rub'';newsta')
    uimenu(op4B,'Label','z-values: LTA(t) function ',...
         'Callback','set(gcf,''Pointer'',''watch'');sta = ''lta'';newsta')


    op4 = uimenu(options,'Label','Mc and b-value estimation');
    uimenu(op4,'Label','automatic', 'Callback','ho=false,selt = ''in'',; bdiff2')
    uimenu(op4,'Label','automatic - overlay existing plot', 'Callback','ho=true,selt = ''in'',;,bdiff2')
 %   uimenu(op4,'Label','manual', 'Callback','bfitnew(newt2)')
    uimenu(op4,'Label','Estimate Mc', 'Callback','mcperc')
    uimenu(op4,'Label','b with depth', 'Callback','bwithde2')
    uimenu(op4,'Label','b with time', 'Callback','selt=''in'';bwithti')
    uimenu(op4,'label','b with magnitude', 'Callback','bwithmag');
    uimenu(op4,'label','Magnitude of completeness (Mc) with time', 'Callback','mcwti');
    uimenu(op4,'label','Create synthetic catalog', 'Callback','synthb');


    pstring=['global freq_field1 freq_field2 freq_field3 freq_field4 freq_field5 tmp1 tmp2 tmp3 tmp4 tmm magn hpndl1 ctiplo mtpl ttcat;ttcat=newt2;'];
    ptstring=[pstring ' cltipval(2);'];
    pmstring=[pstring ' cltipval(1);'];

    op5 = uimenu(options,'Label','p-value estimation');

    %uimenu(op5,'Label','automatic', 'Callback','global hndl1;ttcat =newt2; clpval(3)')
    %The following instruction calls a program for the computation of the parameters in Omori formula, for the catalog of which the cumulative number graph" is
    %displayed (the catalog newt2).
    uimenu(op5,'Label','Completeness in days after mainshock', 'Callback','mcwtidays')
    uimenu(op5,'Label','Define mainshock and estimate p', 'Callback','ho=false;inpu_main')
    uimenu(op5,'Label','Compute p and overlay existing plot', 'Callback','ho=true; pvalcat')
    %In the following instruction the program pvalcat2.m is called. This program computes a map of p in function of the chosen values for the minimum magnitude and
    %initial time.
    uimenu(op5,'Label','p as a function of time and magnitude', 'Callback','pvalcat2')
    %uimenu(op5,'Label','Run aspar3x', 'Callback',' runasp')
    %The previous option is available only under UNIX. The file must contain the mainshock!!
    % uimenu(op5,'Label',' Help/Info on  aspar3x', 'Callback','  do = [ ''web '' hodi ''/help/aspar.htm ;'' ];eval(do) ')
    uimenu(op5,'Label','Cut catalog at mainshock time', 'Callback','l = min(find( newt2.Magnitude == max(newt2.Magnitude) ));newt2 = newt2(l+1:newt2.Count,:);timeplot ')

    op6 = uimenu(options,'Label','Fractal dimension estimation');
    uimenu(op6,'Label','Compute the fractal dimension D', 'Callback',' E = newt2; org = [2]; startfd');
    uimenu(op6,'Label','Compute D for random catalog', 'Callback',' org = [5]; startfd;');
    uimenu(op6,'Label','Compute D with time', 'Callback',' org = [6]; startfd;');
    uimenu(op6,'Label',' Help/Info on  fractal dimension', 'Callback',' showweb(''fractal''); ')

    uimenu(options,'Label','get coordinates with cursor ',...
         'Callback','gi = ginput(1),plot(gi(1),gi(2),''+'');')
    %uimenu(options,'Label','CUSUM ',...
    % 'Callback','cusum(newt2);')
    %uimenu(options,'Label','CUFIT ',...
    % 'Callback','cufit(newt2);')
    uimenu(options,'Label','Cumlative Moment Release ', 'Callback','morel')
    % uimenu(options,'Label','Time to failure  ', 'Callback','savebufe; bufestefan')
    %uimenu(options,'Label','Compute maximum possibe magnitude (Kijko method)', 'Callback','maxmagkijko')

    op7 = uimenu(options,'Label','Stress Tensor Inversion Tools');
    uimenu(op7,'Label','Invert for stress-tensor - Michael''s Method ', 'Callback','doinvers_michael')
    uimenu(op7,'Label','Invert for stress-tensor - Gephart''s Method ', 'Callback','doinversgep_pc')
    uimenu(op7,'Label','Stress tensor with time', 'Callback','stresswtime')
    uimenu(op7,'Label','Stress tensor with depth', 'Callback','stresswdepth')
    uimenu(op7,'Label',' Help/Info on  stress tensor inversions', 'Callback','  showweb(''stress'') ')
    op5C = uimenu(options,'Label','Histograms');

    uimenu(op5C,'Label','Magnitude',...
        'Callback','global histo;hisgra(newt2.Magnitude,stt1);');
    uimenu(op5C,'Label','Depth',...
        'Callback','global histo;hisgra(newt2.Depth,stt2);');
    uimenu(op5C,'Label','Time',...
        'Callback','global histo;hisgra(newt2.Date,''Time '');');
    uimenu(op5C,'Label','Hr of the day',...
        'Callback','global histo;hisgra(newt2.Date.Hour,''Hr '');');


    %uimenu(options,'Label',' Magnitude signature', 'Callback','dispma0')
    uimenu(options,'Label','Save cumulative number curve', 'Callback',{@calSave1, xt, cumu2})

    uimenu(options,'Label','Save cum #  and z value', 'Callback',{@calSave7, xt, cumu2, as})

    % 



%     uicontrol('Units','normal','Position',[.0 .0 .1 .05],'String','Reset', 'Callback','nosort = ''of'';newcat = newcat; newt2 = newcat; stri = ['' '']; stri1 = ['' '']; close(cum); timeplot','tooltip','Resets the catalog to the original selection')
%     uicontrol('Units','normal','Position',[.70 .0 .3 .05],'String','Keep as newcat', 'Callback','newcat = newt2;a=newt2;update(mainmap())','tooltip','Plots this subset in the map window')

    ho2=false;

end
%end;    if figure exist

if ho2
    cumu = 0:1:(tdiff*365/par1)+2;
    cumu2 = 0:1:(tdiff*365/par1)-1;
    cumu = cumu * 0;
    cumu2 = cumu2 * 0;
    n = newt2.Count;
    [cumu, xt] = hist(newt2.Date,(t0b:par1/365:teb));
    cumu2 = cumsum(cumu);


    hold on
    axes(ht)
    tiplot2 = plot(newt2.Date,(1:newt2.Count),'r','era','xor');
    set(tiplot2,'LineWidth',2.0)


    ho2=false
    return
end

figure_w_normalized_uicontrolunits(cum)
delete(gca)
delete(gca)
reset(gca)
dele = 'delete(sicum)';er = 'disp('' '')'; eval(dele,er);
cla
hold off
watchon;

set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','normal',...
    'LineWidth',1.5,...
    'Box','on','SortMethod','childorder')

if isempty(newcat), newcat =a; end

% select big events ( > minmag)
%
l = newt2.Magnitude > minmag;
big = newt2(l,:);
%big=[];
%calculate start -end time of overall catalog
%R
statime=[];
par2=par1;
t0b = min(a.Date);
n = newt2.Count;
teb = max(a.Date);
ttdif=(teb - t0b)*365;
if ttdif>10                 %select bin length respective to time in catalog
    %par1 = ceil(ttdif/300);
elseif ttdif<=10  &&  ttdif>1
    %par1 = 0.1;
elseif ttdif<=1
    %par1 = 0.01;
end


if par1>=1
    tdiff = round((teb - t0b)*365/par1);
    %tdiff = round(teb - t0b);
else
    tdiff = (teb-t0b)*365/par1;
end
% set arrays to zero
%
%if par1>=1
cumu = 0:1:((teb-t0b)*365/par1)+2;
cumu2 = 0:1:((teb-t0b)*365/par1)-1;
%else
%  cumu = 0:par1:tdiff+2*par1;
%  cumu2 =  0:par1:tdiff-1;
%end
% cumu = cumu * 0;
% cumu2 = cumu2 * 0;

%
% calculate cumulative number versus time and bin it
%
n = newt2.Count;
if par1 >=1
    [cumu, xt] = hist(newt2.Date,(t0b:par1/365:teb));
else
    [cumu, xt] = hist((newt2.Date-newt2(1,3)+par1/365)*365,(0:par1:(tdiff+2*par1)));
end
cumu2=cumsum(cumu);
% plot time series
%
%orient tall
set(gcf,'PaperPosition',[0.5 0.5 5.5 8.5])
rect = [0.25,  0.18, 0.60, 0.70];
axes('position',rect)
hold on
%tiplo = plot(xt,cumu2,'ob');
set(gca,'visible','off')
%tiplo2 = plot(xt,cumu2,'b');
%set(tiplo2,'LineWidth',2.5)

%d = datenum(ceil(a.Date)+1900,a.Date.Month,a.Date.Day,a.Date.Hour,a.Date.Minute,a.Date.Minute*0);
%tiplo2 = plot(d,(1:length(d)),'r-.');
%datetick('x',2)

nu = (1:newt2.Count); nu(newt2.Count) = newt2.Count;

tiplot2 = plot([newt2.Date ],nu,'b');
set(tiplot2,'LineWidth',2.0)

% plot end of data
% pl = plot(teb,newt2.Count,'rs');
%set(pl,'LineWidth',1.0,'MarkerSize',6,...
%  'MarkerFaceColor','r','MarkerEdgeColor','g');


% plot big events on curve
%
if par1>=1
    if ~isempty(big)
        %if ceil(big(:,3) -t0b) > 0
        %f = cumu2(ceil((big(:,3) -t0b)*365/par1));
        l = newt2.Magnitude > minmag;
        f = find( l  == 1);
        bigplo = plot(big(:,3),f,'hm');
        set(bigplo,'LineWidth',1.0,'MarkerSize',10,...
            'MarkerFaceColor','y','MarkerEdgeColor','k')
        stri4 = [];
        [le1,le2] = size(big);
        for i = 1:le1
            s = sprintf('  M=%3.1f',big(i,6));
            stri4 = [stri4 ; s];
        end   % for i

        %te1 = text(big(:,3),f,stri4);
        %set(te1,'FontWeight','normal','Color','k','FontSize',8)
        %end

        %option to plot the location of big events in the map
        %
        % figure_w_normalized_uicontrolunits(map)
        % plog = plot(big(:,1),big(:,2),'or','EraseMode','xor');
        %set(plog,'MarkerSize',ms10,'LineWidth',2.0)
        %figure_w_normalized_uicontrolunits(cum)

    end
end %if big

if exist('stri', 'var')
    %v = axis;
    %if par1>=1
    % axis([ v(1) ceil(teb) v(3) v(4)+0.05*v(4)]);
    %end
    %tea = text(v(1)+0.5,v(4)*0.9,stri) ;
    % set(tea,'FontSize',ZmapGlobal.Data.fontsz.s,'Color','k')
else
    strib = [file1];
end %% if stri

strib = [name];

title2(strib,'FontWeight','normal',...
    'FontSize',ZmapGlobal.Data.fontsz.s,...
    'Color','k')

if par1>=1
    xlabel('Time in years ','FontSize',ZmapGlobal.Data.fontsz.s)
else
    statime=newt2(1,3)-par1/365;
    xlabel(['Time in days relative to ',num2str(statime)],'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
end
ylabel('Cumulative Number ','FontSize',ZmapGlobal.Data.fontsz.s)
ht = gca;
set(gca,'Color',color_bg);

%clear strib stri4 s l f bigplo plog tea v
% Make the figure visible
%
set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,...
    'LineWidth',1.0,'TickDir','out','Ticklength',[0.02 0.02],...
    'Box','on')
figure_w_normalized_uicontrolunits(cum);
%sicum = signatur('ZMAP','',[0.65 0.98 .04]);
%set(sicum,'Color','b')
axes(ht);
set(cum,'Visible','on');
watchoff(cum)
watchoff(map)
zmap_message_center.clear_message();
%par1=par2;
done

