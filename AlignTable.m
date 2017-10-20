function [ mPCtoGlobal, xyzKinect ] = AlignTable( imTable, verticesTable, imKinect, uvdKinect, fileData )
%AlignTable Align the center of the table with the kinnect image
%   Assumptions: Can see entire table top
%     User clicks points on table in order to establish positioning of
%     table in the image
%     
%   INPUT:
%     imTable: Picture of the table image with the five points identified
%     verticesTable: Location in 3Space of those five points (5X3 matrix)
%     imKinect: Image from the kinect camera
%     pcKinect: point cloud for that image
%
%   OUTPUT:
%      Matrix that takes the point cloud to the table vertices
%      Image of alignment

% the kinect points with big z values are errors; throw out so that you can
% see the useful points
bKeep = abs( uvdKinect(:,3) ) < 2;
uvdKinect = uvdKinect(bKeep, : );

%% Show the actual point cloud (unaliged)
figure(2)
clf;
nRows = 1;
nCols = 2;
subplot( nRows, nCols, 1 );
% If point cloud has color, plot with color
if size(uvdKinect,2) == 3
    showPointCloud(uvdKinect, [1 0 0] );
else
    showPointCloud(uvdKinect(:, 1:3), uvdKinect(:, 4:6) );
end
% Camera 2D view
hold on;
view(2)
xlabel('x');
ylabel('y');
zlabel('z');
axis equal
title('Point cloud, not aligned');

%% Set up to click points
figure(1);
clf;

% The canonical image with the points in order
subplot( nRows, nCols, 1 );
imshow( imTable );
title('Table image');

% The image from the kinect camera
subplot( nRows, nCols, 2 );
imshow( imKinect );
title('Kinect image');

% Now collect points
fprintf('Click the shown Xs in order\n');
%% Note - uncomment to collect real points, otherwise, use saved
%    useful for debugging
global xsSave;
global ysSave;

bDebug = false;
if bDebug == false || size(xsSave, 1) ~= 5
    [xs, ys] = ginput(5);
    xsSave = xs;
    ysSave = ys;
else
    xs = xsSave;
    ys = ysSave;
end

%% Align with found checkerboard points
% Magic command to get the checkerboard
%   imagePoints are the u,v points in the image of the checkerboard
%   boardWidth is the size of the board
%     For indexing purposes, height is in first component, width in second
[checkerBoardPts2D,boardWidth] = detectCheckerboardPoints(imKinect);
boardIndex = @(ix, iy) ix * (boardWidth(1)-1) + iy + 1;


% Draw the found points/checkerboard on top of the image
%  Mark the coordinate system: Blue is x direction, red is y
hold on;
xMid = floor( (boardWidth(2)-1) / 2 ); % Center of checkerboard
yMid = floor( (boardWidth(1)-1) / 2 );
imPtMid = checkerBoardPts2D( boardIndex( xMid, yMid ),: );
imPtMidXIncr = checkerBoardPts2D( boardIndex( xMid+1, yMid ), : ); % One in x
imPtMidYIncr = checkerBoardPts2D( boardIndex( xMid, yMid+1 ), : ); % One in y
plot( [imPtMid(1) imPtMidXIncr(1)], [imPtMid(2) imPtMidXIncr(2)], '-Xb', 'MarkerSize', 15, 'LineWidth', 3 );
plot( [imPtMid(1) imPtMidYIncr(1)], [imPtMid(2) imPtMidYIncr(2)], '-Xr', 'MarkerSize', 15, 'LineWidth', 3 );
% Draw all points on the checkerboard
plot( checkerBoardPts2D(:,1), checkerBoardPts2D(:,2), 'og', 'MarkerSize', 10 );

% For xs, ys, find the corresponding checkerboard point
%   Snap the xs, ys points to the checkerboard
%   Keep index of found point in checkerboard array
bFound = zeros( length(xs), 1 ) == 1;
iIndices = ones( length(xs), 1 );
dLenSq1 = sqrt( sum( (imPtMidXIncr - imPtMid).^2) );
dLenSq2 = sqrt( sum( (imPtMidYIncr - imPtMid).^2) );
dWidthSq = 0.5 * ( dLenSq1 + dLenSq2 );
for k = 1:length(xs)
    dDist = sqrt( (checkerBoardPts2D(:,1) - xs(k)).^2 + (checkerBoardPts2D(:,2) - ys(k)).^2 );
    [dDistClosest, iIndex] = min( dDist );
    if dDistClosest < dWidthSq / 2
        % Save x and y index, and snap the xs, ys to the found points
        bFound(k) = true;
        xs(k) = checkerBoardPts2D(iIndex, 1);
        ys(k) = checkerBoardPts2D(iIndex, 2);
        iIndices(k) = iIndex;
        fprintf('Keep %0.0f dist %0.6f, index %0.0f\n', k, dDistClosest, iIndex);
    end
end
% Plot matched points
plot( xs, ys, '*g', 'MarkerSize', 20 );
plot( xsSave, ysSave, '*b', 'MarkerSize', 15 );

% Now map each point in the checkerboard to a point in the point cloud
%  These are the uvdCheckerBoardPts points
%  Keep the error of the fit
figure(2)
uvdCheckerBoardPts = zeros( size(checkerBoardPts2D, 1), 3 );
errUVDCheckerBoard = zeros( size(checkerBoardPts2D, 1), 1 );
cols = {'-Xr', '-Xg', '-Xb', '-Xk', '-Xy' };
for k = 1:size(checkerBoardPts2D, 1)
    [vIndex, errUVDCheckerBoard(k)] = PixelToPCVertex( checkerBoardPts2D(k,1),checkerBoardPts2D(k,2), imKinect, uvdKinect, cols{mod(k-1,5)+1} );
    uvdCheckerBoardPts(k,:) = uvdKinect( vIndex, 1:3 );
end

subplot( nRows, nCols, 1 );
hold on;
plot3( uvdCheckerBoardPts(:,1), uvdCheckerBoardPts(:,2), uvdCheckerBoardPts(:,3), '-Xk', 'MarkerSize', 20 );

% 3D points marked on the table. Find the rotation/translation that aligns the 3D
% points with the uvd marked
uvdMarked = uvdCheckerBoardPts( iIndices, : );
[ mPCtoGlobal, R, T, S ] = AlignKinectOpenRave( verticesTable, uvdMarked )

% Transform the clicked and all of the kinect points
xyzImagePoints = Move( uvdCheckerBoardPts, mPCtoGlobal );
xyzKinect = Move( uvdKinect, mPCtoGlobal );
xyzMarked = Move( uvdMarked, mPCtoGlobal );

figure(3);
clf
DrawKinectTableAligned( xyzKinect, verticesTable );
hold on
plot3( xyzImagePoints(:,1), xyzImagePoints(:,2), xyzImagePoints(:,3), '*g');
plot3( xyzMarked(:,1), xyzMarked(:,2), xyzMarked(:,3), 'ob', 'MarkerSize', 20);
figure(1);

% At this point the image points should largely be aligned with z at zero
% (the table normal is zero) and the points marching out in x and y
% Vector for marching in the x direction of the checkerboard
count = 0;
vDx = [0 0 0];
vDy = [0 0 0];
for j = -2:2
    for k = -2:2
        vDx = vDx + xyzImagePoints( boardIndex( xMid+j+1, yMid+k ),: ) - xyzImagePoints( boardIndex( xMid+j, yMid+k ),: );
        vDy = vDy + xyzImagePoints( boardIndex( xMid+j, yMid+k+1 ),: ) - xyzImagePoints( boardIndex( xMid+j, yMid+k ),: );
        count = count + 1;
    end
end

% Adjust for rotation of checkerboard in image
vDx = vDx / count;
vDy = vDy / count;
squareSize = 0.5;
if abs( vDx(1) ) > abs( vDx(2) ) && abs( vDy(2) ) > abs( vDy(1) )
    if vDx(1) > 0
        vDx = [squareSize, 0, 0 ];
    else
        vDx = [-squareSize, 0, 0 ];
    end
    if vDy(2) > 0
        vDy = [0, squareSize, 0 ];
    else
        vDy = [0, -squareSize, 0 ];
    end
elseif abs( vDx(1) ) < abs( vDx(2) ) && abs( vDy(2) ) < abs( vDy(1) )
    if vDy(1) > 0
        vDy = [squareSize, 0, 0 ];
    else
        vDy = [-squareSize, 0, 0 ];
    end
    if vDx(2) > 0
        vDx = [0, squareSize, 0 ];
    else
        vDx = [0, -squareSize, 0 ];
    end
else
    fprintf('Err: Not consistent\n');
end

% Make matching table values for the ones that are worth keeping
xyzTable = [];
uvdKinectTable = [];
iMidX = floor( (iIndices(5)-1) / (boardWidth(2)-1) );
iMidY = mod( iIndices(5)-1, boardWidth(2)-1 );
%iCheck = boardIndex(iMidX, iMidY);
for j = 0:boardWidth(2)-2
    for k = 0:boardWidth(1)-2
        iIndx = boardIndex( j, k );
        if errUVDCheckerBoard(iIndx) < 0.0001 && abs( xyzImagePoints( iIndx,3 ) ) < 0.5
            uvdKinectTable = [ uvdKinectTable; uvdCheckerBoardPts(iIndx,:) ];
            xyzTable = [ xyzTable; (j - iMidX) * vDx + (k - iMidY) * vDy + [0 0.25 0] ];
        end
    end
end

% One more time
[ mPCtoGlobal, R, T, S ] = AlignKinectOpenRave( xyzTable, uvdKinectTable )

% Transform the clicked and all of the kinect points
xyzImagePoints = Move( uvdCheckerBoardPts, mPCtoGlobal );
xyzKinect = Move( uvdKinect, mPCtoGlobal );
xyzKinectTable = Move( uvdKinectTable, mPCtoGlobal );

figure(3);
clf
DrawKinectTableAligned( xyzKinect, verticesTable );
figure(2);

% Draw the table with the points
subplot( nRows, nCols, 2 );
DrawTable( fileData );
hold on;
plot3( xyzKinectTable(:,1), xyzKinectTable(:,2), xyzKinectTable(:,3), 'Xg')
RenderSTL( fileData.frameInitial.armSTL, 2, true, [0.5, 0.5, 0.5] );

xMax = max( abs( xyzImagePoints(:,1) ) );
yMax = max( abs( xyzImagePoints(:,2) ) );
idsOnTable = abs( xyzKinect(:,1) ) < xMax & abs( xyzKinect(:,2) ) < yMax & abs( xyzKinect(:,3) ) < 0.5;
xyzOnTable = xyzKinect( idsOnTable, : );

if size(xyzKinect,2) == 3
    showPointCloud(xyzKinect, [1 0 0] );
    showPointCloud(xyzOnTable, [1 0 0] );
else
    showPointCloud(xyzKinect(:, 1:3), xyzKinect(:, 4:6), 'MarkerSize', 10 );
    showPointCloud(xyzOnTable(:, 1:3), xyzOnTable(:, 4:6), 'MarkerSize', 20 );
end
for k = 1:length( xyzKinectTable )
    plot3( [ xyzKinectTable(k,1), xyzTable(k,1) ], ...
           [ xyzKinectTable(k,2), xyzTable(k,2) ], ...
           [ xyzKinectTable(k,3), xyzTable(k,3) ], '-Xk' );
end

view(0, -90)
xlabel('x');
ylabel('y');
zlabel('z');
axis equal
title('Point cloud, aligned');
% Old code for when full checkerboard not there
% xyLoc = [0 4 0 4 2; 0 0 4 4 2];
% bDone = false;
% bSwapXY = false;
% bNegateX = false;
% bNegateY = false;
% for iX = 1:length(bFound)
%     for iY = iX+1:length(bFound)
%         if bFound(iX) && bFound(iY) 
%             fprintf('diff %0.0f,%0.0f  %0.0f %0.0f\n', iX, iY, xyLoc(1,iX) - xyLoc(1,iY), xyLoc(2,iX) - xyLoc(2,iY) );
%             % First see if x and y are swapped
%             ixDiff = ixIndices(iX) - ixIndices(iY);
%             iyDiff = iyIndices(iX) - iyIndices(iY);
%             ixLocDiff = xyLoc(1,iX) - xyLoc(1,iY);
%             iyLocDiff = xyLoc(2,iX) - xyLoc(2,iY);
%             if abs( ixDiff ) == abs( iyDiff )
%                 fprintf('Not using');
%             elseif abs( ixDiff ) == abs( ixLocDiff ) && abs( iyDiff ) == abs( iyLocDiff )
%                 bSwapXY = false;
%                 fprintf('Not swapping x and y\n');
%             else
%                 % Swap x and y
%                 bSwapXY = true;
%                 fprintf('Swapping x and y\n');
%             end
%             
%             if bSwapXY == false
%                 if abs(ixDiff) > 0 && abs(ixLocDiff) > 0 
%                     if ixDiff * ixLocDiff < 0
%                         bNegateX = true;
%                         fprintf('Negate x\n');
%                     else
%                         fprintf('Do not Negate x\n');
%                     end
%                 end
%                 if abs(iyDiff) > 0 && abs(iyLocDiff) > 0 
%                     if iyDiff * iyLocDiff < 0
%                         bNegateY = true;
%                         fprintf('Negate y\n');
%                     else
%                         fprintf('Do not Negate y\n');
%                     end
%                 end
%             else
%                 ixLocDiff = xyLoc(2,iX) - xyLoc(2,iY);
%                 iyLocDiff = xyLoc(1,iX) - xyLoc(1,iY);
%                 if abs(ixDiff) > 0 && abs(ixLocDiff) > 0 
%                     if ixDiff * ixLocDiff < 0
%                         bNegateX = true;
%                         fprintf('Negate x\n');
%                     else
%                         fprintf('Do not Negate x\n');
%                     end
%                 end
%                 if abs(iyDiff) > 0 && abs(iyLocDiff) > 0 
%                     if iyDiff * iyLocDiff < 0
%                         bNegateY = true;
%                         fprintf('Negate y\n');
%                     else
%                         fprintf('Do not Negate y\n');
%                     end
%                 end
%             end
%         end
%     end
% end
% 
% iK = find( bFound );
% iK = iK(1);
% ixIndex = ixIndices(iK);
% iyIndex = iyIndices(iK);
% dX = -0.5;
% dY = -0.5;
% if bNegateX
%     dX = -dX;
% end
% if bNegateY
%     dY = -dY;
% end
% if bSwapXY
%     xLoc = verticesTable(iK,1) - dY * (iyIndex-1);
%     yLoc = verticesTable(iK,2) - dX * ixIndex;
%     dXs = xLoc + (0:boardWidth(2)-2) * dX;
%     dYs = yLoc + (0:boardWidth(1)-2) * dY;
% else
%     xLoc = verticesTable(iK,1) - dX * ixIndex;
%     yLoc = verticesTable(iK,2) - dY * (iyIndex-1);
%     dXs = xLoc + (0:boardWidth(1)-2) * dX;
%     dYs = yLoc + (0:boardWidth(2)-2) * dY;
% end
% [dXX, dYY] = meshgrid( dXs, dYs );
% 
% disp( dXX );
% disp( dYY );
% 
% plot( xs, ys, '-Xr', 'MarkerSize', 20 );


end

