function [ ptCenter, vecX, vecY, vecZ, dFinger ] = DistFingerTipsOrientation( stlHand, handrep )
%DistFiingerTipsOrientation Coordinate system for measuring distance to
% fingertips
%   Vec X is parallel to palm
%   Vec Y is up out of the grasp
%   Vec Z is vector between thumb and finger tips (averaged)

[ptCenter, ~] = Reconstruct( stlHand, handrep.vIds(7,:), handrep.vBarys(7,:) );
[ptF1, ~] = Reconstruct( stlHand, handrep.vIds(11,:), handrep.vBarys(11,:) );
[ptF2, ~] = Reconstruct( stlHand, handrep.vIds(15,:), handrep.vBarys(15,:) );
[ptLeft, ~] = Reconstruct( stlHand, handrep.vIds(2,:), handrep.vBarys(2,:) );
[ptRight, ~] = Reconstruct( stlHand, handrep.vIds(3,:), handrep.vBarys(3,:) );

% left and right palm are perpendicular to thumb-finger
% so vecY is out of grasp
vecY = ptRight - ptLeft;
vecTF = 0.5 * (ptF1 + ptF2) - ptCenter;
dFinger = sqrt( sum( vecTF.^2 ) );

vecX = cross( vecY, vecTF );
% Ensure orthonormal
vecZ = cross( vecX, vecY );


% ensure unit
vecX = vecX ./ sqrt( sum(vecX .* vecX) );
vecY = vecY ./ sqrt( sum(vecY.^2) );
vecZ = vecZ ./ sqrt( sum(vecZ .* vecZ) );

end

