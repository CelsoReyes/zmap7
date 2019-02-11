function [newQuake, DistAlongPlane, perp_dist]=projection(startPt, endPt, quake)
    % project points onto a line segment
    V1 = endPt - startPt; % vector to project upon
    V2 = quake - startPt; % vector to project
    dfun=@(vec1, vec2)sqrt(sum((vec1-vec2).^2,2)); %nx2 vectors
    AngleToPlane   = angle(V1(:,1) + 1i*(V1(:,2)));
    AngleToQuake = angle(V2(:,1) + 1i*(V2(:,2)));
    orientedAngle = wrapToPi(AngleToQuake - AngleToPlane);
    DistAlongPlane = cos(orientedAngle) .* dfun(V2,[0,0]);
    NewOffset =  [cos(AngleToPlane),sin(AngleToPlane)] .* DistAlongPlane;
    newQuake = NewOffset + startPt;
    perp_dist = sqrt(sum((quake-newQuake).^2,2));
end