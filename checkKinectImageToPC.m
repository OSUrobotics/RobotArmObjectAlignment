imKinect = fileData.frameInitial.imCamera{cam};                    
uvdKinect = fileData.frameInitial.uvdCamera{cam};

figure(1);
clf;

% The image from the kinect camera
imshow( imKinect );
title('Kinect image');

xcheck = [520, 295, 140];
ycheck = [40, 410, 260]; 
uvdcheck = zeros(3, 3);
hold on;
plot( xcheck(1), ycheck(1), '*r', 'MarkerSize', 20 );
plot( xcheck(2), ycheck(2), '*g', 'MarkerSize', 20 );
plot( xcheck(3), ycheck(3), '*b', 'MarkerSize', 20 );

cols = {'-Xr', '-Xg', '-Xb', '-Xk', '-Xy' };

for k = 1:length(xcheck)
    [vIndex, ~] = PixelToPCVertex( xcheck(k),ycheck(k), imKinect, uvdKinect, cols{mod(k-1,5)+1} );
    uvdcheck(k,:) = uvdKinect( vIndex, 1:3 );
end

figure(2)
clf
bKeep = abs( uvdKinect(:,3) ) < 2;
uvdKinect = uvdKinect(bKeep, : );

%% Show the actual point cloud (unaliged)
figure(2)
clf;
showPointCloud(uvdKinect(:, 1:3), uvdKinect(:, 4:6) );

% Camera 2D view
hold on;
view(2)
xlabel('x');
ylabel('y');
zlabel('z');
axis equal
title('Point cloud, not aligned');

plot3( uvdcheck(1,1), uvdcheck(1,2), uvdcheck(1,3), '*r', 'MarkerSize', 20 );
plot3( uvdcheck(2,1), uvdcheck(2,2), uvdcheck(2,3), '*g', 'MarkerSize', 20 );
plot3( uvdcheck(3,1), uvdcheck(3,2), uvdcheck(3,3), '*b', 'MarkerSize', 20 );

