function [  ] = DrawTable( fileData )
%DrawTable Idealized table
%   Checkboard with colors
%     flat in x,y plane at z = 0
%     -1 to 1 in x,y is the middle four boxes (see ImageTable.png)


nBoxesTotal = 15;
offsetW = 0;
offsetH = 0.5;

widthBox = 0.5; 
sclY = 1;
topLeft = [-8 * widthBox, -8 * widthBox];

map = [0 0 0; 255 255 255; 99 94 55; 99 214 210; ...
       217 151 207; 215 120 103; 192 159 253]/255;
colormap(map);

bWhite = true;
col = zeros(4, 3);
for xs = 1:15
    x = topLeft(1) + (xs-1) * widthBox;
    y = topLeft(2);
    for ys = 1:16        
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
        fill3( [x, x+widthBox, x+widthBox, x], ...
               [y, y, y+widthBox*sclY, y+widthBox*sclY]*-1, ...
               [0,0,0,0], col );
           %, 'FaceVertexCData', col, 'FaceColor', 'flat' );
       hold on;
       
       y = y + widthBox*sclY;
    end
    bWhite = ~bWhite;
end

plot3( fileData.VerticesTable(:,1), fileData.VerticesTable(:,2), fileData.VerticesTable(:,3), 'Xr' );
for k = 1:size( fileData.VerticesTable, 1 )
    text( fileData.VerticesTable(k,1), fileData.VerticesTable(k,2), num2str(k), 'Color', [0 1 0], 'FontSize',36 );
end

xlabel('x'); 
ylabel('y');
zlabel('z');
end
