function [ mPCtoGlobal, xyzCheck ] = AlignTable3D( checkerBoardPts2D, checkerBoardPts3D, iIndices, uvdKinect, cameras, verticesTable )
%AlignTable3D Align the selected checkerboard with the 3D version
%   Assumptions: Can see entire table top
%     The camera calibration is off - but can bracket the checkerboard in
%     the uvd data
%   
%     Get a rough alignment from fitting the picked points
%     Use that to find the plane of the checkerboard
%        Ensure the normal points up and plane passes through 0,0
%     Fix the translation by having the user pick a new center
%     Fix the rotation by having the user pick two edges
%     Fix the scale by having the user pick the corners
%     
%   INPUT:
%     checkerBoardPts2D - image-space locations of checkerboard
%     checkerBoardPts3D: Location in 3Space of those five points 
%     iIndices - the indices of the 5 points in the checkerBoardPts2D
%     uvdKinect: point cloud for that image
%     cameras - the cameras from SetCameraParams
%     verticesTable - the 5 special points on the table
%
%   OUTPUT:
%      Matrix that takes the point cloud to the table vertices
%      xyzCheck the moved uvdKinect points

%% Draw the entire Kinect image
figure(2)
clf
set(gcf, 'Position', [40 40 1000 600 ] )

%Number of squares
nSquares = floor( sqrt( size(checkerBoardPts2D,1) ) );

% 3D points marked on the table. Find the rotation/translation that aligns the 3D
% points with the uvd marked
% Find in uvd points
[vIndices, ~] = PixelToPCVertex( cameras, uvdKinect, checkerBoardPts2D(iIndices,:) );
uvdMarked = uvdKinect( vIndices, : );
xyzCB = checkerBoardPts3D(iIndices,:);
[ mPCToZFlat, ~, ~, ~ ] = AlignKinectOpenRave( xyzCB, uvdMarked(:,1:3) )

% Transform the clicked and all of the kinect points
xyzKinectCB = Move( uvdKinect, mPCToZFlat );
mPCtoGlobal = mPCToZFlat;

DrawKinectTableAligned( xyzKinectCB, nSquares / 2 + 4, 1.5, verticesTable )

% Fix transform - rotate normal up and center at zero
global dSquareWidth;
pcObj = pointCloud( xyzKinectCB(:,1:3) );
[model,inlierVs,~] = pcfitplane(pcObj, dSquareWidth * 0.5, [0,0,1]);

wh = (nSquares+2) * dSquareWidth * 0.5;
bOnTable = abs( xyzKinectCB( inlierVs,1 ) ) < wh & abs( xyzKinectCB( inlierVs,2 ) ) < wh;
fprintf('Num vs Inliers %0.0f, num on table %0.0f\n', length( inlierVs ), sum(bOnTable) );
fprintf('Depth %0.4f\n', mean( xyzKinectCB(inlierVs,3) ) );
fprintf('Model: ');
disp( model.Parameters );

% Rotation frame
planeNormal = model.Normal;
vecY = cross( planeNormal, [1 0 0] );
vecX = cross( vecY, planeNormal );
vecX = vecX ./ sqrt( sum( vecX.^2) );
vecY = vecY ./ sqrt( sum( vecY.^2) );
dLenNorm = sqrt( sum( planeNormal.^2) );
vecZ = planeNormal ./ dLenNorm;
matRotNormUp = eye(4);
matRotNormUp(1,1:3) = vecX;
matRotNormUp(2,1:3) = vecY;
matRotNormUp(3,1:3) = vecZ;

% translate to origin
xyzOnPlane = xyzKinectCB( inlierVs,: );
dZ = mean( xyzOnPlane( bOnTable, 3 ) );
%d = model.Parameters(4);
transOrig = -dZ;
matShiftOrig = eye(4);
matShiftOrig(1:3,4) = transOrig';

% Move
xyzKinectCBPlane = Move( xyzKinectCB, matRotNormUp * matShiftOrig );
mPCtoGlobal = matRotNormUp * matShiftOrig * mPCtoGlobal;

clf
pcObjAligned = pointCloud( xyzKinectCBPlane(:,1:3) );
[modelAligned,inlierVsAligned,~] = pcfitplane(pcObjAligned, dSquareWidth * 0.5, [0,0,1]);
bOnTable = abs( xyzKinectCBPlane( inlierVsAligned,1 ) ) < wh & abs( xyzKinectCBPlane( inlierVsAligned,2 ) ) < wh;
fprintf('Num vs Inliers %0.0f, num on table %0.0f\n', length( inlierVsAligned ), sum(bOnTable) );
fprintf('Depth %0.4f\n', mean( xyzKinectCBPlane(inlierVsAligned,3) ) );
fprintf('Model aligned: ');
disp( modelAligned.Parameters );
subplot(1,2,1);
DrawKinectTableAligned( xyzKinectCBPlane, nSquares / 2 + 6, 10.5, verticesTable )
subplot(1,2,2);
pcshow( xyzKinectCBPlane(inlierVs,1:3), xyzKinectCBPlane(inlierVs,4:6));

clf
DrawKinectTableAligned( xyzKinectCBPlane, nSquares / 2 + 4, 2.5, verticesTable )

% %% Refit again, this time to the entire checkerboard, but just pts in plane
% ptsPlane = xyzKinectClickAlign(inlierIndices,:);
% [vIndices, dIndices] = PixelToPCVertex( cameras, uvdKinect, checkerBoardPts2D );
% 
% bKeep = dIndices < 0.25 * dSquareWidth;
% matAdjScl = eye(4);
% if sum( bKeep ) > 4
%     ptsKinect = ptsPlane( vIndices( bKeep ), 1:3 );
%     ptsCheckerboard = checkerBoardPts3D( bKeep );
%     [ mPCSclRotXY, ~, ~, ~ ] = AlignKinectOpenRave( ptsCheckerboard, ptsKinect )
%     vecNew = mPCSclRotXY * [ 1 0 ; 0 1; 0 0; 1 1; ];
%     dTheta = -atan2( vecNew(1,2), vecNew(1,1) );
%     dSclX = sum( sqrt( vecNew(1,1:2).^2 ) );
%     dSclY = sum( sqrt( vecNew(2,1:2).^2 ) );
%     dScl = 0.5 * (dSclX * dSclY );
%     matAdjScl(1,1) = cos(dTheta)/dScl;
%     matAdjScl(2,2) = cos(dTheta)/dScl;
%     matAdjScl(3,3) = 1/dScl;
%     matAdjScl(1,2) = sin(-dTheta);
%     matAdjScl(2,1) = sin(dTheta);
% end
% % Move
% xyzKinectChkbd = Move( xyzKinectClickAlign, matAdjScl );
%     
% DrawKinectTableAligned( xyzKinectChkbd, nSquares / 2 + 4, 1.5, verticesTable );

%%%%%%%%%%%%%%%%%%%%%%%%%% fix translate, rotate, scale
global bDebug;
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
xyzKinectClickCentered = Move( xyzKinectCBPlane, mAlignClick );
mPCtoGlobal = mAlignClick * mPCtoGlobal;

clf
DrawKinectTableAligned( xyzKinectClickCentered, nSquares / 2 + 4, 2.5, verticesTable )

% Scale
fprintf('Click diagonal corners\n');
global xsSave3DScl;
global ysSave3DScl;
if bDebug == false || length(xsSave3DScl) ~= 2
    [xs, ys] = ginput(2);
    xsSave3DScl = xs;
    ysSave3DScl = ys;
else
    xs = xsSave3DScl;
    ys = ysSave3DScl;
end

dSquareSize = 0.0254;
mSclClick = eye(4,4);
dLenTable = sqrt( 2) * 14 * dSquareSize;
dScl = dLenTable / sqrt( ( xs(2) - xs(1) )^2 + (ys(2) - ys(1)).^2 );
mSclClick(1,1) = dScl;
mSclClick(2,2) = dScl;
mSclClick(3,3) = dScl;
xyzKinectClickCenterScale = Move( xyzKinectClickCentered, mSclClick );
mPCtoGlobal = mSclClick * mPCtoGlobal;

xyzCheck = Move( uvdKinect, mPCtoGlobal );

clf
DrawKinectTableAligned( xyzCheck, nSquares/ 2 + 2, 1.0, verticesTable );
end

