function SensitivityAnalysis(modelInUse, shouldSaveFigures, ...
                             NUM_SENSITIVITY_ITERATIONS, ...
                             NUM_SENSITIVITY_VARS)

    %%% return maximum and minimum allowed value for each global variable
    % [ P_init, V_water, C_drag,     theta , rho_water]
    % [ (Pa), (m^3), (unit-less), (radians), (kg/m^3)]
    P_atm = 82943.93; % [Pa]
    PA_TO_PSI = 0.000145038; % [Pa] -> [psi]
    DEG_TO_RAD = pi / 180; % [deg] -> [rad]
    max_global_vals = [827371 + P_atm, 0.002, 1, 90 * DEG_TO_RAD, 1500];
    min_global_vals = [34473.8 + P_atm, 0.00001, 0.01, 0 * DEG_TO_RAD, 500];
    
    %%% define the practical limits on the sensitivty parameters
    % [ P_init, V_water, C_drag,     theta , rho_water]
    % [ (psi) - gauge press, (L), (unit-less), (deg), (kg/m^3)]
    param_limits_low = [10, 0.1, 0.2, 10, 800];
    param_limits_high = [40, 2, 1, 80, 1200];
    
    

    % plotting setup
    title_strang = {'Sensitivty Analysis - Pressure of Air', ...
                    'Sensitivty Analysis - Volume of Propellent', ...
                    'Sensitivty Analysis - Drag Coefficient', ...
                    'Sensitivty Analysis - Launch Angle', ...
                    'Sensitivty Analysis - Propellent Density'};
               
    sens_names = {'$P_{o, air}$', '$V_{water}$', '$C_{D}$', ...
                  '$\theta$', '$\rho_{water}$'};
    print_names = {'Initial Air Pressure', 'Volume of Water', ...
                  'C_Drag', 'Launch Angle', 'Water Density'};
              
    % use degress and psi for display
    sens_units = {'$[psi]$', '$[L]$', '', '$[^\circ]$', '$[kg/m^3]$'}; 
                                                      


    %% Creating Vectors of Varied Parameters

    % initialize testing matrix
    sens_var_vec = cell(1, NUM_SENSITIVITY_VARS);

    for i = 1:NUM_SENSITIVITY_VARS

        % create linearly spaced vectors with 1 variable varied from its
        % min to its max with all of the rest of the variables constant at
        % their
        % current values
        var_index = i;

        current_var_max = max_global_vals(var_index);
        current_var_min = min_global_vals(var_index);

        % Create Basic Test Matrix, a NUM_SENSITIVITY_VARS x
        % NUM_SENSITIVITY_ITERATIONS matrix that contains the values of the
        % sensitivity parameters that are to be varied. For each
        % sensitivity variable, one test matrix will have
        % NUM_SENSITIVITY_ITERATIONS values ranging from the minimum to the
        % maximum global varibale value to do sensitivity analysis on.

        % use the parameters for TA baseline to vary the parameters around
        %         [ 40 psi       , 1 L (0.001 m^3), 0.374, 45 degrees     , 1000kg/m^3]
        var_mat = [275790 + P_atm, 0.001, 0.374, 45 * DEG_TO_RAD, 1000]; 

        temp_mat = repmat(var_mat, [NUM_SENSITIVITY_ITERATIONS, 1]);
        sens_var_vec{var_index} = temp_mat;

        % creating vector that varies from min and max param value, with
        % NUM_SENSITIVITY_ITERATIONS steps
        param_var_vec = linspace(current_var_min, current_var_max,...
                                 NUM_SENSITIVITY_ITERATIONS);

        % Create Varying Paramter column in current Parameter matrix
        sens_var_vec{var_index}(:, var_index) = param_var_vec;

    end
    
    
    %% Run Sens. Analysis
    
    % set which parameters to use in ODE45 based on whether you are doing
    % sensitivity analysis, finding 85m params, or running a verification
    % case
    run_sens_analysis = true;
    find_85m_range = false;
    run_verification_case = false;

    % set global bools that control parameter data flow
    setGlobalBools(run_sens_analysis, find_85m_range, run_verification_case);

    % Plot Constants
    set(0, 'defaulttextinterpreter', 'latex');
    LINEWIDTH = 2;
    MARKERSIZE = 6;
    FONTSIZE = 20;
    SCALE_FACTOR = 1;
    colorVecs = [0.294118 0 0.509804; % indigo #1
                 0.180392 0.545098 0.341176; % sea green #2
                 1 0.270588 0; % orange red #3
                 0.858824 0.439216 0.576471; % forestgreen #4
                 0.133333 0.545098 0.133333; % palevioletred #5
                 0.803922 0.521569 0.247059; % peru #6
                 0 0.74902 1; % deep sky blue #7
                 1 0.498039 0.313725]; % coral #8
             
    markers = {'+','o','*','.','x','s','d','^','v','>','<','p','h'};
    
    
    for i = 1:NUM_SENSITIVITY_VARS % loop through each sens. var

        %% new plot for each variable analyzed

        saveLocation = '../../Figures/';
        saveTitle = cat(2, saveLocation, sprintf('%s.pdf', title_strang{i}));
        hFig = figure('name', title_strang{i});
        scrz = get(groot, 'ScreenSize');
        set(hFig, 'Position', scrz)
        hold on

        % Print Simulation Status to Command Window
        fprintf('Current Parameter Being Varied: %s\n', print_names{i})
        
        [varied_param, dist] = deal(zeros(NUM_SENSITIVITY_ITERATIONS, 1));
        
        % printing Progress
        dispstat('','init'); % One time only initialization
        dispstat(sprintf('Starting Simulation Cycles...'), ...
                 'keepthis');

        % run sens. analysis on the current parameter
        for j = 1:NUM_SENSITIVITY_ITERATIONS 

            %%% Determine value of global variable, and which variable will
            %%% be modified for the current solution iteration
            global_conditions = sens_var_vec{i}(j, :);
            setSensGlobals(global_conditions);

            %% define initial conditions and flight variables

            % Initialize variables, return initial conditions vector
            [~, init_conds] = getInput(run_sens_analysis, ...
                                       find_85m_range, ...
                                       run_verification_case);

            % Definging the range of time values to solve the system of
            % ODEs
            INIT_TIME = 0; % seconds
            FINAL_TIME = 5*((j + 6)/3); % last time of projectile - seconds
            time_interval = [INIT_TIME, FINAL_TIME];

            % Set stopping conditions for ODE45
            opts = odeset('Events', @odeStopFunc);

            %% Solve System of ODEs and return numeric results 
            [~, rocketVars] = ode45(modelInUse, ...
                                    time_interval, init_conds, opts);

            % Save Downrange Distance and Varied Parameter
            varied_param(j) = sens_var_vec{i}(j, i);
            dist(j) = max(rocketVars(:, 1));
            
            % convert radians back to degrees for readability, make
            % Pressure Gauge pressure not total
            if i == 4 % looking at theta, convert [rad] -> [deg]
                varied_param(j) = rad2deg(varied_param(j));
            
            % looking at P_air_init, report only P_gauge, convert [pa] -> [psi]
            elseif i == 1 
                
                varied_param(j) = varied_param(j) - P_atm; % make gauge
                varied_param(j) = varied_param(j) * PA_TO_PSI; % convert to psi
                
            elseif i == 2 % convert [m^3] -> [L]
                varied_param(j) = varied_param(j) * 1000;
            else
                varied_param(j) = varied_param(j);
            end
            
           
            dispstat(sprintf('Progress %0.0f%%', ...
                             j/NUM_SENSITIVITY_ITERATIONS * 100));

        end
        
        dispstat('Finished.', 'keepprev');

        %%% Plot points
        p1 = plot(varied_param, dist, markers{2}, ...
                   'linewidth', LINEWIDTH, ...
                   'markersize', round(MARKERSIZE * 1), ...
                   'Color', colorVecs(5, :));
               
        %%% Plot Practical Limits on Parameter
        ymin = min(dist);
        ymax = max(dist) * 1.5;
        NUM_DATA_PTS = 100;
        
        y_vec = linspace(ymin, ymax, NUM_DATA_PTS);
        
        % create limits on parameter
        param_low_vec = ones(NUM_DATA_PTS, 1) * param_limits_low(i);
        param_high_vec = ones(NUM_DATA_PTS, 1) * param_limits_high(i);
        
        p2 = plot(param_low_vec, y_vec, ':', ...
                  'linewidth', LINEWIDTH, 'Color', [0 0 0]);
        p3 = plot(param_high_vec, y_vec, ':', ...
                  'linewidth', LINEWIDTH, 'Color', [0 0 0]);
              
        
        %%% Plot Optimal Param Value to Maximize Downrange Distance within
        %%% the paractical limits defined above
        
        % find parameter that maximizes range within the given practical
        % bounds.
        valid_idx = and(varied_param > param_limits_low(i), ...
                        varied_param < param_limits_high(i));
        idx_offset = find(valid_idx, 1) - 1;
        [optimal_dist, optimal_idx] = max(dist(valid_idx));
        optimal_param = varied_param(optimal_idx + idx_offset);
        
        % check if max value was found in the pratical bounds for the
        % current sensitivity variable
        if isempty(optimal_dist) || isempty(optimal_param) 
        
            disp('Warning: No maximizing parameter found in bounds.')
            plot_vec = [p1 p2 p3]; 
            
        else
            p4 = plot(optimal_param, optimal_dist, markers{12}, ...
                   'linewidth', LINEWIDTH, ...
                   'markersize', round(MARKERSIZE * 2), ...
                   'Color', colorVecs(7, :));
            plot_vec = [p1 p2 p3 p4];
        end
        
        %% Plot Settings
        
        % axes limits
        xmin = min(varied_param);
        xmax = max(varied_param);
        
        ymin = min(dist);
        ymax = max(dist) * 1.05;
        
        % legend
        leg_string = {sprintf('Distance Acheived with varied %s', sens_names{i}), ...
                      sprintf('Practical Low Limit on %s = %0.3g %s', ... 
                      sens_names{i}, param_limits_low(i), sens_units{i}), ...
                      sprintf('Practical High Limit on %s = %0.3g %s', ... 
                      sens_names{i}, param_limits_high(i), sens_units{i}), ...
                      sprintf('Optimal %s = %0.3g %s', sens_names{i},...
                      optimal_param, sens_units{i})};
        
        % format plot
        xlim([xmin, xmax])
        ylim([ymin, ymax])
        xlabel(sprintf('%s %s', sens_names{i}, sens_units{i})) 
        ylabel('Downrange Distance (m)')
        title( sprintf('%s''s Effect on Downrange Distance',...
               title_strang{i}), 'fontsize', round(FONTSIZE * SCALE_FACTOR))
           
        legend(plot_vec, leg_string, ...
               'location', 'best', 'interpreter', 'latex');
                 
        set(gca,'FontSize', FONTSIZE)
        set(gca, 'defaulttextinterpreter', 'latex')
        set(gca, 'TickLabelInterpreter', 'latex')
        grid on

        hold off
        
        
        %% setup and save figure as .pdf
        if shouldSaveFigures
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
        end

        fprintf('\n')

    end

end