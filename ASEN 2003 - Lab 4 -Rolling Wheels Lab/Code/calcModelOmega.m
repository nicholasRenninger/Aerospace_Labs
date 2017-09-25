%% ASEN 2003: Dynamics & Systems - Spring 2017
% Project: Rolling Wheel Lab (#4)
% Project Members:  Joseph Grengs
%                   Kian Tanner
%                   Nicholas Renniger
%
% Function calculates the model omega based on the given values of theta,
% and the chosen model to use to calculate the new omega.
%
% Project Due Date: Thursday, March 16, 2017 @ 4:00p
% MATLAB Code Created on: 03/02/2017
% MATLAB Code last updated on: 03/14/2017

function [ omega ] = calcModelOmega( theta, M, constants, modelUsed )

    %% Function purpose:
    

    Mc = constants(1);               % Mass of cylinder (kg)
    Mta = constants(2);              % Mass of trailing apparatus (kg)
    Mem = constants(3);              % Mass of extra mass (kg)
    Rc = constants(4);               % Radius of cylinder (m)
    Ic = constants(6);               % MOI of cylinder (kg*m^2)
    Beta = constants(7);             % Angle of ramp (radians)
    Rtem = constants(8);             % Radius to extra mass (m)
    Rem = constants(9);              % Radius of extra mass (m)
    g = constants(10);               % Acceleration due to gravity (m/s^2)

    switch modelUsed
        
        % Case 1: Balanced Wheel Analysis (no fudge factor):
        case 1 
            
            Num1 = 2 * (Mc + Mta) * g * Rc .* theta .* sin(Beta);
            Den1 = (Mc + Mta) * Rc^2 + Ic;
            omega(:, 1) = sqrt(Num1 ./ Den1);

            
        % Case 2: Balanced Wheel Analysis (fudge factor added):    
        case 2 
        
            Num2 = 2 .* theta .* (-M + (Mc + Mta) .* g .* Rc .* sin(Beta));
            Den2 = (Mc + Mta) * Rc^2 + Ic;
            omega(:, 1) = sqrt(Num2 ./ Den2);    
    
            
        % Case 3: Unbalanced Wheel Analysis with extra cylinder modeled as
        % point mass for MOI calcs.
        case 3
            
            Num1 = (Mc + Mta) * g * Rc .* theta .* sin(Beta) - ...
            Mem .* g .* Rtem .* (cos(theta + Beta) - cos(Beta)) + ...
            Mem .* g .* Rc .* theta.* sin(Beta) - M .* theta;

            Den1 = 0.5 .* ((Mc + Mta) .* Rc^2 + Mem .*...
                   (Rc^2 + 2 .* Rc .* Rtem .* cos(theta) + Rtem^2) + Ic);
        
            omega(:, 1) = sqrt(Num1 ./ Den1);

            
        % Case 4: Unbalanced Wheel Analysis with extra cylinder modeled as
        % a cylinder for MOI calcs.
        case 4 
            
            Num1 = (Mc + Mta) * g * Rc .* theta .* sin(Beta) - ...
            Mem .* g .* Rtem .* (cos(theta + Beta) - cos(Beta)) + ...
            Mem .* g .* Rc .* theta.* sin(Beta) - M .* theta;

            Den1 = 0.5 .* ((Mc + Mta) .* Rc^2 + Mem .*...
                   (Rc^2 + 2 .* Rc .* Rtem .* cos(theta) + Rtem^2) + ...
                    + Ic + (1/4 * Mem * Rem^2) );
        
            omega(:, 1) = sqrt(Num1 ./ Den1);
    end
    
end