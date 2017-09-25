function [theta_exp,w_exp,v_exp] = load_lcs(filename)

    %%% [theta_exp,w_exp,v_exp] = load_lcs(filename)
    %%%
    %%% This function stores the data from a file with an inputted name and
    %%% outputs the values required
    %%%             
    %%% Inputs:
    %%%        - filename: name of the file to load the data from
    %%%
    %%% Outputs:
    %%%        - theta_exp: angular position of the disk [deg]
    %%%
    %%%        - w_exp: angular velocity of the disk [rad/s]
    %%%
    %%%        - v_exp: the vertical speed of the collar. [m/s]
    %%%
    %%% Author: Pierre Guillaud
    %%% Date Created: 2/16/17
    %%% Last Modified: 2/23/17

    % Loads data from file 'filename' using the path 'dir_name'.
    data = load(filename);

    % Sets initial angle to  and adjusts the rest.
    diff = mod(data(1,2),360);
    data(1:end,2) = data(1:end,2) - (data(1,2)-diff);

    % Finds all the data in the first 6 revolutions
    desired_data = find( data(1:end,2) < (6*360 + data(1, 2)) );
    index = desired_data(end)+1;

    % Defines the function outputs
    theta_exp = data(1:index, 2); % theta
    w_exp = data(1:index,4);     % deg/s
    w_exp = w_exp * pi / 180;   % converting to rad/s
    v_exp = data(1:index,5)*0.001;     % m/s

end