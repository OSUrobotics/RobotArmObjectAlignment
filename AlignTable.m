function [ mPCtoGlobal, xyzKinect ] = AlignTable( imTable, imKinect, uvdKinect, cameras, verticesTable )
%AlignTable Align the center of the table with the kinnect image
%   Assumptions: Can see entire table top
%     User clicks points on table in order to establish positioning of
%     table in the image
%     
%   INPUT:
%     imTable: Picture of the table image with the five points identified
%     imKinect: Image from the kinect camera
%     uvdKinect: point cloud for that image
%     cameras : camera parameters
%     verticesTable: Location in 3Space of those five points (5X3 matrix)
%
%   OUTPUT:
%      Matrix that takes the point cloud to the table vertices
%      xyzKinect - Move point cloud

% the kinect points with big z values are errors; throw out so that you can
% see the useful points

[ checkerBoardPts2D, checkerBoardPts3D, iIndices ] = AlignTableImage( imTable, imKinect, cameras );

[mPCtoGlobal, xyzKinect] = AlignTable3D( checkerBoardPts2D, checkerBoardPts3D, iIndices, uvdKinect, cameras, verticesTable );

end

