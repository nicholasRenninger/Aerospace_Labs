function [ L_req ] = radial_length( I, R, m, w_0 )
%ANALYZE Calculates required length, L, and deployment time, t of a
%satellite despinner for a radial release.
%   More info if needed....
%
% Inputs: -Total Moment of inertia of satellite (w/o despinners), I(kg*m^2).
%         -Outer radius of same satellite, R (m).
%         -Mass of each despinner, m (kg).
%         -Initial angular velocity before despinners released, w (rpm)
% Outputs: -Required string length, L (m), to stop satellite
%          -time required to stop, t (s)
%          
%
% Created by:
% Created on: 3/21
% Last editted: 

%% Equations
c = I/(m*R^2)+1; %coefficient c, describes the angular momentum at initial conditions

%Length
syms w_f L
w_f = (2*m*R*w_0*sqrt(c)*(R+L)-(I+m*R^2)*w_0)/I == 0;
L_req = double(solve(w_f));


end
