function [ frame ] = ReadFrameData( fileNames, fileData, frameNumber )
%ReadFrameData Read in one frame of data
%   INPUT:
%     fileNames is the global filename structure created by
%     CreateFileNamesAndData
%     frame is the frame to read in
%   OUTPUT:
%     kinect image, point cloud, and the stl for the arm
%

frame = struct;

frame.frameName = sprintf('%sframe%0.0f', fileNames.dirFrames, frameNumber );
frame.armSTL = stlread( strcat( frame.frameName, '.stl' ) );
frame.imCamera = cell(1,2);
frame.uvdCamera = cell(1,2);
frame.xyzCamera = cell(1,2);
frame.matricesCamera = cell(1,2);
frame.matrixArm = eye(4,4);

for cam = [1,2]
    strName = sprintf( '%s_pc%0.0f.jpg', frame.frameName, cam-1 );
    frame.imCamera{cam} = imread( strName );
    strName = sprintf( '%s_pc%0.0f.csv', frame.frameName, cam-1 );
    frame.uvdCamera{cam} = dlmread( strName );
    frame.xyzCamera{cam} = frame.uvdCamera{cam};
    frame.matricesCamera{cam} = eye(4,4);
end

frame.armSTL.vertices = Move( frame.armSTL.vertices, fileData.armToTableMatrix );
end

