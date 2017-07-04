report_this_filefun(mfilename('fullpath'));

BV = [];
BV3 = [];
mag = [];
me = [];
av2=[];
Nmin = 50;

bv2 = [];
bv3 = [] ;
me = [];
def = {'150','5'};
tit ='b with depth input parameters';
prompt={ 'Number of events in each window',...
    'Overlap factor',...
    };


ni2 = inputdlg(prompt,tit,1,def);
l = ni2{1};
ni = str2double(l);
l = ni2{2};
ofac = str2double(l);

ButtonName=questdlg('Mc determination?', ...
    ' Question', ...
    'Automatic','Fixed Mc=Mmin','Money');

think

for i = 1:ni/ofac:length(newt2)-ni

    b = newt2(i:i+ni,:);

    switch ButtonName
        case 'Automatic'
            mcperc_ca3;
            if isnan(Mc95) == 0 
                magco = Mc95;
            elseif isnan(Mc90) == 0 
                magco = Mc90;
            else
                [bv magco stan av me mer me2,  pr] =  bvalca3(b,1,1);
            end
        case 'Fixed Mc=Mmin'
            magco = min(b(:,6))
    end

    l = b(:,6) >= magco-0.05;
    if length(b(l,:)) >= Nmin
        [mea bv stan,  av] =  bmemag(b(l,:));
    else
        bv = nan; bv2 = nan, magco = nan; av = nan; av2 = nan;
    end
    BV = [BV ; bv min(b(:,3)) ; bv max(b(:,3)) ; inf inf];
    BV3 = [BV3 ; bv mean(b(:,3)) stan ];

end

% Find out of figure already exists
%
[existFlag,figNumber]=figure_exists('b-value with time',1);
newdepWindowFlag=~existFlag;
bdep= figNumber;

% Set up the window

if newdepWindowFlag
    bdep = figure_w_normalized_uicontrolunits( ...
        'Name','b-value with time',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','replace', ...
        'backingstore','on',...
        'Visible','on');

    
    matdraw
end

hold on
figure_w_normalized_uicontrolunits(bdep)
hold on
delete(gca)
delete(gca)
axis off

rect = [0.15 0.20 0.7 0.65];
axes('position',rect)
ple = errorbar(BV3(:,2),BV3(:,1),BV3(:,3),BV3(:,3),'k')
set(ple(1),'color',[0.5 0.5 0.5]);

hold on
pl = plot(BV(:,2),BV(:,1),'color',[0.5 0.5 0.5]);

pl = plot(BV3(:,2),BV3(:,1),'sk')

set(pl,'LineWidth',1.0,'MarkerSize',4,...
    'MarkerFaceColor','w','MarkerEdgeColor','k','Marker','s');

set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.,'Ticklength',[ 0.02 0.02])

bax = gca;
strib = [name ', ni = ' num2str(ni), ', Mmin = ' num2str(min(newt2.Magnitude)) ];
ylabel('b-value')
xlabel('Time [years]')
title2(strib,'FontWeight','bold',...
    'FontSize',ZmapGlobal.Data.fontsz.m,...
    'Color','k')

xl = get(gca,'Xlim');
