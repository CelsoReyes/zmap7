
maxmag = ceil(10*max(newt2.Magnitude))/10;
mima = min(newt2.Magnitude);
if mima > 0 ; mima = 0 ; end

[bval,xt2] = hist(newt2.Magnitude,(mima:0.1:maxmag));
% normalise to annula rates
bval = bval/(max(newt2.Date)-min(newt2.Date));
bvalsum = cumsum(bval); % N for M <=
bval2 = bval(length(bval):-1:1);
bvalsum3 = cumsum(bval(length(bval):-1:1));    % N for M >= (counted backwards)
xt3 = (maxmag:-0.1:mima);

backg_ab = log10(bvalsum3);

figure_w_normalized_uicontrolunits(bfig);delete(gca);delete(gca); delete(gca); delete(gca)
rect = [0.22,  0.3, 0.65, 0.6];           % plot Freq-Mag curves
axes('position',rect);

%%
% plot the cum. sum in each bin  %%
%%

%pl =semilogy(xt3,bvalsum3,'sb');
%set(pl,'LineWidth',1.0,'MarkerSize',6,...
%    'MarkerFaceColor','w','MarkerEdgeColor','k');
%hold on
pl1 =semilogy(xt3,bval2,'^b');
set(pl1,'LineWidth',1.0,'MarkerSize',4,...
    'MarkerFaceColor',[0.7 0.7 .7],'MarkerEdgeColor','k');


bv2 = [];bv3 = [] ; me = [];BV = [];
ni2 = 50;

for i = 1:ni2/1:length(newt2)-ni2
    [bv magco stan ] =  bvalca2(newt2(i:i+ni2,:));
    l = newt2(i:i+ni2,:) >= magco;
    nn2 = newt2(i:i+ni2,l);

    [bval,xt2] = hist(nn2(:,6),(mima:0.1:maxmag));
    % normalise to annula rates
    bval = bval/(max(nn2(:,3))-min(nn2(:,3)));
    bvalsum = cumsum(bval); % N for M <=
    bval2 = bval(length(bval):-1:1);
    bvalsum3 = cumsum(bval(length(bval):-1:1));    % N for M >= (counted backwards)

    hold on
    pl1 =semilogy(xt3,bval2,'^b');
    set(pl1,'LineWidth',1.0,'MarkerSize',4,...
        'MarkerFaceColor',[0.7 0.7 .7],'MarkerEdgeColor','k');
    pause

end

bv2 = [bv2 ; magco newt2(i+ni2/2,3)];
BV = [BV ; magco newt2(i,3) ; magco newt2(i+ni2,3) ; inf inf];
