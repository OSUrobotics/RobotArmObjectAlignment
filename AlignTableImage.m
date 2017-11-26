function [ checkerBoardPts2D, checkerBoardPts3D, iIndices ] = AlignTableImage( imTable, imKinect, cameras )
%AlignTableImage Find the checkerboard in the table image
%   Assumptions: Can see entire table top with checkerboard pattern
%     User clicks points on table in order to establish positioning of
%     checkerboard/table in the image
%
%     Align the checkerboard the way we expect, with 0,0 in the middle, the
%     first point clicked being the upper left. Generate the correct 3D
%     points to go with the 2D points (leave the 2D points in the same
%     order)
%     
%   INPUT:
%     imTable: Picture of the ideal table with the five points identified
%     imKinect: Image from the RGB kinect camera
%     cameras: Kinect camera parameters
%
%   OUTPUT:
%      checkerBoardPts2D - the 2D image points of the checkerboard
%      checkerBoardPts3D - x,y,z points on canonical checkerboard
%            Each of these is now ordered correctly
%      iIndices - the clicked 5 points

%% Set up to click points
figure(1);
clf;
set(gcf, 'Position', [40 40 1000 600 ] )

nRows = 1;
nCols = 3;

% The canonical image with the points in order
subplot( nRows, nCols, 1 );
imshow( imTable );
title('Table image');

% Undistort the camera
[imKinectUndistorted,newOrigin] = undistortImage(imKinect, cameras.imageCam,'OutputView','full');

% The image from the kinect camera
subplot( nRows, nCols, [2 3] );
imshow( imKinect );
title('Kinect image');

%% Align with found checkerboard points
% Magic command to get the checkerboard
%   imagePoints are the u,v points in the image of the checkerboard
[checkerBoardPts2D,boardWidth] = detectCheckerboardPoints(imKinectUndistorted);

% Shift by new origin
checkerBoardPts2D = [checkerBoardPts2D(:,1) + newOrigin(1), ...
                     checkerBoardPts2D(:,2) + newOrigin(2)];
                 
%   boardWidth is the size of the board
%     For indexing purposes, height is in first component, width in second
boardIndex = @(ix, iy) ix * (boardWidth(1)-1) + iy + 1;
xIndex = @(index) floor( (index-1) / (boardWidth(1)-1) );
yIndex = @(index) mod( (index-1), (boardWidth(1)-1) );


% Now collect points
fprintf('Click the shown Xs in order\n');
%% Note - uncomment to collect real points, otherwise, use saved
%    useful for debugging
global xsSave;
global ysSave;
global bDebug;

if bDebug == false || size(xsSave, 1) ~= 5
    [xs, ys] = ginput(5);
    xsSave = xs;
    ysSave = ys;
else
    xs = xsSave;
    ys = ysSave;
end


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
    if dDistClosest < dWidthSq
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

%% Now re-order appropriately
xIndices = xIndex( iIndices );
yIndices = yIndex( iIndices );

% indices are a translate then a rotate/swap then a translate
matRot = eye(2);
matRot(1,1) = floor( (xIndices( 2 ) - xIndices(1)) / 4 );
matRot(1,2) = floor( (yIndices( 2 ) - yIndices(1)) / 4 );
matRot(2,1) = floor( (xIndices( 1 ) - xIndices(3)) / 4 );
matRot(2,2) = floor( (yIndices( 1 ) - yIndices(3)) / 4 );

checkerBoardPts3D = zeros( size( checkerBoardPts2D, 1 ), 3 );
global dSquareWidth;
for iX = 0:boardWidth(2)-2
    for iY = 0:boardWidth(1)-2
        iNew = matRot * [iX - xIndices(5); iY - yIndices(5)];
        iIndexBd = boardIndex(iX, iY);
        checkerBoardPts3D( iIndexBd, 1) = iNew(1) * dSquareWidth;
        checkerBoardPts3D( iIndexBd, 2) = iNew(2) * dSquareWidth;
    end
end

end
