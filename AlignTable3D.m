function [ mPCtoGlobal ] = AlignTable3D( verticesTable, imKinect, uvdKinect, checkerBoardPts2D, boardWidth, iIndices )
%AlignTable3D Align the selected points with the 3D version
%   Assumptions: Can see entire table top
%     The camera calibration is off - but can bracket the checkerboard in
%     the uvd data
%     
%   INPUT:
%     verticesTable: Location in 3Space of those five points (5X3 matrix)
%     imKinect: Image from the kinect camera
%     uvdKinect: point cloud for that image
%     checkerBoardPts2D - image-space locations of checkerboard
%     boardWidth - checkerboard width/height
%     iIndices - the indices of the 5 points in the checkerBoardPts2D
%
%   OUTPUT:
%      Matrix that takes the point cloud to the table vertices

bKeep = abs( uvdKinect(:,3) ) < 2;
uvdKinect = uvdKinect(bKeep, : );


% Now map each point in the checkerboard to a point in the point cloud
%  These are the uvdCheckerBoardPts points
%  Keep the error of the fit
boardIndex = @(ix, iy) ix * (boardWidth(1)-1) + iy + 1;

%% Draw the entire connect image
figure(2)
clf

uvdCheckerBoardPts = zeros( size(checkerBoardPts2D, 1), 3 );
errUVDCheckerBoard = zeros( size(checkerBoardPts2D, 1), 1 );
cols = {'-Xr', '-Xg', '-Xb', '-Xk', '-Xy' };
for k = 1:size(checkerBoardPts2D, 1)
    [vIndex, errUVDCheckerBoard(k)] = PixelToPCVertex( checkerBoardPts2D(k,1),checkerBoardPts2D(k,2), imKinect, uvdKinect, cols{mod(k-1,5)+1} );
    uvdCheckerBoardPts(k,:) = uvdKinect( vIndex, 1:3 );
end

% 3D points marked on the table. Find the rotation/translation that aligns the 3D
% points with the uvd marked
uvdMarked = uvdCheckerBoardPts( iIndices, : );
[ mPCToZFlat, ~, ~, ~ ] = AlignKinectOpenRave( verticesTable, uvdMarked )


% Transform the clicked and all of the kinect points
xyzKinect = Move( uvdKinect, mPCToZFlat );

DrawKinectTableAligned( xyzKinect, verticesTable, 10, 0.5 );

%%%%%%%%%%%%%%%%%%%%%%%%%% fix scale
fprintf('Click diagonal corners\n');
global xsSave3DScl;
global ysSave3DScl;
global bDebug;
if bDebug == false || length(xsSave3DScl) ~= 2
    [xs, ys] = ginput(2);
    xsSave3DScl = xs;
    ysSave3DScl = ys;
else
    xs = xsSave3DScl;
    ys = ysSave3DScl;
end

mSclClick = eye(4,4);
dLenTable = sqrt( 2) * 14 * 0.5;
dScl = dLenTable / sqrt( ( xs(2) - xs(1) )^2 + (ys(2) - ys(1)).^2 );
mSclClick(1,1) = dScl;
mSclClick(2,2) = dScl;
mSclClick(3,3) = dScl;
mPCtoGlobal = mSclClick * mPCToZFlat;
xyzKinect = Move( uvdKinect, mPCtoGlobal );

clf
DrawKinectTableAligned( xyzKinect, verticesTable, 10, 1.0 );

fprintf('Click new point old point\n');
global xsSave3D;
global ysSave3D;
if bDebug == false || length(xsSave3D) ~= 2
    [xs, ys] = ginput(2);
    xsSave3D = xs;
    ysSave3D = ys;
else
    xs = xsSave3D;
    ys = ysSave3D;
end

mAlignClick = eye(4,4);
mAlignClick(1,4) = xs(2) - xs(1);
mAlignClick(2,4) = ys(2) - ys(1);
mPCtoGlobal = mAlignClick * mSclClick * mPCToZFlat;
xyzKinect = Move( uvdKinect, mPCtoGlobal );

figure(3)
clf
DrawKinectTableAligned( xyzKinect, verticesTable, 10, 1.0 );

end

