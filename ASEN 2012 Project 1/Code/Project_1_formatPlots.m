%%% Purpose:
%%%         This function takes the processed data and formats the basic
%%%         plots produced in the other function. Adds labeling for the
%%%         relevant data points calculated from the calorimeter data.
%%%
%%% Inputs: T_o - initial temperature of the calorimeter
%%%         T_1 - initial temperature of the sample
%%%         T_2 - equilibrium temperature of the calorimeter and sample
%%%         T_2_time - time at which T_2 occurs on the extrapolated best
%%%                    fit line for the equilibrium state of system
%%%         TC4 - array containing the temperature profile of the boiling
%%%               water
%%%         search_midpoint_T - average temperature of T_H and T_L as
%%%                             defined in the lab document procedure
%%%         index_hot_sample_added - array index for time / temp when
%%%                                  sample is introduced to calorimeter
%%%         timeStamps - array of time stamps for each measurement taken
%%%
%%% Outputs: none - formats existing calorimeter plot and creates and
%%%                 formats plot of the boiling water profile
%%%
%%% Assumptions: 
%%%             - none made here - just plotting
%%%
%%% Author ID:  0dc91b091fd8
%%% Date Created:   10/15/2016
%%% Date Modified:  10/21/2016
 
%%
function Project_1_formatPlots(T_o, T_1, T_2, T_2_time, TC4, search_midpoint_T, ...
                               index_hot_sample_added, timeStamps)
                           
    %% plot for calorimeter TCs
    
    LINEWIDTH = 2.5;
    FONTSIZE = 28;
    LEGEND_STRING = {sprintf('Experimental Data'), sprintf('Regression Line for finding $T_{o}$'),...
                     sprintf('Regression Line for finding $T_{2}$'),...
                     sprintf('Regression Line for finding $\\frac{T_{H} \\, + \\, T_{L}}{2}$')}; 
    LEGEND_LOCATION = 'southeast';
    X_LABEL_NAME = sprintf('time');
    X_LABEL_UNITS = ' (s)';
    X_LABEL_STRING = cat(2, X_LABEL_NAME, X_LABEL_UNITS);
    Y_LABEL_NAME = sprintf('Temperature');
    Y_LABEL_UNITS = sprintf( ' %cC', char(176));
    Y_LABEL_STRING = cat(2, Y_LABEL_NAME, Y_LABEL_UNITS);
    TITLE_STRING = sprintf('%s vs. %s (calorimeter temp. profile)', Y_LABEL_NAME, X_LABEL_NAME);
    
    timeSampleAdded = timeStamps(index_hot_sample_added);
    
    T_o_string = sprintf('$T_{o} \\, (T_{L})$');
    T_2_string = sprintf('$T_{2}$');
    T_TH_TL_string = sprintf('$\\frac{T_{H} \\, + \\, T_{L}}{2}$');
    
    hold on
    
    % plotting points and graph formatting
    plot(timeSampleAdded, T_o, 'gs', 'MarkerFaceColor', ...
        [0.5, 0.5, 0.5], 'MarkerSize', 11, 'LineWidth', LINEWIDTH) % T_o
    
    plot(T_2_time, search_midpoint_T, 'ks', 'MarkerFaceColor', ...
        [0.5, 0.5, 0.5], 'MarkerSize', 11, 'LineWidth', LINEWIDTH) % search_midpoint_T
    
    plot(T_2_time, T_2, 'ms', 'MarkerFaceColor', ...
        [0.5, 0.5, 0.5], 'MarkerSize', 11, 'LineWidth', LINEWIDTH) % T_2
    
    % labeling points on graph
    text(timeSampleAdded * 0.95, T_o * 0.98, T_o_string, 'FontSize', FONTSIZE, ...
         'interpreter', 'latex'); % T_o
     
    text(T_2_time * 0.85, search_midpoint_T, T_TH_TL_string, ...
        'FontSize', FONTSIZE, 'interpreter', 'latex'); % search_midpoint_T
     
    text(T_2_time * 0.92, T_2 * 0.99, T_2_string, 'FontSize', FONTSIZE, ...
         'interpreter', 'latex'); % T_2
    
    hold off
    
    legend(LEGEND_STRING, 'location', LEGEND_LOCATION, 'interpreter', 'latex')
    xlabel(X_LABEL_STRING, 'interpreter', 'default') 
    ylabel(Y_LABEL_STRING, 'interpreter', 'default')
    title(TITLE_STRING)
    
    
    %% plot for boiling water TC
    
    LINEWIDTH = 2.5;
    FONTSIZE = 22;
    MARKERSIZE = 2;
    LEGEND_STRING = {sprintf('Expiremental Data')}; 
    LEGEND_LOCATION = 'southeast';
    X_LABEL_NAME = sprintf('time');
    X_LABEL_UNITS = ' (s)';
    X_LABEL_STRING = cat(2, X_LABEL_NAME, X_LABEL_UNITS);
    Y_LABEL_NAME = sprintf('Temperature');
    Y_LABEL_UNITS = sprintf( ' %cC', char(176));
    Y_LABEL_STRING = cat(2, Y_LABEL_NAME, Y_LABEL_UNITS);
    TITLE_STRING = sprintf('%s vs. %s (boiling water temp. profile)', Y_LABEL_NAME, X_LABEL_NAME);
    X_LOW = 0;
    X_HIGH = 1850;
    
    T_1_string = sprintf('$T_{1}$');
    
    hFig = figure(2);
    set(gca,'FontSize', FONTSIZE)
    set(hFig, 'Position', [100 100 1600 900])
    
    xlim([X_LOW, X_HIGH])
    
    hold on
    
    plot(timeStamps, TC4, 'o', 'MarkerSize', MARKERSIZE) % expiremental data
    plot(timeSampleAdded, T_1, 'rs', 'MarkerFaceColor', [0.5, 0.5, 0.5], ... % T_1
        'MarkerSize', 11, 'LineWidth', LINEWIDTH)
    
    text(timeSampleAdded * 0.93, T_1 * 0.98, T_1_string, 'FontSize', FONTSIZE, ...
         'interpreter', 'latex'); % T_1
    
    hold off
    
    legend(LEGEND_STRING, 'location', LEGEND_LOCATION, 'interpreter', 'latex')
    xlabel(X_LABEL_STRING, 'interpreter', 'default') 
    ylabel(Y_LABEL_STRING, 'interpreter', 'default')
    title(TITLE_STRING)
    
end
