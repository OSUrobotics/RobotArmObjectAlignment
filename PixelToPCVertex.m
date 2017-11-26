function [ indices, dists ] = PixelToPCVertex( cameras, uvd, ptsRGBImage )
%PixelToPCVertex Convert from a pixel in the image to a vertex index
%   INPUT:
%     cameras - camera from SetCameraParams
%     uvd - kinect point cloud
%     ptsRGBImage - points in RGB image (2D image coords)
%
%   OUTPUT:
%     Best match index
%     Distance in uv


% Project xyz down to uv in depth camera
xyzKinect = cameras.PDepth * [ uvd(:,1:3) ones(size(uvd,1),1)]';
xyzKinect = xyzKinect';
xyzKinect(:,1) = xyzKinect(:,1) ./ xyzKinect(:,3);
xyzKinect(:,2) = xyzKinect(:,2) ./ xyzKinect(:,3);

% Get k matrices for depth and image
depthCam = toStruct( cameras.depthCam );
KDepth = depthCam.IntrinsicMatrix;

imageCam = toStruct( cameras.imageCam );
KImage = imageCam.IntrinsicMatrix;

% Convert input points to depth
cbXYCanonical = inv(KImage') * [ptsRGBImage ones(size(ptsRGBImage,1),1)]';
cbXYDepth = KDepth' * cbXYCanonical;
cbXY = cbXYDepth';

% Find closest point in uvd
indices = ones( 1, size( ptsRGBImage, 1 ) );
dists = ones( 1, size( ptsRGBImage, 1 ) );
for k = 1:size(ptsRGBImage, 1 )
    diff = (xyzKinect(:,1) - cbXY(k,1)).^2 + (xyzKinect(:,2) - cbXY(k,2)).^2;
    [dist, vertexIndex] = min( diff );
    indices(k) = vertexIndex;
    dists(k) = dist;
    fprintf('diff %0.4f, %0.0f\n', dist, vertexIndex);
end

end

