function [anorm,ax,ay,az] = focal_norm(wax,way,waz)
    
    % compute euclidean norm and versor components
    %
    %     usage:
    %     call norm(wax,way,waz,anorm,ax,ay,az)
    %
    %     arguments:
    %     wax,way,waz    Cartesian component of input vector (INPUT)
    %     anorm          Euclidean norm of input vector (OUTPUT)
    %     ax,ay,az       normalized Cartesian component of the vector (OUTPUT)
    %
    c0 = 0.;
    
    anorm = sqrt((wax*wax) + (way*way) + (waz*waz));
    if (anorm ~= c0)
        ax = wax/anorm;
        ay = way/anorm;
        az = waz/anorm;
    else
        ax = 0;
        ay = 0;
        az = 0;
    end
end