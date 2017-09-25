%%% !! README !!
%%% The code MUST HAVE that the following directory structure exits so that
%%% it can find and save all of the data, results, and plots. The following
%%% directories must also all be in the same parent directory (for example
%%% a directory called "Lab 1" might contain the Code/, Figures/, and Data/
%%% directories as such:
%%% 
%%%
%%% ../Lab 1/Code/ - contains all of the .m files
%%% ../Lab 1/Figures/ - save location for .pdf figure files
%%% ../Lab 1/Data/ - where all data is saved. This directory must contain
%%%                  the following directories:
%%%
%%%                  ../Lab 1/Data/Test Data/S_011 - section 1 data
%%%                  ../Lab 1/Data/Test Data/S_012 - section 2 data
%%%                  ../Lab 1/Data/Test Data/S_013 - section 3 data
%%%      
%%% 
%%% 
%%% Last Modified: 3/8/17
%%% ASEN 2004 Lab #1
%%% Author: Nicholas Renninger -  Lab 011
%%%


%% Housekeeping

close all
clear variables
clc


%% Wing Geometry Constants %%%
[S_F16_MODEL, MAC_F16_MODEL, ...
 S_787_MODEL, MAC_787_MODEL, ...
 W_F16_MODEL, W_787_MODEL, ...
 DIST_CG_F16_CLEAN, ...
 DIST_CG_F16_DIRTY, ...
 DIST_CG_787, SCALE_F16, SCALE_787] = Define_Model_Geometry;

S_BOTTLE_ROCKET.data = 0.0094; % [m^2]
S_BOTTLE_ROCKET.error = 0.00001; % [m^2]


%% Plot Constants %%%
set(0, 'defaulttextinterpreter', 'latex')
FONTSIZE = 30;
LINEWIDTH = 2;
MARKERSIZE = 7;


% Read in Data from Excel Files
[test_matrix] = ASEN_2004_Lab_1_readInput();

% Breaking up cell array into its constituent structs for readability
clean = test_matrix{1};
dirty = test_matrix{2};
seven87 = test_matrix{3};
        

% Lift & Drag Analysis

%% Clean F-16 Model %%%
fprintf('\nAnalyzing Data...')
clean = LiftDragMoment(clean, DIST_CG_F16_CLEAN,...
                       S_BOTTLE_ROCKET, MAC_787_MODEL);
fprintf('\nSuccessfully Analyzed Data.\n')

% %% Dirty F-16 Model %%%
% fprintf('\n\nAnalyzing Dirty F-16 Data...')
% dirty = LiftDragMoment(dirty, DIST_CG_F16_DIRTY,...
%                        S_F16_MODEL, MAC_F16_MODEL);
% fprintf('\nSuccessfully Analyzed Data.')
% 
% %% 787 Model %%%
% fprintf('\n\nAnalyzing 787 Data...')
% seven87 = LiftDragMoment(seven87, DIST_CG_787,...
%                                 S_787_MODEL, MAC_787_MODEL);
% fprintf('\nSuccessfully Analyzed Data.')


% %% Calculate Static Longitudinal Stability, dCL/dAoA, S.M., & L/D
% fprintf(['\nCalculating Static Longitudinal Stability,', ...
%          'dCL/dAoA, S.M., & L/D ...\n']);
% 
% isMilitary = true;
% clean = auxilaryCalculations(clean, S_F16_MODEL, W_F16_MODEL, ...
%                              SCALE_F16, isMilitary);
%                          
% dirty = auxilaryCalculations(dirty, S_F16_MODEL, W_F16_MODEL, ...
%                              SCALE_F16, isMilitary);
% 
% isMilitary = false;
% seven87 = auxilaryCalculations(seven87, S_787_MODEL, W_787_MODEL, ...
%                                SCALE_787, isMilitary);
% 
% fprintf('Done\n');


%% Plotting
fprintf('\nPlotting...\n')

colorVecs = [0.294118 0 0.509804; % indigo
             0.854902 0.647059 0.12549; % goldenrod
             1 0.270588 0]; % orange red


%%%%%%%%%%%%%% C_L vs. AoA %%%%%%%%%%%%%%
plot_CL_CD_AoA(clean, dirty, seven87, ...
               FONTSIZE, LINEWIDTH, colorVecs, MARKERSIZE)

% %%%%%%%%%%%%%% C_M vs. AoA %%%%%%%%%%%%%%
% plot_CM_AoA(clean, dirty, seven87, ... 
%             FONTSIZE, LINEWIDTH, colorVecs, MARKERSIZE);
%         
%         
% %%%%%%%%%%%%%% C_L vs. C_D %%%%%%%%%%%%%%
% plot_drag_polar(clean, dirty, seven87, ...
%                 FONTSIZE, LINEWIDTH, colorVecs, MARKERSIZE)
% 
% %%%%%%%%%%%%%% Lift over Drag vs. AoA %%%%%%%%%%%%%%
% plot_L_over_D_AoA(clean, dirty, seven87, ...
%                   FONTSIZE, LINEWIDTH, colorVecs, MARKERSIZE)

              
% %% Printing Results of Analysis
% 
% rowNames = {'Static Margin @ AoA = 0 [%MAC]:', ...
%              'Longitudinal Stability @ AoA = 0 [1/deg]:', ...
%              'Lift Slope @ AoA = 0 [1/deg]:', ...
%              'Min. Landing Speed - Model (actual Model) [knots]:', ...
%              'Min. Landing Speed - Model (theor. Mass Model) [knots]:', ...
%              'Min. Landing Speed - Actual Plane (from actual Model) [knots]:', ...
%              'Min. Landing Speed - Actual Plane (from theor. Mass Model) [knots]:'};
% 
% filePath = '../results.txt';
% fid = fopen(filePath, 'w+');
% m_p_s_to_knots = 1.94384;
% 
% fprintf('Printing Results of Analysis to %s\n', filePath);
% 
% % print SM
% data1 = clean.SM_at_0;
% data2 = dirty.SM_at_0;
% data3 = seven87.SM_at_0;
% fprintf(fid, '%s \r\nclean: %f \t dirty: %f \t 787: %f \r\n\r\n', ...
%              rowNames{1}, data1, data2, data3);
% 
% % print Longitudinal Stability      
% data1 = clean.longit_stability_at_0;
% data2 = dirty.longit_stability_at_0;
% data3 = seven87.longit_stability_at_0;
% fprintf(fid, '%s \r\nclean: %f \t dirty: %f \t 787: %f \r\n\r\n', ...
%              rowNames{2}, data1, data2, data3);
%          
% % print dCL / dAoA     
% data1 = clean.dCL_dAoA;
% data2 = dirty.dCL_dAoA;
% data3 = seven87.dCL_dAoA;
% fprintf(fid, '%s \r\nclean: %f \t dirty: %f \t 787: %f \r\n\r\n', ...
%              rowNames{3}, data1, data2, data3);
% 
% % Print landing speeds
% data1 = clean.V_land_min_real_model * m_p_s_to_knots;
% data2 = dirty.V_land_min_real_model * m_p_s_to_knots;
% data3 = seven87.V_land_min_real_model * m_p_s_to_knots;
% fprintf(fid, '%s \r\nclean: %f \t dirty: %f \t 787: %f \r\n\r\n', ...
%              rowNames{4}, data1, data2, data3); 
%          
% data1 = clean.V_land_min_theoretical_model * m_p_s_to_knots;
% data2 = dirty.V_land_min_theoretical_model * m_p_s_to_knots;
% data3 = seven87.V_land_min_theoretical_model * m_p_s_to_knots;
% fprintf(fid, '%s \r\nclean: %f \t dirty: %f \t 787: %f \r\n\r\n', ...
%              rowNames{5}, data1, data2, data3);
%          
% data1 = clean.V_land_realPlane * m_p_s_to_knots;
% data2 = dirty.V_land_realPlane * m_p_s_to_knots;
% data3 = seven87.V_land_realPlane * m_p_s_to_knots;
% fprintf(fid, '%s \r\nclean: %f \t dirty: %f \t 787: %f \r\n\r\n', ...
%              rowNames{6}, data1, data2, data3);
%          
% data1 = clean.V_land_realPlane_theory * m_p_s_to_knots;
% data2 = dirty.V_land_realPlane_theory * m_p_s_to_knots;
% data3 = seven87.V_land_realPlane_theory * m_p_s_to_knots;
% fprintf(fid, '%s \r\nclean: %f \t dirty: %f \t 787: %f \r\n\r\n', ...
%              rowNames{7}, data1, data2, data3);
% 
% fclose(fid);

