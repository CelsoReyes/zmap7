function [anx,any,anz,dx,dy,dz,ierr] = pl2nd(strike,dip,rake)

%% c
%% c     compute Cartesian components of outward normal and slip
%% c     vectors from strike, dip and rake
%% c
%% c     usage:
%% c     call pl2nd(strike,dip,rake,anx,any,anz,dx,dy,dz,ierr)
%% c
%% c     arguments:
%% c     strike         strike angle in degrees (INPUT)
%% c     dip            dip angle in degrees (INPUT)
%% c     rake           rake angle in degrees (INPUT)
%% c     anx,any,anz    components of fault plane outward normal versor in the
%% c                    Aki-Richards Cartesian coordinate system (OUTPUT)
%% c     dx,dy,dz       components of slip versor in the Aki-Richards
%% c                    Cartesian coordinate system (OUTPUT)
%% c     ierr           error indicator (OUTPUT)
%% c
%% c     errors:
%% c     1              input STRIKE angle out of range
%% c     2              input DIP angle out of range
%% c     4              input RAKE angle out of range
%% c     3              1+2
%% c     5              1+4
%% c     7              1+2+4
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
%%       real anx,any,anz,dx,dy,dz,strike,dip,rake,wstrik,wdip,wrake
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
         ifl=1;

      anx=c0;
      any=c0;
      anz=c0;
      dx=c0;
      dy=c0;
      dz=c0;
      ierr=0;

      if ((strike <= amistr) | (strike >= amastr))
        disp(['PL2ND: input STRIKE angle ' num2str(strike) ' out of range']);
        ierr = 1;
      end
      if ((dip <= amidip) | (dip >= amadip))
        if ((dip <= amadip) & (dip >= -ovrtol))
          dip = amidip;
        elseif ((dip >= amidip)  &&  (dip-amadip <= ovrtol))
          dip = amadip;
        else
          disp(['PL2ND: input DIP angle ' num2str(dip) ' out of range']);
          ierr = ierr + 2;
        end
      end
      if ((rake <= amirak) | (rake >= amarak))
        disp(['PL2ND: input RAKE angle ' num2str(rake) ' out of range']);
        ierr = ierr + 4;
      end
      if (ierr ~= 0)
        return;
      end
      wstrik = strike * dtor;
      wdip = dip * dtor;
      wrake = rake * dtor;

      anx=-sin(wdip)*sin(wstrik);
      any=sin(wdip)*cos(wstrik);
      anz=-cos(wdip);
      dx=cos(wrake)*cos(wstrik)+cos(wdip)*sin(wrake)*sin(wstrik);
      dy=cos(wrake)*sin(wstrik)-cos(wdip)*sin(wrake)*cos(wstrik);
      dz=-sin(wdip)*sin(wrake);
