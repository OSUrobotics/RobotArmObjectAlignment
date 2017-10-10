function [idsInPlane, objPointsOriented ] = PlaneThroughHand( ptCenter, vecX, vecY, vecZ, objPointsAndNorms, height )
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

global bDraw;

% Translate the points
objPointsCenter = objPointsAndNorms(:,1:3);
for k = 1:3
    objPointsCenter(:,k) = objPointsCenter(:,k) - ptCenter(k);
end
objNorms = objPointsAndNorms(:,4:6);

% Make the rotation matrix

matRot = [ vecX; vecY; vecZ];
% Rotate
objPointsOriented = matRot * objPointsCenter';
objNormsOriented = matRot * objNorms';

objPointsOriented = [ objPointsOriented', objNormsOriented' ];

% Clip
idsInPlane = abs( objPointsOriented(:,2) ) < height;

if bDraw == true
    hold on;
    plot3( objPointsAndNorms(idsInPlane, 1), objPointsAndNorms(idsInPlane, 2), objPointsAndNorms(idsInPlane, 3), 'xr');
    pts = [ ptCenter - vecY * 5*height; ptCenter + vecY * 5*height ];
    plot3( pts(:,1), pts(:,2), pts(:,3), 'O-b');
    pts = [ ptCenter - vecX * 5*height; ptCenter + vecX * 5*height ];
    plot3( pts(:,1), pts(:,2), pts(:,3), 'O-g');
    pts = [ ptCenter; ptCenter + vecZ * 10*height ];
    plot3( pts(:,1), pts(:,2), pts(:,3), 'O-r');
end
end