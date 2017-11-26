function [ xyzPCNotTable, isObject ] = TrimPC( xyzPCinGlobal, bCenterOfTable )
%TrimPC Trim the point cloud to just the points above the table
%   Take out table pointcloud points as best as possible

% Use four: black, white, object/hand, other
%[idX, colClusters] = kmeans( xyzPCinGlobal(:,4:6), 4 );

%intensityCol = mean( colClusters' );
%[~,blackId] = min( intensityCol );
%[~,whiteId] = max( intensityCol );


global dSquareWidth;

if ~exist( 'bCenterOfTable', 'var' )
    bCenterOfTable = false;
end

% Give width of squares, depth of table
nSquares = 8;
if bCenterOfTable
    nSquares = 4;
end
tableWidth = nSquares * dSquareWidth;
tableHeight = nSquares * dSquareWidth;
dDepth = 0.5 * dSquareWidth;

%isLikelyTable = idX == blackId | idX == whiteId;
pcObj = pointCloud( xyzPCinGlobal(:,1:3) );
[~,inlierIndices,~] = pcfitplane(pcObj, dDepth,[0,0,1]);

isOnTable = zeros(size(xyzPCinGlobal,1), 1);
isOnTable(inlierIndices) = 1;
%
isOffTable = abs( xyzPCinGlobal(:,1) ) > tableWidth | abs( xyzPCinGlobal(:,2) ) > tableHeight;
isBelowTable = xyzPCinGlobal(:,3) < 0;

isObject = ~isOffTable & ~isOnTable & ~isBelowTable;

xyzPCNotTable = xyzPCinGlobal( isObject, : );
end

