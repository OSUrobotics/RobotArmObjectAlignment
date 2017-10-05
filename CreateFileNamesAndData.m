function [ fileNames, fileData ] = CreateFileNamesAndData( dir, studyGen, studyCol, trial )
%CreateFileNamesAndData Create a structure with all the needed file names,
%  data
%   INPUT:
%     dir - the home directory to start from
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
fnameRobotHandMask = 'robotArmHandMask.txt';
fnameRobotBaseMask = 'robotArmBaseMask.txt';
fnameArmToTable = 'ArmToTableMatrix.csv';

handMask = dlmread( strcat(fileNames.dirMasks, fnameRobotHandMask ) );
fileData.handMask = handMask == 1;
baseMask = dlmread( strcat(fileNames.dirMasks, fnameRobotBaseMask ) );
fileData.baseMask = baseMask == 1;

fileData.armToTableMatrix = dlmread( strcat(fileNames.dirGenerated, fnameArmToTable ) );

end

