function [ checkerBoardPts2D, boardWidth, iIndices ] = AlignTableImage( imTable, imKinect, uvdKinect )
%AlignTablImage Align the center of the table with the kinnect image
%   Assumptions: Can see entire table top
%     User clicks points on table in order to establish positioning of
%     table in the image
%     
%   INPUT:
%     imTable: Picture of the table image with the five points identified
%     imKinect: Image from the kinect camera
%     uvdKinect: point cloud for that image
%
%   OUTPUT:
%      checkerBoardPts2D - the 2D image points of the checkerboard
%      boardWidth - height, width of checkerboard
%      iIndices - indices in the checkerBoardPts cooresponding to the 5
%      alignment points

% the kinect points with big z values are errors; throw out so that you can
% see the useful points
bKeep = abs( uvdKinect(:,3) ) < 2;
uvdKinect = uvdKinect(bKeep, : );

%% Set up to click points
figure(1);
clf;

nRows = 1;
nCols = 3;

% The canonical image with the points in order
subplot( nRows, nCols, 1 );
imshow( imTable );
title('Table image');

% The image from the kinect camera
subplot( nRows, nCols, [2 3] );
imshow( imKinect );
title('Kinect image');

% Now collect points
fprintf('Click the shown Xs in order\n');
%% Note - uncomment to collect real points, otherwise, use saved
%    useful for debugging
global xsSave;
global ysSave;
global bDebug;

bDebug = true;
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


end

