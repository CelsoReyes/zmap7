report_this_filefun(mfilename('fullpath'));

BV = [];
BV3 = [];
mag = [];
me = [];
av2=[];

Nmin = 50;
keepcat = newt2;
def = {'15'};
ni2 = inputdlg('Depth extend?','Input',1,def);
l = ni2{:};
intdep = str2double(l);
think
[s,is] = sort(newt2.Depth);
newt1 = newt2(is(:,1),:) ;
watchon;

for dep = 0:intdep/4:500

    % calculate b-value based an weighted LS
    l = newt1(:,7) > dep  & newt1(:,7) <= dep + intdep*4;
    b = newt1(l,:);
    newt2 = b;
    length(b(:,1))
    if length(b(:,1)) > 30;

        clear Mc95 Mc90
        mcperc_ca3;
        if isnan(Mc95) == 0 
            magco = Mc95;
            Mc95
        elseif isnan(Mc90) == 0 
            magco = Mc90;
            Mc90
        else
            [bv magco stan av me mer me2,  pr] =  bvalca3(b,1,1);
        end

    else

        magco = nan;
    end

    %l = b(:,6) >= magco-0.05;
    %if length(b(l,:)) >= Nmin
    %[bv magco0 stan av me mer me2,  pr] =  bvalca3(b(l,:),2,2);
    %  [mea bv stan,  av] =  bmemag(b(l,:));
    %else
    %   bv = nan; bv2 = nan, magco = nan; av = nan; av2 = nan;
    %end
    %[bv magco stan av me mer me2,  pr] =  bvalca3(b,1,1);

    BV = [BV ; magco dep ; magco dep+intdep  ; inf inf];
    BV3 = [BV3 ; magco dep  ];
    %mag = [mag ; av newt1(t+round(ni/2),7)];

    % calculate b-value based on maximum likelihood
    %av2 = [av2 ;   av  newt1(t+round(ni/2),7) stan bv];

end


watchoff

% Find out of figure already exists
%
[existFlag,figNumber]=figure_exists('Mc-value with depth',1);
newdepWindowFlag=~existFlag;
bdep= figNumber;

% Set up the Cumulative Number window

if newdepWindowFlag
    bdep = figure_w_normalized_uicontrolunits( ...
        'Name','Mc-value with depth',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','add', ...
        'backingstore','on',...
        'Visible','on', ...
        'Position',[ 150 150 winx-50 winy-20]);

    
    uicontrol('Units','normal',...
        'Position',[.0 .85 .08 .06],'String','Info ',...
         'Callback','infoz(1)');

    matdraw
end

figure_w_normalized_uicontrolunits(bdep)
delete(gca)
delete(gca)
delete(gca)
delete(gca)
hold off

axis off
hold on
orient tall
%rect = [0.15 0.65 0.7 0.25];
rect = [0.25 0.15 0.5 0.75];
axes('position',rect)
ple = plot(BV3(:,2),BV3(:,1),'k')
%set(ple(1),'color',[0.5 0.5 0.5]);

hold on
pl = plot(BV(:,2),BV(:,1),'color',[0.5 0.5 0.5]);

pl = plot(BV3(:,2),BV3(:,1),'sk')

set(pl,'LineWidth',1.0,'MarkerSize',4,...
    'MarkerFaceColor','w','MarkerEdgeColor','k','Marker','s');

set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'normal','FontSize',fontsz.m,'Linewidth',1.,'Ticklength',[ 0.02 0.02])

bax = gca;
strib = [name ', di [km] = ' num2str(intdep), ', Mmin = ' num2str(min(newt2.Magnitude)) ];
ylabel('Mc')
xlabel('Depth [km]')
title2(strib,'FontWeight','bold',...
    'FontSize',fontsz.m,...
    'Color','k')

xl = get(gca,'Xlim');
view([90 90])
newt2 = keepcat;
clear keepcat
