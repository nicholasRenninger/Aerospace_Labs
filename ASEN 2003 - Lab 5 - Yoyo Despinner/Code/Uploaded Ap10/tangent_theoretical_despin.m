function [t, w_t, al_t, L_req, t_req] = tangent_theoretical_despin(I, R, m, w_0);
%ANALYZE Calculates the angular velocity and acceleration of a satellite,
%and tension of the despinner strings as a function of time
%satellite despinner for a tangential release.
%   More info....
%
% Inputs: -Total Moment of inertia of satellite (w/o despinners), I(kg*m^2).
%         -Outer radius of same satellite, R (m).
%         -Mass of each despinner, m (kg).
%         -Initial angular velocity before despinners released, w (rpm)
%         -Total time to compute, t_f
%         -Length of despinner strings, L
% Outputs: -none, but creates graphs
%
% Created by:
% Created on: 3/21
% Last editted: 

%% Convert constants to consistent units, declare other necessary constants
 %coefficient c, describes the angular momentum at initial conditions
c = I/(m*R^2)+1;

%% Calculate required t and L
syms t
w = w_0*((c-w_0^2*t^2)/(c+w_0^2*t^2));
t_req = double(solve(w, t));
t_req = t_req(t_req>0); %t_req returns a negative and positive, extract pos

L_req = w_0*t_req*R;

%% Length with respect to time
t = linspace(0,t_req);
L = w_0*t*R;

%% Angular velocity vs. time, w(t)
w_t = w_0*((c-w_0^2*t.^2)./(c+w_0^2*t.^2));
%w_L = w_0*((c*R.^2-L.^2)/(c*R.^2+L.^2));

%% Angular acceleration, al(pha), vs time, al(t)
%al_L = -4*c*w_0^2.*(L/R)./(c+(L/R).^2).^2;

al_t = -4*c*w_0^3.*t./(c+w_0.^2*t.^2).^2;

%% String Tension vs time, T(t)
%T_L = (-2*I*c*w_0.^2*L/R)/(R*(c+(L/R).^2).^2);

T_t = -2*I*c*w_0.^3*t./(R*(c+w_0.^2*t.^2).^2);

%% Graphs
%al(t)
figure(1)
plot(t, al_t)
xlabel('time (s)')
ylabel('\alpha (rad/s^2)')
title('Yoyo Despinner, tangent release, rpm_i=100rpm')

%w(t)
figure(2)
plot(t, w_t)
xlabel('time (s)')
ylabel('\omega (rad/s)')
title('Yoyo Despinner, tangent release, rpm_i=100rpm')

%T(t)
figure(3)
plot(t,T_t)
xlabel('time (s)')
ylabel('Tension (N)')
title('Yoyo Despinner, tangent release, rpm_i=100rpm')

end

