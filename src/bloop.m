report_this_filefun(mfilename('fullpath'));

re = []
for i = min(newt2.Magnitude):0.1:max(newt2.Magnitude)-0.5
    i
    l = newt2.Magnitude >= i;
    [bv magco stan av me,  mer] =  bvalcalc(newt2(l,:));
    re = [re ; i bv me];
end

figure
pl = plot(re(:,1),re(:,3),'b')
set(pl,'LineWidth',2.5)
hold on
pl = plot(re(:,1),re(:,2),':r')
set(pl,'LineWidth',2.5)
set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)


le =legend('-b','b(L2)','ro','b(maxli)');
grid
xlabel('Magnitude')
ylabel('b-value')

