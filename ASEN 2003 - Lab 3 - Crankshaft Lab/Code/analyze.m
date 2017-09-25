function analyze(L, R, D, filename, volt)

    %%% analyze(L, R, D, filename, volt)
    %%%
    %%% This function takes multiple inputs, including constants and the
    %%% name of the file to study. This function then calls in three
    %%% functions: load_lcs.m, LCSMODEL.m, and calcStatistics.m, that loads
    %%% in the data from the desired file, calculates the analytical data,
    %%% and then finds the statistics of the error. This function also
    %%% creates plots for each data set.
    %%%
    %%%
    %%% Inputs: 
    %%%        - R: distance between the origin (rotation axis) and the
    %%%             attachment point A. [m]
    %%%
    %%%        - D: horizontal distance between the vertical shaft and the
    %%%             center of the disk. [m]
    %%%
    %%%        - L: length of the connecting bar from A to B. [m]
    %%%
    %%%        - filename: name of the file to load the data from
    %%%
    %%%        - volt: voltage of the data set studied
    %%%
    %%% Authors: Pierre Guillaud, Nicholas Renninger
    %%% Date Created: 2/16/17
    %%% Last Modified: 2/28/17

    %% DATA LOADING
    % Loads in the data from the desired file
    [theta_exp, w_exp, v_exp] = load_lcs(filename);


    %% CALCULATE
    % Calls in the LCSMODEL.m function to find an analytical
    v_model = LCSMODEL(R, D, L, theta_exp, w_exp);


    %% ERROR
    % Calculate the difference between the experimental and analytical
    % data
    residuals = v_exp - v_model;


    %% Plots
    % Puts in subplots: 
    % 1. The angular velocity vs angle, 
    % 2. the linear velocity vs angle
    % 3. The Residual vs angle, 
    % 4. The histogram of the Residual plotted previously
    
    %%%%%%%%%%%%%%%%%%%%%%%% Plot Setup %%%%%%%%%%%%%%%%%%%%%%%%
    set(0, 'defaulttextinterpreter', 'latex');
    titleString = sprintf('Analysis-%dV', volt);
    saveLocation = '../Figures/';
    saveTitle = cat(2, saveLocation, sprintf('%s.pdf', titleString));
    LINEWIDTH = 1.5;
    FONTSIZE = 17;
    colorVecs = [0.294118 0 0.509804; % indigo
                 0.180392 0.545098 0.341176; % sea green
                 1 0.270588 0; % orange red
                 0 0.74902 1]; % deep sky blue
   
    hFig = figure('name', titleString);
    scrz = get(groot, 'ScreenSize');
    set(hFig, 'Position', scrz)
    
    
    %%%%%%%%%%%%%%%%%%%%%%%% Plot Each Data Set %%%%%%%%%%%%%%%%%%%%%%%%
    
    % Subplot (1)
    subplot(2,2,1)
    
    x_data = theta_exp;
    xmin = min(x_data) * 0.95;
    xmax = max(x_data) * 1.01;
    
    y_data = w_exp;
    ymin = 4;
    ymax = 25;
    
    plot(x_data, y_data, 'linewidth', LINEWIDTH, ...
                          'Color', colorVecs(1, :));
                      
    xlim([xmin, xmax])
    ylim([ymin, ymax])
    title(sprintf(['Angular Velocity ($\\omega$) vs. ', ...
                   'Angle ($\\theta$) - %dV'], volt))
    xlabel('$\theta$ (deg)')
    ylabel('$\omega$ (rad/s)')
    set(gca,'FontSize', FONTSIZE)
    set(gca, 'defaulttextinterpreter', 'latex')
    set(gca, 'TickLabelInterpreter', 'latex')
    
    
    % Subplot (2)
    subplot(2,2,2)
    
    x_data = theta_exp;
    xmin = min(x_data) * 0.95;
    xmax = max(x_data) * 1.01;
    
    y1_data = v_model * 100; %[cm / s]
    y2_data = v_exp * 100; % [cm / s]
    ymin = -2 * 100;
    ymax = 3 * 100;
    
    hold on
    
    plot(x_data, y1_data, 'linewidth', LINEWIDTH, ...
                             'Color', colorVecs(2, :));
    plot(x_data, y2_data, '*', 'MarkerSize', LINEWIDTH + 7, ...
                               'Color', colorVecs(3, :));
                           
    xlim([xmin, xmax])
    ylim([ymin, ymax])
    title(sprintf('Collar Velocity vs. Angle ($\\theta$) - %dV', volt))
    xlabel('$\theta$ (deg)')
    ylabel('Velocity (cm/s)')
    leg = legend({'Model V', 'Experimental V'}, 'location', ...
                  'northwest', 'interpreter', 'latex');
    set(gca, 'FontSize', FONTSIZE)
    set(leg, 'FontSize', round(FONTSIZE * 0.6))
    set(gca, 'defaulttextinterpreter', 'latex')
    set(gca, 'TickLabelInterpreter', 'latex')
    
    
    % Subplot (3)
    subplot(2,2,3)
    x_data = theta_exp;
    xmin = min(x_data) * 0.95;
    xmax = max(x_data) * 1.01;
    
    y_data = residuals * 100; % [cm / s]
    ymin = -0.4 * 100;
    ymax = 0.4 * 100;
    
    plot(theta_exp, y_data, 'linewidth', LINEWIDTH, ...
                              'Color', colorVecs(4, :));
    
    xlim([xmin, xmax])
    ylim([ymin, ymax])
    title(sprintf('Residual vs. Angle ($\\omega$) - %dV', volt))
    xlabel('$\omega$ (deg)')
    ylabel('Residual (cm/s)')
    set(gca,'FontSize', FONTSIZE)
    set(gca, 'defaulttextinterpreter', 'latex')
    set(gca, 'TickLabelInterpreter', 'latex')
    
    
    % Subplot (4)
    subplot(2,2,4)
    histfit(residuals * 100, 20)
    title(sprintf('Histogram of Residual - %dV',volt))
    xlabel('Residual (cm/s)')
    ylabel('Num. Samples w/ Given Residual')
    set(gca,'FontSize', FONTSIZE)
    set(gca, 'defaulttextinterpreter', 'latex')
    set(gca, 'TickLabelInterpreter', 'latex')
    
    % setup and save figure as .pdf
    curr_fig = gcf;
    set(curr_fig, 'PaperOrientation', 'landscape');
    set(curr_fig, 'PaperUnits', 'normalized');
    set(curr_fig, 'PaperPosition', [0 0 1 1]);
    [fid, errmsg] = fopen(saveTitle, 'w+');
    if fid < 1 % check if file is already open.
       error('Error Opening File in fopen: \n%s', errmsg); 
    end
    fclose(fid);
    print(gcf, '-dpdf', saveTitle);
    
    %% Calculate Statistics
    calcStatistics(residuals, volt)
    
end

