% brand draws x random samples of size N from the current dataset and computes the b-value
% sw, last modifies 9/2001

report_this_filefun(mfilename('fullpath'));

ar2 = [];
arm2 = [];
br2 = [];
brm2 = [];

def = {'50','10','200','100'};
tit ='Random b-value calculation';
prompt={'Minimum number of events per sample ?', 'Step width in events ? ',...
    'Maximum number of events per sample?','Number of samples drawn ?'};

ni2 = inputdlg(prompt,tit,1,def);
l = ni2{4};
nr = str2double(l);
l = ni2{3};
n2 = str2double(l);
l = ni2{2};
ns = str2double(l);
l = ni2{1};
n1 = str2double(l);

%n1 = str2double(prmptdlg('Minimum number of events per sample','50'));
%ns = str2double(prmptdlg('Step width in events','10'));
%n2 = str2double(prmptdlg('Maximum number of events per sample','200'));
%nr = str2double(prmptdlg('Numer of samples drawn ','100'));
tic
niv = n1:ns:n2;
for ni = n1:ns:n2
    ni
    ar = [];
    arm = [];
    br = [];
    brm = [];
    for i = 1:nr
        l = ceil(rand([ni 1])*a.Count);
        %[bv magco stan,  av] =  bvalca3(newa(l,:),2,2);
        %br = [br bv];
        %ar = [ar av];
        [me1 bv2 stan av2 ] =  bmemag(a(l,:));
        brm = [brm bv2];
        arm = [arm av2];
    end
    %br2 = [br2 ; br];
    brm2 = [brm2 ; brm];
    %ar2 = [ar2 ; ar];
    arm2 = [arm2 ; arm];
end

figure
pl1 =plot(niv,prctile2(brm2',50),'k')
set(pl1,'LineWidth',2.0)
hold on
pl2=plot(niv,prctile2(brm2',95),'r--');;
set(pl2,'LineWidth',1.0,'color',[0.3 0.3 0.3])
pl3=plot(niv,prctile2(brm2',5),'r-.');
set(pl3,'LineWidth',1.0,'color',[0.3 0.3 0.3])

legend([pl1 pl2 pl3],'mean','95%','5%');

set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',fontsz.m,'Linewidth',1.2)
xlabel('Number of eqs')
ylabel('Range of b-value')
matdraw



figure

pl1=plot(niv,prctile2(arm2',50),'k');
set(pl1,'LineWidth',2.0)
hold on
pl2=plot(niv,prctile2(arm2',95),'r--');
set(pl2,'LineWidth',1.0,'color',[0.3 0.3 0.3])
pl3=plot(niv,prctile2(arm2',5),'r-.');
set(pl3,'LineWidth',1.0,'color',[0.3 0.3 0.3])
legend([pl1 pl2 pl3],'mean','95%','5%');


set(gca,'box','on',...
    'SortMethod','childorder','TickDir','out','FontWeight',...
    'bold','FontSize',fontsz.m,'Linewidth',1.2)
xlabel('Number of eqs')
ylabel('Range ofa-value')
grid
matdraw

toc
%
return

% experimental code ...

A = [];
for i = 1:1:99
    i
    A = [A ; niv' prctile2(brm2',i)' niv'*0+i];
end
% l = A(:,3)>50; A(l,3) = 100 - A(l,3);
[ X, Y ] = meshgrid(n1:ns:n2,0.5:0.01:1.5);

Z = griddata(A(:,1),A(:,2),A(:,3),X,Y);

figure
contourf(X,Y,Z,[1 5 10 50 90 95 99]);

g = gray(6);
g = g(11:-1:2,:);
colormap(g);





