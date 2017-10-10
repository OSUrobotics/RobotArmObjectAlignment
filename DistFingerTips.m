function [ metrics ] = DistFingerTips( stlHand, handrep, handWidth, objPoints, objNorms, height )
%DistFingerTips Distance finger tip metric
%   Take vector between thumb and middle of fingers
%   Measure closest and farthest points
%   Measure contact region normals at those points

global bDraw;

metrics = struct;
metrics.dists = zeros(1,6) + 1000;
metrics.strLabels = {'Min dist thumb', 'Min dist fingers', ...
                     'Thumb ang', 'Thumb ang sd', 'Finger ang', 'Finger ang sd'};

if bDraw == true
    RenderSTL( stlHand, 1, false, [0.5 0.5 0.5] );
    hold on;
end

% orient 
%   Vec X is parallel to palm
%   Vec Y is up out of the grasp
%   Vec Z is palm normal
[ ptCenter, vecX, vecY, vecZ, dFinger ] = DistFingerTipsOrientation( stlHand, handrep );
% Rotate so x is x axis, etc
% Clip to height in Y
[ idsInPlane, objPointsOriented ] = PlaneThroughHand( ptCenter, vecX, vecY, vecZ, [objPoints objNorms], height );

% Clip to thumb width
idsInPinch = abs( objPointsOriented(:, 1) ) < (handWidth/6);

if sum( idsInPlane & idsInPinch ) == 0 
    fprintf('DistFingerTips no ids\n');
else
    % Do distances in z (palm normal)
    dMin = min( objPointsOriented(idsInPinch & idsInPlane, 3) );
    dMax = max( objPointsOriented(idsInPinch & idsInPlane, 3) );

    % Add a bit of wiggle - two fat cones glued together
    dMid = 0.5 * (dMax + dMin);
    dAngLeftPt = atan2( objPointsOriented(:,3), objPointsOriented(:,1) - handWidth/12 );
    dAngRightPt = atan2( objPointsOriented(:,3), objPointsOriented(:,1) + handWidth/12 );
    idsOnLeft = dAngLeftPt <= pi/2 & dAngLeftPt >= pi/2 - pi/16 & objPointsOriented(:,3) < dMid;
    idsOnRight = dAngRightPt >= pi/2 & dAngRightPt <= pi/2 + pi/16 & objPointsOriented(:,3) < dMid;
    idsInPinch = idsInPinch | idsOnLeft | idsOnRight;

    % Shift to finger and point other way
    dAngLeftPt = atan2( -(objPointsOriented(:,3) - dFinger), objPointsOriented(:,1) - handWidth/12 );
    dAngRightPt = atan2( -(objPointsOriented(:,3) - dFinger), objPointsOriented(:,1) + handWidth/12 );
    idsOnLeft = dAngLeftPt <= pi/2 & dAngLeftPt >= pi/2 - pi/16 & -(objPointsOriented(:,3) - dFinger) < dMid;
    idsOnRight = dAngRightPt >= pi/2 & dAngRightPt <= pi/2 + pi/16 & -(objPointsOriented(:,3) - dFinger) < dMid;
    idsInPinch = idsInPinch | idsOnLeft | idsOnRight;

    idsForNormThumb = idsInPlane & idsInPinch & objPointsOriented(:,3) <= dMin + height & objPointsOriented(:,6) < 0;
    idsForNormFingers = idsInPlane & idsInPinch & objPointsOriented(:,3) >= dMax - height & objPointsOriented(:,6) > 0;
    norms = objNorms( idsForNormThumb | idsForNormFingers, :);
    
    metrics.dists(1) = dMin;
    metrics.dists(2) = dMax;
    if sum( idsForNormThumb ) > 0
        metrics.dists(3) = mean( objPointsOriented(idsForNormThumb, 6 ) );
        metrics.dists(4) = std( objPointsOriented(idsForNormThumb, 6 ) );
    else
        metrics.dists(3) = 1;
        metrics.dists(4) = 10;
    end
    
    if sum( idsForNormFingers ) > 0
        metrics.dists(5) = mean( objPointsOriented(idsForNormFingers, 6 ) );
        metrics.dists(6) = std( objPointsOriented(idsForNormFingers, 6 ) );
    else
        metrics.dists(5) = 1;
        metrics.dists(6) = 10;
    end
    
    if bDraw == true
        pts = [ptCenter + vecZ * dMin; ptCenter + vecZ * dMax];
        objPts = objPoints( idsInPlane & idsInPinch, : );
        plot3( objPts(:, 1), objPts(:, 2), objPts(:, 3), 'Oy', 'MarkerSize', 15);
        plot3( pts(:,1), pts(:,2), pts(:,3), '*-k', 'MarkerSize', 20);
        pts = objPoints( idsForNormThumb | idsForNormFingers, : );
        quiver3( pts(:, 1), pts(:, 2), pts(:, 3), ...
                 norms(:, 1), norms(:, 2), norms(:, 3) );
    end
end

end

