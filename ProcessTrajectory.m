function [ metricsTrajectory ] = ProcessTrajectory( strDirName, nFiles, handrep, handWidth, height )
%ProcessTrajectory Summary of this function goes here
%   Detailed explanation goes here

metricsTrajectory = zeros( nFiles, 4 );
clf
objPoints = dlmread( strcat(strDirName, '/ObjectPts.off') );

for k = 1:nFiles
    handSTL = stlread( strcat( strDirName, 'frame', num2str(k-1), '.stl' ) );

    RenderSTL( handSTL, 1, false, [0.5 0.5 0.5] );
    hold on;
    plot3( objPoints(:,1), objPoints(:,2), objPoints(:,3), '.k');
    metrics = CalcAllMetrics( handSTL, handrep, handWidth, objPoints, height );
    
    metricsTrajectory(k,:) = metrics;
end

end

