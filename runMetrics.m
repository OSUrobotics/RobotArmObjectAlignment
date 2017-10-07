clear;
clc
clf

name = 'handAndArm';
%name = 'handOnly';

dir = '/Users/grimmc/Dropbox/Unity/Meshes/';
handrep = load( strcat(dir, 'handrep', name, '.mat') );
handrep = handrep.handrep;

m = stlread( strcat(dir, name, '.stl') );
RenderSTL( m, 1, false, [0.5 0.5 0.5] );
hold on
for k = 1:size(handrep.vIds, 1 )
    pt = Reconstruct(m, handrep.vIds(k,:), handrep.vBarys(k,:) );
    plot3( pt(1), pt(2), pt(3), '*g', 'MarkerSize', 20 );
end

m2 = stlread( strcat(dir, 'frame0.stl') );
RenderSTL( m2, 1, true, [0.2 0.5 0.5] );
hold on
for k = 1:size(handrep.vIds, 1 )
    pt = Reconstruct(m2, handrep.vIds(k,:), handrep.vBarys(k,:) );
    plot3( pt(1), pt(2), pt(3), 'Xb', 'MarkerSize', 20 );
end

pLeft = Reconstruct(m, handrep.vIds(2,:), handrep.vBarys(2,:) );
pRight = Reconstruct(m, handrep.vIds(3,:), handrep.vBarys(3,:) );
vPalm = pRight - pLeft;
handWidth = sqrt( sum(vPalm.^2) ) * 1.5;
handHeight = 0.1 * handWidth;

metrics = ProcessTrajectory( dir, 3, handrep, handWidth, handHeight );