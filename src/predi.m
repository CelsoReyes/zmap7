
report_this_filefun(mfilename('fullpath'));

def = {'4'};
ni2 = inputdlg('Test prediction of the last X years. X = ?? years','Input',1,def);
l = ni2{:};
pt = str2double(l);

newt0 = newt2;


lt =  newt2.Date >= t0b &  newt2.Date <teb-pt ;

obs = newt2(lt,:);
ho = 'noho';
bdiff(newt2(lt,:));
ho = 'hold';
lt =  newt2.Date >= teb-pt &  newt2.Date <= teb ;
bdiff(newt2(lt,:));

pre = newt2(lt,:);


newt2 = obs;
mcperc_ca3;
if isnan(Mc95) == 0 
    magco = Mc95;
elseif isnan(Mc90) == 0 
    magco = Mc90;
else
    [bv magco stan av me mer me2,  pr] =  bvalca3(newt2,1,1);
end
magco = magco+0.
l = obs(:,6) >= magco-0.05;

[bv magco0 stan av me mer me2,  pr] =  bvalca3(obs(l,:),2,2);
[av2 bv2 stan2 ] =  bmemag(obs(l,:));

av2 = log10(length(obs(l,1))) + bv2*magco;

af = log10(length(obs(l,1))) + 0.85*magco;

tdpre = max(obs(:,3)) - min(obs(:,3));
tr2 = [];

for m = magco:0.1:7
    N = 10^(av2-bv2*m)/tdpre*pt;
    N2 = 10^(af-0.85*m)/tdpre*pt;   % this is with a fixed b =
    tr = (teb-t0b-pt)/(10^(av-bv*m));
    tr2 = [tr2 ; N  m N2];
end

pr = -diff(tr2(:,:),1);
pr = [  NaN NaN NaN ; pr];

% this i sthge observed
l = pre(:,6) > magco;
[px,x] = hist(pre(l,6),magco-0.05:0.1:7);

[existFlag,figNumber]=figure_exists('Probability Test',1);
newMapWindowFlag=~existFlag;

% Set up the Seismicity Map window Enviroment
%
if newMapWindowFlag
    figure_w_normalized_uicontrolunits( ...
        'Name','Probability Test',...
        'NumberTitle','off', ...
        'backingstore','on',...
        'NextPlot','add', ...
        'Visible','on', ...
        'Position',[ 200 900 600 800 ]);
else
    figure_w_normalized_uicontrolunits(figNumber)
    clf
end


axes('pos',[0.15 0.55 0.7 0.4])

pl =  semilogy(tr2(:,2),pr(:,1));
set(pl,'LineWidth',2.0)
hold on
pl2 =  semilogy(tr2(:,2),pr(:,3),'g');
set(pl2,'LineWidth',2.0)

pl3 =  semilogy(x,px,'or');
set(pl3,'LineWidth',2.0)

legend([pl pl3 pl2],'predicted (var. b)','observed','predicted (b = const.)');
set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',fontsz.m,'Linewidth',1.2)
ylabel(' Number ')
set(gca,'XTicklabel',[])

newt2 = newt0;

matdraw



axes('pos',[0.15 0.1 0.7 0.4])
hold on
P = poisspdf(px',pr(:,1));

Pk = poisspdf(px',pr(:,3));

lP = log(P);
l = isinf(lP);
lP(l) = 0;

lPk = log(Pk);
l = isinf(lPk);
lPk(l) = 0;

pl1 = plot(x,cumsum((lP)),'b')
set(pl1,'LineWidth',2.0)
hold on

pl2 = plot(x,cumsum((lPk)),'g')
set(pl2,'LineWidth',2.0)
legend([pl1  pl2],'predicted (var. b)','predicted (b = const.)','location','SouthWest');

set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',fontsz.m,'Linewidth',1.2)
xlabel('Magnitude')
ylabel('Ln(P)')


disp(['Log likelihood sum: local Tl model: ' num2str(sum(lP)) ' Kagan & Jackson model: ' num2str(sum(lPk)) ])
str2 = ['Log likelihood sum: local Tl model: ' num2str(sum(lP)) ];
str3 = ['Kagan & Jackson model: ' num2str(sum(lPk))  ];

axes('pos',[0 0 1 0.5 ])
axis off
text(0.4,0.9,['Log likelihood sum:'] )
text(0.4,0.85,str2)
text(0.4,0.8,str3)

