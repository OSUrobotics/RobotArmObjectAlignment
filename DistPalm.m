function [ dPalm, dCenter, dWidest, dMax ] = DistPalm( stlHand, handrep, handWidth, objPoints, height )
%DistPalm Distance palm metric
%   Rotate object points to origin
%   Clip to points in +- height
%   Find closest, mean, widest (in x) and furthest points
%     Measured out of the palm

% orient 
[ ptCenter, vecX, vecY ] = DistPalmOrientation( stlHand, handrep );
% Clip to height
[ idsInPlane, objPointsOriented ] = PlaneThroughHand( ptCenter, vecX, vecY, objPoints, height );

% Clip to palm width
idsInFrontOfPalm = abs( objPointsOriented(:, 1) ) < (handWidth/2);

dPalm = min( objPointsOriented(idsInFrontOfPalm & idsInPlane, 2) );
dMax = max( objPointsOriented(idsInFrontOfPalm & idsInPlane, 2) );
dCenter = mean( objPointsOriented(idsInFrontOfPalm & idsInPlane, 2) );

% Should replace this with polygon made by fingers, but...
zDivs = linspace( dPalm, dMax, 20 );
xWidth = 0;
for k = 1:length(zDivs)-1
    idsInSlice = idsInPlane & objPointsOriented(:, 2) >= zDivs(k) & ...
                              objPointsOriented(:, 2) <= zDivs(k+1);
    xMin = min( objPointsOriented(idsInSlice,1) );
    xMax = max( objPointsOriented(idsInSlice,1) );
    if xMax - xMin > xWidth
        dWidest = 0.5 * (zDivs(k+1) - zDivs(k));
        xWidth = xMax - xMin;
    end
end

pts = [ptCenter + vecZ * dPalm; ptCenter + vecZ * dCenter; ptCenter + vecZ * dWidest; ptCenter + vecZ * dMax];
plot3( pts(:,1), pts(:,2), pts(:,3), '*-k');
end

