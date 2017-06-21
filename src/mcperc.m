report_this_filefun(mfilename('fullpath'));

% This is a comleteness determinationm test


[bv magco0 stan av ] =  bvalca3(newt2,inb1,inb2);


dat = [];

for i = magco0 - 0.9:0.1:magco0+1.5
    i
    l = newt2.Magnitude >= i - 0.0499; nu = length(newt2(l,6));
    %[bv magco stan,  av] =  bvalca3(newt2(l,:),2,2);
    [mw bv2 stan2,  av] =  bmemag(newt2(l,:));
    synthb_aut
    res0 = res;
    % bv = bv + stan ; synthb_aut; res1 = res;
    % bv = bv - 2*stan ; synthb_aut; res2 = res;

    nc = 10.^(av - bv2*(i+0.05)) ;
    nc1 = 10.^(av - (bv2-stan/2)*(i+0.05)) ;
    nc2 = 10.^(av - (bv2+stan/2)*(i+0.05)) ;

    dat = [dat ; i nc nu nu/nc nu/nc1 nu/nc2 res0  ];
    %disp(['Completeness Mc: ' num2str(i) ';  rati = ' num2str(nu/nc)]);

end

fi = findobj('tag','mcfig');
if isempty(fi) == 1
    figure_w_normalized_uicontrolunits('pos',[300 300 600 300],...
        'tag','mcfig');
else
    figure_w_normalized_uicontrolunits(fi); delete(gca);delete(gca);
end

j =  min(find(dat(:,7) < 10 ));
if isempty(j) == 1; Mc90 = nan
else;
    Mc90 = dat(j,1);
end

j =  min(find(dat(:,7) < 5 ));
if isempty(j) == 1; Mc95 = nan
else;
    Mc95 = dat(j,1);
end

disp(['Completeness Mc at 90% confidence: ' num2str(Mc90) ]);
disp(['Completeness Mc at 95% confidence: ' num2str(Mc95) ]);


axes('pos',[0.15 0.2 0.7 0.65])
plot(dat(:,1),dat(:,7),'k','LineWidth',1.)
hold on
pl = plot(dat(:,1),dat(:,7),'b^')
set(pl,'LineWidth',1.0,'MarkerSize',8,...
    'MarkerFaceColor','y','MarkerEdgeColor','b');

%errorbar(dat(:,1),dat(:,7),abs(dat(:,7) - dat(:,8)),abs(dat(:,7) - dat(:,9)))
grid

set(gca,'visible','on','FontSize',fontsz.m,'FontWeight','bold',...
    'TickDir','out','LineWidth',1.0,...
    'Box','on')
xlabel('Magnitude')
ylabel('Residual in %')
title('Goodness of FMD fit to power law');
te = text(0.6,0.8,['Mc at 90% confidence: ' num2str(Mc90) ],...
    'Units','normalized','FontWeight','bold');
te = text(0.6,0.9,['Mc at 95% confidence: ' num2str(Mc95) ],...
    'Units','normalized','FontWeight','bold');




