report_this_filefun(mfilename('fullpath'));

bv2 = [];
bv3 = [] ;
me = [];
def = {'150'};
ni2 = inputdlg('Number of events in each window?','Input',1,def);
l = ni2{:};
ni = str2double(l);
BV = [];
think

for i = 1:ni/5:length(ZG.newt2)-ni
    % [bv magco,  stan] =  bvalcalc(ZG.newt2(i:i+ni,:));
    [bv magco stan ] =  bvalca2(ZG.newt2(i:i+ni,:));

    bv2 = [bv2 ; magco ZG.newt2(i+ni/2,3)];
    BV = [BV ; magco ZG.newt2(i,3) ; magco ZG.newt2(i+ni,3) ; inf inf];

end

% Find out of figure already exists
%
[existFlag,figNumber]=figure_exists('Mc with time',1);
newdepWindowFlag=~existFlag;
bdep= figNumber;

% Set up the window

if newdepWindowFlag
    Mcfig = figure_w_normalized_uicontrolunits( ...
        'Name','Mc with time',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'NextPlot','replace', ...
        'backingstore','on',...
        'Visible','on');

    matdraw
end

hold on
figure_w_normalized_uicontrolunits(Mcfig)
hold on
delete(gca)
delete(gca)
axis off

i  = min(find(ZG.newt2.Magnitude ==  max(ZG.newt2.Magnitude)));
maepi = ZG.newt2(i,:);

rect = [0.15 0.30 0.7 0.45];
axes('position',rect)
pl = plot((bv2(:,2)-ZG.maepi.Date(1))*365,bv2(:,1),'^r');
set(pl,'LineWidth',1.5,'MarkerSize',10,...
    'MarkerFaceColor','y','MarkerEdgeColor','r')
hold on
pl = plot((bv2(:,2)-ZG.maepi.Date(1))*365,bv2(:,1),'b')
set(pl,'LineWidth',1.0)
pl = plot(((BV(:,2)-ZG.maepi.Date(1))*365),BV(:,1),'color',[0.5 0.5 0.5]);

%grid
set(gca,'Color',color_bg)
set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
%
ylabel('Mc')
%set(gca,'Xlim',[t0b teb]);

xlabel('Time in days after mainshock')
tist = [  name ' - b(t), ni = ' num2str(ni) ];
title(tist)




nt = [];
con = 0;

ms = round(bv2(:,1)*10)/10;
for  m = max(bv2(:,1)):-0.1:min(bv2(:,1))

    % find comp level and times.
    i = max(find(abs(m-ms) < 0.01));
    if isempty(i) == 0
        con = con+1;
        nt = [nt ; m bv2(i,2)];

        if con > 1 &  nt(con,2) < nt(con-1,2) ; nt(con,:) = []; con = con-1; end
    end
end

nt(1,2) = min(ZG.newt2.Date)
i = max(find((ms-min(ms) > 0.01)));
% nt(con,2) = bv2(i+1,2);


done
