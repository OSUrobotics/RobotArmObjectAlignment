function [ xyzPCNotTable ] = TrimPC( xyzPCinGlobal )
%TrimPC Trim the point cloud to just the points above the table
%   Take out table pointcloud points as best as possible

% Use four: black, white, object/hand, other
[idX, colClusters] = kmeans( xyzPCinGlobal(:,4:6), 4 );

intensityCol = sum( mean( colClusters ) );
[~,blackId] = min( intensityCol );
[~,whiteId] = max( intensityCol );


isLikelyTable = idX == blackId | idX == whiteId;

isOnTable = xyzPCinGlobal(:,3) < 0.01 | ( xyzPCinGlobal(:,3) < 0.1 & isLikelyTable );
%
tableWidth = 8*0.5;
tableHeight = 8*0.5;
isOffTable = abs( xyzPCinGlobal(:,1) ) > tableWidth | abs( xyzPCinGlobal(:,2) ) > tableHeight;

isObject = ~isOffTable & ~isOnTable;

xyzPCNotTable = xyzPCinGlobal( isObject, : );
end

