function [ xyzOut ] = Move( xyzIn, mat )
%Multiply the matrix by the points (works even if xyzIn has colors)

xyzOut = xyzIn;
xyzOutPts = mat * [xyzIn(:,1:3)'; ones(1,size(xyzIn,1))];
xyzOut(:,1:3) = xyzOutPts(1:3,:)';


end

