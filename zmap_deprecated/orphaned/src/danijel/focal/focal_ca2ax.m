function [trend,plunge,ierr] = focal_ca2ax(wax,way,waz)

%% c     compute trend and plunge from Cartesian components
%% c
%% c     usage:
%% c     call ca2ax(ax,ay,az,trend,plunge,ierr)
%% c
%% c     arguments:
%% c     ax,ay,az       components of axis direction vector in the Aki-Richards
%% c                    Cartesian coordinate system (INPUT)
%% c     trend          clockwise angle from North in degrees (OUTPUT)
%% c     plunge         inclination angle in degrees (OUTPUT)
%% c     ierr           error indicator (OUTPUT)
%% c
%% c     errors:
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
%%       real wax,way,waz,wnorm,ax,ay,az,trend,plunge
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
      [wnorm,ax,ay,az] = focal_norm(wax,way,waz);
      if (az < c0)
        [ax,ay,az] = focal_invert(ax,ay,az);
      end
      if ((ay ~= c0) | (ax ~= c0))
        trend=atan2(ay,ax)/dtor;
      else
        trend=c0;
      end
      trend=mod(trend+c360,c360);
      plunge=asin(az)/dtor;
