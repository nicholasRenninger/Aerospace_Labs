function [height, time] = findFive(y, tIN)

    %%% function [height, time] = findFive(y, tIN)
    %%%
    %%% Function takes a set of data and returns the data corresponding to
    %%% the first five bounces of the ball.
    %%%
    %%% Inputs: 
    %%%        - y: vector containing the height of the ball as function of
    %%%             the time vector, tIN.
    %%%
    %%%        - tIN: vector containing the times corresponding to the
    %%%               measured values of height, y.
    %%%
    %%% Outputs:
    %%%         - height: vector containing only the peak height of 
    %%%                   the first five bounces.
    %%%
    %%%         - time: vector containing the airborne time of each bounce
    %%%
    %%% Author: Jeffrey Mariner Gonzalez
    %%% Date Created: 2/10/17
    %%% Last Modified: 2/15/17
    
    
    %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %%
    
    % find the max height of first 5 bounces
    PKS = findpeaks(y);
    height = PKS(1:5);
    
    % find when it hits the ground
    updown = max(y) - y;    
    [~, minIDX] = findpeaks(updown);
    
    % find time when it hits the ground
    temp = tIN(minIDX);
    temp = temp(1:6);
    
    % find how long each bounce takes
    for i = 1:5
       time(i) = temp(i+1) - temp(i);
    end
    
end

