function [ tableMaskPC ] = GetTableMask( kinectPC )
%GetTableMask Find the points that belong to the table
%   Essentially fit a plane...

% Eliminate points on table
bboxTable = [-1.5 -0.5 -0.15; -0.5 0.5 -0.05];

tableMaskPC = InsideBBox( kinectPC(:, 1:3), bboxTable, 1.0 );
for loops = 1:2
    tableCenter = mean( kinectPC( tableMaskPC, 1:3) );
    tablePCA = pca( kinectPC( tableMaskPC, 1:3) );
    tableNormal = tablePCA(3,:);

    iCheck = uint32(find( tableMaskPC ) );
    ds = zeros( length(iCheck), 1);
    for k = 1:length(iCheck)
        iPt = iCheck(k);
        d = DistanceToPlane( tableCenter, tableNormal, kinectPC(iPt, 1:3) );
        ds(k) = abs(d);
    end
    
    dPlaneTableEps = 0.8 * mean(ds) + 0.2 * max(ds);
    tableMaskPC( iCheck( ds > dPlaneTableEps ) ) = false;
end

end

