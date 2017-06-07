function [fNewLat1, fNewLat2, fNewLon1, fNewLon2] = rotate_xsection(fLat1, fLat2, fLon1, fLon2, fAngle)

    % Compute the center of the given cross-section
    fCenterLat = fLat1 - ((fLat1 - fLat2)/2);
    fCenterLon = fLon1 - ((fLon1 - fLon2)/2);

    % Move the center of the cross-section to the origin
    vPos1 = [fLon1-fCenterLon; fLat1-fCenterLat];
    vPos2 = [fLon2-fCenterLon; fLat2-fCenterLat];

    % Compute angle in radians
    fAngle = fAngle*pi/180;

    % Set up the rotation matrix
    mRotate = [cos(fAngle) -sin(fAngle); sin(fAngle) cos(fAngle)];

    % Rotate the cross-section vectors
    vNewPos1 = mRotate * vPos1;
    vNewPos2 = mRotate * vPos2;

    % Move them back to their previous position
    fNewLon1 = vNewPos1(1) + fCenterLon;
    fNewLat1 = vNewPos1(2) + fCenterLat;
    fNewLon2 = vNewPos2(1) + fCenterLon;
    fNewLat2 = vNewPos2(2) + fCenterLat;


