function [ M ] = AlignPointClouds( armPts, kinectData )
%Use ICP to align point clouds
%   Eventually will do cluster assignment...

[TR, TT] = icp( armPts', kinectData', ...
                'Matching', 'kDtree' );

matRot = eye(4,4);
matTrans = eye(4,4);
matRot(1:3,1:3) = TR;
matTrans(1:3,4) = TT;
M = matTrans * matRot;

end

