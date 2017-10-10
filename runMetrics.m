clear;
clc
clf

name = 'handAndArm';
%name = 'handOnly';

dir = '/Users/grimmc/Dropbox/Unity/Meshes/';
dirFrames = '/Users/grimmc/Box Sync/Grasping/In-person studies/Collected data/NRI Study/9-29-17/large_part0_2017-09-29-15-37-17/';
handrep = load( strcat(dir, 'handrep', name, '.mat') );
handrep = handrep.handrep;

% mOrig = stlread( strcat(dir, name, '.stl') );
% RenderSTL( mOrig, 1, false, [0.5 0.5 0.5] );
% hold on
% for k = 1:size(handrep.vIds, 1 )
%     pt = Reconstruct(mOrig, handrep.vIds(k,:), handrep.vBarys(k,:) );
%     plot3( pt(1), pt(2), pt(3), '*g', 'MarkerSize', 20 );
% end

% Check that handrep is good
m = stlread( strcat(dirFrames, 'frame0.stl') );
RenderSTL( m, 1, false, [0.2 0.5 0.5] );
hold on
for k = 1:size(handrep.vIds, 1 )
    pt = Reconstruct(m, handrep.vIds(k,:), handrep.vBarys(k,:) );
    plot3( pt(1), pt(2), pt(3), 'Xb', 'MarkerSize', 20 );
end

pLeft = Reconstruct(m, handrep.vIds(2,:), handrep.vBarys(2,:) );
pRight = Reconstruct(m, handrep.vIds(3,:), handrep.vBarys(3,:) );
vPalm = pRight - pLeft;
handWidth = sqrt( sum(vPalm.^2) ) * 1.5;
handHeight = 0.1 * handWidth;

metrics = ProcessTrajectory( dirFrames, 339, handrep, handWidth, handHeight );

dlmwrite( strcat( dirFrames, 'metrics.csv' ), metrics );
