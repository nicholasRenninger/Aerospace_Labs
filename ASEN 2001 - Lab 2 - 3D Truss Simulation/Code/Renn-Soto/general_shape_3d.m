%%% Function takes joint locations in x, y, z and plots out the basic
%%% outline of the truss for easier visualization
%%%
%%% input - joints (n x 3) matrix of joint locations in xyz
%%%
%%% Author - Nicholas Renninger 
%%% Last Updated - 10/27/16


function general_shape_3d(joints)
   

    %{
    % joints for LAK group
  
    joints = [0.0   0.0   0.0; ...
            11    0.0   0.0; ...
            0.0   8     0.0; ...
            11    8     0.0; ...
            0.0   8     6.0; ...
            11    8     6.0; ...
            0.0   16    0.0; ...
            11    16    0.0; ...
            0.0   16    12.0; ...
            11    16    12.0; ...
            5.5   22    0.0;];
    %}
    
    figure(2)
    
    x = joints(:, 1);
    y = joints(:, 2);
    z = joints(:, 3);
    
    set(gcf,'Renderer','openGl')
    
    plot3(x, y, z, '.b', 'MarkerSize', 16)
    grid on
    k = boundary(joints, 0);
    hold on
    trisurf(k, x, y, z)

    axis off
    light('Position', [25 25 150]);
    lighting gouraud
    shading faceted

    view(3)
    axis('equal');
    
end