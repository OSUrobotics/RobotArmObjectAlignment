function [ metrics, metricsPalm, metricsFinger, metricsPinch ] = CalcAllMetrics( stlHand, handrep, handWidth, objPoints, objNorms, height  )
%CalcAllMetrics Summary of this function goes here
%   Detailed explanation goes here


% How far out is the min/max extent of the hand wrt the palm
metricsPalm = DistPalm( stlHand, handrep, handWidth, objPoints, objNorms, height );

% Orientation of the closest points wrt the fingers
metricsFinger = DistAllPoints( stlHand, handrep, objPoints, objNorms, height );

metricsPinch = DistFingerTips( stlHand, handrep, handWidth, objPoints, objNorms, height );

mFs = reshape( metricsFinger.dists, [ numel( metricsFinger.dists ), 1 ] );

metrics = struct;
metrics.strLabels = { metricsPalm.strLabels metricsFinger.strLabels metricsPinch.strLabels };
metrics.handWidth = handWidth;
metrics.sliceHeight = height;

metrics.dists =  [ metricsPalm.dists metricsPinch.dists mFs' ];

end

