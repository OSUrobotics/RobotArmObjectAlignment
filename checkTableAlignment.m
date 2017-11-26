                
% Try out one
global xsSave;
global ysSave;
global bDebug;
global xsSave3D;
global ysSave3D;
global xsSave3DScl;
global ysSave3DScl;

bDebug = true;

cam = 1;
xsSaveCam = [ 444.4526  374.6344  406.0020  340.2312  393.8597; ...
              456.1975  381.7738  416.0323  352.2406  401.8564];
ysSaveCam = [ 335.5090  365.0422  301.2504  329.6023  330.7837; ...
              327.0138  360.4051  293.6225  321.9545  324.9901];
    

xsSaveCam23D = [ -0.0490    0.0152    -0.2036    0.1942];
ysSaveCam23D = [0.0644    0.0522   0.2031   -0.2127];

xsSave = xsSaveCam(cam,:)';
ysSave = ysSaveCam(cam,:)';
if cam == 1
    xsSave3D = xsSaveCam23D(cam,1:2);
    ysSave3D = ysSaveCam23D(cam,1:2);
    xsSave3DScl = xsSaveCam23D(cam,3:4);
    ysSave3DScl = ysSaveCam23D(cam,3:4);
else
xsSave3D = [];
ysSave3D = [];
xsSave3DScl = [];
ysSave3DScl = [];
end

%% Check camera alignment
[ cameras ] = SetCameraParams( cam );

imTable = fileData.ImageTable;
imKinect = fileData.frameCheckerBoard.imCamera{1};
uvdKinect = fileData.frameCheckerBoard.uvdCamera{1};
% the kinect points with big z values are errors; throw out so that you can
% see the useful points
bKeep = abs( uvdKinect(:,3) ) < 2;
uvdKinect = uvdKinect(bKeep, : );

[ checkerBoardPts2D, checkerBoardPts3D, iIndices ] = AlignTableImage( imTable, imKinect, cameras );

verticesTable = fileData.VerticesTable;
[mat, xyzCheck] = AlignTable3D( checkerBoardPts2D, checkerBoardPts3D, iIndices, uvdKinect, cameras, verticesTable );


% Check alignment
depthCam = toStruct( cameras.depthCam );
KDepth = depthCam.IntrinsicMatrix;
%xyKinect = KDepth' * xyKinect';
%xyKinect = xyKinect';
PDepth = [448.0877685546875, 0.0, 236.62889099121094, -0.058705687522888184 ;...
          0.0, 448.0877685546875, 179.5, -0.00016042569768615067 ;...
          0.0, 0.0, 1.0, 0.00042840142850764096];

xyzKinect = PDepth * [ uvdKinect(:,1:3) ones(size(uvdKinect,1),1)]';
xyzKinect = xyzKinect';
xyzKinect(:,1) = xyzKinect(:,1) ./ xyzKinect(:,3);
xyzKinect(:,2) = xyzKinect(:,2) ./ xyzKinect(:,3);
xyzKinect(:,3) = xyzKinect(:,3) ./ xyzKinect(:,3);


figure(1);
clf
subplot(1,2,1);
imshow( imKinect );
hold on;
plot( checkerBoardPts2D(:,1), checkerBoardPts2D(:,2), 'Xg');
subplot(1,2,2);
pcshow( xyzKinect, uvdKinect(:,4:6), 'MarkerSize', 20);
view(0,-90);
hold on;
imageCam = toStruct( cameras.imageCam );
K = imageCam.IntrinsicMatrix;
cbXY = inv(K') * [checkerBoardPts2D ones(size(checkerBoardPts2D,1),1)]';
cbXY = KDepth' * inv(K') * [checkerBoardPts2D ones(size(checkerBoardPts2D,1),1)]';
cbXY = cbXY';
%aRatio = 480/640;
%plot3(cbXY(:,1)-0.5, cbXY(:,2)-0.5 * aRatio, zeros( size(cbXY,1), 1 )+1, 'Xg', 'MarkerSize', 10)
plot3(cbXY(:,1), cbXY(:,2), zeros( size(cbXY,1), 1 )+1, 'Xg', 'MarkerSize', 10)
view(0,-90);
