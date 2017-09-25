function radial_analyze_despin(I, R, m, L, w_0, t_f);
%ANALYZE Calculates the angular velocity and acceleration of a satellite,
%and tension of the despinner strings as a function of time
%satellite despinner for a radial release.
%   More info....
%
% Inputs: -Total Moment of inertia of satellite (w/o despinners), I(kg*m^2).
%         -Outer radius of same satellite, R (m).
%         -Mass of each despinner, m (kg).
%         -Initial angular velocity before despinners released, w (rpm)
%         -Total time to compute, t_f
%         -Length of despinner strings, L
% Outputs: -matrix with alpha, omega, and T (angular acceleration, angular 
%               velocity, and string tension) vs t [a, w, T, t]
%
% Created by:
% Created on: 3/21
% Last editted: 

%% Convert constants to consistent units, declare other necessary constants
w_0 = w_0*2*pi/60; %100rpm*(2*pi rad/rot)*(min/60s) = rad/s
t = linspace(1,t_f,200);

%% Angular velocity vs. time, w(t)

%% Angular acceleration, al(pha), vs time, al(t)

%% String Tension vs time, T(t)

%% Prepare data for output
awTt = [al, w, T, t];

end

