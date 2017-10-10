function [ metricsTrajectory ] = ProcessTrajectory( strDirName, nFiles, handrep, handWidth, height )
%ProcessTrajectory Summary of this function goes here
%   Detailed explanation goes here

global bDraw;
metricsTrajectory = zeros( nFiles, 4 );

if bDraw == true
    clf
end

objPointsAndNormals = dlmread( strcat(strDirName, 'Object_PtsNorms.txt') );
objPoints = objPointsAndNormals(:,1:3);
objNorms = objPointsAndNormals(:,4:6);

%-48 -90 90

matRotX = eye(3,3);
dAng = -48;
matRotX( 2,2 ) = cosd( dAng );
matRotX( 3,3 ) = cosd( dAng );
matRotX( 2,3 ) = -sind( dAng );
matRotX( 3,2 ) = sind( dAng );

matRotY = eye(3,3);
dAng = -90;
matRotY( 1,1 ) = cosd( dAng );
matRotY( 3,3 ) = cosd( dAng );
matRotY( 1,3 ) = -sind( dAng );
matRotY( 3,1 ) = sind( dAng );

matRotZ = eye(3,3);
dAng = 90;
matRotZ( 1,1 ) = cosd( dAng );
matRotZ( 2,2 ) = cosd( dAng );
matRotZ( 1,2 ) = sind( dAng );
matRotZ( 2,1 ) = -sind( dAng );


matRot = matRotY * matRotX * matRotZ;
objPoints = matRot * objPoints';
objNorms = matRot * objNorms';

objPoints = objPoints';
objNorms = objNorms';

ptCenter = [-0.7121   0.012 1.143];

for k = 1:3
    objPoints(:,k) = objPoints(:,k) + ptCenter(k);
end


for k = 1:nFiles
    handSTL = stlread( strcat( strDirName, 'frame', num2str(k-1), '.stl' ) );

    %if bDraw == true

        RenderSTL( handSTL, 1, false, [0.5 0.5 0.5] );
        hold on;
        quiver3( objPoints(:,1), objPoints(:,2), objPoints(:,3), ...
                 objNorms(:,1), objNorms(:,2), objNorms(:,3), '.k');
    %end
    
    % 6, 15x3, 6 = 12 + 45 = 57
    [ metrics, metricsPalm, metricsFinger, metricsPinch ] = ...
        CalcAllMetrics( handSTL, handrep, handWidth, objPoints, objNorms, height );
    
    save( strcat( strDirName, 'metrics', num2str(k-1), '.mat' ), ...
          'metricsPalm', 'metricsFinger', 'metricsPinch' );
      
    if k == 1
        metricsTrajectory = zeros( nFiles, length(metrics.dists) );
    end
    metricsTrajectory(k,:) = metrics.dists;
end

end

