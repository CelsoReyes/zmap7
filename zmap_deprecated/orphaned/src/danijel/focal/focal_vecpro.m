function [bx,by,bz] = focal_vecpro(px,py,pz,tx,ty,tz)

%% c     compute vector products of two vectors
%% c
%% c     usage:
%% c     call vecpro(px,py,pz,tx,ty,tz,bx,by,bz)
%% c
%% c     arguments:
%% c
%% c     px,py,pz       Cartesian component of first vector (INPUT)
%% c     tx,ty,tz       Cartesian component of second vector (INPUT)
%% c     bx,by,bz       Cartesian component of vector product (OUTUT)

      bx=py*tz-pz*ty;
      by=pz*tx-px*tz;
      bz=px*ty-py*tx;
