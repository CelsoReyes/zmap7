function [ax,ay,az,ierr] = ax2ca(trend,plunge)
    % compute cartesian components from trend and plunge
    %
    %     usage:
    %     call ax2ca(trend,plunge,ax,ay,az,ierr)
    %
    %     arguments:
    %     trend          clockwise angle from North in degrees (INPUT)
    %     plunge         inclination angle in degrees (INPUT)
    %     ax,ay,az       components of the axis direction downward versor in the
    %                    Aki-Richards Cartesian coordinate system (OUTPUT)
    %     ierr           error indicator (OUTPUT)
    %
    %     errors:
    %     1              input TREND angle out of range
    %     2              input PLUNGE angle out of range
    %     3              1+2
    %
    %      implicit none
    
    % c-------------------------------------------------------------------------------
    %      integer io
    %      real amistr,amastr,amidip,amadip,amirak,amarak,amitre,amatre
    %     1,amiplu,amaplu,orttol,ovrtol,tentol,dtor,c360,c90,c0,c1,c2,c3
    %      common /fpscom/amistr,amastr,amidip,amadip,amirak,amarak,amitre
    %     1,amatre,amiplu,amaplu,orttol,ovrtol,tentol,dtor,c360,c90,c0,c1,c2
    %     2,c3,io
    % c-------------------------------------------------------------------------------
    %      real ax,ay,az,trend,plunge
    %      integer ierr
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
    
    ax=c0;
    ay=c0;
    az=c0;
    ierr=0;
    if ((trend < amitre) || (trend > amatre))
        disp(['AX2CA: input TREND angle ' num2str(trend) ' out of range']);
        ierr=1;
    end
    if ((plunge < amiplu) || (plunge > amaplu))
        if ((plunge < amaplu) && (plunge > -ovrtol))
            plunge = amiplu;
        elseif ((plunge > amiplu) && (plunge-amaplu < ovrtol))
            plunge = amaplu;
        else
            disp(['AX2CA: input PLUNGE angle ' num2str(plunge) ' out of range']);
            ierr = ierr + 2;
        end
    end
    if (ierr ~= 0)
        return;
    end
    ax = cos(plunge * dtor) * cos(trend * dtor);
    ay = cos(plunge * dtor) * sin(trend * dtor);
    az = sin(plunge * dtor);
end
