%%% Author: Group 3
%%% Last Modified: 11/30/16
%%% ASEN 2002 Lab #4

clear
close all
clc

%% define constants
c = 3.5; % [in]
set(0, 'defaulttextinterpreter', 'latex')
LEGEND_LOCATION = 'best';
FONTSIZE = 30;
LINEWIDTH = 2.5;

%% Read in Data from Excel Files
[velocity_test_matrix] = ASEN_2002_Lab_4_readInput();

% Breaking up cell array into its constituent arrays for readability
velocity_10_test_matrix = velocity_test_matrix{1};
velocity_20_test_matrix = velocity_test_matrix{2};
velocity_30_test_matrix = velocity_test_matrix{3};

%% Coefficient of Pressure
% Compute and Plot pressure distributions in the form of pressure
% coefficient v chord-wise position
 
%find number of angles of attack we are running through
angle_of_attack_iteration_number = length(velocity_10_test_matrix);

%compute pressure coefficient 
for i = 1:angle_of_attack_iteration_number
    for j = 6:21
        pressure_coefficient(i, j-5, 1) = velocity_10_test_matrix(i,j) / ...
                                          velocity_10_test_matrix(i,5);
                                    
        pressure_coefficient(i, j-5, 2) = velocity_20_test_matrix(i,j) / ...
                                          velocity_20_test_matrix(i,5);
                                    
        pressure_coefficient(i, j-5, 3) = velocity_30_test_matrix(i,j) / ...
                                          velocity_30_test_matrix(i,5);
    end
end

%compute chordwise position in [inches]
port_number = linspace(1,20,20);
x_position_of_ports = [0, 0.175, 0.35, 0.7, 1.05, 1.4, 1.75, 2.1, NaN,...
                       2.8, NaN, 2.8, NaN, 2.1, NaN,...
                       1.4, 1.05, 0.7, 0.35, 0.175];
y_position_of_ports = [0.14665, 0.33075, 0.4018, 0.476, 0.49, 0.4774, ...
                       0.4403, 0.38325, NaN, 0.21875, NaN, 0, NaN, 0, ...
                       NaN, 0, 0, 0.0014, 0.0175, 0.03885];

% get rid of inactive ports                  
port_position_array = cat(1, port_number, x_position_of_ports,...
                             y_position_of_ports);
port_position_array(:,9)=[];
port_position_array(:,10)=[];
port_position_array(:,11)=[];
port_position_array(:,12)=[];

% get positions of active scanivalve ports
x_position_of_ports = port_position_array(2, :);
y_position_of_ports = port_position_array(3, :);

%%pressure coefficient and chordwise position arrays are organized thusly
%%... Row 1 = Angle of Attack 1 ; Column 1 = Port Number 1  and so on

%save x position of ports 
x_position_of_upper_ports = port_position_array(2,1:9);
x_position_of_lower_ports = [ port_position_array(2, 1), ...
                             flip(port_position_array(2, 10:16)) ];

%% calculate c_p graph, c_l, and c_d for each AoA @ each tested Velocity

num_vel_tested = length(velocity_test_matrix);

% finding # of AoAs 
[num_AoA, ~, ~] = size(pressure_coefficient(:, :, 1));

% initialize data_cell
data_cell = cell(num_vel_tested, 1);


for j = 1:num_vel_tested
    
    % initialize counter to be 1 every time you add into data cell
    idx = 1;
    
    % initialize AoA section of data cell
    data_cell{j} = cell(num_AoA, 3);
    
    for i = 1:num_AoA % loop over all angle of attack data
        
        % Set current Angle of Attack under inspection and its index in data
        % matrices
        current_AoA = velocity_test_matrix{j}(i, end); 
        current_AoA_index = i;

        %save pressure coefficients for convenience in coordination with upper and
        %lower port arrays
        upper_port_c_p_velocity_curr = pressure_coefficient(current_AoA_index, 1:9, j);
        lower_port_c_p_velocity_curr = [pressure_coefficient(current_AoA_index, 1, j),...
                                        flip(pressure_coefficient(current_AoA_index, 10:16, j))];

        %% extrapolation of trailing edge from last 2 ports

        x_pos_trailing_edge = c; % inches

        %%% upper data
        x = x_position_of_upper_ports(end-2:end);
        y = upper_port_c_p_velocity_curr(end-2:end);
        c_p_extrap_point_upper = polyval(polyfit(x, y, 1), ...
                                         x_pos_trailing_edge);

        %%% lower data
        x = x_position_of_lower_ports(end-2:end);
        y = lower_port_c_p_velocity_curr(end-2:end);
        c_p_extrap_point_lower = polyval(polyfit(x, y, 1), ...
                                         x_pos_trailing_edge);

        %%% average data
        c_p_extrap_point = (c_p_extrap_point_upper + c_p_extrap_point_lower) / 2;

        %%% concatanate extrapolation trailing edge to upper and lower port arrays

        %%% x data
        x_position_of_upper_ports_curr = [x_position_of_upper_ports,...
                                          x_pos_trailing_edge];
        x_position_of_lower_ports_curr = [x_position_of_lower_ports,...
                                          x_pos_trailing_edge];
                                      
        % divide by chord length to get chordwise position
        chordwise_x_pos_upper = x_position_of_upper_ports_curr / c;
        chordwise_x_pos_lower = x_position_of_lower_ports_curr / c;
        
        %%% c_p data
        upper_port_c_p_velocity_curr = [upper_port_c_p_velocity_curr, c_p_extrap_point];
        lower_port_c_p_velocity_curr = [lower_port_c_p_velocity_curr, c_p_extrap_point];


        %% format data into struct arrays
        data_cell{j, 1}{idx, 1}(1, :) = chordwise_x_pos_upper;
        data_cell{j, 1}{idx, 1}(2, :) = upper_port_c_p_velocity_curr;
        data_cell{j, 1}{idx + 1, 1}(1, :) = chordwise_x_pos_lower;
        data_cell{j, 1}{idx + 1, 1}(2, :) = lower_port_c_p_velocity_curr;
        

        %% Lift & Drag Analysis

        %%% coefficient of lift
        % pressure_coefficient(current_AoA_index, :, j);
        c_p = [upper_port_c_p_velocity_curr,...
               flip(lower_port_c_p_velocity_curr(2:end - 1))];
        
        %%% remake x
        x = [x_position_of_upper_ports_curr,...
             flip(x_position_of_lower_ports_curr(2:end - 1))];
        
        % Start sum at 0
        C_n = 0;
        C_a = 0;
        
        % finding number of pressures measured
        [~, num_Press_points, ~] = size(pressure_coefficient);
        
        %%% Computing normal and axial coefficients
        for k = 1: num_Press_points - 1

            delta_x = x_position_of_ports(k + 1) - x_position_of_ports(k);
            delta_y = y_position_of_ports(k + 1) - y_position_of_ports(k);

            % find c_n
            current_sum_c_n = (1/2) * (c_p(k) + c_p(k + 1)) * (delta_x / c);

            % find c_a
            current_sum_c_a = (1/2) * (c_p(k) + c_p(k + 1)) * (delta_y / c);

            % add current integration calculation to running total
            C_n = C_n + current_sum_c_n;
            C_a = C_a + current_sum_c_a;
        end

        % C_n is (-) summation
        C_n = -C_n;


        %%% Computing lift and drag coefficients
        C_l = C_n * cosd(current_AoA) - C_a * sind(current_AoA);
        C_d = C_n * sind(current_AoA) + C_a * cosd(current_AoA);
        
        %%% storing the calculated C_d and C_l for every AoA and Velocity
        data_cell{j}{idx, 2} = C_l;
        data_cell{j}{idx, 3} = C_d;
        
        % increment by 2. Each i iteration you add two elems
        idx = idx + 2;
        
    end
end


%% plot chordwise position versus pressure coefficient

%%%%%%%%%%%%%%%%%%%%% AoA = -10 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set AoA index into data_cell (idx = 1 => -14 deg AoA)
AoA = -10;
AoA_index = (AoA * 2) + 29; % * 2, as there is both upper and lower data for ea. AoA

%%% pull data out of data_cell

% x data
x_upper_10 = data_cell{1}{AoA_index, 1}(1, :);
x_upper_20 = data_cell{2}{AoA_index, 1}(1, :);
x_upper_30 = data_cell{3}{AoA_index, 1}(1, :);

x_lower_10 = data_cell{1}{AoA_index + 1, 1}(1, :);
x_lower_20 = data_cell{2}{AoA_index + 1, 1}(1, :);
x_lower_30 = data_cell{3}{AoA_index + 1, 1}(1, :);

% c_p data
cp_upper_10 = data_cell{1}{AoA_index, 1}(2, :);
cp_upper_20 = data_cell{2}{AoA_index, 1}(2, :);
cp_upper_30 = data_cell{3}{AoA_index, 1}(2, :);

cp_lower_10 = data_cell{1}{AoA_index + 1, 1}(2, :);
cp_lower_20 = data_cell{2}{AoA_index + 1, 1}(2, :);
cp_lower_30 = data_cell{3}{AoA_index + 1, 1}(2, :);

% plot
figure_title = sprintf('$C_p$ vs. $x/c$, $\\alpha = %d^\\circ$', AoA);
legend_string = {'Velocity $= \> 10 \> m/s$ (lower surface)', ...
                 'Velocity $= \> 10 \> m/s$ (upper surface)', ...
                 'Velocity $= \> 20 \> m/s$ (lower surface)', ...
                 'Velocity $= \> 20 \> m/s$ (upper surface)', ...
                 'Velocity $= \> 30 \> m/s$ (lower surface)', ...
                 'Velocity $= \> 30 \> m/s$ (upper surface)'};
xlabel_string = sprintf('$x/c$');
ylabel_string = sprintf('$C_p$');

hFig = figure(1);
set(hFig, 'Position', [100 100 1600 900])

p1 = plot(x_lower_10, cp_lower_10, 'o--', x_upper_10, cp_upper_10, 'o-', ...
          'Color', [0.8 0.4 0.1], 'LineWidth', LINEWIDTH);
hold on
p2 = plot(x_lower_20, cp_lower_20, 'o--', x_upper_20, cp_upper_20, 'o-', ...
          'Color', [0.1 0.9 0.4], 'LineWidth', LINEWIDTH);
p3 = plot(x_lower_30, cp_lower_30, 'o--', x_upper_30, cp_upper_30, 'o-', ...
          'Color', [0.1 0.1 0.6], 'LineWidth', LINEWIDTH);

set(gca, 'Ydir', 'Reverse')
set(gca,'FontSize', FONTSIZE)
title(figure_title)
xlabel(xlabel_string)
ylabel(ylabel_string)
legend(legend_string, 'location', LEGEND_LOCATION, ...
       'interpreter', 'latex')
   
%%%%%%%%%%%%%%%%%%%%% AoA = 10 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set AoA index into data_cell (idx = 1 => -14 deg AoA)
AoA = 10;
AoA_index = (AoA * 2) + 29; % * 2, as there is both upper and lower data for ea. AoA

%%% pull data out of data_cell

% x data
x_upper_10 = data_cell{1}{AoA_index, 1}(1, :);
x_upper_20 = data_cell{2}{AoA_index, 1}(1, :);
x_upper_30 = data_cell{3}{AoA_index, 1}(1, :);

x_lower_10 = data_cell{1}{AoA_index + 1, 1}(1, :);
x_lower_20 = data_cell{2}{AoA_index + 1, 1}(1, :);
x_lower_30 = data_cell{3}{AoA_index + 1, 1}(1, :);

% c_p data
cp_upper_10 = data_cell{1}{AoA_index, 1}(2, :);
cp_upper_20 = data_cell{2}{AoA_index, 1}(2, :);
cp_upper_30 = data_cell{3}{AoA_index, 1}(2, :);

cp_lower_10 = data_cell{1}{AoA_index + 1, 1}(2, :);
cp_lower_20 = data_cell{2}{AoA_index + 1, 1}(2, :);
cp_lower_30 = data_cell{3}{AoA_index + 1, 1}(2, :);

% plot
figure_title = sprintf('$C_p$ vs. $x/c$, $\\alpha = %d^\\circ$', AoA);
legend_string = {'Velocity $= \> 10 \> m/s$ (lower surface)', ...
                 'Velocity $= \> 10 \> m/s$ (upper surface)', ...
                 'Velocity $= \> 20 \> m/s$ (lower surface)', ...
                 'Velocity $= \> 20 \> m/s$ (upper surface)', ...
                 'Velocity $= \> 30 \> m/s$ (lower surface)', ...
                 'Velocity $= \> 30 \> m/s$ (upper surface)'};
xlabel_string = sprintf('$x/c$');
ylabel_string = sprintf('$C_p$');

hFig = figure(2);
set(hFig, 'Position', [100 100 1600 900])

p1 = plot(x_lower_10, cp_lower_10, 'o--', x_upper_10, cp_upper_10, 'o-', ...
          'Color', [0.8 0.4 0.1], 'LineWidth', LINEWIDTH);
hold on
p2 = plot(x_lower_20, cp_lower_20, 'o--', x_upper_20, cp_upper_20, 'o-', ...
          'Color', [0.1 0.9 0.4], 'LineWidth', LINEWIDTH);
p3 = plot(x_lower_30, cp_lower_30, 'o--', x_upper_30, cp_upper_30, 'o-', ...
          'Color', [0.1 0.1 0.6], 'LineWidth', LINEWIDTH);

set(gca, 'Ydir', 'Reverse')
set(gca,'FontSize', FONTSIZE)
title(figure_title)
xlabel(xlabel_string)
ylabel(ylabel_string)
legend(legend_string, 'location', LEGEND_LOCATION, ...
       'interpreter', 'latex')
   
%%%%%%%%%%%%%%%%%%%%% AoA = 15 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set AoA index into data_cell (idx = 1 => -14 deg AoA)
AoA = 15;
AoA_index = (AoA * 2) + 29; % * 2, as there is both upper and lower data for ea. AoA

%%% pull data out of data_cell

% x data
x_upper_10 = data_cell{1}{AoA_index, 1}(1, :);
x_upper_20 = data_cell{2}{AoA_index, 1}(1, :);
x_upper_30 = data_cell{3}{AoA_index, 1}(1, :);

x_lower_10 = data_cell{1}{AoA_index + 1, 1}(1, :);
x_lower_20 = data_cell{2}{AoA_index + 1, 1}(1, :);
x_lower_30 = data_cell{3}{AoA_index + 1, 1}(1, :);

% c_p data
cp_upper_10 = data_cell{1}{AoA_index, 1}(2, :);
cp_upper_20 = data_cell{2}{AoA_index, 1}(2, :);
cp_upper_30 = data_cell{3}{AoA_index, 1}(2, :);

cp_lower_10 = data_cell{1}{AoA_index + 1, 1}(2, :);
cp_lower_20 = data_cell{2}{AoA_index + 1, 1}(2, :);
cp_lower_30 = data_cell{3}{AoA_index + 1, 1}(2, :);

% plot
figure_title = sprintf('$C_p$ vs. $x/c$, $\\alpha = %d^\\circ$', AoA);
legend_string = {'Velocity $= \> 10 \> m/s$ (lower surface)', ...
                 'Velocity $= \> 10 \> m/s$ (upper surface)', ...
                 'Velocity $= \> 20 \> m/s$ (lower surface)', ...
                 'Velocity $= \> 20 \> m/s$ (upper surface)', ...
                 'Velocity $= \> 30 \> m/s$ (lower surface)', ...
                 'Velocity $= \> 30 \> m/s$ (upper surface)'};
xlabel_string = sprintf('$x/c$');
ylabel_string = sprintf('$C_p$');

hFig = figure(3);
set(hFig, 'Position', [100 100 1600 900])

p1 = plot(x_lower_10, cp_lower_10, 'o--', x_upper_10, cp_upper_10, 'o-', ...
          'Color', [0.8 0.4 0.1], 'LineWidth', LINEWIDTH);
hold on
p2 = plot(x_lower_20, cp_lower_20, 'o--', x_upper_20, cp_upper_20, 'o-', ...
          'Color', [0.1 0.9 0.4], 'LineWidth', LINEWIDTH);
p3 = plot(x_lower_30, cp_lower_30, 'o--', x_upper_30, cp_upper_30, 'o-', ...
          'Color', [0.1 0.1 0.6], 'LineWidth', LINEWIDTH);

set(gca, 'Ydir', 'Reverse')
set(gca,'FontSize', FONTSIZE)
title(figure_title)
xlabel(xlabel_string)
ylabel(ylabel_string)
legend(legend_string, 'location', LEGEND_LOCATION, ...
       'interpreter', 'latex')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot C_l vs. AoA

%%% pull data out of data_cell

% C_l data
cl_10 = [];
cl_20 = [];
cl_30 = [];

% C_d data
cd_10 = [];
cd_20 = [];
cd_30 = [];

% pull data out of the data_cell array for plotting
for i = 1:length(data_cell{1})
    if i ~= 1
        if ~isempty(data_cell{1}{i, 2})
            
            % C_l
            cl_10 = [cl_10, data_cell{1}{i, 2}];
            cl_20 = [cl_20, data_cell{2}{i, 2}];
            cl_30 = [cl_30, data_cell{3}{i, 2}];
            
            % C_d
            cd_10 = [cd_10, data_cell{1}{i, 3}];
            cd_20 = [cd_20, data_cell{2}{i, 3}];
            cd_30 = [cd_30, data_cell{3}{i, 3}];
        end
        
    else
        % C_l
        cl_10 = [cl_10, data_cell{1}{i, 2}];
        cl_20 = [cl_20, data_cell{2}{i, 2}];
        cl_30 = [cl_30, data_cell{3}{i, 2}];

        % C_d
        cd_10 = [cd_10, data_cell{1}{i, 3}];
        cd_20 = [cd_20, data_cell{2}{i, 3}];
        cd_30 = [cd_30, data_cell{3}{i, 3}];
    end
end


% AoA Data
AoA = velocity_10_test_matrix(:, end);

% NACA
AoA_NACA_CL = [-8, -4, -2, 0, 2, 4, 8, 12, 16];
C_L_NACA = [-0.12, 0.18, 0.32, 0.48, 0.63, 0.78, 1.07, 1.5, 1.51];

AoA_NACA_CD = [-8, -6, -4, -2, 0, 2, 4, 6, 8, 10, 12, 14, 16];
C_D_NACA = [0.012, 0.010, 0.012, 0.018, 0.022, 0.033, 0.047, 0.060,...
    0.076, 0.095, 0.117, 0.130, 0.178];

%%% Checking lift slope
[p_20, ~] = polyfit(AoA(15:17)', cl_20(15:17), 1);
slope_20 = p_20(1);

[p_NACA, ~] = polyfit(AoA_NACA_CL(4:5), C_L_NACA(4:5), 1);
slope_NACA = p_NACA(1);

percent_diff_NACA = (abs(slope_NACA - slope_20) / slope_NACA) * 100;

fprintf(['The percent diff in lift slopes between the 20 m/s ', ...
        'and the NACA data is: %0.3f\n'], percent_diff_NACA);

%%%% plot C_l %%%%
figure_title = sprintf('$C_l$ vs. $\\alpha$');
legend_string = {'NACA Y-14 Data: Velocity $= \> 21.5 \> m/s$', ...
                 'Velocity $= \> 10 \> m/s$', ...
                 'Velocity $= \> 20 \> m/s$', ...
                 'Velocity $= \> 30 \> m/s$'};
xlabel_string = sprintf('$\\alpha \\> (^\\circ)$');
ylabel_string = sprintf('$C_l$');

hFig = figure(4);
set(hFig, 'Position', [100 100 1600 900])

p1 = plot(AoA_NACA_CL, C_L_NACA, ':ok', 'LineWidth', LINEWIDTH);
hold on
p2 = plot(AoA, cl_10, 'o-', ...
          'Color', [0.8 0.4 0.1], 'LineWidth', LINEWIDTH);
p3 = plot(AoA, cl_20, 'o-', ...
          'Color', [0.1 0.9 0.4], 'LineWidth', LINEWIDTH);
p4 = plot(AoA, cl_30, 'o-', ...
          'Color', [0.1 0.1 0.6], 'LineWidth', LINEWIDTH);

set(gca,'FontSize', FONTSIZE)
xlim([-14, 16])
title(figure_title)
xlabel(xlabel_string)
ylabel(ylabel_string)
legend(legend_string, 'location', LEGEND_LOCATION, ...
       'interpreter', 'latex')

%%% plot C_d %%%
figure_title = sprintf('$C_d$ vs. $\\alpha$');
legend_string = {'NACA Y-14 Data: Velocity $= \> 21.5 \> m/s$', ...
                 'Velocity $= \> 10 \> m/s$', ...
                 'Velocity $= \> 20 \> m/s$', ...
                 'Velocity $= \> 30 \> m/s$'};
xlabel_string = sprintf('$\\alpha \\> (^\\circ)$');
ylabel_string = sprintf('$C_d$');

hFig = figure(5);
set(hFig, 'Position', [100 100 1600 900])

p1 = plot(AoA_NACA_CD, C_D_NACA, ':ok', 'LineWidth', LINEWIDTH);
hold on
p2 = plot(AoA, cd_10, 'o-', ...
          'Color', [0.8 0.4 0.1], 'LineWidth', LINEWIDTH);
p3 = plot(AoA, cd_20, 'o-', ...
          'Color', [0.1 0.9 0.4], 'LineWidth', LINEWIDTH);
p4 = plot(AoA, cd_30, 'o-', ...
          'Color', [0.1 0.1 0.6], 'LineWidth', LINEWIDTH);

set(gca,'FontSize', FONTSIZE)
xlim([-14, 16])
title(figure_title)
xlabel(xlabel_string)
ylabel(ylabel_string)
legend(legend_string, 'location', LEGEND_LOCATION, ...
       'interpreter', 'latex')
   
%% plot wing geometry

ClarkY14_AirfoilGeom