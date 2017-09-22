function [ matrix, xyzKinect ] = AlignTable( imTable, verticesTable, imKinect, uvdKinect, fileData )
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

bKeep = abs( uvdKinect(:,3) ) < 2;
uvdKinect = uvdKinect(bKeep, : );

figure(1);
clf;
nRows = 1;
nCols = 2;

subplot( nRows, nCols, 1 );
imshow( imTable );
title('Table image');

subplot( nRows, nCols, 2 );
imshow( imKinect );
title('Kinect image');

figure(2)
clf;
subplot( nRows, nCols, 1 );
if size(uvdKinect,2) == 3
    showPointCloud(uvdKinect, [1 0 0] );
else
    showPointCloud(uvdKinect(:, 1:3), uvdKinect(:, 4:6) );
end
hold on;
view(0, -90)
xlabel('x');
ylabel('y');
zlabel('z');
axis equal
title('Point cloud, not aligned');

figure(1)
subplot( nRows, nCols, 2 );
fprintf('Click the shown Xs in order\n');
%[xs, ys] = ginput(5);
global xsSave;
global ysSave;
xs = xsSave;
ys = ysSave;

% Align with found checkerboard points
[imagePoints,boardWidth] = detectCheckerboardPoints(imKinect);
dWidthSq = (xs(1) - xs(2)) / 4;

hold on;
xMid = floor( (boardWidth(2)-1) / 2 );
yMid = floor( (boardWidth(1)-1) / 2 );
boardIndex = @(ix, iy) ix * (boardWidth(1)-1) + iy + 1;
imPtMid = imagePoints( boardIndex( xMid, yMid ),: );
imPtMidXIncr = imagePoints( boardIndex( xMid+1, yMid ), : );
imPtMidYIncr = imagePoints( boardIndex( xMid, yMid+1 ), : );
plot( [imPtMid(1) imPtMidXIncr(1)], [imPtMid(2) imPtMidXIncr(2)], '-Xb', 'MarkerSize', 15 );
plot( [imPtMid(1) imPtMidYIncr(1)], [imPtMid(2) imPtMidYIncr(2)], '-Xr', 'MarkerSize', 15 );
plot( imagePoints(:,1), imagePoints(:,2), 'og', 'MarkerSize', 10 );

bFound = zeros( length(xs), 1 ) == 1;
ixIndices = zeros( length(xs), 1 );
iyIndices = zeros( length(xs), 1 );
for k = 1:length(xs)
    dDist = sqrt( (imagePoints(:,1) - xs(k)).^2 + (imagePoints(:,2) - ys(k)).^2 );
    [dDistClosest, iIndex] = min( dDist );
    if dDistClosest < dWidthSq / 2
        bFound(k) = true;
        xs(k) = imagePoints(iIndex, 1);
        ys(k) = imagePoints(iIndex, 2);
        ixIndices(k) = mod( iIndex-1, boardWidth(1)-1 );
        iyIndices(k) = floor( (iIndex-1) / (boardWidth(1)-1) );
        fprintf('Keep %0.0f x %0.0f y %0.0f\n', k, ixIndices(k), iyIndices(k));
    end
end

xyLoc = [0 4 0 4 2; 0 0 4 4 2];
bDone = false;
bSwapXY = false;
bNegateX = false;
bNegateY = false;
for iX = 1:length(bFound)
    for iY = iX+1:length(bFound)
        if bFound(iX) && bFound(iY) 
            fprintf('diff %0.0f,%0.0f  %0.0f %0.0f\n', iX, iY, xyLoc(1,iX) - xyLoc(1,iY), xyLoc(2,iX) - xyLoc(2,iY) );
            % First see if x and y are swapped
            ixDiff = ixIndices(iX) - ixIndices(iY);
            iyDiff = iyIndices(iX) - iyIndices(iY);
            ixLocDiff = xyLoc(1,iX) - xyLoc(1,iY);
            iyLocDiff = xyLoc(2,iX) - xyLoc(2,iY);
            if abs( ixDiff ) == abs( iyDiff )
                fprintf('Not using');
            elseif abs( ixDiff ) == abs( ixLocDiff ) && abs( iyDiff ) == abs( iyLocDiff )
                bSwapXY = false;
                fprintf('Not swapping x and y\n');
            else
                % Swap x and y
                bSwapXY = true;
                fprintf('Swapping x and y\n');
            end
            
            if bSwapXY == false
                if abs(ixDiff) > 0 && abs(ixLocDiff) > 0 
                    if ixDiff * ixLocDiff < 0
                        bNegateX = true;
                        fprintf('Negate x\n');
                    else
                        fprintf('Do not Negate x\n');
                    end
                end
                if abs(iyDiff) > 0 && abs(iyLocDiff) > 0 
                    if iyDiff * iyLocDiff < 0
                        bNegateY = true;
                        fprintf('Negate y\n');
                    else
                        fprintf('Do not Negate y\n');
                    end
                end
            else
                ixLocDiff = xyLoc(2,iX) - xyLoc(2,iY);
                iyLocDiff = xyLoc(1,iX) - xyLoc(1,iY);
                if abs(ixDiff) > 0 && abs(ixLocDiff) > 0 
                    if ixDiff * ixLocDiff < 0
                        bNegateX = true;
                        fprintf('Negate x\n');
                    else
                        fprintf('Do not Negate x\n');
                    end
                end
                if abs(iyDiff) > 0 && abs(iyLocDiff) > 0 
                    if iyDiff * iyLocDiff < 0
                        bNegateY = true;
                        fprintf('Negate y\n');
                    else
                        fprintf('Do not Negate y\n');
                    end
                end
            end
        end
    end
end

iK = find( bFound );
iK = iK(1);
ixIndex = ixIndices(iK);
iyIndex = iyIndices(iK);
dX = -0.5;
dY = -0.5;
if bNegateX
    dX = -dX;
end
if bNegateY
    dY = -dY;
end
if bSwapXY
    xLoc = verticesTable(iK,1) - dY * (iyIndex-1);
    yLoc = verticesTable(iK,2) - dX * ixIndex;
    dXs = xLoc + (0:boardWidth(2)-2) * dX;
    dYs = yLoc + (0:boardWidth(1)-2) * dY;
else
    xLoc = verticesTable(iK,1) - dX * ixIndex;
    yLoc = verticesTable(iK,2) - dY * (iyIndex-1);
    dXs = xLoc + (0:boardWidth(1)-2) * dX;
    dYs = yLoc + (0:boardWidth(2)-2) * dY;
end
[dXX, dYY] = meshgrid( dXs, dYs );

disp( dXX );
disp( dYY );

plot( xs, ys, '-Xr', 'MarkerSize', 20 );

figure(2)
uvdClicked = zeros( size(imagePoints, 1), 3 );
cols = {'-Xr', '-Xg', '-Xb', '-Xk', '-Xy' };
for k = 1:size(imagePoints, 1)
    vIndex = PixelToPCVertex( imagePoints(k,1),imagePoints(k,2), imKinect, uvdKinect, cols{mod(k-1,5)+1} );
    uvdClicked(k,:) = uvdKinect( vIndex, 1:3 );
end
subplot( nRows, nCols, 1 );
hold on;
plot3( uvdClicked(:,1), uvdClicked(:,2), uvdClicked(:,3), '-Xk', 'MarkerSize', 20 );

dXX = reshape( dXX, [size( dXX,1 ) * size( dXX,2 ), 1 ] );
dYY = reshape( dYY, [size( dYY,1 ) * size( dYY,2 ), 1 ] );
vsTable = [dXX dYY zeros( length( dXX ), 1 ) ];
[ matrix, R, T, S ] = AlignKinectOpenRave( vsTable, uvdClicked )

xyzClicked = Move( uvdClicked, matrix );
xyzKinect = Move( uvdKinect, matrix );

subplot( nRows, nCols, 2 );
DrawTable( fileData );
hold on;
plot3( vsTable(:,1), vsTable(:,2), vsTable(:,3), 'Xg')
RenderSTL( fileData.frameInitial.armSTL, 2, true, [0.5, 0.5, 0.5] );

if size(xyzKinect,2) == 3
    showPointCloud(xyzKinect, [1 0 0] );
else
    showPointCloud(xyzKinect(:, 1:3), xyzKinect(:, 4:6), 'MarkerSize', 10 );
end
for k = 1:length( xyzClicked )
    plot3( [ xyzClicked(k,1), vsTable(k,1) ], ...
           [ xyzClicked(k,2), vsTable(k,2) ], ...
           [ xyzClicked(k,3), vsTable(k,3) ], 'Xk' );
end

view(0, -90)
xlabel('x');
ylabel('y');
zlabel('z');
axis equal
title('Point cloud, aligned');
end

