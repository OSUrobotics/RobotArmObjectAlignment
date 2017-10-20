function [  ] = DrawKinectTableAligned( xyzKinect, vsTable, nSquares, dDepth )
%DrawKinectTableAligned Clip the kinect points and draw with table vs
%marked
%   

wh = nSquares * 0.5;
    
bIsWhite = xyzKinect(:,4) > 0.8 & xyzKinect(:,5) > 0.8 & xyzKinect(:,6) > 0.8;
xyzKinect( bIsWhite, 4 ) = 0.75;
xyzKinect( bIsWhite, 5 ) = 0.75;
xyzKinect( bIsWhite, 6 ) = 0.5;

idsTable = abs( xyzKinect(:,3) ) < dDepth & abs( xyzKinect(:,1) ) < wh & abs( xyzKinect(:,2) ) < wh;
xyzTable = xyzKinect( idsTable,: );
showPointCloud(xyzTable(:, 1:3), xyzTable(:, 4:6), 'MarkerSize', 20 );

hold on
plot3( vsTable(:,1),vsTable(:,2), vsTable(:,3), ':Xr', 'MarkerSize', 20, 'LineWidth', 2 );
plot3( vsTable(1,1),vsTable(1,2), vsTable(1,3), 'og', 'MarkerSize', 20 );
xlabel('x');
ylabel('y');
zlabel('z');
view(0, -90)
axis equal

end

