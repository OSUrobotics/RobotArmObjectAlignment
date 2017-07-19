function [ matrix, xyzKinect ] = AlignTable( imTable, verticesTable, imKinect, uvdKinect )
%AlignTable Align the center of the table with the kinnect image
%   Align the four points of the plane
%   INPUT:
%     imTable: Picture of the table image with the five points identified
%     verticesTable: Location in 3Space of those five points (5X3 matrix)
%     imKinect: Image from the kinect camera
%     pcKinect: point cloud for that image
%
%   OUTPUT:
%      Matrix that takes the point cloud to the table vertices
%      Image of alignment

nRows = 2;
nCols = 2;

subplot( nRows, nCols, 1 );
imshow( imTable );
title('Table image');

subplot( nRows, nCols, 2 );
imshow( imKinect );
title('Kinect image');

subplot( nRows, nCols, 3 );
showPointCloud(uvdKinect, [1 0 0] );
title('Point cloud, not aligned');

subplot( nRows, nCols, 2 );
fprintf('Click the shown Xs in order\n');
[xs, ys] = ginput(5);

hold on;
plot( xs, ys, '-Xk', 'MarkerSize', 20 );

uvdClicked = zeros( length(xs), 3 );
for k = 1:length(xs)
    vIndex = PixelToPCVertex( xs(k),ys(k), imKinect );
    uvdClicked(k,:) = uvdKinect( vIndex, 1:3 );
end
subplot( nRows, nCols, 3 );
hold on;
plot3( uvdClicked(:,1), uvdClicked(:,2), uvdClicked(:,3), '-Xk', 'MarkerSize', 20 );

[ matrix, R, T, S ] = AlignKinectOpenRave( verticesTable, uvdClicked )

xyzClicked = Move( uvdClicked, matrix );
xyzKinect = Move( uvdKinect, matrix );

subplot( nRows, nCols, 4 );
showPointCloud(xyzKinect, [1 0 0] );
hold on;
for k = 1:length( xyzClicked )
    plot3( [ xyzClicked(k,1), verticesTable(k,1) ], ...
           [ xyzClicked(k,2), verticesTable(k,2) ], ...
           [ xyzClicked(k,3), verticesTable(k,3) ], 'Xk' );
end
DrawTable( fileData );
title('Point cloud, aligned');
end

