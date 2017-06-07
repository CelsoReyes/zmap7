%
% Plots the histogramm and overlays the normal distribution on top.
% Francesco Pacchiani 3/2000
%
[m,n] = size(re3);
reall = reshape(re3,1,m*n);
l = isnan(reall);
reall(l) = [];
%re = find(reall>2.5);
%reall=reall(re);

[mo stad moci,  stadci] = normfit(reall);
reall = (reall-mo)/stad;
npdf = normpdf(reall,mo,stad)';
xno = (min(reall))-0.01:0.001:(max(reall))+0.015;
nopdf = normpdf(xno,mo,stad)';
npdfci1 = normpdf(reall, moci(1,1), stadci(1,1))';
npdfci2 = normpdf(reall, moci(2,1), stadci(2,1))';
nopdfci1= normpdf(xno, moci(1,1), stadci(1,1))';
nopdfci2= normpdf(xno, moci(2,1), stadci(2,1))';

%max(npdf)
figure;
Hnpdf = plot(reall,npdf,'ko');
hold on;
%Hnpdfci1 = plot(reall-moci(1,1), npdfci1/max(npdfci1), 'ro');
%hold on;
%Hnpdfci2 = plot(reall-moci(2,1), npdfci2/max(npdfci2), 'bo');
%hold on;
%Hnopdfci1 = plot(xno-moci(1,1), nopdfci1/max(nopdfci1), 'r-');
%hold on;
%Hnopdfci2 = plot(xno-moci(2,1), nopdfci2/max(nopdfci2), 'b-');

%axes('pos',[0.2 0.2 0.75 0.75],'Xlim',[1.4991 1.5791], 'Ylim',[0 3]); axis off; hold on;
[n,x] =histogram(reall,30);
bar(x,(n/max(n)),0.001);
hold on;
Hnopdf = plot(xno,nopdf,'k-');
%set(gca, 'Xlim',[-0.4 0.4],'fontweight','bold');
Xlabel('Standard Deviation','fontsize',12);
Ylabel('Probability Density','fontsize',12);
Title('Probalility Density Function of the Correlation Dimension','fontsize',12, 'fontweight','bold')
stra = ['Mean = ' sprintf('%.3f',mo)];
strb = ['St. Dev. =  ' sprintf('%.3f',stad)];
axes('pos',[0 0 1 1]); axis off; hold on;
tea = text(0.2, 0.8, stra ,'Fontweight','bold');
teb = text(0.2, 0.75, strb, 'Fontweight', 'bold');

clear re xno moci studci nopdfci2 nopdfci1 npdfci2 npdfci1 nopdf pdf
