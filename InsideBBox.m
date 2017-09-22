function [ mask ] = InsideBBox( vs, bbox, scale )
%Determine if the vertices are inside of the bounding box
%   Set scale to be one to just get bbox

    bInside = zeros( size(vs,1), 3 );
    bInside = bInside == 1;
    bboxCenter = 0.5 * (bbox(1,:) + bbox(2,:));
    bboxLeft = bboxCenter - (bbox(2,:) - bbox(1,:)) * 0.5 * scale;
    bboxRight = bboxCenter + (bbox(2,:) - bbox(1,:)) * 0.5 * scale;

    bboxScaled = [bboxLeft; bboxCenter; bboxRight];
%     hold off;
%     plot3(bbox(:,1), bbox(:,2), bbox(:,3), '-Xk');
%     plot3(bboxScaled(:,1), bboxScaled(:,2), bboxScaled(:,3), '-Xr');
%     hold on;
    for k = 1:3
        bInside(:,k) = vs(:,k) >= bboxLeft(k) & vs(:,k) <= bboxRight(k);
%         color = [0 0 0];
%         color(k) = 1;
%         showPointCloud( vs(bInside(:,k),:), color );
%         hold on;
    end

    mask = bInside(:,1) & bInside(:,2) & bInside(:,3);
end

