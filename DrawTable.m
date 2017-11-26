function [  ] = DrawTable( verticesTable, bFill )
%DrawTable Idealized table
%   Checkboard with colors
%     flat in x,y plane at z = 0
%     -1 to 1 in x,y is the middle four boxes (see ImageTable.png)
%
%   0,0 is middle (picked point 5)
%   1st picked point is upper left (-x, positive y) [brown]
%   2nd picked point is upper right (positive x and y) [cyan]
%
%  Grid size is set in the global variable dSquareWidth
%     1 inch, currently

nBoxesTotal = 15;

global dSquareWidth;

widthBox = dSquareWidth; 
topLeft = [-8 * widthBox, -8 * widthBox];

map = [0 0 0; 255 255 255; 99 94 55; 99 214 210; ...
       217 151 207; 215 120 103; 192 159 253]/255;
colormap(map);

bWhite = true;
col = 0;
dX = dSquareWidth * 0.05;
for xs = 1:nBoxesTotal
    x = topLeft(1) + (xs-1) * widthBox;
    y = topLeft(2);
    for ys = 1:nBoxesTotal+1        
        if bWhite == true 
            col = 2;
        else
            col = 1;
        end
        bWhite = ~bWhite;
        if xs == 7 && ys == 7
            col = 3;
        elseif xs == 9 && ys == 7
            col = 4;
        elseif xs == 7 && ys == 9
            col = 5;
        elseif xs == 10 && ys == 10
            col = 6;
        elseif xs == 8 && ys == 12
            col = 7;
        end
        if ys == 1 || ys == 16
            sclY = 0.5;
        else
            sclY = 1;
        end
        if bFill
            fill3( [x, x+widthBox, x+widthBox, x], ...
                   [y, y, y+widthBox*sclY, y+widthBox*sclY]*-1, ...
                   [0,0,0,0], col );
        else
            plot3( [x+dX, x+widthBox-dX, x+widthBox-dX, x+dX, x+dX], ...
                   [y+dX, y+dX, y+widthBox-dX, y+widthBox-dX, y+dX]*-1, ...
                   [0,0,0,0,0], '-k', 'LineWidth', 1.5, 'Color', map(col,:) );
        end
       hold on;
       
       y = y + widthBox*sclY;
    end
    bWhite = ~bWhite;
end

plot3( verticesTable(:,1), verticesTable(:,2), verticesTable(:,3), 'Xr' );
for k = 1:size( verticesTable, 1 )
    text( verticesTable(k,1), verticesTable(k,2), num2str(k), 'Color', [1 0 1], 'FontSize',18 );
end

xlabel('x'); 
ylabel('y');
zlabel('z');
end
