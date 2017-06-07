report_this_filefun(mfilename('fullpath'));

def = {'0','1','100','10000'};
tit ='Random Zmax calculation - Normal distribution';
prompt={'Mean of the population?', 'Standard deviation of the population',...
    'Number of samples in each set ?','Number of repeats ?'};

ni2 = inputdlg(prompt,tit,1,def);
l = ni2{4};
nr2 = str2double(l);
l = ni2{3};
na2 = str2double(l);
l = ni2{2};
si2 = str2double(l);
l = ni2{1};
me = str2double(l);

%me = str2double(prmptdlg('Mean of the population?','0'));
%si2 = str2double(prmptdlg('Standard deviation of the population','1'));
%na2 = str2double(prmptdlg('Number of samples in each set?','100000'));
%nr2 = str2double(prmptdlg('Number of repeats','100'));


ma = [];
wai = waitbar(0,' Please Wait ...  ');
set(wai,'NumberTitle','off','Name','Makegrid  -Percent done');;

for i = 1:nr2;
    if rem(i,10) == 0; waitbar(i/nr2); end
    n = normrnd(me,si2,na2,1);
    ma = [ma ; max(n)];
end
close(wai)

figure
histogram(ma)
set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',fontsz.m,'Linewidth',1.2)
grid
xlabel('Zmax')
ylabel('Number ')
title(['std=' num2str(si2) ', #samples = ' num2str(na2) ', #repeats=' num2str(nr2) ', mean= ' num2str(me)]) ;


matdraw

