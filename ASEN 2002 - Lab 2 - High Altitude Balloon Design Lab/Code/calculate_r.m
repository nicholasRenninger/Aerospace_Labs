clear all
close all
clc

NUM_SAMPLES = 100000;
LINE_WIDTH = 2.0;
FONTSIZE = 18;
MARKER_SIZE = 10;
MARKER_STYLE = 'o';
BALLOON_ALTITUDE = 35000;
PRESSURE_GAUGE = 10;
K2_VAL = 12;
M_TO_MICROMETERS = 1000000;

MATERIAL = 'MDPE Film';
RHO_AVG_MATERIAL = 936;
AVG_THICKNESS = 27.6e-06;
MIN_THICKNESS = 20e-06;
MAX_THICKNESS = 38.1e-06;
SIGMA_U_AVG = 37.0e6;
SIGMA_U_MIN = 33e6;
SIGMA_U_MAX = 39e6;

[Temperature_air, ~, Pressure_air, rho_air] = atmoscoesa(BALLOON_ALTITUDE);

rho_H2 = (Pressure_air) / ( 4124 * Temperature_air );

r_vec = ones(1, NUM_SAMPLES);
r_sigma_u_min_vec = r_vec;
r_sigma_u_max_vec = r_vec;

t_vec = zeros(1, NUM_SAMPLES);
t_sigma_u_min_vec = t_vec;
t_sigma_u_max_vec = t_vec;

mass_balloon = zeros(1, NUM_SAMPLES);
mass_sigma_u_min_balloon = mass_balloon;
mass_sigma_u_max_balloon = mass_balloon;

k = linspace(1, 20, NUM_SAMPLES);


for i = 1:NUM_SAMPLES
   
   r = nthroot( (500 / ( (4/3) * pi )) / ( rho_air - ( ( 3 * PRESSURE_GAUGE * k(i) ) / (2 * SIGMA_U_AVG) ) * RHO_AVG_MATERIAL - rho_H2 ), 3 );
   t = ( k(i) * PRESSURE_GAUGE * r ) / (2 * SIGMA_U_AVG);
   mass_b = (4 * pi * r^2) * t * RHO_AVG_MATERIAL;
   
   r_sigma_u_min = nthroot( (500 / ( (4/3) * pi )) / ( rho_air - ( ( 3 * PRESSURE_GAUGE * k(i) ) / (2 * SIGMA_U_MIN) ) * RHO_AVG_MATERIAL - rho_H2 ), 3 );
   t_sigma_u_min = ( k(i) * PRESSURE_GAUGE * r_sigma_u_min ) / (2 * SIGMA_U_MIN);
   mass_b_sigma_u_min = (4 * pi * r_sigma_u_min^2) * t_sigma_u_min * RHO_AVG_MATERIAL;
   
   r_sigma_u_max = nthroot( (500 / ( (4/3) * pi )) / ( rho_air - ( ( 3 * PRESSURE_GAUGE * k(i) ) / (2 * SIGMA_U_MAX) ) * RHO_AVG_MATERIAL - rho_H2 ), 3 );
   t_sigma_u_max = ( k(i) * PRESSURE_GAUGE * r_sigma_u_max ) / (2 * SIGMA_U_MAX);
   mass_b_sigma_u_max = (4 * pi * r_sigma_u_max^2) * t_sigma_u_max * RHO_AVG_MATERIAL;
   
   if r > 0
       
       r_vec(i) = r;
       t_vec(i) = t;
       mass_balloon(i) = mass_b;
       
       last_index = i;
   end
   
   if r_sigma_u_min > 0
       
       r_sigma_u_min_vec(i) = r_sigma_u_min;
       t_sigma_u_min_vec(i) = t_sigma_u_min;
       mass_sigma_u_min_balloon(i) = mass_b_sigma_u_min;
       
       last_index_sigma_u_min_vec = i;
   end
   
   if r_sigma_u_max > 0
       
       r_sigma_u_max_vec(i) = r_sigma_u_max;
       t_sigma_u_max_vec(i) = t_sigma_u_max;
       mass_sigma_u_max_balloon(i) = mass_b_sigma_u_max;

       last_index_sigma_u_max_vec = i;

   end
   
   if t > AVG_THICKNESS && t < AVG_THICKNESS + 0.005e-06
       
       k_index = i;
   end
   
   if t_sigma_u_min > AVG_THICKNESS && t_sigma_u_min < AVG_THICKNESS + 0.005e-06
       
       k_sigma_u_min_vec_index = i;
   end
   
   if t_sigma_u_max > AVG_THICKNESS && t_sigma_u_max < AVG_THICKNESS + 0.005e-06
       
       k_sigma_u_max_index = i;
   end
   
   if k(i) > K2_VAL && k(i) < K2_VAL + 0.001
      
       k2_index = i;
   end
   
   
end

r_value = r_vec( k_index );
r2_value = r_vec( k2_index );

vol_balloon = (4/3) * pi * r_value^3;
vol2_balloon = (4/3) * pi * r2_value^3;

mass_val = mass_balloon(k_index);
mass2_val = mass_balloon(k2_index);
mass_H2 = rho_H2 * vol_balloon;
total_mass = mass_H2 + mass_val + 500;

min_thickness_x = ones(1, NUM_SAMPLES) .* MIN_THICKNESS;
min_thickness_y = linspace(0, mass2_val * 2, NUM_SAMPLES);

max_thickness_x = ones(1, NUM_SAMPLES) .* MAX_THICKNESS;
max_thickness_y = linspace(0, mass2_val * 2, NUM_SAMPLES);

thickness_value = t_vec(k_index) * M_TO_MICROMETERS;
thickness2_value = t_vec(k2_index) * M_TO_MICROMETERS;

fprintf('Radius (m): %.5f\n', r_value);
fprintf('K Safety: %.5f\n', k(k_index));
fprintf('Mass of Balloon (kg): %.5f\n', mass_val);
fprintf('Mass of H2 (kg): %0.5f\n', mass_H2);
fprintf('Total Mass (kg): %0.5f\n', total_mass);
fprintf('Thickness (um): %.5e\n', thickness_value);
fprintf('Volume (m^3): %0.5e\n\n', vol_balloon);

fprintf('Radius 2 (m): %.5f\n', r2_value);
fprintf('K_2 Safety: %.5f\n', k(k2_index));
fprintf('Mass of Balloon 2 (kg): %.5f\n', mass2_val);
fprintf('Thickness 2 (um): %.5e\n', thickness2_value);
fprintf('Volume 2(m^3): %0.5e\n\n', vol2_balloon);

legendString = cell(2, 1);
legendString{1, 1} = sprintf('\\sigma_{u} = %0.3e (Pa)', SIGMA_U_MIN);
legendString{2, 1} = sprintf('\\sigma_{u} = %0.3e (Pa)', SIGMA_U_MAX);
legendString{3, 1} = sprintf('\\sigma_{u} = %0.3e (Pa) - Used this average value', SIGMA_U_AVG);
legendString{4, 1} = sprintf('k = %0.3f, radius = %0.3f (m), mass = %0.3f (kg),\n      thickness = %0.3f (\\mum), volume = %0.3e (m^{3})',...
                              k(k_index), r_vec(k_index), mass_val, thickness_value, vol_balloon);
legendString{5, 1} = sprintf('k = %0.3f, radius = %0.3f (m), mass = %0.3f (kg),\n      thickness = %0.3f (\\mum), volume = %0.3e (m^{3})',...
                              k(k2_index), r_vec(k2_index), mass2_val, thickness2_value, vol2_balloon);

hold on
set(gca,'FontSize', FONTSIZE)
plot( k(1:last_index_sigma_u_min_vec), r_sigma_u_min_vec(1:last_index_sigma_u_min_vec), ':', k(1:last_index_sigma_u_max_vec), r_sigma_u_max_vec(1:last_index_sigma_u_max_vec), ':', k(1:last_index), r_vec(1:last_index), '-', 'LineWidth', LINE_WIDTH)
plot(k(k_index), r_value, MARKER_STYLE, 'MarkerSize', MARKER_SIZE, 'LineWidth', LINE_WIDTH)
plot(k(k2_index), r2_value, MARKER_STYLE, 'MarkerSize', MARKER_SIZE, 'LineWidth', LINE_WIDTH)
legend(legendString)
ylim([0, r2_value * 1.1])
xlim([1, k(k2_index) * 1.1])
xlabel('k') 
ylabel('Balloon Radius (m)')
titleString = sprintf('Balloon Radius vs. k (%s)', MATERIAL);
title(titleString)
hold off

figure

hold on
set(gca,'FontSize', FONTSIZE)
plot(r_sigma_u_min_vec(1:last_index_sigma_u_min_vec), k(1:last_index_sigma_u_min_vec),  ':', r_sigma_u_max_vec(1:last_index_sigma_u_max_vec), k(1:last_index_sigma_u_max_vec), ':', r_vec(1:last_index), k(1:last_index),  '-', 'LineWidth', LINE_WIDTH)
plot( r_value, k(k_index), MARKER_STYLE, 'MarkerSize', MARKER_SIZE, 'LineWidth', LINE_WIDTH)
plot( r2_value, k(k2_index), MARKER_STYLE, 'MarkerSize', MARKER_SIZE, 'LineWidth', LINE_WIDTH)
legend(legendString)
xlim([0, r2_value * 1.1])
ylim([1, k(k2_index) * 1.1])
xlabel('Balloon Radius') 
ylabel('k')
titleString = sprintf('k vs. Balloon Radius (%s)', MATERIAL);
title(titleString)
hold off

figure

hold on
set(gca,'FontSize', FONTSIZE)
plot( k(1:last_index_sigma_u_min_vec), mass_sigma_u_min_balloon(1:last_index_sigma_u_min_vec), ':', k(1:last_index_sigma_u_max_vec), mass_sigma_u_max_balloon(1:last_index_sigma_u_max_vec), ':', k(1:last_index), mass_balloon(1:last_index), '-', 'LineWidth', LINE_WIDTH)
plot( k(k_index), mass_val, MARKER_STYLE, 'MarkerSize', MARKER_SIZE, 'LineWidth', LINE_WIDTH)
plot( k(k2_index), mass2_val, MARKER_STYLE, 'MarkerSize', MARKER_SIZE, 'LineWidth', LINE_WIDTH)
legend(legendString)
xlim([1, k(k2_index) * 1.1])
ylim([1, mass2_val * 1.1])
xlabel('k') 
ylabel('Mass of Balloon (kg)')
titleString = sprintf('Mass of Balloon vs. k (%s)', MATERIAL);
title(titleString)
hold off

figure

hold on
legendString2{1, 1} = legendString{3, 1};
legendString2{2,1} = sprintf('Minimum thickness threshold of %s = %0.3f (\\mum)', MATERIAL, MIN_THICKNESS * M_TO_MICROMETERS);
legendString2{3,1} = sprintf('Maximum thickness threshold of %s = %0.3f (\\mum)', MATERIAL, MAX_THICKNESS * M_TO_MICROMETERS);
legendString2{4, 1} = legendString{4, 1};
legendString2{5, 1} = legendString{5, 1};
set(gca,'FontSize', FONTSIZE)
plot(t_vec, mass_balloon, '-r', 'LineWidth', LINE_WIDTH)
plot( min_thickness_x, min_thickness_y, '--' ,'LineWidth', LINE_WIDTH)
plot( max_thickness_x, max_thickness_y, '--' ,'LineWidth', LINE_WIDTH)
plot( t_vec(k_index), mass_val, MARKER_STYLE, 'MarkerSize', MARKER_SIZE, 'LineWidth', LINE_WIDTH)
plot( t_vec(k2_index), mass2_val, MARKER_STYLE, 'MarkerSize', MARKER_SIZE, 'LineWidth', LINE_WIDTH)
legend(legendString2)
if MAX_THICKNESS > t_vec(k2_index)
    xlim([t_vec(k_index)*0.1, MAX_THICKNESS * 1.1])
else
    xlim([t_vec(k_index)*0.1, t_vec(k2_index) * 1.1])
end
ylim([0, mass2_val * 1.1])
xlabel('Thickness (m)') 
ylabel('Mass of Balloon (kg)')
titleString = sprintf('Mass of Balloon vs. Thickness (%s)', MATERIAL);
title(titleString)
hold off
hold off