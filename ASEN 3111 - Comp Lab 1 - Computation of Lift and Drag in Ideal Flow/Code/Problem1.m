function Problem1()

    %%% Numeric Simulation of Lift and Drag over a cylindrical Airfoil
    %%%
    %%% Returns lift and drag per unit span for the airfoil by numerically
    %%% intergrating the pressure distribution around the airfoil using
    %%% Simpson's rule.
    %%%
    %%% Last Modified: 9/13/2017
    %%% Date Created: 9/3/2017
    %%% Author: Nicholas Renninger
    
    fprintf('Entering Problem 1 Solution.\n')
    tic
    
    
    %% Define Numeric and Output Constants
    
    % number of iterations to perform (# of panels)
    N = 1e7;
    
    % define limits of integration
    B = 2*pi;                               % [rad]
    A = 0;                                  % [rad]

    % x-step size. x_k = a + (k - 1)*h
    H = (B - A) / N;                        % [rad]
    
    % Theta vector for integration
    theta = linspace(A, B, N+1);              % [rad]
    
    
    %% Define Flow & Airfoil Constants
    
    % Givens
    D = 2;                                  % [m]
    V_INF = 25;                             % [m/s]
    RHO_INF = 0.9093;                       % [kg/m^3]
    P_INF = 7.012e4;                        % [Pa]
    
    % Analytic expression for c_p
    c_p = @(theta) 1 - 4 .* (sin(theta)).^2;
    
    % Computed constants
    r = D/2;                                % [m]
    q_inf = (1/2) * RHO_INF * V_INF^2;      % [Pa]
    
    
    %% Calculate L' and D' Using Numeric Integration via Simpson's Rule
    
    % start L' and D' sums at 0
    [L_prime, D_prime] = deal(0);
    
    % printing Progress
    dispstat('', 'init'); % One time only initialization
    dispstat( sprintf('Starting Numeric Integration with %0.1e Panels...', ...
                       N), 'keepthis' );
    
    % Numeric Integration. Summation of three terms from k = [1, N/2]
    for k = 1:(N/2)
        
        % Define prev, curr, and next Pressures along theta to reduce code
        % motion.
        P_theta_prev = c_p(theta(2*k - 1)) + q_inf; % [Pa]
        P_theta_curr(k) = c_p(theta(2*k)) + q_inf;     % [Pa]
        P_theta_next = c_p(theta(2*k + 1)) + q_inf; % [Pa]
        
        
        % Define Summed Terms 
        sum_L = P_theta_prev * sin(theta(2*k - 1)) + ...
                4*P_theta_curr(k) * sin(theta(2*k)) + ...
                P_theta_next * sin(theta(2*k + 1)); % [Pa]
        
        sum_D = P_theta_prev * cos(theta(2*k - 1)) + ...
                4*P_theta_curr(k) * cos(theta(2*k)) + ...
                P_theta_next * cos(theta(2*k + 1)); % [Pa]
            
        % Simpson's Rule Summing
        L_prime = L_prime + sum_L;
        D_prime = D_prime + sum_D;
        
        
        % Print Progress at 5% intervals
        if mod(k, round(N/20)) == 0
            dispstat(sprintf('Progress %0.0f%%', k/(N/2) * 100));
        end
        
    end
    
    disp('Finished Numeric Integration')
    
    
    %% Process Results of Numeric Integration
    
    % Finish Simpson's Rule Calculations
    L_prime = -r * (H/3) * L_prime;
    D_prime = -r * (H/3) * D_prime;
    
    cprintf('UnterminatedStrings', ...
            '\n=====================================================\n');
    cprintf('hyper',...
            '"Exact" Lift and Drag Results with %0.0e Panels:\n', N);
    cprintf('key', 'L'' = %0.5g [N/m]\n', L_prime)
    cprintf('key', 'D'' = %0.5g [N/m]\n\n', D_prime)
    
    
    %% Plot c_p vs. x/c
    
    % make the chordwise position vector
    x_0_R_vec = linspace(0, r, 100);
    x_R_2R_vec = linspace(r, D, 100);
    x_c_vec = [x_0_R_vec, x_R_2R_vec] ./ D;
    
    % define theta as a function of chordwise position
    theta_0_90 = @(x) acos( (x - r) ./ r );
    theta_90_180 = @(x) 2*pi - acos( (x - r) ./ r );
    theta_v_plot = [theta_0_90(x_0_R_vec), theta_90_180(x_R_2R_vec)];
    
    % get cp
    cp_upper = c_p(theta_v_plot);
    cp_lower = -cp_upper;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Plot Results
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % hide figures until computation is over
    set(0,'DefaultFigureVisible','off')
    
    % Plot Setup
    set(0, 'defaulttextinterpreter', 'latex');
    saveLocation = '';
    LINEWIDTH = 2.5;
    FONTSIZE = 21;
    colors = linspecer(2);
    colors_hsv = rgb2hsv(colors);

    shouldSaveFigures = true;
    
    titleString = sprintf('cp_vs_x_c');

    % setup plot saving
    saveTitle = cat(2, saveLocation, sprintf('%s.pdf', titleString));

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Plot Results
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    hFig = figure('name', titleString);
    scrz = get(groot, 'ScreenSize');
    set(hFig, 'Position', scrz)
    
    p3 = area(x_c_vec, -cp_upper);
    hold on
    p4 = area(x_c_vec, -cp_lower);
    p1 = plot(x_c_vec, -cp_upper, ...
         'linewidth', LINEWIDTH, ...
         'color', colors(1, :)*0.8);
    p2 = plot(x_c_vec, -cp_lower, ...
         'linewidth', LINEWIDTH, ...
         'color', colors(2, :));
   
    % plot formatting
    xlabel('$x/c$')
    ylabel('$-C_p$')
    legend([p1, p2], ...
           {'Upper Surface',...
            'Lower Surface'}, ...
           'interpreter', 'latex', ...
           'location', 'best')
    
    % Adjust Saturation Values of shaded area, then convert back to rgb
    K = 4;
    colors_hsv(1,2) = colors_hsv(1,2) / K;
    colors_hsv(2,2) = colors_hsv(2,2) / K;
    
    p3(1).EdgeColor = 'none';   
    p3(1).FaceColor = hsv2rgb(colors_hsv(1, :));
    p3(1).ShowBaseLine = 'off';
    
    p4(1).EdgeColor = 'none'; 
    p4(1).FaceColor = hsv2rgb(colors_hsv(2, :));
    p4(1).ShowBaseLine = 'off';

    set(gca, 'defaulttextinterpreter', 'latex')
    set(gca, 'TickLabelInterpreter', 'latex')

    ylim([-3, 6])
    xlim([0, 1])

    h = gca;
    leg = h.Legend;
    titleStruct = h.Title;
    set(titleStruct, 'FontWeight', 'bold')
    set(gca, 'FontSize', FONTSIZE)
    set(leg, 'FontSize', round(FONTSIZE * 0.7))

    grid on


    %% Save data to tables and save plot

    % setup and save figure as .pdf
    saveMeSomeFigs(shouldSaveFigures, saveTitle)
    
    if shouldSaveFigures
        fprintf('Saved Figure to %s\n', saveTitle)
    end
    
    toc
    cprintf('Finished Problem 1 Computation.\n')
    cprintf('UnterminatedStrings', ...
            '=====================================================\n\n');
        
end