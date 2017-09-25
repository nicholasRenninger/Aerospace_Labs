function [v_model] = LCSMODEL(r, d, L, theta, w)
    
    %%% [v_mod] = LCSMODEL(r, d, l, theta, w)
    %%%
    %%% Computes the vertical speed of the collar based on the geometry of
    %%% the locamotive, its current angle theta, and the angular velocity
    %%% of the disk.
    %%%       
    %%% Inputs:
    %%%        - r: distance between the origin (rotation axis) and the 
    %%%             attachment point A. [m]
    %%%
    %%%        - d: horizontal distance between the vertical shaft and the 
    %%%             center of the disk. [m]
    %%%
    %%%        - L: length of the connecting bar from A to B. [m]
    %%%
    %%%        - theta: angular position of the disk [deg]
    %%%
    %%%        - w: angular velocity of the disk [rad/s]
    %%%
    %%% Outputs:
    %%%         - v_model: the vertical speed of the collar. [m/s]
    %%%
    %%% Author: Nicholas Renninger
    %%% Date Created: 2/16/17
    %%% Last Modified: 2/20/17
    
    
    %% Implement Model in the most EXCELLENT way
    
    % Calculate the angle between the connecting rod to the vertical shaft
    beta = asind( (d - r .* sind(theta)) ./ L ); % [deg]
    
    % Calculate the linear velocity of the slider
    v_model = -w .* r .* (cosd(theta) .* tand(beta) + sind(theta)); % [m/s]
    
    
    
    
end