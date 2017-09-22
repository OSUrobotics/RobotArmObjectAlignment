
%% Master alignment

dir = '~/Google Drive/Research/Robot grasp/Grasp capture/Kinect Calibration Samples/';
grasps = [6 7 9];
fname = 'obj6_sub7_grasp6_extreme0_points.xls';

xyzArmAll = [];
xyzKinectAll = [];

% Which columns are which
armRange = 7:9;
kinectRange = 4:6;

clf
% For each grasp
for k = 1:length(grasps)
    fname(16) = num2str(grasps(k));
    
    % Read in the spreadsheet (.xls)
    f = strcat(dir, fname);
    xyz = xlsread( f );
    
    % Get the points from the file
    xyzArm = xyz(:,armRange);
    xyzKinect = xyz(:,kinectRange);
    
    % Calculate the alignment matrix
    [M, R, T, S] = AlignKinectOpenRave(xyzArm, xyzKinect);

    R(3,3)
    T(1:3,4)
    S(1,1)
    
    % Multiply points by matrix
    xyzCheck = M * [xyzKinect'; ones(1,size(xyz,1))];
    xyzBack = xyzCheck(1:3,:)';

    % Draw!
    showPointCloud(xyzArm, [1 0 0]);
    hold on;
    showPointCloud(xyzBack, [0 1 0]);

    % Distance between the arm points and the transformed kinect ones
    score = sum( (xyzArm(:,:)-xyzBack(:,:)).^2, 2 );
    % Draw lines between the points and their pairs
    for l=1:size(xyz,1)
        plot3([xyzArm(l,1),xyzBack(l,1)], ...
              [xyzArm(l,2),xyzBack(l,2)], ...
              [xyzArm(l,3),xyzBack(l,3)], '-k');
        fprintf('%f %f\n', l, score(l));
    end
    
    % Grab the points with good matching scores
    xyzArmAll = [xyzArmAll; xyzArm(score < 0.2,:)];
    xyzKinectAll = [xyzKinectAll; xyzKinect(score < 0.2,:)];
    
end

% Repeat with all points
[M, R, T, S] = AlignKinectOpenRave(xyzArmAll, xyzKinectAll);

R(3,3)
T(1:3,4)
S(1,1)

% Final check
xyzCheck = M * [xyzKinectAll'; ones(1,size(xyzKinectAll,1))];
xyzBack = xyzCheck(1:3,:)';

hold on;
showPointCloud(xyzBack, [0 0 1]);
for l=1:size(xyzArmAll,1)
    plot3([xyzArmAll(l,1),xyzBack(l,1)], ...
          [xyzArmAll(l,2),xyzBack(l,2)], ...
          [xyzArmAll(l,3),xyzBack(l,3)], '-k');
end

% Write out alignment matrix
dlmwrite( strcat(dir, 'MasterMatrix.txt'), M );
