function [strika,dipa,rakea,dipdia,strikb,dipb,rakeb,dipdib,ierr] = pt2pl(trendp,plungp,trendt,plungt)
    
    % compute strike dip and rake (and dip direction) of two nodal planes from trend and plung of P and T axes
    %
    %     usage:
    %     call pt2pl(trendp,plungp,trendt,plungt,strika,dipa,rakea
    %    1,dipdia,strikb,dipb,rakeb,dipdib,ierr)
    %
    %     arguments:
    %     trendp         trend of P axis in degrees (INPUT)
    %     plungp         plunge of P axis in degrees (INPUT)
    %     trendt         trend of P axis in degrees (INPUT)
    %     plungt         plunge of P axis in degrees (INPUT)
    %     strika         strike angle of first nodal plane in degrees (OUTPUT)
    %     dipa           dip angle of first nodal plane in degrees (OUTPUT)
    %     rakea          rake angle of first nodal plane in degrees (OUTPUT)
    %     dipdia         dip direction angle of first nodal plane in degrees (OUTPUT)
    %     strikb         strike angle of second nodal plane in degrees (OUTPUT)
    %     dipb           dip angle of second nodal plane in degrees (OUTPUT)
    %     rakeb          rake angle of second nodal plane in degrees (OUTPUT)
    %     dipdib         dip direction angle of second nodal plane in degrees (OUTPUT)
    %     ierr           error indicator (OUTPUT)
    %
    %     errors:
    %     1              input TREND angle of P axis out of range
    %     2              input PLUNGE angle P axis out of range
    %     3              1+2
    %     4              input TREND angle of P axis out of range
    %     5              input PLUNGE angle P axis out of range
    %     6              4+5
    %     8,9,10         internal errors
    %
    % c
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
    % c
    %      call ax2ca(trendp,plungp,px,py,pz,ierr)
    [px,py,pz,ierr] = focal_ax2ca(trendp,plungp);
    if (ierr ~= 0)
        disp(['PT2PL: ierr=' num2str(ierr)]);
        return;
    end
    
    %      call ax2ca(trendt,plungt,tx,ty,tz,ierr)
    [tx,ty,tz,ierr] = focal_ax2ca(trendt,plungt);
    if (ierr ~= 0)
        ierr = ierr + 3;
        disp(['PT2PL: ierr=' num2str(ierr)]);
        return;
    end
    
    [anx,any,anz,dx,dy,dz,ierr] = focal_pt2nd(px,py,pz,tx,ty,tz);
    if (ierr ~= 0)
        ierr = 8;
        disp(['PT2PL: ierr=' num2str(ierr)]);
        return;
    end
    [strika,dipa,rakea,dipdia,ierr] = focal_nd2pl(anx,any,anz,dx,dy,dz);
    if (ierr ~= 0)
        ierr = 9;
        disp(['PT2PL: ierr=' num2str(ierr)]);
        return;
    end
    [strikb,dipb,rakeb,dipdib,ierr] = focal_nd2pl(dx,dy,dz,anx,any,anz);
    if (ierr ~= 0)
        ierr = 10;
        disp(['PT2PL: ierr=' num2str(ierr)]);
        return;
    end
end