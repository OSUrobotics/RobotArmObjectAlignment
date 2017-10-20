%% Do the initial alignment

addpath('STLRead');
addpath('icp');

%dir = '/Users/grimmc/Box Sync/Grasping/In-person studies/';
dir = '/Users/grimmc/Code/DataGrasp/';
studyGen = 'Summer2017';
%trial = 'Trial 5';
studyCol = 'NRI Study';
trial = 'large_part0_2017-09-29-15-37-17';
trial = 'pringles_part0_2017-10-06-11-45-40';

if ~exist( 'fileNames', 'var' ) || ~exist( 'fileData', 'var' )
    [ fileNames, fileData ] = CreateFileNamesAndData( dir, studyGen, studyCol, trial );
end

if ~isfield( fileData, 'frameInitial' )
    fileData.frameInitial = ReadFrameData( fileNames, fileData, 1, 2 );
end

global bDebug;
bDebug = false;
for cam = 1:length( fileData.frameInitial.imCamera )
    [camMatrix, xyzPts] = ...
        AlignTable( fileData.ImageTable, fileData.VerticesTable, ...
                    fileData.frameInitial.imCamera{cam}, ...
                    fileData.frameInitial.uvdCamera{cam} );
    fileData.frameInitial.matricsCamera{cam} = camMatrix;
    fileData.frameInitial.xyzCamera{cam} = xyzPts;
end

save( strcat( fileNames.dirCollected, 'fileData.mat'), 'fileData' );
%% Show result
figure(1);
clf
nRows = 2;
nCols = length( fileData.frameInitial.imCamera );

% The canonical image with the points in order
subplot( nRows, nCols, [1 2] );
imshow( fileData.ImageTable );
title('Table image');

wh = 7 * 0.5;
for cam = 1:length( fileData.frameInitial.imCamera )
    % The image from the kinect camera
    subplot( nRows, nCols, cam + nCols );
    
    DrawKinectTableAligned( fileData.frameInitial.xyzCamera{cam}, fileData.VerticesTable, 7, 0.5 );
end

