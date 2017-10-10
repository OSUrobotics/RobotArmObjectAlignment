function [ dists ] = DistPoint( ptCenter, vecX, vecY, vecZ, objPointsAndNorms, height, width )
%DistPoint Distance point metric
%   Rotate object points to origin
%   Clip to points in +- height, width
%   Find min (in z) and dot product of normal with object points
%     Measured out of point on finger/thumb

global bDraw;

dists = zeros(1,3);

if bDraw == true
    clf
    plot3( objPointsAndNorms(:,1), objPointsAndNorms(:,2), objPointsAndNorms(:,3), '.b');
    hold on;
end

% Rotate so x is x axis, etc
% Clip to height in Y
[ idsInPlane, objPointsOriented ] = PlaneThroughHand( ptCenter, vecX, vecY, vecZ, objPointsAndNorms, height );

% Clip to width of contact area
idsInFrontOfPoints = abs( objPointsOriented(:, 1) ) < width;

if sum( idsInFrontOfPoints & idsInPlane ) == 0 
    dists = [10000, 1, 10];
else
    % Do distances in z (palm normal)
    dists(1) = min( objPointsOriented(idsInFrontOfPoints & idsInPlane, 3) );

    idsForNorm = idsInPlane & idsInFrontOfPoints & objPointsOriented(:,3) <= dists(1) + width;
    % Already set to be z axis, so dot product is just z value
    dDotAvg = objPointsOriented( idsForNorm, 6);
    dists(2:3) = [ mean( dDotAvg ), std( dDotAvg ) ];

    if bDraw == true
        pts = [ptCenter + vecZ * dists(1), ptCenter, ptCenter + vecX * width, ptCenter, ptCenter + vecY * height];
        objPts = objPointsAndNorms( idsInPlane & idsInFrontOfPoints, 1:3 );
        plot3( objPts(:, 1), objPts(:, 2), objPts(:, 3), 'Oy', 'MarkerSize', 15);
        plot3( pts(:,1), pts(:,2), pts(:,3), '*-k', 'MarkerSize', 20);
        pts = objPointsAndNorms( idsForNorm, 1:3 );
        norms = objPointsOriented( idsForNorm, 4:6);
        quiver3( pts(:, 1), pts(:, 2), pts(:, 3), ...
                 norms(:, 1), norms(:, 2), norms(:, 3) );
    end

end
end

