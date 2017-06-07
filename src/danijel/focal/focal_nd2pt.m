function [px,py,pz,tx,ty,tz,bx,by,bz,ierr] = nd2pt(wanx,wany,wanz,wdx,wdy,wdz)

%% c     compute Cartesian component of P, T and B axes from outward normal
%% c     and slip vectors
%% c
%% c     usage:
%% c     call nd2pt(anx,any,anz,dx,dy,dz,px,py,pz,tx,ty,tz,bx,by,bz,ierr)
%% c
%% c     arguments:
%% c     anx,any,anz    components of fault plane outward normal vector in the
%% c                    Aki-Richards Cartesian coordinate system (INPUT)
%% c     dx,dy,dz       components of slip vector in the Aki-Richards
%% c                    Cartesian coordinate system (INPUT)
%% c     px,py,pz       components of downward P (maximum dilatation) axis versor
%% c                    in the Aki-Richards Cartesian coordinate system (OUTPUT)
%% c     tx,ty,tz       components of downward T (maximum tension) axis versor
%% c                    in the Aki-Richards Cartesian coordinate system (OUTPUT)
%% c     bx,by,bz       components of downward B (neutral) axis versor in the
%% c                    Aki-Richards Cartesian coordinate system (OUTPUT)
%% c     ierr           error indicator (OUTPUT)
%% c
%% c     errors:
%% c     1              input vectors not perpendicular among each other

%% c
%% c      implicit none
%% c-------------------------------------------------------------------------------
%%       integer io
%%       real amistr,amastr,amidip,amadip,amirak,amarak,amitre,amatre
%%      1,amiplu,amaplu,orttol,ovrtol,tentol,dtor,c360,c90,c0,c1,c2,c3
%%       common /fpscom/amistr,amastr,amidip,amadip,amirak,amarak,amitre
%%      1,amatre,amiplu,amaplu,orttol,ovrtol,tentol,dtor,c360,c90,c0,c1,c2
%%      2,c3,io
%% c-------------------------------------------------------------------------------
%%       real wanx,wany,wanz,amn,anx,any,anz,wdx,wdy,wdz,amd,dx,dy,dz
%%      1,ang,px,py,pz,tx,ty,tz,bx,by,bz,amp
%%       integer ierr
%% c



%%       call fpsset
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
         io=6;

      ierr=0;
      [amn,anx,any,anz] = focal_norm(wanx,wany,wanz);
      [amd,dx,dy,dz] = focal_norm(wdx,wdy,wdz);
      [ang] = focal_angle(anx,any,anz,dx,dy,dz);
      if (abs(ang-c90) > orttol)
        disp(['ND2PT: input vectors not perpendicular, angle=' num2str(ang)]);
        ierr=1;
      end
      px=anx-dx;
      py=any-dy;
      pz=anz-dz;
      [amp,px,py,pz] = focal_norm(px,py,pz);
      if (pz < c0)
        [px,py,pz] = focal_invert(px,py,pz);
      end
      tx=anx+dx;
      ty=any+dy;
      tz=anz+dz;
      [amp,tx,ty,tz] = focal_norm(tx,ty,tz);
      if (tz < c0)
        [tx,ty,tz] = focal_invert(tx,ty,tz);
      end
      [bx,by,bz] = focal_vecpro(px,py,pz,tx,ty,tz);
      if(bz < c0)
        [bx,by,bz] = focal_invert(bx,by,bz);
      end
