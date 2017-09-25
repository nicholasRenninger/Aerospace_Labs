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
w_106 = 106*2*pi/60; %rpm*rad/(s/min) = rad/s
w_102 = 102*2*pi/60; %rpm*rad/(s/min) = rad/s
w_100 = 100*2*pi/60; %rpm*rad/(s/min) = rad/s

%% Calculations for tangential release of despinners
% For comparison with w_0 = 106
[t_tan106, w_tan106, al_tan106, L_req106, t_req106] = tangent_theoretical_despin(I, R, m, w_106); %matrix with [t; alpha; omega; Tension]
% For comparison with w_0 = 102
[t_tan102, w_tan102, al_tan102, L_req102, t_req102] = tangent_theoretical_despin(I, R, m, w_102); %matrix with [t; alpha; omega; Tension]
% For comparison with w_0 = 100
[t_tan100, w_tan100, al_tan100, L_req100, t_req100] = tangent_theoretical_despin(I, R, m, w_100); %matrix with [t; alpha; omega; Tension]

%% Calculations for radial release required length
[L_req_rad105, w_rad106, t_rad106] = despinner_radial(I, R, m, w_106);
[L_req_rad102, w_rad102, t_rad102] = despinner_radial(I, R, m, w_102);
[L_req_rad100, w_rad100, t_rad100] = despinner_radial(I, R, m, w_100);

%% Experimental Data - No despin
[t_0in, w_0in, ~] = import_data('110_RPM_NoMass_Lubed.txt');

%% Experimental Data - Too short
[t_short, w_short, ~] = import_data('100_RPM_8_INCH.txt');

%time offset from data - doesn't despin until ~3s
t_tan102_short = t_tan102 +3;

%With a string length of 8in (0.2032 m), a tangential release would have released
%at:
t_full_length_short = 0.2032/w_102/R;
t_full_length_short = t_full_length_short +3;

%find index where t_13_5 is closest to t_full_length
[~, idx1] = min(abs(t_short-t_full_length_short));

%% Experimental Data - 13.6 in - Closest length
[t_13_6in, w_13_6in, al_13_6in] = import_data('100_RPM_13.6_INCH.txt');

%time offset from data - doesn't despin until ~3s
t_tan100_13_6 = t_tan100 +3;

%With a string length of 13.5in (0.34544 m), a tangential release would have released
%at:
t_full_length_13_6in = 0.34544/w_100/R;
t_full_length_13_6in = t_full_length_13_6in +3.03;

%find index where t_13_5 is closest to t_full_length
[~, idx2] = min(abs(t_13_6in-t_full_length_13_6in));

%% Experimental Data - Too Long
[t_long, w_long, ~] = import_data('106_RPM_16.125_INCH.txt');

%time offset from data - doesn't despin until ~3s
t_tan106_long = t_tan106 +3;

%With a string length of 16.125in (0.409575 m), a tangential release would have released
%at:
t_full_length_long = 0.409575/w_106/R;
t_full_length_long = t_full_length_long +3;

%find index where t_13_5 is closest to t_full_length
[~, idx3] = min(abs(t_long-t_full_length_long));

%% Plots
% experimental w as a function of time for the case without using the
% yo-yodespin mechanism
hFig = figure;
    scrz = get(groot, 'ScreenSize');
    set(hFig, 'Position', scrz)
scatter(t_0in, w_0in,'.')
xlabel('time (s)')
ylabel('\omega (rad/s)')
title('Satellite Spin, no despin mechanism')
axis([3, 16.5, 0, 12])
set(gca,'fontsize',24);

% setup and save figure as .pdf
    curr_fig = gcf;
    set(curr_fig, 'PaperOrientation', 'landscape');
    set(curr_fig, 'PaperUnits', 'normalized');
    set(curr_fig, 'PaperPosition', [0 0 1 1]);
    [fid, errmsg] = fopen('nodespin.pdf', 'w+');
    if fid < 1 % check if file is already open.
       error('Error Opening File in fopen: \n%s', errmsg); 
    end
    fclose(fid);
    print(gcf, '-dpdf', 'nodespin.pdf');
set(gca,'fontsize',24);   

%Plot omega, experimental vs theoretical - Sample data, short string
hFig = figure;
    scrz = get(groot, 'ScreenSize');
    set(hFig, 'Position', scrz)
plot(t_tan102+3, w_tan102)
hold on
plot(t_short(idx1), w_short(idx1),'*')
scatter(t_short, w_short)
xlabel('time (s)')
ylabel('\omega (rad/s)')
title('Class Data, L = 8 in, initial rpm = 100') 
legend('Tangential release, theoretical','L_{tangent} reached','Radial release, experimental')
axis([2.9, 3.7, 0, 11])
set(gca,'fontsize',24);

% setup and save figure as .pdf
    curr_fig = gcf;
    set(curr_fig, 'PaperOrientation', 'landscape');
    set(curr_fig, 'PaperUnits', 'normalized');
    set(curr_fig, 'PaperPosition', [0 0 1 1]);
    [fid, errmsg] = fopen('omega_short.pdf', 'w+');
    if fid < 1 % check if file is already open.
       error('Error Opening File in fopen: \n%s', errmsg); 
    end
    fclose(fid);
    print(gcf, '-dpdf', 'omega_short.pdf');
set(gca,'fontsize',24);

%Plot omega, experimental vs theoretical - Sample data, 13.6in string
hFig = figure;
    scrz = get(groot, 'ScreenSize');
    set(hFig, 'Position', scrz)
plot(t_tan100+3, w_tan100)
hold on
plot(t_13_6in(idx2), w_13_6in(idx2),'*')
scatter(t_13_6in, w_13_6in)
xlabel('time (s)')
ylabel('\omega (rad/s)')
title('Class Data, L = 13.6 in, initial rpm=100') 
legend('Tangential release, theoretical','L_{string, tangent} reached','Radial release, experimental')
axis([3, 4, 0, 11])
set(gca,'fontsize',24);
% setup and save figure as .pdf
    curr_fig = gcf;
    set(curr_fig, 'PaperOrientation', 'landscape');
    set(curr_fig, 'PaperUnits', 'normalized');
    set(curr_fig, 'PaperPosition', [0 0 1 1]);
    [fid, errmsg] = fopen('omega_136.pdf', 'w+');
    if fid < 1 % check if file is already open.
       error('Error Opening File in fopen: \n%s', errmsg); 
    end
    fclose(fid);
    print(gcf, '-dpdf', 'omega_136.pdf');
    
%Plot omega, experimental vs theoretical - Sample data, long string
hFig = figure;
    scrz = get(groot, 'ScreenSize');
    set(hFig, 'Position', scrz)
plot(t_tan106_long, w_tan106)
hold on
plot(t_long(idx3), w_long(idx3),'*')
scatter(t_long, w_long)
xlabel('time (s)')
ylabel('\omega (rad/s)')
title('Class Data, L = 16.125 in, initial rpm=106') 
legend('Tangential release, theoretical','L_{string, tangent} reached','Radial release, experimental')
axis([3, 4, 0, 12])
set(gca,'fontsize',24);
% setup and save figure as .pdf
    curr_fig = gcf;
    set(curr_fig, 'PaperOrientation', 'landscape');
    set(curr_fig, 'PaperUnits', 'normalized');
    set(curr_fig, 'PaperPosition', [0 0 1 1]);
    [fid, errmsg] = fopen('omega_long.pdf', 'w+');
    if fid < 1 % check if file is already open.
       error('Error Opening File in fopen: \n%s', errmsg); 
    end
    fclose(fid);
    print(gcf, '-dpdf', 'omega_long.pdf');
    
%alpha plot
hFig = figure;
    scrz = get(groot, 'ScreenSize');
    set(hFig, 'Position', scrz)
plot(t_tan100+3, al_tan100)
hold on
plot(t_13_6in, al_13_6in,'o')
xlabel('time (s)')
ylabel('\alpha (rad/s)')
legend('Tangential release, theoretical','Radial release, experimental')
title('Class Data, L = 13.6 in, initial rpm=100') 
axis([3, 3.5, -50, 50])
set(gca,'fontsize',24);
% setup and save figure as .pdf
    curr_fig = gcf;
    set(curr_fig, 'PaperOrientation', 'landscape');
    set(curr_fig, 'PaperUnits', 'normalized');
    set(curr_fig, 'PaperPosition', [0 0 1 1]);
    [fid, errmsg] = fopen('alphacompare.pdf', 'w+');
    if fid < 1 % check if file is already open.
       error('Error Opening File in fopen: \n%s', errmsg); 
    end
    fclose(fid);
    print(gcf, '-dpdf', 'alphacompare.pdf');
