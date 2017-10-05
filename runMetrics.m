clear;
clc

name = 'handAndArm';
%name = 'handOnly';

dir = '/Users/grimmc/Dropbox/Unity/Meshes/';
handrep = load( strcat(dir, 'handrep', name, '.mat') );
handrep = handrep.handrep;

m = stlread( strcat(dir, name, '.stl') );
pLeft = Reconstruct(m, handrep.vIds(2,:), handrep.vBarys(2,:) );
pRight = Reconstruct(m, handrep.vIds(3,:), handrep.vBarys(3,:) );
vPalm = pRight - pLeft;
handWidth = sqrt( sum(vPalm.^2) ) * 1.5;
handHeight = 0.1 * handWidth;

metrics = ProcessTrajectory( dir, 3, handrep, handWidth, handHeight );