function [  ] = DrawKinectTableAligned( xyzKinect, nSquares, dDepthPerc, fileData )
%DrawKinectTableAligned Clip the kinect points and draw with table vs
%marked
%   

global dSquareWidth;

% Give width of squares, depth of table
wh = nSquares * dSquareWidth;
dDepth = dDepthPerc * dSquareWidth;
    
bIsWhite = xyzKinect(:,4) > 0.8 & xyzKinect(:,5) > 0.8 & xyzKinect(:,6) > 0.8;
xyzKinect( bIsWhite, 4 ) = 0.75;
xyzKinect( bIsWhite, 5 ) = 0.75;
xyzKinect( bIsWhite, 6 ) = 0.5;

idsTable = abs( xyzKinect(:,3) ) < dDepth & abs( xyzKinect(:,1) ) < wh & abs( xyzKinect(:,2) ) < wh;
xyzTable = xyzKinect( idsTable,: );

fprintf('Draw table: %0.0f white, %0.0f on table\n', sum(bIsWhite), sum( idsTable ) );

pcshow(xyzTable(:, 1:3), xyzTable(:, 4:6), 'MarkerSize', 20 );

hold on
DrawTable( fileData, false );
xlabel('x');
ylabel('y');
zlabel('z');
view(0, -90)
axis equal

end

