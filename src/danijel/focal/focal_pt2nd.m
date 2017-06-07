function [anx,any,anz,dx,dy,dz,ierr] = focal_pt2nd(wpx,wpy,wpz,wtx,wty,wtz)

%% c
%% c     compute Cartesian component of P and T versors
%% c     from outward normal and slip vectors
%% c
%% c     usage:
%% c     call pt2nd(px,py,pz,tx,ty,tz,anx,any,anz,dx,dy,dz,ierr)
%% c
%% c     arguments:
%% c     px,py,pz       components of P (maximum dilatation) axis vector
%% c                    in the Aki-Richards Cartesian coordinate system (INPUT)
%% c     tx,ty,tz       components of T (maximum tension) axis vector
%% c                    in the Aki-Richards Cartesian coordinate system (INPUT)
%% c     anx,any,anz    components of fault plane outward normal versor in the
%% c                    Aki-Richards Cartesian coordinate system (OUTPUT)
%% c     dx,dy,dz       components of slip versor in the Aki-Richards
%% c                    Cartesian coordinate system (OUTPUT)
%% c     ierr           error indicator (OUTPUT)
%% c
%% c     errors:
%% c     1              input vectors not perpendicular among each other
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
      anx=c0;
      any=c0;
      anz=c0;
      dx=c0;
      dy=c0;
      dz=c0;
      ierr=0;
      [ang] = focal_angle(wpx,wpy,wpz,wtx,wty,wtz);
      if (abs(ang - c90) > orttol)
        disp(['PT2ND: input vectors not perpendicular, angle=' num2str(ang)]);
        ierr = 1;
      end
      [pnorm,px,py,pz] = focal_norm(wpx,wpy,wpz);

      if (pz < c0)
        [px,py,pz] = focal_invert(px,py,pz);
      end
      [tnorm,tx,ty,tz] = focal_norm(wtx,wty,wtz);
      if (tz < c0)
        [tx,ty,tz] = focal_invert(tx,ty,tz);
      end
      anx = tx + px;
      any = ty + py;
      anz = tz + pz;
      [amn,anx,any,anz] = focal_norm(anx,any,anz);
% c
      dx = tx - px;
      dy = ty - py;
      dz = tz - pz;
      [amn,dx,dy,dz] = focal_norm(dx,dy,dz);
      if(anz > c0)
        [anx,any,anz] = focal_invert(anx,any,anz);
        [dx,dy,dz] = focal_invert(dx,dy,dz);
      end
