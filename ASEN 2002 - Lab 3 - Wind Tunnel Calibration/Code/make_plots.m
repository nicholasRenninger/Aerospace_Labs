%%% Plots Test Results using the proccesed data from the main function
%%%
%%% Nicholas Renninger
%%% Date Modified: 11/14/2016

function make_plots(Boundry_Layer_heights, pitot_air_velocity, ...
            venturi_air_velocity, x, x_cr_lam_index, x_cr_ht,...
            port_locations, pitot_best_fit_velocity, ...
            venturi_best_fit_velocity, pitot_coefs, ...
            venturi_coefs, sigmaV_comparision, sigmaV, ...
            VoltVec_mano, VeloVec_mano, VoltVec_trans, ...
            VeloVec_trans, velocity_test_matrices)

    %% Un-package arrays for Plotting

    % for boundry layer
    test_boundry_heights = Boundry_Layer_heights{1};
    laminar_boundry_heights = Boundry_Layer_heights{2};
    turbulent_boundry_heights = Boundry_Layer_heights{3};
    
    % voltages for airspeed vs voltage
    volts_PS = velocity_test_matrices{1}(:, 4);
    volts_VT = velocity_test_matrices{2}(:, 4);
    

    %% Defome Plot Constants for Boundry Layer
    LINEWIDTH = 2.5;
    MARKERSIZE = 10;
    FONTSIZE = 28;
    LEGEND_STRING = {sprintf('Test Data'), sprintf('Laminar Boundary Layer'),...
                     sprintf('Turbulent Boundary Layer')};
    LEGEND_LOCATION = 'northwest';
    X_LABEL_NAME = sprintf('Distance from Start of Test Section');
    X_LABEL_UNITS = ' (m)';
    X_LABEL_STRING = cat(2, X_LABEL_NAME, X_LABEL_UNITS);
    Y_LABEL_NAME = sprintf('Height of Boundary Layer');
    Y_LABEL_UNITS = sprintf( ' (mm)');
    Y_LABEL_STRING = cat(2, Y_LABEL_NAME, Y_LABEL_UNITS);
    TITLE_STRING = sprintf('%s vs. %s', Y_LABEL_NAME, X_LABEL_NAME);
    X_LOW = min(x);
    X_HIGH = max(x);

    %% Plot Boundry Data

    hFig = figure;
    set(hFig, 'Position', [100 100 1600 900])

    hold on

    % plot laminar boundry layers
    laminar_x = x(1:x_cr_lam_index);
    p2 = plot(laminar_x, laminar_boundry_heights(1:x_cr_lam_index),':', 'LineWidth', LINEWIDTH);

    % plot turbulent boundary layer
    turb_x = x(x_cr_lam_index:end);
    p3 = plot(turb_x, turbulent_boundry_heights, ':', 'LineWidth', LINEWIDTH);

    % plot critical point in boundry layer
    plot(x(x_cr_lam_index), x_cr_ht, 's', 'MarkerFaceColor', [0.5, 0.5, 0.5], ... 
            'MarkerSize', 11, 'LineWidth', LINEWIDTH)
    % plot test data boundry layer
    p1 = plot(port_locations, test_boundry_heights, 'o', 'MarkerFaceColor', ...,
              [0.3, 1, 0.7], 'MarkerSize', MARKERSIZE);

    set(gca,'FontSize', FONTSIZE)

    % label critical point
    text(x(x_cr_lam_index)*0.55, x_cr_ht*1.2, 'Critical Point', 'FontSize', FONTSIZE, ...
             'interpreter', 'latex'); 

    xlim([X_LOW, X_HIGH])

    hold off

    legend([p1, p2, p3], LEGEND_STRING, 'location', LEGEND_LOCATION, 'interpreter', 'default')
    xlabel(X_LABEL_STRING, 'interpreter', 'default') 
    ylabel(Y_LABEL_STRING, 'interpreter', 'default')
    title(TITLE_STRING)


    %% Defome Plot Constants for Velocity Calculations
    LINEWIDTH = 2.5;
    MARKERSIZE = 8;
    FONTSIZE = 28;
    LEGEND_STRING = {sprintf('Air Velocity - Pitot-Static Probe Data'), ...
                     sprintf('Air Velocity - Static Rings Data'), ...
                     sprintf('Pitot-Static Velocity Control Model: %0.3gV - %0.3g', pitot_coefs(1), abs(pitot_coefs(2)) ), ...
                     sprintf('Static Ring Velocity Control Model: %0.3gV - %0.3g', venturi_coefs(1), abs(venturi_coefs(2)))};
    LEGEND_LOCATION = 'northwest';
    X_LABEL_NAME = sprintf('Voltage Control');
    X_LABEL_UNITS = ' (V)';
    X_LABEL_STRING = cat(2, X_LABEL_NAME, X_LABEL_UNITS);
    Y_LABEL_NAME = sprintf('Air Velocity');
    Y_LABEL_UNITS = sprintf( ' (m/s)');
    Y_LABEL_STRING = cat(2, Y_LABEL_NAME, Y_LABEL_UNITS);
    TITLE_STRING = sprintf('Air Velocity vs. Voltage');
    X_LOW = min(volts_PS);
    X_HIGH = max(volts_PS);

    %% Plot Velocity Data
    
    sigmaV_PS = sigmaV{1};
    sigmaV_VT = sigmaV{2};
    
    hFig = figure;
    set(hFig, 'Position', [100 100 1600 900])

    % plot pitot static velocity vs. voltage
    p1 = errorbar(volts_PS, pitot_air_velocity, sigmaV_PS, 'o', 'MarkerSize', MARKERSIZE);
    
    hold on
    
    % plot static ring velocity vs. voltage
    p2 = errorbar(volts_VT, venturi_air_velocity, sigmaV_VT, '*', 'MarkerSize', MARKERSIZE);
    
    % plot voltage control model for pitot-static tube measurements
    p3 = plot(volts_PS, pitot_best_fit_velocity, 'LineWidth', LINEWIDTH + 1);
    
    % plot voltage control model for venturi tube measurements
    p4 = plot(volts_VT, venturi_best_fit_velocity, ':', 'LineWidth', LINEWIDTH);

    set(gca,'FontSize', FONTSIZE)

    xlim([X_LOW, X_HIGH])
    ylim([-50, inf])

    hold off

    legend([p1, p2, p3, p4], LEGEND_STRING, 'location', LEGEND_LOCATION, 'interpreter', 'default')
    xlabel(X_LABEL_STRING, 'interpreter', 'default') 
    ylabel(Y_LABEL_STRING, 'interpreter', 'default')
    title(TITLE_STRING)
    
    %% Plotting Comparison between Manometer and Trasnducer
    
    sigmaV_trans = sigmaV_comparision{1};
    sigmaV_mano = sigmaV_comparision{2};
      
    %%% Transducer %%%
    
    %set up plot for velocity versus voltage
    hFig = figure;
    set(hFig, 'Position', [100 100 1600 900])
    set(gca,'FontSize', 28)
    hold on 
    title ('Velocity vs. Voltage')
    xlabel('Voltage (Volts)')
    ylabel('Velocity (m/s)')
    
    % set up plot for velocity versus voltage
    axis([1.25, 9.5, 0, 55]);
    x = VoltVec_trans;
    y = VeloVec_trans;
    errorbar(x,y,sigmaV_trans,'o--', 'LineWidth', 2.5)
    
    %%% Manometer %%%

    %plot points of the velocities and the voltages
    errorbar(VoltVec_mano, VeloVec_mano, sigmaV_mano, '*r', 'MarkerSize', 10, 'LineWidth', 2.5);
    hold off
    legend('Velocity (Transducer)', 'Velocity (Manometer)', 'location', 'best')
    
end