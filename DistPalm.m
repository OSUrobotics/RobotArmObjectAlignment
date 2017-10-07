function [ dPalm, dCenter, dWidest, dMax ] = DistPalm( stlHand, handrep, handWidth, objPoints, height )
%DistPalm Distance palm metric
%   Rotate object points to origin
%   Clip to points in +- height
%   Find closest, mean, widest (in z) and furthest points
%     Measured out of the palm

% orient 
%   Vec X is parallel to palm
%   Vec Y is up out of the grasp
%   Vec Z is palm normal
[ ptCenter, vecX, vecY, vecZ ] = DistPalmOrientation( stlHand, handrep );
% Rotate so x is x axis, etc
% Clip to height in Y
[ idsInPlane, objPointsOriented ] = PlaneThroughHand( ptCenter, vecX, vecY, vecZ, objPoints, height );

% Clip to palm width
idsInFrontOfPalm = abs( objPointsOriented(:, 1) ) < (handWidth/2);

% Allow a little bit of wiggle
dAngLeftPt = atan2( objPointsOriented(:,3), objPointsOriented(:,1) - handWidth/2 );
dAngRightPt = atan2( objPointsOriented(:,3), objPointsOriented(:,1) + handWidth/2 );
idsOnLeft = dAngLeftPt <= pi/2 & dAngLeftPt >= pi/2 - pi/8;
idsOnRight = dAngRightPt >= pi/2 & dAngRightPt <= pi/2 + pi/8;

idsInFrontOfPalm = idsInFrontOfPalm | idsOnLeft | idsOnRight;

% Do distances in z (palm normal)
dPalm = min( objPointsOriented(idsInFrontOfPalm & idsInPlane, 3) );
dMax = max( objPointsOriented(idsInFrontOfPalm & idsInPlane, 3) );
dCenter = mean( objPointsOriented(idsInFrontOfPalm & idsInPlane, 3) );

% Should replace this with polygon made by fingers, but...
zDivs = linspace( dPalm, dMax, 20 );
xWidth = 0;
for k = 1:length(zDivs)-1
    idsInSlice = idsInPlane & objPointsOriented(:, 3) >= zDivs(k) & ...
                              objPointsOriented(:, 3) <= zDivs(k+1);
    xMin = min( objPointsOriented(idsInSlice,1) );
    xMax = max( objPointsOriented(idsInSlice,1) );
    if xMax - xMin > xWidth
        dWidest = 0.5 * (zDivs(k+1) - zDivs(k));
        xWidth = xMax - xMin;
    end
end

pts = [ptCenter + vecZ * dPalm; ptCenter + vecZ * dCenter; ptCenter + vecZ * dWidest; ptCenter + vecZ * dMax];
objPts = objPoints( idsInPlane & idsInFrontOfPalm,: );
plot3( objPts(:, 1), objPts(:, 2), objPts(:, 3), 'Oy', 'MarkerSize', 15);
plot3( pts(:,1), pts(:,2), pts(:,3), '*-k', 'MarkerSize', 20);
end

