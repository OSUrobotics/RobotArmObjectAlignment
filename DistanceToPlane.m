function [ dist ] = DistanceToPlane( planeC, planeN, pt )
%DistanceToPlane Distance to plane
%   Detailed explanation goes here

dist = dot( pt - planeC, planeN );

end

