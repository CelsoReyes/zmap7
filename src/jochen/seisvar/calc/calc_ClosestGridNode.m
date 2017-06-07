function [fXGridNode, fYGridNode, nNodeGridPoint] = calc_ClosestGridNode(mPolygon, fX, fY)
% function [fXGridNode, fYGridNode, nNodeGridPoint] = calc_ClosestGridNode(mPolygon, fX, fY);
% -------------------------------------------------------------------------------------------
% Function to determine closest grid point to a point picked on a map with a defined polygon
% Compute distance as great circle distance between the two points on the globe.
%
% Incoming variables:
% mPolygon: Coordinates of the polygon
% fX      : X-coordinate to find the next gridpoint to (use f.e. ginput)
% fY      : Y-coordinate to find the next gridpoint to (use f.e. ginput)
%
% Outgoing variables:
% fXGridNode : X-coordinate of closest grid node
% fYGridNode : Y-coordinate of closest grid node
% nNodeGridPoint : Grid node indice
%
% J. Woessner, woessner@seismo.ifg.ethz.ch
% last update: 19.08.02

%%%% Determine next grid point  %%%%%%%%%%%%
mPos = [fX fY];
mPos = repmat(mPos,length(mPolygon(:,1)), 1);
mDist = abs(distance(mPolygon(:,1), mPolygon(:,2), mPos(:,1), mPos(:,2)));
vSel = (mDist == min(mDist));
mNodePos = mPolygon(find(vSel),:)
fXGridNode = mNodePos(1,1);
fYGridNode = mNodePos(1,2);

% Determine the gridpoint number
for nNode = 1:length(mPolygon(:,1))
    x = fXGridNode-mPolygon(nNode,1);
    y = fYGridNode-mPolygon(nNode,2);
    if (x == 0 & y == 0)
        nNodeGridPoint = nNode;
    end
end

%%% Remember this for cartesian coordinates (cross section use)
% fMinDistX = min(sqrt(mPolygon(:,1).^2 - fX^2));
% fXDiff = sqrt(mPolygon(:,1).^2-fX^2);
% bX = ((fMinDistX-fXDiff) == 0);
% fNextGridPointsX=mPolygon(bX,1);
%
% fMinDistY = min(sqrt(mPolygon(:,2).^2 - fY^2));
% fYDiff = sqrt(mPolygon(:,2).^2-fY^2);
% bY = ((fMinDistY-fYDiff) == 0);
% fNextGridPointsY=mPolygon(bY,2);
%
% if fX < 0
%     fXGridNode= -fNextGridPointsX(1,1);
% else
%     fXGridNode= fNextGridPointsX(1,1)
% end
% if fY < 0
%     fYGridNode= -fNextGridPointsY(1,1);
% else
%     fYGridNode=fNextGridPointsY(1,1);
% end
