%% Show result
figure(1);
clf
nRows = 2;
nCols = length( fileData.frameInitial.imCamera );

% The canonical image with the points in order
subplot( nRows, nCols, 1 );
imshow( fileData.ImageTable );
title('Table image');

subplot( nRows, nCols, 2 );
DrawTable( fileData );
hold on;
RenderSTL( fileData.frameInitial.armSTL, 1, true, [0.5, 0.5, 0.5] );
for cam = 1:length( fileData.frameInitial.imCamera )
    xyzAboveTable = TrimPC( fileData.xyzCamera );
    showPointCloud(xyzAboveTable(:, 1:3), xyzAboveTable(:, 4:6), 'MarkerSize', 10 );
end

wh = 7 * 0.5;
for cam = 1:length( fileData.frameInitial.imCamera )
    % The image from the kinect camera
    subplot( nRows, nCols, cam + nCols );
    
    DrawKinectTableAligned( fileData.xyzCamera, fileData.VerticesTable, 7 );

    xyzKinect = fileData.xyzCamera;
end
    
