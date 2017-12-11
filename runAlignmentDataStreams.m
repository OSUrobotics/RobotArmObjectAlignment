%% Do the initial alignment

addpath('STLRead');
addpath('icp');

%dir = '/Users/grimmc/Box Sync/Grasping/In-person studies/';
dir = '/Users/grimmc/Code/DataGrasp/';
studyGen = 'Summer2017';
%trial = 'Trial 5';
studyCol = 'NRI Study';
studyCol = 'CallibrationTest';
trial = 'large_part0_2017-09-29-15-37-17';
trial = 'pringles_part0_2017-10-06-11-45-40';
trial = 'Checkerboard';
objName = 'PringlesCan.STL';

% Which frames to use to get data
frameCheckerboard = 1;
frameArm = 22;
frameObj = 62;
nCameras = 2;

% Global variables used by the alignment
global dSquareWidth;
dSquareWidth = 0.02; % 1 inch squares on the checkerboard, in Meters
global checkerboardSize;
checkerboardSize = [24 18];

% Actually do the alignment - don't use saved values
global bDebug;
bDebug = false;

%% If the file names haven't been filled in, then fill them in
%   Also gets masks and table image
if ~exist( 'fileNames', 'var' ) || ~exist( 'fileData', 'var' )
    [ fileNames, fileData ] = CreateFileNamesAndData( dir, studyGen, studyCol, trial, nCameras );
end

%% FileData already exists for this data sequence - read in
if exist( strcat( fileNames.dirCollected, 'fileData.mat'), 'file' ) && ~exist( 'fileData', 'var' )
    fileData = load( strcat( fileNames.dirCollected, 'fileData.mat'), 'fileData' );
    fileData = fileData.fileData;
end

%% Read in image, kinect points, stl for frame to get checker board aligned
%  Used to align checkerboard
%  Make the initial matrix that brings the arm to the table
%    Rotate and translate up
if ~isfield( fileData, 'frameCheckerBoard' )
    fileData.frameCheckerBoard = ReadFrameData( fileNames, frameCheckerboard, nCameras, fileData );

    save( strcat( fileNames.dirCollected, 'fileData.mat'), 'fileData' );
end

%% Read in the camera parameters
%  Show the image and the point cloud side-by-side for the initial frame
if ~isfield( fileData, 'cameraParams' )
    fileData.cameraParams = cell(1,nCameras);
    fileData.cameraMatrix = cell(1,nCameras);
    for cam = 1:nCameras
        [fileData.cameraParams{cam}] = SetCameraParams(cam);
        fileData.cameraMatrix{cam} = eye(4);
    end
    
    figure(1);
    set(gcf, 'Position', [40 40 1000 600 ] )
    clf;
    for cam = 1:nCameras
        % Camera image
        subplot(2,2,cam);
        imshow( fileData.frameCheckerBoard.imCamera{cam} );

        % Project point cloud
        z = ones( size( fileData.frameCheckerBoard.uvdCamera{cam}, 1 ), 1 );
        camProj = fileData.cameraParams{cam}.PDepth;
        uvC = camProj * [fileData.frameCheckerBoard.uvdCamera{cam}(:,1:3) z]';
        uvC = uvC';
        uvC(:,1) = uvC(:,1) ./ uvC(:,3);
        uvC(:,2) = uvC(:,2) ./ uvC(:,3);
        uvC(:,3) = uvC(:,3) ./ uvC(:,3);
        subplot(2,2,cam+nCameras);
        xyzMin = min( uvC );
        xyzMax = max( uvC );
        fill3( [xyzMin(1) xyzMax(1) xyzMax(1) xyzMin(1) ], ...
               [xyzMin(2) xyzMin(2) xyzMax(2) xyzMax(2) ], ...
               [0 0 0 0]+10, 'y');
        hold on
        pcshow( uvC, fileData.frameCheckerBoard.uvdCamera{cam}(:,4:6), 'MarkerSize', 20);
        plot3( [xyzMin(1) xyzMax(1) xyzMax(1) xyzMin(1) ], ...
               [xyzMin(2) xyzMin(2) xyzMax(2) xyzMax(2) ], ...
               [0 0 0 0]-10, 'k');
        % Look down at the top
        view(0, -90);
    end
    save( strcat( fileNames.dirCollected, 'fileData.mat'), 'fileData' );
end

%% Align the checkerboard
matIdentity = eye(4,4);
for cam = 1:nCameras
    % Look to see if the matrix has been set or not
    camMatrix = fileData.cameraMatrix{cam};
    if sum( sum( camMatrix == matIdentity ) ) == 16
        [camMatrix, xyzPts] = ...
            AlignTable( fileData.ImageTable, ...
                        fileData.frameCheckerBoard.imCamera{cam}, ...
                        fileData.frameCheckerBoard.uvdCamera{cam}, ...
                        fileData.cameraParams{cam}, ...
                        fileData.VerticesTable );
        fileData.cameraMatrix{cam} = camMatrix;
        fileData.frameCheckerBoard.xyzCamera{cam} = xyzPts;
        
        save( strcat( fileNames.dirCollected, 'fileData.mat'), 'fileData' );
    end
end

%% Now align the arm to the point cloud
%    Need the frame that is the first one the arm is in the image
if ~isfield( fileData, 'frameArm' )
    fileData.frameArm = ReadFrameData( fileNames, frameArm, nCameras, fileData );
    % Get the initial alignment 
    stlArm = fileData.frameArm.armSTL;
    [ fileData.matAlignArmTable, stlArm.vertices ] = AlignArmToTable( fileData.frameArm.armSTL, fileData );

    %% Show original data
    figure(1);
    clf;
    set(gcf, 'Position', [40 40 1000 600 ] )
    width = dSquareWidth * 10;
    xyzKinect = cell( nCameras, 1);
    for cam = 1:nCameras
        % Camera image
        subplot(2,2,cam);
        imshow( fileData.frameArm.imCamera{cam} );
        subplot(2,2,cam+nCameras);
        xyzTrim = fileData.frameArm.xyzCamera{cam};
        xyzTrim = xyzTrim( abs( xyzTrim(:,1) ) < width & abs( xyzTrim(:,2) ) < width, : );
        pcshow( xyzTrim(:, 1:3), xyzTrim(:,4:6), 'MarkerSize', 20);
        view(0,-90);
    end
        
    %% Fit arm
    figure(2);
    clf
    set(gcf, 'Position', [40 40 1000 600 ] )
    [ matAdjustSTL, stlArm.vertices ] = AlignHandSTLtoPC( stlArm, fileData.handMask, fileData.wristMask | fileData.armMask, fileData.frameArm.xyzCamera );
    % Save the matrix adjust
    fileData.matAlignArmTable = matAdjustSTL * fileData.matAlignArmTable;
    
    %% Check it looks ok
    figure(2);
    clf
    DrawTable(fileData.VerticesTable, true);
    hold on;
    RenderSTL( stlArm, 2, true, [0.7 0.7 0.3] );
    for cam = 1:nCameras
        xyzHand = TrimPC(fileData.frameArm.xyzCamera{cam});    
        pcshow(xyzHand(:, 1:3), xyzHand(:, 4:6), 'MarkerSize', 20 );
    end
    save( strcat( fileNames.dirCollected, 'fileData.mat'), 'fileData' );
end


if ~isfield( fileData, 'frameObj' )
    fileData.frameObj = ReadFrameData( fileNames, frameObj, 2, fileData );
    fileData.stlObj = stlread( strcat( fileNames.dirFrames, 'PringlesCan.STL' ) );
    
    % Move the arm
    stlArm = fileData.frameObj.armSTL;
    stlArm.vertices = Move( stlArm.vertices, fileData.matAlignArmTable );
    
    % Rotate the object STL - this will vary by trial
    matRot = eye(4,4);
    matRot(2,2) = cos( pi/2 );
    matRot(3,3) = cos( pi/2 );
    matRot(2,3) = -sin( pi/2 );
    matRot(3,2) = sin( pi/2 );
    matScl = eye(4,4);
    matScl(3,3) = 2;

    stlObj = fileData.stlObj;
    stlObj.vertices = Move( fileData.stlObj.vertices, matScl * matRot );
    
    figure(1);
    clf;
    subplot(1,2,1);
    imshow( fileData.frameObj.imCamera{1} );
    subplot(1,2,2);
    imshow( fileData.frameObj.imCamera{2} );
    
    figure(2);
    [ matAdjustObj, stlVsAligned ] = AlignObjtoPC( stlObj, stlArm, fileData.handMask | fileData.wristMask, fileData.frameObj.xyzCamera );
end


%% Show result
figure(1);
clf
nRows = 2;
nCols = length( fileData.frameCheckerBoard.imCamera );

% The canonical image with the points in order
subplot( nRows, nCols, [1 2] );
imshow( fileData.ImageTable );
title('Table image');

for cam = 1:length( fileData.frameCheckerBoard.imCamera )
    % The image from the kinect camera
    subplot( nRows, nCols, cam + nCols );
    
    DrawKinectTableAligned( fileData.frameCheckerBoard.xyzCamera{cam}, fileData.VerticesTable, 7, 1.0 );
end

