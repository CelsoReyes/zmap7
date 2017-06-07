function calc_misdMcorr(mCatalog_, sFilecorr)

m=mCatalog_(:,6);
% transform catalog years to days
mCatalog_(:,3)=mCatalog_(:,3).*365;
t=mCatalog_(:,3);

mc=m*0;

I=find(m>=7);
for n=1:length(I)
i=I(n);
dt=t-t(i);
J=find(dt>0 & dt<0.26);
mc(J)=max([mc(J)' ; -0.25*log(dt(J)/0.26)']);
end

I=find(m>=6 & m<7);
for n=1:length(I)
i=I(n);
dt=t-t(i);
J=find(dt>0 & dt<0.19);
mc(J)=max([mc(J)' ; -0.20*log(dt(J)/0.19)']);
end

fid=fopen(sFilecorr,'w');
for n=1:length(m)
fprintf(fid,'%f\n',10^(1.05*mc(n)));
end
fclose(fid);
