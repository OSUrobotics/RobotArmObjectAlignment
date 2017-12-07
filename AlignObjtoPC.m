function [ matAdjustObj, stlVsAligned ] = AlignObjtoPC( objSTL, armSTL, handAndWristMask, xyzKinect )
%AlignObjtoPC Move the object stl file to the vertices
%   Essentially ICP 
%
%   Assumptions:
%     Bottom of object is on table
%     Scale of object is correct
%     May need to rotate object
%     Arm is aligned with PC so can remove those
%
%  INPUT:
%    stlIn - the hand/arm stl
%    hand & arm Mask - stl vertices for the hand/arm
%    xyzKinect - the point cloud aligned with the table
%
%  OUTPUT:
%    matAdjustObj - matrix to move the object stl to the point cloud
%    stlVsAligned - move the stl vertices

global dSquareWidth;
dPCOnObj = dSquareWidth * 0.25;

%% First find the point cloud vertices that belong to the object


%% Cull out the stl vertices that are the hand and the arm
bboxHand = [ min( armSTL.vertices(handAndWristMask,:) ); max( armSTL.vertices(handAndWristMask,:) ) ];    

% Get all the vertices that weren't painted
handMask = InsideBBox( armSTL.vertices, bboxHand, 1.01 );

% Put all the point cloud vs into one collection
%   but keep track of which one is which
xyzTrim = [];
whichCam = [];
for cam = 1:length( xyzKinect )
    xyzTrimCam = TrimPC( xyzKinect{cam}, true );
    xyzTrim = [ xyzTrim; xyzTrimCam ];
    whichCam = [ whichCam; zeros( size(xyzTrim,1 ), 1 )+ cam];
end

% All point cloud that might be hand
bBoxHandPC = InsideBBox( xyzTrim(:,1:3), bboxHand, 1.01 );
dSizeBox = sqrt( sum( ( bboxHand(2,:) - bboxHand(1,:) ).^2 ) );
distances = DistPointsToMesh( xyzTrim, bBoxHandPC, armSTL, handMask, 0.1 * dSizeBox, dSizeBox );

% Know table is in meters
bHandPC = distances < dPCOnObj;

%% Translate bottom to best guess of point cloud middle
bPCObj = ~bHandPC;
bboxObj = [ min( objSTL.vertices ); max( objSTL.vertices ) ];    
dSizeObj = sqrt( sum( ( bboxObj(2,:) - bboxObj(1,:) ).^2 ) );
% do twice
for k = 1:2
    xyz = mean( xyzTrim( bPCObj, : ) );

    % best guess which points are not outliers
    bInBox = (sqrt( (xyzTrim(:,1) - xyz(1) ).^2 + (xyzTrim(:,2) - xyz(2) ).^2 ) < dSizeObj);
    bPCObj = ~bHandPC & bInBox';
end

% For ICP
bObjMask = zeros( size( objSTL.vertices,1 ), 1 ) == 0;
ptsResampleObj = GetPtsForICP( objSTL, bObjMask, 20 );
xyzSTLObj = mean( ptsResampleObj );

% Translate obj to center of xy, on top of table
matTrans = eye(4,4);
matTrans(1:2,4) = -xyzSTLObj(1:2) + xyz(1:2);
matTrans(3,4) = -bboxObj(1,3);
vsObj = Move( ptsResampleObj, matTrans );
objSTL.vertices = Move( objSTL.vertices, matTrans );

%% Check
RenderSTL( objSTL, 2, false, [1.0 0.5 0.5] )
hold on;
plot3( vsObj(1,:), vsObj(2,:), vsObj(3,:), '.g');
pcshow( xyzTrim( bPCObj,1:3 ), xyzTrim( bPCObj,4:6 ) );

%% Object
maskObj = zeros( size( objSTL.vertices, 1 ), 1 ) == 0;
distsObj = DistPointsToMesh( xyzTrim, bBoxHandPC, objSTL, maskObj, 0.1 * dSizeBox, dSizeBox );

bIsHand = distances < distsObj & distances < dPCOnObj;
bIsObj = distances > distsObj & distsObj < dPCOnObj;
clf
RenderSTL( armSTL, 2, true, [0.2 0.5 0.5] )
hold on;
pcshow( xyzTrim( bIsHand,1:3 ), xyzTrim( bIsHand,4:6 ) );
plot3( objSTL.vertices(:,1), objSTL.vertices(:,2), objSTL.vertices(:,3), '-r');
pcshow( xyzTrim( bIsObj,1:3 ), xyzTrim( bIsObj,4:6 ), 'MarkerSize', 20 );

fprintf('Aligning\n');
matAdjustSTL = AlignPointClouds( xyzTrim( bIsObj, 1:3 ), vsObj );

end
