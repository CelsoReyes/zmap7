function [strikb,dipb,rakeb,dipdib,ierr] = focal_pl2pl(strika,dipa,rakea)
    
    % compute strike, dip and rake of a nodal plane from strike, dip and rake of the other one
    %
    %
    %     usage:
    %     call pl2pl(strika,dipa,rakea,strikb,dipb,rakeb,dipdib,ierr)
    %
    %     arguments:
    %     strika         strike angle in degrees of the first nodal plane (INPUT)
    %     dipa           dip angle in degrees of the first nodal plane (INPUT)
    %     rakea          rake angle in degrees of the first nodal plane (INPUT)
    %     strikb         strike angle in degrees of the second nodal plane (OUTPUT)
    %     dipb           dip angle in degrees of the second nodal plane (OUTPUT)
    %     rakeb          rake angle in degrees of the second nodal plane (OUTPUT)
    %     dipdib         dip direction in degrees of the second nodal plane (OUTPUT)
    %     ierr           error indicator (OUTPUT)
    %
    %     errors:
    %     1              input STRIKE angle out of range
    %     2              input DIP angle out of range
    %     4              input RAKE angle out of range
    %     3              1+2
    %     5              1+4
    %     7              1+2+4
    %     8              internal error
    %
    %      implicit none
    %-------------------------------------------------------------------------------
    %%       integer io
    %%       real amistr,amastr,amidip,amadip,amirak,amarak,amitre,amatre
    %%      1,amiplu,amaplu,orttol,ovrtol,tentol,dtor,c360,c90,c0,c1,c2,c3
    %%       common /fpscom/amistr,amastr,amidip,amadip,amirak,amarak,amitre
    %%      1,amatre,amiplu,amaplu,orttol,ovrtol,tentol,dtor,c360,c90,c0,c1,c2
    %%      2,c3,io
    %-------------------------------------------------------------------------------
    %%       real strika,dipa,rakea,anx,any,anz,dx,dy,dz,strikb,dipb,rakeb,
    %%      1dipdib
    %%       integer ierr
    %
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
end