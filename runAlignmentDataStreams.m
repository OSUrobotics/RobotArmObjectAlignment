%% Do the initial alignment

addpath('STLRead');
addpath('icp');

dir = '/Users/grimmc/Box Sync/Grasping/In-person studies/';
%dir = '/Users/grimmc/Code/DataGrasp/';
studyGen = 'Summer2017';
%trial = 'Trial 5';
studyCol = 'NRI Study';
trial = 'large_part0_2017-09-29-15-37-17';

if ~exist( 'fileNames', 'var' ) || ~exist( 'fileData', 'var' )
    [ fileNames, fileData ] = CreateFileNamesAndData( dir, studyGen, studyCol, trial );
end

if ~isfield( fileData, 'frameInitial' )
    fileData.frameInitial = ReadFrameData( fileNames, fileData, 1, 2 );
end

for cam = 1:length( fileData.frameInitial.imCamera )
    [fileData.frameInitial.matricsCamera, fileData.xyzCamera] = ...
        AlignTable( fileData.ImageTable, fileData.VerticesTable, ...
                    fileData.frameInitial.imCamera{cam}, ...
                    fileData.frameInitial.uvdCamera{cam}, fileData );
end
