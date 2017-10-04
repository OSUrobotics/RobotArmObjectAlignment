function [ metrics ] = CalcAllMetrics( stlHand, handrep, handWidth, objPoints, height  )
%CalcAllMetrics Summary of this function goes here
%   Detailed explanation goes here

[dMin, dCenter, dWidth, dMax] = DistPalm( stlHand, handrep, handWidth, objPoints, height );

metrics = zeros( 1,4);
metrics(1) = dMin;
metrics(2) = dCenter;
metrics(3) = dWidth;
metrics(4) = dMax;

end

