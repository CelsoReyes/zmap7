function [dist1, dist2] = funDistance(i,bgevent,ac,mycat,err,derr)
% distance.m                                          A.Allmann
% calculates the distance in [km] between two eqs
% precise version based on Raesenbergs Program
% the calculation is done simultaniously for the biggest event in the
% cluster and for the current event

pi2 = 1.570796;
rad = 1.745329e-2;
flat= 0.993231;

alatr1=mycat.Latitude(i)*rad;     %conversion from degrees to rad
alonr1=mycat.Longitude(i)*rad;
alatr2=mycat.Latitude(bgevent)*rad;
alonr2=mycat.Longitude(bgevent)*rad;
blonr=mycat.Longitude(ac)*rad;
blatr=mycat.Latitude(ac)*rad;

tana(1)=flat*tan(alatr1);
tana(2)=flat*tan(alatr2);
geoa=atan(tana);
acol=pi2-geoa;
tanb=flat*tan(blatr);
geob=atan(tanb);
bcol=pi2-geob;
diflon(:,1)=blonr-alonr1;
diflon(:,2)=blonr-alonr2;
cosdel(:,1)=(sin(acol(1))*sin(bcol)).*cos(diflon(:,1))+(cos(acol(1))*cos(bcol));
cosdel(:,2)=(sin(acol(2))*sin(bcol)).*cos(diflon(:,2))+(cos(acol(2))*cos(bcol));
delr=acos(cosdel);
top=sin(diflon)';
den(1,:)=sin(acol(1))/tan(bcol)-(cos(acol(1))*cos(diflon(:,1)))';
den(2,:)=sin(acol(2))/tan(bcol)-(cos(acol(2))*cos(diflon(:,2)))';
azr=atan2(top,den);                   %azimuth to North
colat(:,1)=pi2-(alatr1+blatr)/2;
colat(:,2)=pi2-(alatr2+blatr)/2;
radius=6371.227*(1+(3.37853e-3)*(1/3-((cos(colat)).^2)));
r=delr.*radius;            %epicenter distance
r=r-1.5*err;               %influence of epicenter error
tmp1=find(r<0);
if ~isempty(tmp1)
  r(tmp1)=zeros(length(tmp1),1);
end
z(:,1)=abs(mycat.Depth(ac)-mycat.Depth(i));    %depth distance
z(:,2)=abs(mycat.Depth(ac)-mycat.Depth(bgevent));
z=z-derr;
tmp2=find(z<0);
if ~isempty(tmp2)
 z(tmp2)=zeros(length(tmp2),1);
end
r=sqrt(z.^2+r.^2);                   %hypocenter distance
%alpha=atan2(z,r);
%ca =cos(alpha);
%sa =sin(alpha);
dist1=r(:,1);           %distance between eqs
dist2=r(:,2);


