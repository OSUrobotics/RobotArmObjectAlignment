function [  ] = RenderSTL( stlMesh, figureNumber, bOverlay, color )
%RenderSTL Make a nice picture of the stl mesh
%   Set figureNumber to -1 to use the current figure
% bOverlay = true means hold on

    if figureNumber ~= -1
        figure( figureNumber );
    end

    if bOverlay
        hold on;
    else
        clf;
    end

    % The model is rendered with a PATCH graphics object. We also add some dynamic
    % lighting, and adjust the material properties to change the specular
    % highlighting.

    patch(stlMesh,'FaceColor',       color, ...
             'EdgeColor',       'none',        ...
             'FaceLighting',    'gouraud',     ...
             'AmbientStrength', 0.15);

    % Add a camera light, and tone down the specular highlighting
    camlight('headlight');
    material('dull');

    % Fix the axes scaling, and set a nice view angle
    axis('image');
    view([-135 35]);
   
    xlabel('x');
    ylabel('y');
    zlabel('z');
end

