function [ang] = focal_angle(wax,way,waz,wbx,wby,wbz)

%% c     compute the angle (in degrees) between two vectors
%% c
%% c     usage:
%% c     call angle(wax,way,waz,wbx,wby,wbz,ang)
%% c
%% c     arguments:
%% c     wax,way,waz    Cartesian component of first vector (INPUT)
%% c     wbx,wby,wbz    Cartesian component of second vector (INPUT)
%% c     ang            angle between the two vectors in degrees (OUTPUT)
%% c
%      call fpsset
         amistr=-360.;
         amastr=360.;
         amidip=0.;
         amadip=90.;
         amirak=-360.;
         amarak=360.;
         amitre=-360.;
         amatre=360.;
         amiplu=0.;
         amaplu=90.;
         orttol=2.;
         ovrtol=0.001;
         tentol=0.0001;
         dtor=0.017453292519943296;
         c360=360.;
         c90=90.;
         c0=0.;
         c1=1.;
         c2=2.;
         c3=3.;
%%c
      [anorm,ax,ay,az] = focal_norm(wax,way,waz);
      [bnorm,bx,by,bz] = focal_norm(wbx,wby,wbz);
      prod = (ax*bx) + (ay*by) + (az*bz);
      ang = acos(max(-c1,min(c1,prod)))/dtor;

