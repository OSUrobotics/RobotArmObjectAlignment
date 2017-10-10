function [ metrics ] = DistAllPoints( stlHand, handrep, objPoints, objNorms, height )
%DistAllPoints For all hand points, closest distance and norm
%   Rotate object points to origin/point on finger
%     Up is out of palm
%   Clip to points in +- height
%   Find closest, mean, widest (in z) and furthest points
%     Measured out of the palm

global bDraw;

metrics = struct;
metrics.dists = zeros(size( handrep.vIds, 1 ) - 3, 3);
metrics.strLabels = {'Min dist', 'Orientation avg', 'Orientation sd'};

[~, palmNorm] = Reconstruct( stlHand, handrep.vIds(1,:), handrep.vBarys(1,:) );
[ptLeft, ~] = Reconstruct( stlHand, handrep.vIds(2,:), handrep.vBarys(2,:) );
[ptRight, ~] = Reconstruct( stlHand, handrep.vIds(3,:), handrep.vBarys(3,:) );

% left and right palm are perpendicular to thumb-finger
% so vecY is out of grasp
vecYOut = ptRight - ptLeft;

metrics.sliceWidth = sqrt( sum( (ptRight - ptLeft).^2) );

if bDraw == true
    RenderSTL( stlHand, 1, false, [0.5 0.5 0.5] );
    hold on;

    pts = zeros( size( handrep.vIds,1 ), 3 );
    norms = pts;
    for k = 1:size( handrep.vIds, 1 )
        [ptCenter, ptNorm] = Reconstruct( stlHand, handrep.vIds(k,:), handrep.vBarys(k,:) );
        pts(k,:) = ptCenter;
        norms(k,:) = ptNorm;
    end
    quiver3( pts(:,1), pts(:,2), pts(:,3), norms(:,1), norms(:,2), norms(:,3) );
    pts = [ ptLeft ptRight ];
    plot3( pts(:,1), pts(:,2),pts(:,3), '-r');
end

for k = 4:size( handrep.vIds, 1 )
    [ptCenter, ptNorm] = Reconstruct( stlHand, handrep.vIds(k,:), handrep.vBarys(k,:) );

    vecZ = ptNorm ./ sqrt( sum(palmNorm.^2) );
    vecX = cross( vecYOut, vecZ );

    % Ensure orthonormal
    vecY = cross( vecZ, vecX );

    % ensure unit
    vecX = vecX ./ sqrt( sum(vecX .* vecX) );
    vecY = vecY ./ sqrt( sum(vecY.^2) );
    vecZ = vecZ ./ sqrt( sum(vecZ .* vecZ) );
    
    metrics.dists(k-3,:) = DistPoint( ptCenter, vecX, vecY, vecZ, [objPoints objNorms], height, metrics.sliceWidth );
end

end