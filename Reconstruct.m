function [ pt, vecN ] = Reconstruct( stlHand, vIds, barys )
%Reconstruct Find the point & normal 
%   Linear combo

pt = zeros(1,3);
vecN = zeros(1,3);
for k = 1:3
    pt = pt + stlHand.vertices( vIds(k), 1:3) .* barys(k);
end

if size( stlHand.vertices, 2 ) == 6
    for k = 1:3
        vecN = vecN + stlHand.vertices( vIds(k), 4:6) .* barys(k);
    end
else
    vecN = cross( stlHand.vertices( vIds(2),:) - stlHand.vertices( vIds(1),:), ...
                  stlHand.vertices( vIds(3),:) - stlHand.vertices( vIds(1),:) );
    vecN = vecN ./ sqrt( sum( vecN.^2 ) );
end


end

