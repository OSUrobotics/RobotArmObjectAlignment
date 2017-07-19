%% Do the initial alignment

addpath('STLRead');
addpath('icp');

dir = '/Users/grimmc/Box Sync/Grasping/In-person studies/';
study = 'Summer2017';
trial = 'trial1';

if ~exist( 'fileNames', 'var' ) || ~exist( 'fileData', 'var' )
    [ fileNames, fileData ] = CreateFileNamesAndData( dir, study, trial );
end

if ~isfield( fileData, 'frameInitial' )
    fileData.frameInitial = ReadFrameData( fileNames, fileData, 0 );
end

for cam = 1:length( fileData.frameInitial.imCamera )
    [fileData.frameInitial.matricsCamera, fileData.xyzCamera] = ...
        AlignTable( fileData.ImageTable, fileData.VerticesTable, ...
                    fileData.frameInitial.imCamera{cam}, ...
                    fileData.frameInitial.uvdCamera{cam} );
end
