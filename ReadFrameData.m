function [ frame ] = ReadFrameData( fileNames, frameNumber, nCameras, fileData )
%ReadFrameData Read in one frame of data
%   INPUT:
%     fileNames is the global filename structure created by
%         CreateFileNamesAndData
%     frameNumber is the frame to read in
%     nCameras is the number of cameras
%     fileData is needed for the camera matrices (initially identity)
%
%   OUTPUT:
%     kinect image, point cloud, and the stl for the arm
%

frame = struct;

frame.frameName = sprintf('%sframe%0.0f', fileNames.dirFrames, frameNumber );
frame.armSTL = stlread( strcat( frame.frameName, '.stl' ) );
frame.imCamera = cell(1,nCameras);
frame.uvdCamera = cell(1,nCameras);
frame.xyzCamera = cell(1,nCameras);
frame.matrixObj = eye(4,4);

for cam = 1:nCameras
    strName = sprintf( '%s_camera%0.0f.png', frame.frameName, cam );
    frame.imCamera{cam} = imread( strName );
    strName = sprintf( '%s_pc%0.0f.csv', frame.frameName, cam-1 );
    frame.uvdCamera{cam} = dlmread( strName );
    frame.xyzCamera{cam} = Move( frame.uvdCamera{cam}, fileData.cameraMatrix{cam} );
end

end

