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
al_max = min(al_t);

%find index
[~, idxal] = min(abs(al_t-al_max));

%% String Tension vs time, T(t)
%T_L = (-2*I*c*w_0.^2*L/R)/(R*(c+(L/R).^2).^2);

T_t = -2*I*c*w_0.^3*t./(R*(c+w_0.^2*t.^2).^2);
T_max = max(abs(T_t));

%find index
[~, idxT] = min(T_t-T_max);
%% Graphs
%al(t)
hFig = figure;
    scrz = get(groot, 'ScreenSize');
    set(hFig, 'Position', scrz)
plot(t, al_t)
hold on
plot(t(idxal),al_t(idxal),'o')
xlabel('time (s)')
ylabel('\alpha (rad/s^2)')
title('Yoyo Despinner, tangent release, \alpha rpm_i=100rpm')
legend('\alpha(t)','Max \alpha = 38.2 rad/s^2')
set(gca,'fontsize',24);
% setup and save figure as .pdf
    curr_fig = gcf;
    set(curr_fig, 'PaperOrientation', 'landscape');
    set(curr_fig, 'PaperUnits', 'normalized');
    set(curr_fig, 'PaperPosition', [0 0 1 1]);
    [fid, errmsg] = fopen('al_max.pdf', 'w+');
    if fid < 1 % check if file is already open.
       error('Error Opening File in fopen: \n%s', errmsg); 
    end
    fclose(fid);
    print(gcf, '-dpdf', 'al_max.pdf');
    
%w(t)
hFig = figure;
    scrz = get(groot, 'ScreenSize');
    set(hFig, 'Position', scrz)
plot(t, w_t)
xlabel('time (s)')
ylabel('\omega (rad/s)')
title('Yoyo Despinner, tangent release, \omega rpm_i=100rpm')
set(gca,'fontsize',24);
% setup and save figure as .pdf
    curr_fig = gcf;
    set(curr_fig, 'PaperOrientation', 'landscape');
    set(curr_fig, 'PaperUnits', 'normalized');
    set(curr_fig, 'PaperPosition', [0 0 1 1]);
    [fid, errmsg] = fopen('omega_theor.pdf', 'w+');
    if fid < 1 % check if file is already open.
       error('Error Opening File in fopen: \n%s', errmsg); 
    end
    fclose(fid);
    print(gcf, '-dpdf', 'omega_theor.pdf');
    
%T(t)
hFig = figure;
    scrz = get(groot, 'ScreenSize');
    set(hFig, 'Position', scrz)
plot(t,T_t)
hold on
plot(t(idxT),T_t(idxT),'o')
xlabel('time (s)')
ylabel('Tension (N)')
title('Yoyo Despinner, tangent release, Tension rpm_i=100rpm')
legend('Tension(t)','Max Tension = 8.54 N')
set(gca,'fontsize',24);
% setup and save figure as .pdf
    curr_fig = gcf;
    set(curr_fig, 'PaperOrientation', 'landscape');
    set(curr_fig, 'PaperUnits', 'normalized');
    set(curr_fig, 'PaperPosition', [0 0 1 1]);
    [fid, errmsg] = fopen('Tension_max.pdf', 'w+');
    if fid < 1 % check if file is already open.
       error('Error Opening File in fopen: \n%s', errmsg); 
    end
    fclose(fid);
    print(gcf, '-dpdf', 'Tension_max.pdf');

end

