function [matPtCloud, matObj, assignment, distances] = ...
    AlignHandAndObject( stlMeshArm, stlMeshObj, maskHand, maskArm, ...
                        kinectPC )
%AlignHandAndObjec Move both the point cloud and the object
%   Assign point cloud to one or the other and alternate alignment

% First convert the mesh hand into triangles
trisHand = ConvertToTriangles( stlMeshArm, maskHand );
bboxHand = [ min( stlMeshArm.vertices(maskHand,:) ); max( stlMeshArm.vertices(maskHand,:) ) ];    
bboxArm = [ min( stlMeshArm.vertices(maskArm,:) ); max( stlMeshArm.vertices(maskArm,:) ) ];
ptsResampleArm = [ GetPtsForICP( stlMeshArm, maskArm, 60 ); ...
                   GetPtsForICP( stlMeshArm, maskHand, 5 ) ];
ptsResampleObj = GetPtsForICP( stlMeshObj, stlMeshObj.vertices(:,1) > -10, 100 );

% Save for checking
stlMeshObjOrig = stlMeshObj;
kinectPCOrig = kinectPC;

% Will need to move
trisObj = ConvertToTriangles( stlMeshObj, ones(size(stlMeshObj.vertices)));

matPtCloud = eye(4,4);
matObj = eye(4,4);

% Fit the table
% Table points
fprintf('Getting table mask\n');
tableMaskPC = GetTableMask( kinectPC );

% Narrow down during loops
armPerc = [0.8 0.8 0.8];
handPerc = [1.5 1.2 1.1 ];
objPerc = [ 0.9 1.05 1.1 ];
clipPerc = [0.1 0.09 0.08]; % Percentage of bounding box to clip points
for loops = 1:3
    % Bounding box of the object
    bboxObj = [ min( stlMeshObj.vertices ); max( stlMeshObj.vertices ) ];

    % Mask point cloud for hand and object
    handMaskPC = InsideBBox( kinectPC(:, 1:3), bboxHand, handPerc(loops) );
    objMaskPC = InsideBBox( kinectPC(:, 1:3), bboxObj, objPerc(loops) );
    armMaskPC = InsideBBox( kinectPC(:, 1:3), bboxArm, armPerc(loops) );
    armMaskPC = armMaskPC & ~(handMaskPC | objMaskPC);
    
    % After first loop clip the base out
    bboxArm( 2, 1 ) = -0.2;
    bboxArm( 1, 3 ) = 0.1;

    objMaskPC = objMaskPC & ~tableMaskPC;

    % Assign point cloud to the hand or the object
    maskBothPC = handMaskPC | objMaskPC;
    [assignment, distances] = AssignPointsToMesh( kinectPC, maskBothPC,...
                                                  trisHand, trisObj, clipPerc(loops) );

    % First find all the kinect points for the arm and hand
    armMaskPC = (assignment == 1 & handMaskPC) | armMaskPC;    
    switch loops
        case 1
            fprintf('Loop 1: Arm and assigned hand points\n');
            mFixPC = AlignPointClouds( ptsResampleArm, kinectPC( armMaskPC, 1:3 ) );
        case 2
            fprintf('Loop 2: Just hand points\n');
            mFixPC = AlignPointClouds( ptsResampleArm, kinectPC( handMaskPC & assignment == 1, 1:3 ) );
        case 3
            fprintf('Loop 3: Hand points using procrustes\n');
            mFixPC = AlignObjToPointCloud( stlMeshArm, kinectPC( handMaskPC & assignment == 1, 1:3 ) );
    end
    kinectPC = Move( kinectPC, mFixPC );

    % Now move the object - do point cloud and then procrustes
    fprintf('Object to point cloud using icp\n');
    mFixObjICP = AlignPointClouds( kinectPC( assignment == 2, 1:3 ), ptsResampleObj );
    stlMeshObj.vertices = Move( stlMeshObj.vertices, mFixObjICP );
    fprintf('Object to point cloud using procrustes\n');
    mFixObjPROC = AlignObjToPointCloud( stlMeshObj, kinectPC( assignment == 2, 1:3 ) );
    stlMeshObj.vertices = Move( stlMeshObj.vertices, mFixObjPROC );

    % Regenerate
    trisObj = ConvertToTriangles( stlMeshObj, ones(size(stlMeshObj.vertices)));
    ptsResampleObj = GetPtsForICP( stlMeshObj, stlMeshObj.vertices(:,1) > -10, 100 );
    
    %Accumulate matrices
    matObj = mFixObjPROC * mFixObjICP * matObj;
    matPtCloud = mFixPC * matPtCloud;

    % Show the cummulative results
    stlMeshObjMove = stlMeshObjOrig;
    stlMeshObjMove.vertices = Move( stlMeshObjMove.vertices, matObj );
    RenderSTL( stlMeshArm, 7, false, [0.8 0.8 0.2] );
    RenderSTL( stlMeshObjMove, -1, true, [0.2 0.2 0.8] );
    kinectPCMove = Move( kinectPCOrig, matPtCloud );
    showPointCloud( kinectPCMove( armMaskPC & ~ handMaskPC, 1:3 ), [1 0 0] );
    showPointCloud( kinectPCMove( handMaskPC & assignment == 1, 1:3 ), [1 0 1] );
    showPointCloud( kinectPCMove( assignment == 2, 1:3 ), [0 1 0] );
    showPointCloud( kinectPCMove( assignment > 2, 1:3 ), [0.2 0.2 0.2] );

    % Check the icp alignment and masking    
    RenderSTL( stlMeshArm, 6, false, [0.8 0.8 0.2] );
    RenderSTL( stlMeshObj, -1, true, [0.2 0.2 0.8] );
    showPointCloud( kinectPC( armMaskPC & ~ handMaskPC, 1:3 ), [1 0 0] );
    showPointCloud( kinectPC( handMaskPC & assignment == 1, 1:3 ), [1 0 1] );
    showPointCloud( kinectPC( assignment == 2, 1:3 ), [0 1 0] );
    showPointCloud( kinectPCMove( assignment > 2, 1:3 ), [0.2 0.2 0.2] );
    showPointCloud( ptsResampleObj, [0.5 0.5 0.5] );
                                              
end

