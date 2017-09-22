%% Draw the robot arm and/or object and kinect point cloud

clear;
clc;

%dir = '~/Google Drive/Research/Robot grasp/Grasp capture/Kinect Calibration Samples/';
dir = '/Users/grimmc/Code/GraspData/';
fnameBase = 'obj%d_sub%d_grasp%d_%s%d';
grasps = [6 7 9];

%addpath('~/Documents/MATLAB/STLRead');
%addpath('~/Documents/MATLAB/icp');
addpath('STLRead');
addpath('icp');

% Read in kinect point cloud
% Multiply by master matrix to roughly align
% Cull out background points by calculating distance between point cloud
% and stl file (icp might do this)
%   Clip by bounding box of hand first maybe
% Kmeans clustering: Is the point in the point cloud closer to the hand or
% to the object stl
%   Ran icp with object -> distances for point
%                r
%    Assign to closest
%  Cull by color

% object, subject, grasp, # extreme etc
ids = [ 6 1 7 0];
strs = {'extreme'};
for k = 1:length(ids)
    %% Read and clean up data
    % Cycle through the three test arm positions
    fname = sprintf( fnameBase, ids(k,1), ids(k,2), ids(k,3), strs{k}, ids(k,4) );
    [matPC, matObj] = AlignSTLArmKinect( dir, fname, 'CrackerBox.stl' );
end

% Old code for checking master matrix
% Points that were used to make the master matrix
%fnamePickedPts = '_points.xls';
%pickedPts = xlsread( strcat(dir, fnameBase, fnamePickedPts) );
