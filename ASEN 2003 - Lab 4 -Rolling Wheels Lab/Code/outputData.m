function outputData(theta_exp, theta_mod, omega_exp, ...
                    omega_model_a, omega_model_b, ...
                    residuals_a, residuals_b, ...
                    testString, modelsTested, shouldSaveFigures)
    

    %% ASEN 2003: Dynamics & Systems - Spring 2017
    % Project: Rolling Wheel Lab (#4)
    % Project Members:  Joseph Grengs
    %                   Kian Tanner
    %                   Nicholas Renniger
    %
    %
    % Function takes all of the calculated and measured values for theta
    % and omega and plots the experimental and model data, along with a
    % time history and histogram of the residuals.
    %
    % Project Due Date: Thursday, March 16, 2017 @ 4:00p
    % MATLAB Code Created on: 03/02/2017
    % MATLAB Code last updated on: 03/15/2017

    %% Plot Setup 
    
    set(0, 'defaulttextinterpreter', 'latex');
    titleString = sprintf('%s', testString);
    saveLocation = '../Figures/';
    saveTitle = cat(2, saveLocation, sprintf('%s', titleString));
    LINEWIDTH = 2;
    MARKERSIZE = 6;
    FONTSIZE = 20;
    SCALE_FACTOR = 1;
    colorVecs = [0.294118 0 0.509804; % indigo
                 0.180392 0.545098 0.341176; % sea green
                 1 0.270588 0; % orange red
                 0 0.74902 1; % deep sky blue
                 0.858824 0.439216 0.576471; % forestgreen
                 0.133333 0.545098 0.133333; % palevioletred
                 0.803922 0.521569 0.247059; % peru
                 1 0.498039 0.313725]; % coral
             
    markers = {'+','o','*','.','x','s','d','^','v','>','<','p','h'};
   
    hFig = figure('name', titleString);
    scrz = get(groot, 'ScreenSize');
    set(hFig, 'Position', scrz)
    
    
    %% Subplot (1): Model and Experimental Omega vs. Theta
    subplot(2, 2, 1)
    
    xmin = 0;
    xmax = 15;
    
    y_info = omega_model_a{1};
    ymin = min(y_info) * 0.2;
    ymax = max(y_info) * 1.05;
    
    hold on
    grid on
     
    % plot the experimental data
    for i = 1:length(theta_exp)
        
        p_vec(i) = plot(theta_exp{i}, omega_exp{i}, markers{i}, ...
                    'linewidth', LINEWIDTH, 'markersize', MARKERSIZE, ...
                    'Color', colorVecs(i + 2, :));
        
        % Chnage trial nums if running unbalanced        
        if strfind(testString, 'Balanced')
            exp_data_leg_string{i} = sprintf('Trial %d Experimental Data', ...
                                         i);
        else
            exp_data_leg_string{i} = sprintf('Trial %d Experimental Data', ...
                                         i + 2);
        end
    end
    
    % plot the model "a" data
    p1 = plot(theta_mod{1}, omega_model_a{1}, ':', ...
         'linewidth', LINEWIDTH, 'Color', colorVecs(1, :));
    p1_leg_string = sprintf('Model %s', modelsTested{1});
    
    % plot the model "b" data
    p2 = plot(theta_mod{1}, omega_model_b{1}, '-', ...
         'linewidth', LINEWIDTH, 'Color', colorVecs(2, :)); 
    p2_leg_string = sprintf('Model %s', modelsTested{2});
    
    plot_handles = [p1, p2, p_vec];
    leg_string = [p1_leg_string, p2_leg_string, exp_data_leg_string];
    
    xlim([xmin, xmax])
    ylim([ymin, ymax])
    xlabel('$\theta$ (rad)')
    ylabel('$\omega$ (rad/s)')
    leg = legend(plot_handles, leg_string, ...
                 'location', 'best', 'interpreter', 'latex');
    set(leg, 'FontSize', round(FONTSIZE * 0.7))
    set(gca,'FontSize', FONTSIZE)
    title(sprintf('%s - $\\omega$ vs. $\\theta$', titleString), ...
          'fontsize', round(FONTSIZE * SCALE_FACTOR))
    set(gca, 'defaulttextinterpreter', 'latex')
    set(gca, 'TickLabelInterpreter', 'latex')
    
    
    
    %% Subplot (2): Residuals vs. Theta
    subplot(2, 2, 2)
    
    xmin = 0;
    xmax = 15;
    
    ymin = min(residuals_a{1}) - 0.1;
    ymax = max(residuals_b{1}) + 0.1;
    
    hold on
    grid on
    
    % plot the residual data against theta
    for i = 1:length(theta_exp)
        
        % model "a"
        resid_plot_a(i) = plot(theta_exp{i}, residuals_a{i}, ...
              [markers{i + 2}, ':'], ...
             'linewidth', LINEWIDTH, 'markersize', MARKERSIZE, ...
             'Color', colorVecs(1, :));
         
        % model "b" 
        resid_plot_b(i) = plot(theta_exp{i}, residuals_b{i}, ...
             [markers{i + length(theta_exp) + 2}, '-'], ...
             'linewidth', LINEWIDTH, 'markersize', MARKERSIZE, ...
             'Color', colorVecs(2, :));
        
        %%%  legends
        
        % Chnage trial nums if running unbalanced        
        if strfind(testString, 'Balanced')
            res_a_leg_string{i} = sprintf('Model %s: Trial %d', ...
                                      modelsTested{1}, i);
            res_b_leg_string{i} = sprintf('Model %s: Trial %d', ...
                                      modelsTested{2}, i);
        else 
            res_a_leg_string{i} = sprintf('Model %s: Trial %d', ...
                                      modelsTested{1}, i + 2);
            res_b_leg_string{i} = sprintf('Model %s: Trial %d', ...
                                      modelsTested{2}, i + 2);
        end
    end
    
    leg_string = cat(2, res_a_leg_string, res_b_leg_string);
    plot_handles = cat(2, resid_plot_a, resid_plot_b);
    
    xlim([xmin, xmax])
    ylim([ymin, ymax])
    xlabel('$\theta$ (rad)')
    ylabel('Residual (rad/s)')
    leg = legend(plot_handles, leg_string, ...
                 'location', 'best', 'interpreter', 'latex');
    set(gca, 'FontSize', FONTSIZE)
    title(sprintf('%s - Residuals', testString), 'fontsize', ...
          round(FONTSIZE * SCALE_FACTOR))
    set(leg, 'FontSize', round(FONTSIZE * 0.7))
    set(gca, 'defaulttextinterpreter', 'latex')
    set(gca, 'TickLabelInterpreter', 'latex')
    
    
    
    %% Subplot (3): Histogram of Model "a" Residuals
    
    subplot(2,2,3)
 
    histfit(residuals_a{1}, 8)
    title_string = sprintf('Histogram of Residual - Model %s, Trial 1', ...
                           modelsTested{1});
    xlabel('Residual (rad/s)')
    ylabel('\# Samples w/ Residual')
    set(gca,'FontSize', round(FONTSIZE * SCALE_FACTOR))
    title(title_string, 'fontsize', round(FONTSIZE * SCALE_FACTOR))
    set(gca, 'defaulttextinterpreter', 'latex')
    set(gca, 'TickLabelInterpreter', 'latex')
    
    
    
    %% Subplot (4): Histogram of Model "b" Residuals
    
    subplot(2,2,4)
 
    histfit(residuals_b{1}, 8)
    title_string = sprintf('Histogram of Residual - Model %s, Trial 1', ...
                           modelsTested{2});
    xlabel('Residual (rad/s)')
    ylabel('\# Samples w/ Residual')
    set(gca,'FontSize', round(FONTSIZE * SCALE_FACTOR))
    title(title_string, 'fontsize', round(FONTSIZE * SCALE_FACTOR))
    set(gca, 'defaulttextinterpreter', 'latex')
    set(gca, 'TickLabelInterpreter', 'latex')
    
    

    
    %% setup and save figure as .pdf
    if shouldSaveFigures
        savefig(saveTitle, 'pdf', '-r500');
    end
     
end

