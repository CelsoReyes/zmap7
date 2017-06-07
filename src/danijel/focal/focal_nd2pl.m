function [phi,delta,alam,dipdir,ierr] = focal_nd2pl(wanx,wany,wanz,wdx,wdy,wdz)

%% c     compute strike, dip, rake and dip directions from Cartesian
%% c     components of the outward normal and slip vectors
%% c
%% c     usage:
%% c     call nd2pl(anx,any,anz,dx,dy,dz,strike,dip,rake,dipdir,ierr)
%% c
%% c     arguments:
%% c     anx,any,anz    components of fault plane outward normal vector in the
%% c                    Aki-Richards Cartesian coordinate system (INPUT)
%% c     dx,dy,dz       components of slip vector in the Aki-Richards
%% c                    Cartesian coordinate system (INPUT)
%% c     strike         strike angle in degrees (OUTPUT)
%% c     dip            dip angle in degrees (OUTPUT)
%% c     rake           rake angle in degrees (OUTPUT)
%% c     dipdir         dip direction angle in degrees (OUTPUT)
%% c     ierr           error indicator (OUTPUT)
%% c
%% c     errors:
%% c     1              input vectors not perpendicular among each other
%% c
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

      ierr = 0;
      [ang] = focal_angle(wanx,wany,wanz,wdx,wdy,wdz);
      if (abs(ang - c90) > orttol)
        disp(['ND2PL: input vectors not perpendicular, angle=' num2str(ang)]);
        ierr = 1;
      end
      [anorm,anx,any,anz] = focal_norm(wanx,wany,wanz);
      [dnorm,dx,dy,dz] = focal_norm(wdx,wdy,wdz);
      if (anz > c0)
        [anx,any,anz] = focal_invert(anx,any,anz);
        [dx,dy,dz] = focal_invert(dx,dy,dz);
      end

      if(anz == -c1)
        wdelta = c0;
        wphi = c0;
        walam = atan2(-dy, dx);
      else
        wdelta = acos(-anz);
        wphi = atan2(-anx, any);
        walam = atan2(-dz/sin(wdelta),dx*cos(wphi)+dy*sin(wphi));
      end
      phi = wphi/dtor;
      delta = wdelta/dtor;
      alam = walam/dtor;
      phi = mod(phi+c360, c360);
      dipdir = phi+c90;
      dipdir = mod(dipdir+c360,c360);
