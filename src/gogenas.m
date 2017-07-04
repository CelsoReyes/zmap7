% Matlab script to call algorithm GENAS in function genas
% Operates on     newcat
%                            R. Zuniga, 4/94

report_this_filefun(mfilename('fullpath'));

clear global ztimes
clear global ztime1
clear global ztime2
clear ZBEL
clear ZABO
%    maxmg = floor(max(newcat.Magnitude));
xsum = newcat.Count;
t0b = newcat(1,3)
teb = newcat(xsum,3)
incx = par1/365;
xt = t0b:incx:teb;
bin0 = 1;
bin1 = length(xt)
nmag = minmg:magstep:maxmg;
ztime1 = 1:bin1;
time2 = 1:bin1;
cumu1 = 1:bin1;
cumu2 = 1:bin1;
welcome
think

figure;
genfig = gcf;
set(genfig,'NumberTitle','off','Name','GENAS-1');

set(gca,'visible','off')
txt1 = text(...
    'Color',[0 0 0 ],...
    'EraseMode','normal',...
    'Position',[0.1 0.50 0 ],...
    'Rotation',0 ,...
    'FontSize',16 );
set(txt1,'String', '')
set(txt1,'String',  ' Please Wait...' );
%wai = waitbar(0,'Please wait...');
%set(wai,'Color',[0.8 0.8 0.8],'NumberTitle','off','Name','Percent-Done');
%pause(1.1);
set(gcf,'Pointer','watch');
pause(0.1)
ztime1 =0;
ztime2 =0;

%
for i = minmg:magstep:maxmg,         % steps in magnitude
    clear global ztimes                %clears ztimes from previous results
    cumu1 = cumu1*0;
    cumu2 = cumu2*0;
    ztime1 = ztime1*0;
    ztime2 = ztime2*0;

    %uicontrol('Units','normal','Position',[.90 .10 .10 %.10],'String','Wait... ')

    l =   newcat.Magnitude < i;            % Mags and below
    junk = newcat.subset(l);
    if ~isempty(junk), [cumu1, xt] = hist(junk(:,3),xt); end

    ztime1 = genas(cumu1,xt,bin1,bin0,bin1);    % call GenAS algorithm
    if i == minmg
        ZBEL = ztime1';
    else
        ZBEL = [ZBEL,  ztime1' ];
    end      % if i

    clear global ztimes               %clears ztimes from previous results

    l =   newcat.Magnitude > i;           % Mags and above
    junk = newcat.subset(l);
    if ~isempty(junk), [cumu2, xt] = hist(junk(:,3),xt); end

    ztime2 = genas(cumu2,xt,bin1,bin0,bin1);   % call GenAS algorithm
    if i == minmg
        ZABO = ztime2';
    else
        ZABO = [ZABO,  ztime2' ];
    end  %if i

    S = sprintf('                            magnitude %3.1f done!', i);
    disp(S);
    cumbelow=cumsum(cumu1);
    cumabove=cumsum(cumu2);

    plot(xt,cumbelow,'r');
    plot(xt,cumabove,'b-.');
    xlabel('time (yrs)','FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.m);
    ylabel('cum number of events','FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.m);
    set(gca,'FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2);
    set(gca,'Color',color_bg)
    set(gcf,'Color',color_fbg)
    t1 = xsum-xsum*0.1;
    t1p = [  xt(10)  t1; xt(30)   t1];
    %plot(t1p(:,1),t1p(:,2),'r');
    tt1 = text(0.1,0.8,' mag and below: ___','Units','normalized');
    set(tt1,'FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.m,'Color','r')
    t1 = xsum-xsum*0.2;
    t1p = [  xt(10)  t1; xt(30)   t1];
    %plot(t1p(:,1),t1p(:,2),'b-.');
    tt1 =text(0.1, 0.9,' mag and above: ._.','Units','normalized');
    set(tt1,'FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.m,'Color','b')
    %figure_w_normalized_uicontrolunits(wai);
    %waitbar(i/maxmg)
    %percent = i/maxmg * 100	;
    %  set(txt1,'String', '')
    %  set(txt1,'String', [num2str(percent) ' Percent Done'] )
    % pause(0.1)
    drawnow;
end        % for i
set(gcf,'Pointer','arrow');
S = sprintf('                 FINISHED!', i);
disp(S);
%close(wai);
stri = [  ' GenAS - ' file1];
title2(stri,'FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.m)

set(gca,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','normal',...
    'Ticklength',[0.02 0.02],'LineWidth',1.0,...
    'Box','on','SortMethod','childorder','TickDir','out')

%hpop1 = uicontrol('Style','Popup',,'Units','normal',...
%'Position',[.88 .94 .11 .06],'String','Print|Printer|Postscript ',...
% 'Callback','prtm(hpop1)');


figure;
set(gcf,'pos',[100 100 550 400 ],'NumberTitle','off','Name','GENAS-2','MenuBar','none');

nummag = length(nmag);                  %  5 magnitude tick marks and labels
tickinc = nummag/4;
xtick = 0:tickinc:nummag;
xtick(1) = 1;
for i = 1:5
    i
    xtlabls(i,:) = sprintf('%3.1f',nmag(floor(xtick(i))));
end


tickinc = bin1/9;                   %  10 tick marks for time axis
ytick = 0:tickinc:bin1;
ytick(1) = 1;
ytlabls(1,:) = sprintf('%3.2f',xt(1));
for i = 2:10
    ytlabls(i,:) = sprintf('%3.2f',xt(floor(ytick(i))));
end


%subplot(1,2,1),contour(xt,nmag,ZBEL)
ma1 = max(max([ ZBEL ZABO]));
mi1 = min(min([ ZBEL ZABO]));

rect = [0.15 0.15 0.3 0.7];
axes('pos',[rect]);
set(gca,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','normal');
pcolor(ZBEL);
colormap(jet)
shading flat
caxis([-7 7 ])
xlabel('Mag and below','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','normal');
ylabel('Time (yrs)','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','normal');
set(gca,'Xtick',xtick,'Xticklabels',xtlabls,'Ytick',ytick,...
    'Yticklabels',ytlabls);

set(gca,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','normal',...
    'Ticklength',[0.02 0.02],'LineWidth',1.0,...
    'Box','on','SortMethod','childorder','TickDir','out')

stri = [  ' GenAS - ' file1];
title2(stri,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','normal')
set(gca,'Ytick',ytick,'Yticklabels',ytlabls)
p1 = gca;
rect = [0.50 0.15 0.35 0.7];
axes('pos',rect);
set(gca,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','normal');
pcolor(ZABO);
j = jet;
j = [j(1:25,:) ; 0.9 .9 0.9 ; 0.9 0.9 0.9 ; j(40:64,:) ];
colormap(j)
shading flat
caxis([-7 7])
co = colorbar;
set(co,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','normal','TickDir','out','Ticklength',0.015)
cop = get(co,'pos');
set(co,'pos',[cop(1) cop(2) cop(3)/2 cop(4)/3 ]);
xlabel('Mag and above','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','normal');
set(gca,'Xtick',xtick,'Xticklabels',xtlabls,'Ytick',ytick,...
    'Yticklabels',ytlabls);
set(gca,'Ytick',[],'Yticklabels',ytlabls);

set(gca,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','normal',...
    'Ticklength',[0.02 0.02],'LineWidth',1.0,...
    'Box','on','SortMethod','childorder','TickDir','out')


p2 = gca;
hold on;
clear ytlabls ytick xtlabls xt tickinc;

save_button=uicontrol('Style','Pushbutton',...
    'Position',[.88 .01 .11 .06 ],...
    'Units','normalized',...
    'Callback','savgenas',...
    'String','SaveOut');
%messg = 'Postscript File genas.ps saved on disk';

set(gcf,'color','w');
matdraw
op3 = uimenu('Label','  B&W-Display');
uimenu(op3,'Label','Invers gray',...
    'Callback','g=gray(10);g=g(10:-1:1,:);colormap(g);colorbar;brighten(0.4);');
uimenu(op3,'Label','Plus/minus display ',...
    'Callback','genbw');
uimenu(op3,'Label','Get coordinates with cursor',...
     'Callback','gi = ginput(1); disp([''Time: '' num2str(t0b +gi(2)*par1/365,6) ]); ')

done
