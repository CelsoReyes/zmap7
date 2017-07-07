function [trendp,plungp,trendt,plungt,trendb,plungb,ierr] = focal_pl2pt(strike,dip,rake)

%% c     compute trend and plunge of P, T and B axes
%% c     from strike, dip and rake of a nodal plane
%% c
%% c
%% c     usage:
%% c     call pl2pt(strike,dip,rake,trendp,plungp,trendt,plungt,trendb,plungb,ierr)
%% c
%% c     arguments:
%% c     strike         strike angle in degrees of the first nodal plane (INPUT)
%% c     dip            dip angle in degrees of the first nodal plane (INPUT)
%% c     rake           rake angle in degrees of the first nodal plane (INPUT)
%% c     trendp         trend of P axis (OUTPUT)
%% c     plungp         plunge or P axis (OUTPUT)
%% c     trendt         trend of T axis (OUTPUT)
%% c     plungt         plunge or T axis (OUTPUT)
%% c     trendb         trend of B axis (OUTPUT)
%% c     plungb         plunge or B axis (OUTPUT)
%% c     ierr           error indicator (OUTPUT)
%% c
%% c     errors:
%% c     1              input STRIKE angle out of range
%% c     2              input DIP angle out of range
%% c     4              input RAKE angle out of range
%% c     3              1+2
%% c     5              1+4
%% c     7              1+2+4
%% c     8,9,10,11      internal error



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
%%       real strike,dip,rake,anx,any,anz,dx,dy,dz,px,py,pz,tx,ty,tz
%%      1,bx,by,bz,trendp,plungp,trendt,plungt,trendb,plungb
%%       integer ierr

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


      [anx,any,anz,dx,dy,dz,ierr] = focal_pl2nd(strike,dip,rake);
      if (ierr ~= 0)
        disp(['PL2PT: ierr=' num2str(ierr)]);
        return;
      end
      [px,py,pz,tx,ty,tz,bx,by,bz,ierr] = focal_nd2pt(dx,dy,dz,anx,any,anz);
      if (ierr ~= 0)
        ierr=8;
        disp(['PL2PT: ierr=' num2str(ierr)]);
      end
      [trendp,plungp,ierr] = focal_ca2ax(px,py,pz);
      if (ierr ~= 0)
        ierr=9;
        disp(['PL2PT: ierr=' num2str(ierr)]);
      end
      [trendt,plungt,ierr] = focal_ca2ax(tx,ty,tz);
      if (ierr ~= 0)
        ierr=10;
        disp(['PL2PT: ierr=' num2str(ierr)]);
      end
      [trendb,plungb,ierr] = focal_ca2ax(bx,by,bz);
      if (ierr ~= 0)
        ierr=11;
        disp(['PL2PT: ierr=' num2str(ierr)]);
      end
