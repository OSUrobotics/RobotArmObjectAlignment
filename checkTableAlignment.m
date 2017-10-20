                
% Try out one
global xsSave;
global ysSave;
global bDebug;
global xsSave3D;
global ysSave3D;
global xsSave3DScl;
global ysSave3DScl;

bDebug = true;

xsSaveCam1 = [ 444.4526  374.6344  406.0020  340.2312  393.8597]';
ysSaveCam1 = [ 327.0138  360.4051  293.6225  321.9545  324.9901]';

xsSaveCam23D = [-2.1517   -0.3860   -2.1982   -0.4790   -1.2456];
ysSaveCam23D = [0.1966    0.2663   -1.4297   -1.5227   -0.6631];

xsSave = xsSaveCam1;
ysSave = ysSaveCam1;
xsSave3D = [];
ysSave3D = [];
xsSave3DScl = [];
ysSave3DScl = [];

imTable = fileData.ImageTable;
imKinect = fileData.frameInitial.imCamera{1};
uvdKinect = fileData.frameInitial.uvdCamera{1};
[ checkerBoardPts2D, boardWidth, iIndices ] = AlignTableImage( imTable, imKinect, uvdKinect );

verticesTable = fileData.VerticesTable;
[mat] = AlignTable3D( verticesTable, imKinect, uvdKinect, checkerBoardPts2D, boardWidth, iIndices );

