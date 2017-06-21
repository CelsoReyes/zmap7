% This script file is supposed to find an anomaly
% and estimet the exstend in tame and space
%
% Stefan Wiemer  11/94

report_this_filefun(mfilename('fullpath'));

[i,j] = find(pr == max(max(pr)));
X = reshape(loc(1,:),length(gy),length(gx));
Y = reshape(loc(2,:),length(gy),length(gx));

%figure_w_normalized_uicontrolunits(zmap)
%hold on
%pla = plot(X(i,j),Y(i,j),'*w')
%set(pla,'MarkerSize',12,'LineWidth',1.5,'EraseMode','xor')

l = a.Date < td | a.Date > ted;
ba = a.subset(l);
l = a.Date >= td & a.Date <= ted;
an = a.subset(l);


figure
plot(ba(:,1),ba(:,2),'rx')
hold on
plot(an(:,1),an(:,2),'bo')
axis([ s2 s1 s4 s3])
xlabel('Longitude [deg]','FontWeight','bold','FontSize',fontsz.m)
ylabel('Latitude [deg]','FontWeight','bold','FontSize',fontsz.m)
strib = [  ' Map of   '  name '; '  num2str(t0b) ' to ' num2str(teb) ];

title2(strib,'FontWeight','bold',...
    'FontSize',fontsz.m,'Color','r')
h1 = gca;
set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',fontsz.m,'Linewidth',1.2)


overlay_
matdraw



