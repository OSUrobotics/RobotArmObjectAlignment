function [ ptCenter, vecX, vecY ] = DistPalmOrientation( stlHand, handrep )
%DistPalmOrientation Coordinate system for measuring distance to palm
%   Vec X is parallel to palm
%   Vec Y is up out of the grasp
%   Vec Z is palm normal

[ptCenter, palmNorm] = Reconstruct( stlHand, handrep.vIds(1,:), handrep.vBarys(1,:) );
[ptLeft, ~] = Reconstruct( stlHand, handrep.vIds(2,:), handrep.vBarys(2,:) );
[ptRight, ~] = Reconstruct( stlHand, handrep.vIds(3,:), handrep.vBarys(3,:) );

vecY = ptRight - ptLeft;
vecY = vecY ./ sqrt( sum(vecY.^2) );
vecZ = palmNorm ./ sqrt( sum(palmNorm.^2) );
vecX = cross( vecY, vecZ );

end

