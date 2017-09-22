function [ vertexIndex ] = PixelToPCVertex( x,y, im, uvd, col )
%PixelToPCVertex Convert from a pixel in the image to a vertex index
%   INPUT:
%     x - x location in pixels OR 0-1
%     y - y location in pixels OR 0-1
%             Assumes indexing from 0
%    im - image

w = size( im, 2 );
h = size( im, 1 );

if size(uvd, 1) == w * h
    if x < 1 && y < 1
        x = round( x ) * w;
        y = round( y ) * h;
    else
        x = round(x);
        y = round(y);
    end

    if x > w-1
        x = w-1;
    end

    if y > h-1
        y = h-1;
    end

    vertexIndex = x * h + y;
    
else
    % convert from image coordinates to -0.5, 0.5
    u = (x ./ w - 0.5);
    v = (y ./ h - 0.5);
    
    % convert from -0.5, -0.5 to -1, 1 in smallest direction (height)
    uScl = u; % * (w/h);
    vScl = v * (h/w);% * 2;
    
    fprintf('u %0.2f v %0.2f ', uScl, vScl );
    % Find closest point in uvd
    diff = (uvd(:,1) - uScl).^2 + (uvd(:,2) - vScl).^2;
    [~, vertexIndex] = min( diff );
    fprintf('diff %0.4f, %0.0f\n', min(diff), vertexIndex);
    plot3( [uScl uScl], [vScl, vScl], [0.5, 1.5], col );
end

end

