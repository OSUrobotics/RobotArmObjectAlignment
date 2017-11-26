function [ fileNames, fileData ] = CreateFileNamesAndData( dir, studyGen, studyCol, trial, nCameras )
%CreateFileNamesAndData Create a structure with all the needed file names,
%  data
%   INPUT:
%     dir - the home directory to start from
%     studyGen - the directory where to put the generated data
%     studyCol - the directory where the collected/raw data is
%     trial - the trial name
%
%  Data
%    Masks for robot arm vertices (which vertices belong to what parts)
%    Blank camera matrices
%    Where to find the object STLS
%    
%  

fileNames = struct;
fileData = struct;

fileNames.dir = dir;
fileNames.dirCollected = strcat( dir, 'Collected data/', studyCol, '/' );
fileNames.dirAnalyzed = strcat( dir, 'Analyzed data/', studyCol, '/' );
fileNames.dirGenerated = strcat( dir, 'Generated study data/', studyGen, '/' );
fileNames.dirMasks = strcat(fileNames.dirGenerated, 'Masks/');
fileNames.dirObjectSTLS = strcat( fileNames.dirGenerated, 'ObjectSTLs/');
fileNames.dirFrames = strcat( fileNames.dirCollected, trial, '/Frames/' );

fileData.ImageTable = imread( strcat(fileNames.dirGenerated, 'imageTable.png') );
fileData.VerticesTable = dlmread( strcat(fileNames.dirGenerated, 'verticesCheckerboard.csv') );

% File names that are the same for all
fnameRobotHandMask = 'RobotHandArm_hand.txt';
fnameRobotWristMask = 'RobotHandArm_wrist.txt';
fnameRobotArmMask = 'RobotHandArm_arm.txt';
fnameRobotBaseAllMask = 'RobotHandArm_baseAll.txt';
fnameRobotBaseFrontMask = 'RobotHandArm_baseFront.txt';
fnameRobotBaseMask = 'RobotHandArm_base.txt';

mapIds = dlmread( strcat(fileNames.dirMasks, 'mapIds.csv' ) );

mask = dlmread( strcat(fileNames.dirMasks, fnameRobotHandMask ) );
mask = mask == 1;
fileData.handMask = mask(mapIds);
mask = dlmread( strcat(fileNames.dirMasks, fnameRobotWristMask ) );
mask = mask == 1;
fileData.wristMask = mask(mapIds);
mask = dlmread( strcat(fileNames.dirMasks, fnameRobotArmMask ) );
mask = mask == 1;
fileData.armMask = mask(mapIds);
mask = dlmread( strcat(fileNames.dirMasks, fnameRobotBaseAllMask ) );
mask = mask == 1;
fileData.baseAllMask = mask(mapIds);
mask = dlmread( strcat(fileNames.dirMasks, fnameRobotBaseFrontMask ) );
mask = mask == 1;
fileData.baseFrontMask = mask(mapIds);
mask = dlmread( strcat(fileNames.dirMasks, fnameRobotBaseMask ) );
mask = mask == 1;
fileData.baseMask = mask(mapIds);

frame.matricesCamera = cell(1,nCameras);
for cam = 1:nCameras
    frame.matricesCamera{cam} = eye(4,4);
end

% mapIds = zeros( size( stlVs, 1 ), 1 );
% 
% for k = 1:size( stlVs, 1 )
%     dists = (stlVs(k,1) - plyFile(:,1)).^2 + (stlVs(k,2) - plyFile(:,2)).^2 + (stlVs(k,3) - plyFile(:,3)).^2;
%     [dMin, iMin] = min( dists );
%     mapIds(k) = iMin;
% end

end

