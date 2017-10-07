function [idsInPlane, objPointsOriented ] = PlaneThroughHand( ptCenter, vecX, vecY, vecZ, objPoints, height )
%% PlaneThroughHand : Transform the object points into the given coordinate
% system then return all of the object points that lie in the resulting x,z
% plane
% 
% Input:
%  ptCenter: R3 Pt that goes to the origin
%  vecX: R3Vec that goes to the x direction
%  vecY: R3Vec that goes to the y direction
%  vecZ: R3Vec that goes to the z direction
%  objPoints: R3 points + (optional) normals on the object
%  height: How "thick" the slice should be - usually 1/8ish of the span of
%  the hand, or 1/4 of the palm

% Translate the points
objPointsCenter = objPoints(:,1:3) - ptCenter;

% Make the rotation matrix

matRot = [ vecX; vecY; vecZ];
% Rotate
objPointsOriented = matRot * objPointsCenter';
objPointsOriented = objPointsOriented';

% Clip
idsInPlane = abs( objPointsOriented(:,2) ) < height;

plot3( objPoints(idsInPlane, 1), objPoints(idsInPlane, 2), objPoints(idsInPlane, 3), 'xr');
pts = [ ptCenter - vecY * 5*height; ptCenter + vecY * 5*height ];
plot3( pts(:,1), pts(:,2), pts(:,3), 'O-b');
pts = [ ptCenter - vecX * 5*height; ptCenter + vecX * 5*height ];
plot3( pts(:,1), pts(:,2), pts(:,3), 'O-g');
pts = [ ptCenter; ptCenter + vecZ * 10*height ];
plot3( pts(:,1), pts(:,2), pts(:,3), 'O-r');
end