function [strikb,dipb,rakeb,dipdib,ierr] = focal_pl2pl(strika,dipa,rakea)

%% c
%% c     compute strike, dip and rake of a nodal plane
%% c     from strike, dip and rake of the other one
%% c
%% c
%% c     usage:
%% c     call pl2pl(strika,dipa,rakea,strikb,dipb,rakeb,dipdib,ierr)
%% c
%% c     arguments:
%% c     strika         strike angle in degrees of the first nodal plane (INPUT)
%% c     dipa           dip angle in degrees of the first nodal plane (INPUT)
%% c     rakea          rake angle in degrees of the first nodal plane (INPUT)
%% c     strikb         strike angle in degrees of the second nodal plane (OUTPUT)
%% c     dipb           dip angle in degrees of the second nodal plane (OUTPUT)
%% c     rakeb          rake angle in degrees of the second nodal plane (OUTPUT)
%% c     dipdib         dip direction in degrees of the second nodal plane (OUTPUT)
%% c     ierr           error indicator (OUTPUT)
%% c
%% c     errors:
%% c     1              input STRIKE angle out of range
%% c     2              input DIP angle out of range
%% c     4              input RAKE angle out of range
%% c     3              1+2
%% c     5              1+4
%% c     7              1+2+4
%% c     8              internal error
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
%%       real strika,dipa,rakea,anx,any,anz,dx,dy,dz,strikb,dipb,rakeb,
%%      1dipdib
%%       integer ierr
%% c
%%      call fpsset
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

      [anx,any,anz,dx,dy,dz,ierr] = focal_pl2nd(strika,dipa,rakea);
      if (ierr ~= 0)
        disp(['PL2PL: ierr = ' num2str(ierr)]);
        return;
      end
      [strikb,dipb,rakeb,dipdib,ierr] = focal_nd2pl(dx,dy,dz,anx,any,anz);
      if (ierr ~= 0)
        ierr = 8;
        disp(['PL2PL: ierr = ' num2str(ierr)]);
      end
