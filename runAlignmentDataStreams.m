%% Do the initial alignment

addpath('STLRead');
addpath('icp');

dir = '/Users/grimmc/Box Sync/Grasping/In-person studies/';
dir = '/Users/grimmc/Code/DataGrasp/';
study = 'Summer2017';
trial = 'Trial 5';

if ~exist( 'fileNames', 'var' ) || ~exist( 'fileData', 'var' )
    [ fileNames, fileData ] = CreateFileNamesAndData( dir, study, trial );
end

if ~isfield( fileData, 'frameInitial' )
    fileData.frameInitial = ReadFrameData( fileNames, fileData, 29, 2 );
end

for cam = 1:length( fileData.frameInitial.imCamera )
    [fileData.frameInitial.matricsCamera, fileData.xyzCamera] = ...
        AlignTable( fileData.ImageTable, fileData.VerticesTable, ...
                    fileData.frameInitial.imCamera{cam}, ...
                    fileData.frameInitial.uvdCamera{cam}, fileData );
end
