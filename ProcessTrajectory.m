function [ metricsTrajectory ] = ProcessTrajectory( strDirName, nFiles, handrep, handWidth, height )
%ProcessTrajectory Summary of this function goes here
%   Detailed explanation goes here

metricsTrajectory = zeros( nFiles, 4 );
clf
objPoints = dlmread( strcat(strDirName, 'ObjectPts.off') );

matObjAlign = eye(3,3);
matObjAlign( 2,2 ) = cos( pi/2 );
matObjAlign( 3,3 ) = cos( pi/2 );
matObjAlign( 2,3 ) = -sin( pi/2 );
matObjAlign( 3,2 ) = sin( pi/2 );

objPoints = matObjAlign * objPoints';

matObjAlign = eye(3,3);
dAng = -38;
matObjAlign( 1,1 ) = cosd( dAng );
matObjAlign( 2,2 ) = cosd( dAng );
matObjAlign( 1,2 ) = -sind( dAng );
matObjAlign( 2,1 ) = sind( dAng );

objPoints = matObjAlign * objPoints;

objPoints = objPoints';

ptCenter = [-0.7732    0.10392    1.1984];

for k = 1:3
    objPoints(:,k) = objPoints(:,k) + ptCenter(k);
end

for k = 1:nFiles
    handSTL = stlread( strcat( strDirName, 'frame', num2str(k-1), '.stl' ) );

    RenderSTL( handSTL, 1, false, [0.5 0.5 0.5] );
    xlabel('x');
    ylabel('y');
    zlabel('z');
    hold on;
    plot3( objPoints(:,1), objPoints(:,2), objPoints(:,3), '.k');
    metrics = CalcAllMetrics( handSTL, handrep, handWidth, objPoints, height );
    
    metricsTrajectory(k,:) = metrics;
end

end

