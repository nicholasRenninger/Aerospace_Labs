%{
The purpose of this code...

Written by:
Created: 3/21
Last modified:
%}
close all; clear all; clc;

%% Declare constants
%spacecraft constants
I = 165; %lb(m)*in^2, total moment of inertia without despin masses
R = 4.25; %in, outer radius
%convert to metric
I = I*0.000293; %kg*m^2
R = R*0.0254; %(in)*(m/in)=m

%other constants
m = 2*125/1000; %grams*kg/g = kg, 2 despin masses
w_107 = 107*2*pi/60; %rpm*rad/(s/min) = rad/s
w_105 = 105*2*pi/60; %rpm*rad/(s/min) = rad/s
w_100 = 100*2*pi/60; %rpm*rad/(s/min) = rad/s

%% Calculations for tangential release of despinners
% For comparison with w_0 = 107
[t_tan107, w_tan107, al_tan107, L_req107, t_req107] = tangent_theoretical_despin(I, R, m, w_107); %matrix with [t; alpha; omega; Tension]
% For comparison with w_0 = 105
[t_tan105, w_tan105, al_tan105, L_req105, t_req105] = tangent_theoretical_despin(I, R, m, w_105); %matrix with [t; alpha; omega; Tension]
% For comparison with w_0 = 100
[t_tan100, w_tan100, al_tan100, L_req100, t_req100] = tangent_theoretical_despin(I, R, m, w_100); %matrix with [t; alpha; omega; Tension]

%% Calculations for radial release required length
[L_req_rad107, w_rad107, t_rad107] = despinner_radial(I, R, m, w_107);
[L_req_rad105, w_rad105, t_rad105] = despinner_radial(I, R, m, w_105);
[L_req_rad100, w_rad100, t_rad100] = despinner_radial(I, R, m, w_100);

%% Experimental Data from our group - Long String
[t_exp, w_exp, al_exp] = import_data('data_long_string.txt');

%time offset from data - doesn't despin until ~3s
t_tan107= t_tan107+3;

%With a string length of 13?in (0.3302 m), a tangential release would have released
%at:
t_full_length_13in = 0.3302/w_107/R;
t_full_length_13in = t_full_length_13in +3;

%find index where t_13_5 is closest to t_full_length
[~, idx1] = min(abs(t_exp-t_full_length_13in));

%% Experimental Data - No despin
[t_0in, w_0in, ~] = import_data('110_RPM_NoMass_Lubed.txt');

%% Experimental Data - 13.5 in - Closest length
[t_13_5in, w_13_5in, ~] = import_data('100_RPM_13.5_INCH.txt');

%time offset from data - doesn't despin until ~3s
t_tan100 = t_tan100 +3;

%With a string length of 13.5in (0.3492 m), a tangential release would have released
%at:
t_full_length_13_5in = 0.3429/w_100/R;
t_full_length_13_5in = t_full_length_13_5in +3;

%find index where t_13_5 is closest to t_full_length
[~, idx] = min(abs(t_13_5in-t_full_length_13_5in));

%% Plots
% experimental w as a function of time for the case without using the
% yo-yodespin mechanism
figure(4)
scatter(t_0in, w_0in,'.')
xlabel('time (s)')
ylabel('\omega (rad/s)')
title('Satellite Spin, no despin mechanism')
axis([3, 16.5, 0, 12])

%Plot omega, experimental vs theoretical, group data
figure(5)
plot(t_tan107, w_tan107)
hold on
plot(t_exp(idx), w_exp(idx),'*')
scatter(t_exp, w_exp)
xlabel('time (s)')
ylabel('\omega (rad/s)')
title('Group XX Data, initial rpm=107') 
legend('Tangential release, theoretical','L_{string, tangent} reached','Radial release, experimental')
axis([2.95, 3.4, -0.5, 12])
hold off

%Plot omega, experimental vs theoretical - Sample data, 13.5in string
figure(6)
plot(t_tan100, w_tan100)
hold on
plot(t_13_5in(idx), w_13_5in(idx),'*')
scatter(t_13_5in, w_13_5in)
xlabel('time (s)')
ylabel('\omega (rad/s)')
title('Class Data, L = 13.5 in, initial rpm = 100') 
legend('Tangential release, theoretical','L_{tangent} reached','Radial release, experimental')
axis([2.9, 3.7, -0.5, 12])
hold off

%{
%Plot omega, experimental vs theoretical - Sample data, 13.6in string
figure(7)
plot(t_tan105, w_tan105)
hold on
plot(t_req105, 0,'*')
plot(t_13_6in, w_13_6in)
xlabel('time (s)')
ylabel('\omega (rad/s)')
title('Class Data, initial rpm=105') 
legend('Tangential release, theoretical','L_{string, tangent} reached','Radial release, experimental')
%axis([2.95, 17, -0.5, 12])
hold off
%}

%alpha plot
figure(10)
plot(t_tan107, al_tan107)
hold on
plot(t_exp, al_exp,'o')
xlabel('time (s)')
ylabel('\alpha (rad/s)')
legend('Tangential release, theoretical','Radial release, experimental')
axis([2.95, 3.4, -50, 50])


