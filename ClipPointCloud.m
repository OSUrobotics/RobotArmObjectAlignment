function [ xyzKinectClipped ] = ClipPointCloud( xyzKinect )
%ClipPointCloud Clip the point cloud to (roughly) points within what should
% be the table
%   Use the xy points that were clicked to clip the volume

bBadX = abs( xyzKinect(:,1) ) > 4.25;
bBadY = abs( xyzKinect(:,2) ) > 4.25;

clipWhite = 0.9;
clipBlack = 0.1;
bWhite = xyzKinect(:, 4) > clipWhite & ...
         xyzKinect(:, 5) > clipWhite & ...
         xyzKinect(:, 6) > clipWhite;

bBlack = xyzKinect(:, 4) < clipBlack & ...
         xyzKinect(:, 5) < clipBlack & ...
         xyzKinect(:, 6) < clipBlack;
     
bBadZ = abs( xyzKinect(:,3) ) > 0.5;

bUse = ~bBadX & ~bBadY & (bWhite | bBlack) & ~bBadZ;

xyzKinectClipped = xyzKinect( bUse, :);
end

