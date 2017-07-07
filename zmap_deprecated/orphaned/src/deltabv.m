report_this_filefun(mfilename('fullpath'));

[file1,path1] = uigetfile([ '*.mat'],'Grid File (Referenz)');
load([path1 file1])
bvg1=bvg;

[file1,path1] = uigetfile([ '*.mat'],'Grid File');
load([path1 file1])
bvg2=bvg;



bvg = [bvg2(:,1)-bvg1(:,1) , bvg2(:,2)-bvg1(:,2) ,...
    bvg2(:,3)-bvg1(:,3) , bvg2(:,4)-bvg1(:,4) , ...
    bvg2(:,5)-bvg1(:,5) , bvg2(:,6)-bvg1(:,6) ,...
    bvg2(:,7)-bvg1(:,7) , bvg2(:,8)-bvg1(:,8) ,...
    bvg2(:,9)-bvg1(:,9) , bvg2(:,10)-bvg1(:,10) ,...
    bvg2(:,11)-bvg1(:,11) ];

normlap2=ones(length(tmpgri(:,1)),1)*nan;
normlap2(ll)= bvg(:,1);
re3=reshape(normlap2,length(yvect),length(xvect));

normlap2(ll)= bvg(:,5);
r=reshape(normlap2,length(yvect),length(xvect));

normlap2(ll)= bvg(:,6);
meg=reshape(normlap2,length(yvect),length(xvect));

normlap2(ll)= bvg(:,2);
old1=reshape(normlap2,length(yvect),length(xvect));

normlap2(ll)= bvg(:,7);
pro=reshape(normlap2,length(yvect),length(xvect));

normlap2(ll)= bvg(:,8);
avm=reshape(normlap2,length(yvect),length(xvect));

normlap2(ll)= bvg(:,9);
stanm=reshape(normlap2,length(yvect),length(xvect));

normlap2(ll)= bvg(:,10);
Prmap=reshape(normlap2,length(yvect),length(xvect));



old = re3;

% View the b-value map
view_bva_newwin
