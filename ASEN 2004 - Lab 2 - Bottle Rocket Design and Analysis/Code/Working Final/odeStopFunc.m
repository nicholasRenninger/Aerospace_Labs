function [value, isterminal, direction] = odeStopFunc(t, y)

    height_idx = getGlobalHeightIDX;
    
    % Locate the time when height passes through zero in a decreasing
    % direction and stop integration.
    
    value = y(height_idx); % detect when height = 0
    isterminal = 1; % stop the integration
    direction = -1; % negative direction
    
end