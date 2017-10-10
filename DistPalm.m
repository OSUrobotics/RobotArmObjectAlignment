function [ metrics ] = DistPalm( stlHand, handrep, handWidth, objPoints, objNorms, height )
%DistPalm Distance palm metric
%   Rotate object points to origin
%   Clip to points in +- height
%   Find closest, mean, widest (in z) and furthest points
%     Measured out of the palm

global bDraw;

metrics = struct;
metrics.dists = zeros(1,6);
metrics.strLabels = {'Min dist', 'Center dist', 'Widest dist', 'Max dist', 'Contact ang mean', 'Contact ang sd'};
metrics.handWidth = handWidth;
metrics.sliceHeight = height;

% orient 
%   Vec X is parallel to palm
%   Vec Y is up out of the grasp
%   Vec Z is palm normal
[ ptCenter, vecX, vecY, vecZ ] = DistPalmOrientation( stlHand, handrep );
% Rotate so x is x axis, etc
% Clip to height in Y
[ idsInPlane, objPointsOriented ] = PlaneThroughHand( ptCenter, vecX, vecY, vecZ, [objPoints objNorms], height );

% Clip to palm width
idsInFrontOfPalm = abs( objPointsOriented(:, 1) ) < (handWidth/2);

% Allow a little bit of wiggle
dAngLeftPt = atan2( objPointsOriented(:,3), objPointsOriented(:,1) - handWidth/2 );
dAngRightPt = atan2( objPointsOriented(:,3), objPointsOriented(:,1) + handWidth/2 );
idsOnLeft = dAngLeftPt <= pi/2 & dAngLeftPt >= pi/2 - pi/8;
idsOnRight = dAngRightPt >= pi/2 & dAngRightPt <= pi/2 + pi/8;

idsInFrontOfPalm = idsInFrontOfPalm | idsOnLeft | idsOnRight;

if sum( idsInPlane & idsInFrontOfPalm ) == 0 
    dMin = 1000;
    dMax = 1000;
    dCenter = 1000;
    dWidest = 1000;

    metrics.dists(5:6) = [ 1 10 ];
else
    % Do distances in z (palm normal)
    dMin = min( objPointsOriented(idsInFrontOfPalm & idsInPlane, 3) );
    dMax = max( objPointsOriented(idsInFrontOfPalm & idsInPlane, 3) );
    dCenter = mean( objPointsOriented(idsInFrontOfPalm & idsInPlane, 3) );

    % Should replace this with polygon made by fingers, but...
    zDivs = linspace( dMin, dMax, 20 );
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

    idsForNorm = idsInPlane & idsInFrontOfPalm & objPointsOriented(:,3) <= dMin + height;
    norms = objNorms( idsForNorm, :);
    dDotAvg = zeros( size( norms, 1 ), 1 );
    for k = 1:size(norms,1)
        dDotAvg(k) = sum( vecZ .* norms(k,:) );
    end
    metrics.dists(5:6) = [ mean( dDotAvg ), std( dDotAvg ) ];

    pts = [ptCenter + vecZ * dMin; ptCenter + vecZ * dCenter; ptCenter + vecZ * dWidest; ptCenter + vecZ * dMax];
    objPts = objPoints( idsInPlane & idsInFrontOfPalm, : );
    if bDraw == true
        plot3( objPts(:, 1), objPts(:, 2), objPts(:, 3), 'Oy', 'MarkerSize', 15);
        plot3( pts(:,1), pts(:,2), pts(:,3), '*-k', 'MarkerSize', 20);
        pts = objPoints( idsForNorm, : );
        quiver3( pts(:, 1), pts(:, 2), pts(:, 3), ...
                 norms(:, 1), norms(:, 2), norms(:, 3) );
    end
end

metrics.dists(1) = dMin;
metrics.dists(2) = dCenter;
metrics.dists(3) = dWidest;
metrics.dists(4) = dMax;

end

