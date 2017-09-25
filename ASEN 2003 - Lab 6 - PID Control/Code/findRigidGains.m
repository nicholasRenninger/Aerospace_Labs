%%% Uses a variable-step Monte Carlo Simulation to determine the optimal
%%% theoretical gains for the rigid arm system, and plots the results. Also
%%% generates a plot showing the mesh grid used to search for the optimal
%%% values, as well as the practical limits on the system when choosing
%%% gains. Automatically saves all figures to a 'Figures' directory:
%%% '../Figures'.
%%%
%%%
%%% Last Modified: 5/3/2017
%%% Date Created: 4/24/2017
%%% Author: Nicholas Renninger

clc
close all
clear

%%%%%%%%%%%%%%%%%%%%%%%% Plot Setup %%%%%%%%%%%%%%%%%%%%%%%%
set(0, 'defaulttextinterpreter', 'latex');
saveLocation = '../Figures/';
LINEWIDTH = 2;
MARKERSIZE = 9;
FONTSIZE = 24;
colorVecsOrig = [0.294118 0 0.509804; % indigo
                 0.1 0.1 0.1; % orange red
                 1 0.843137 0; % gold
                 0.180392 0.545098 0.341176; % sea green
                 0.662745 0.662745 0.662745]; % dark grey 

% de-saturate background colors. saturation must be from 0-1
saturation = 0.5;
colorVecs = colorVecsOrig * saturation;
             
         
markers = {'o','*','s','.','x','d','^','+','v','>','<','p','h'};

shouldSaveFigures = true;

%% Setup
Kg = 48.4; %total gear ratio []
Km = 0.0107; %motor constant [V/(rad/sec) or Nm/amp]
Rm = 3.29; %armature resistance [ohms]

Jh = 0.002; %base inertia [Kg*m^2]
Jl = 0.0015; %load inertia of bar [Kg*m^2]
J = Jh + Jl; %total intertia [Kg*m^2]

% choose range of zeta (damping coef.) values to solve for new gains
zeta_min = 0.9; 
zeta_max = 1.1;
num_zeta_to_try = 20;

% define limits on proportional and deriv. gains
K_p_min = 0.1;
K_p_max = 20;

K_d_min = 0;
K_d_max = 1.5;
num_gains_to_try = 250;

% desired pointing angle
theta_des = 0.7; %[rad]

% define range of zeta (damping coef.) values to try
zeta_vec = linspace(zeta_min, zeta_max, num_zeta_to_try);

% define range of K_p values to try for each zeta value
K_p_vec = linspace(K_p_min, K_p_max, num_gains_to_try);

% define limits on time and voltage
TIME_LIMIT = 0.5; % [s]
V_LIMIT = 5; % [V]
numTimeSteps = 1000;
tspan = linspace(0, 1, numTimeSteps + 1)'; % [s]

% define high and low voltages
error = 0.05;
minV = 1;
maxV = 5;


%% Define New Closed loop system with Varied Gains

% initialize
[acceptable.zeta, acceptable.K_p, ...
 acceptable.K_d,  acceptable.timeToSettle, ...
 acceptable.lowKP, acceptable.lowKD, ...
 acceptable.highKP, acceptable.highKD] = deal(zeros(1,1));

for j = 1:num_zeta_to_try
    
    curr_zeta = zeta_vec(j);
    
    for i = 1:num_gains_to_try
        
        curr_K_p = K_p_vec(i);
        
        % solve for new K_d
        num = 2* curr_zeta * sqrt(curr_K_p * Kg * Km * J * Rm) - ...
              (Kg^2 * Km^2);
          
        denom = Kg * Km;
        curr_K_d = num / denom;
       
        
        %%% Compute step response of system with new gains
        n1 = (curr_K_p*Kg*Km)/(J*Rm);
        d2 = 1;
        d1 = (curr_K_d*Kg*Km+(Kg^2)*(Km^2))/(J*Rm);
        d0 = (curr_K_p*Kg*Km)/(J*Rm);

        %%% define closed loop transfer fcn
        num = n1;
        den = [d2 d1 d0];
        sysTF = tf(num,den);

        [x, t] = step(sysTF, tspan);
        theta = 2*theta_des*x;
        
        %%% If system stays within spec, save values of zeta, K_d, and K_p
        Vin = curr_K_p .* (theta_des - theta(1:end-1)) + ...
              curr_K_d.*-1*(diff(theta)./diff(t));
        within5timesRigid = find(abs(2*theta_des*x-theta_des) < 2*theta_des*.05);
        greaterThanVLimit = find(abs(Vin) > V_LIMIT);
        
        % save acceptable values
        if  max(abs(Vin)) < (minV + error)
            acceptable.lowKP = [acceptable.lowKP curr_K_p];
            acceptable.lowKD = [acceptable.lowKD curr_K_d];
        elseif max(abs(Vin)) > (maxV - error) && max(abs(Vin)) < (maxV + error)
            acceptable.highKP = [acceptable.highKP curr_K_p];
            acceptable.highKD = [acceptable.highKD curr_K_d];
        end
        
        % if the voltage is below the limit, and re
        if isempty(greaterThanVLimit) && ~isempty(within5timesRigid)
            timeReachRigid = t(within5timesRigid(1));
            
            if timeReachRigid < TIME_LIMIT
                
                acceptable.zeta = [acceptable.zeta, curr_zeta];
                acceptable.K_d = [acceptable.K_d, curr_K_d];
                acceptable.K_p = [acceptable.K_p , curr_K_p];
                acceptable.timeToSettle = [acceptable.timeToSettle, timeReachRigid];
                
            end
                
        end
        
    end
end

% get rid of blank at beginning of each array
acceptable.zeta(1) = [];
acceptable.K_p(1) = [];
acceptable.K_d(1) = [];
acceptable.timeToSettle(1) = [];

[acceptable.timeToSettle, sortedIDX] = sortrows(acceptable.timeToSettle');

% pull out the gains that led to the fastest time to settle
acceptable.K_p = acceptable.K_p(sortedIDX);
acceptable.K_d = acceptable.K_d(sortedIDX);
acceptable.zeta = acceptable.zeta(sortedIDX);

% fastest time to settle
K_d_fast = acceptable.K_d(1);
K_p_fast = acceptable.K_p(1);

% slowest time to settle
K_d_slow = acceptable.K_d(end);
K_p_slow = acceptable.K_p(end);

fprintf('fast K_d: %0.3g, slow K_d: %0.3g\n', K_d_fast, K_d_slow)
fprintf('fast K_p: %0.3g, slow K_p: %0.3g\n', K_p_fast, K_p_slow)
fprintf('zeta for fast gain values: %0.3g\n', acceptable.zeta(1))


%% plot fastest gains model - theta vs time

%%% Compute step response of system with new gains
n1 = (K_p_fast*Kg*Km)/(J*Rm);
d2 = 1;
d1 = (K_d_fast*Kg*Km+(Kg^2)*(Km^2))/(J*Rm);
d0 = (K_p_fast*Kg*Km)/(J*Rm);

%%% define closed loop transfer fcn
num = n1;
den = [d2 d1 d0];
sysTF = tf(num,den);

[x, t] = step(sysTF, tspan);
theta = 2*theta_des*x;

% plot where the step should end up at
t_vec = linspace(0, max(t), 100);
max_step_vec = ones(1, 100) * theta_des * 2;


titleString = sprintf('Rigid Arm - Theta vs Time');

% setup plot saving
saveTitle = cat(2, saveLocation, sprintf('%s.pdf', titleString));

hFig = figure('name', titleString);
scrz = get(groot, 'ScreenSize');
set(hFig, 'Position', scrz)


plot(t_vec, max_step_vec, '--', 'linewidth', LINEWIDTH)
hold on
plot(t, theta, 'linewidth', LINEWIDTH)


colormap('linspecer')
xlabel('t [sec.]')
xlim([0 0.5])
ylabel('$\theta$ [rad.]')
title('Rigid Arm Angle vs. Time')
within5timesRigid = find(abs(2*theta_des*x-theta_des) < 2*theta_des*.05);
timeReachRigid = t(within5timesRigid(1));
fprintf('Time rigid reaches within 5%%: %0.3g sec. \n',timeReachRigid)
legend({sprintf('$\\theta_{desired}$ = %0.3g rad', theta_des*2), ...
       'Step Response'}, 'interpreter', 'latex', ...
       'location', 'best')
   
set(gca, 'defaulttextinterpreter', 'latex')
set(gca, 'TickLabelInterpreter', 'latex')

h = gca;
leg = h.Legend;
titleStruct = h.Title;
set(titleStruct, 'FontWeight', 'bold')
set(gca, 'FontSize', FONTSIZE)
set(leg, 'FontSize', round(FONTSIZE * 0.7))

grid on

% setup and save figure as .pdf
saveMeSomeFigs(shouldSaveFigures, saveTitle)


%% voltage plot

% plot where the step should end up at
t_vec = linspace(0, max(t), 100);
max_volt_vec = ones(1, 100) * V_LIMIT;

titleString = sprintf('Rigid Arm - Voltage vs Time');

% setup plot saving
saveTitle = cat(2, saveLocation, sprintf('%s.pdf', titleString));

hFig = figure('name', titleString);
scrz = get(groot, 'ScreenSize');
set(hFig, 'Position', scrz)

colors = linspecer(2);

hold on
plot(t_vec, -max_volt_vec, '--', 'linewidth', LINEWIDTH, ...
     'color', colors(1, :));
p1 = plot(t_vec, max_volt_vec, '--', 'linewidth', LINEWIDTH, ......
     'color', colors(1, :));
Vin = K_p_fast .* (theta_des - theta(1:end-1)) + ...
      K_d_fast .* -1 * (diff(theta) ./ diff(t));
p2 = plot(t(1:end-1), Vin, 'linewidth', LINEWIDTH, ...
     'color', colors(2, :));


xlabel('t [sec.]')
xlim([0 0.5])
ylim([-V_LIMIT*1.05, V_LIMIT*1.05])
ylabel('$Voltage$ [volts]')
title('Rigid Arm Voltage vs. Time')
within5timesRigid = find(abs(2*theta_des*x-theta_des) < 2*theta_des*.05);
timeReachRigid = t(within5timesRigid(1));
fprintf('Max Voltage for rigid: +%0.3gV and -%0.3gV \n', ...
        abs(max(Vin)), abs(min(Vin)))
    
leg_str = {sprintf('$| V_{max} |$ = %0.3g V', V_LIMIT), ...
           'Control Motor Voltage'};    
legend([p1 p2], leg_str, 'interpreter', 'latex', ...
       'location', 'best')
   
set(gca, 'defaulttextinterpreter', 'latex')
set(gca, 'TickLabelInterpreter', 'latex')

h = gca;
leg = h.Legend;
titleStruct = h.Title;
set(titleStruct, 'FontWeight', 'bold')
set(gca, 'FontSize', FONTSIZE)
set(leg, 'FontSize', round(FONTSIZE * 0.7))

grid on


% setup and save figure as .pdf
saveMeSomeFigs(shouldSaveFigures, saveTitle)
   
%% plot all of the acceptable values and format

K_d = acceptable.K_d;
K_p = acceptable.K_p;

zeta = 1;

%%% get K_p and K_d for zeta = 1
for i = 1:num_gains_to_try
    curr_K_p = K_p_vec(i);

    % solve for new K_d
    num = 2* zeta * sqrt(curr_K_p * Kg * Km * J * Rm) - ...
          (Kg^2 * Km^2);

    denom = Kg * Km;
    K_d_zetaOne(i) = num / denom;
end


%%% Ploting
titleString = sprintf('Rigid Arm Gain Determination');

% setup plot saving
saveTitle = cat(2, saveLocation, sprintf('%s.pdf', titleString));

hFig = figure('name', titleString);
scrz = get(groot, 'ScreenSize');
set(hFig, 'Position', scrz)
colors = linspecer(5);

hold on

p1 = plot(K_p, K_d, '.', 'markersize', MARKERSIZE, 'color', colors(1,:));
hold on
p2 = plot(acceptable.highKP, acceptable.highKD, 'bo', ...
          'markersize', MARKERSIZE, 'color', colors(2, :), ...
          'linewidth', LINEWIDTH * 0.6);
p3 = plot(acceptable.lowKP, acceptable.lowKD, 'rs', ...
          'markersize', MARKERSIZE, 'color', colors(3, :), ...
          'linewidth', LINEWIDTH * 0.6);
p4 = plot(K_p_fast, K_d_fast, 'pg', 'markersize', MARKERSIZE*1.5, ...
          'color', colors(4, :), 'linewidth', LINEWIDTH*0.8);
p5 = plot(K_p_vec, K_d_zetaOne, 'linewidth', LINEWIDTH * 1.6, ...
          'color', colors(5, :));

xlim([min(K_p), max(K_p)])
ylim([min(K_d), max(K_d)])


xlabel('$K_P$')
ylabel('$K_D$')
title('Rigid Arm Gain Computations')
    
leg_str = {'Gain Values with $t_{settling, \, 5\%}$ = 0.5s and $|V_{max} \leq 5V|$', ...
           'Gain Values Corresponding to $|V_{max} = 5V|$', ...
           'Gain Values Corresponding to motor deadband: $|V_{max} < 1V|$', ...
           sprintf(['Optimal Gain Values (underdamped): ', ...
                    '$K_P = %0.3g$, $K_D = %0.3g$'], K_p_fast, K_d_fast), ...
           'Gain Values for $\zeta = 1$'};    
legend([p1 p2 p3 p4 p5], leg_str, 'interpreter', 'latex', ...
       'location', 'best')
   
set(gca, 'defaulttextinterpreter', 'latex')
set(gca, 'TickLabelInterpreter', 'latex')

h = gca;
leg = h.Legend;
titleStruct = h.Title;
set(titleStruct, 'FontWeight', 'bold')
set(gca, 'FontSize', FONTSIZE)
set(leg, 'FontSize', round(FONTSIZE * 0.7))

grid on


% setup and save figure as .pdf
saveMeSomeFigs(shouldSaveFigures, saveTitle)

