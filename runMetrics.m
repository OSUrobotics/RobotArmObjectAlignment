clear;
clc

dirHome = '~/Code/NRI Study/large_part0_2017-09-29-15-37-17/';

dir = '/Users/grimmc/Dropbox/Unity/Meshes/';
handrep = load( strcat(dir, 'handrep.mat') );
handrep = handrep.handrep;

m = stlread( strcat(dir, 'handOnly.stl') );
pLeft = Reconstruct(m, handrep.vIds(2,:), handrep.vBarys(2,:) );
pRight = Reconstruct(m, handrep.vIds(3,:), handrep.vBarys(3,:) );
vPalm = pRight - pLeft;
handWidth = sqrt( sum(vPalm.^2) ) * 1.5;
handHeight = 0.1 * handWidth;
metrics = ProcessTrajectory( dirHome, 3, handrep, handWidth, handHeight );