function Problem2()

    %%% Numeric Simulation of Lift and Drag over a NACA 0012 Airfoil 
    %%%
    %%% Returns lift and drag per unit span for the airfoil by numerically
    %%% intergrating the pressure distribution around the airfoil using the
    %%% trapezoidal rule.
    %%%
    %%% Last Modified: 9/13/2017
    %%% Date Created: 9/3/2017
    %%% Author: Nicholas Renninger

    fprintf('Entering Problem 2 Solution.\n')
    tic
    
    
    %% Define Numeric and Output Constants
    
    % number of iterations to perform (# of panels)
    N = 1e7;

    % filepath to data file and to output folder
    filepath_data = '../Data/';

    % filename of data and output file
    filename_data = 'Cp.mat';

    % full filename of data file
    fname_full_data = cat(2, filepath_data, filename_data);
    
    % turn on printing initially
    shouldPrint = true;

    
    %% Load in Data from file
    fprintf('Loading c_p Spline Data from %s ...\n', fname_full_data)

    spline_data = load(fname_full_data);
    fprintf('c_p Spline Data Loaded.\n')
    
    
    %% "Exact Analysis"
    
    [L_prime, D_prime] = find_L_D_Problem_2(N, spline_data, shouldPrint);


    %% Find the Number of Trapezoids needed for %error

    %{  
        Error Notes:
        |u - u_n| approx =  CN^-2
        |u - u_2n| <= |u - u_2n| + |u_2n - u_n|

        where |u - u_2n| goes to C/4 N^-2:

        |u_2n - u_n| >= 3/4CN^-2 = 3/4 |u - u_n|
        |u - u_2n| <= 4/3 |u_2n - u_n| 
    %}

    % define each of the relative errors, assuming that L_prime is the
    % "exact solution"
    rel_err(1) = L_prime * 0.05;    % 5%   error
    rel_err(2) = L_prime * 0.01;    % 1%   error
    rel_err(3) = L_prime * 0.001;   % 0.1% error
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Start by approximating the N (# of panels) needed to compute
    %%% L_prime to each of the relative errors by first calculating the
    %%% rel. error at k points equispaced in the N domain:
    %%% (dN = (N-0) / k)
    %%% Then create a best fit line to these 10 points and then base a
    %%% naive local grid search on the location in N of each rel. error.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % define the # of divisions of the N-domain, k
    k = 100;
    max_N = 10000;
    temp_N = 10;
    L = k^(log(max_N) / 7.4); 
    
    % turn off printing of progress
    shouldPrint = false;
    
    fprintf(['\nCalculating fit curve using %d points', ...
            ' to determine grid search start points...\n'], k)
    
    % calculate rel. error across domain
    for i = 1:k
        
        % Find L' with the new N (i)
        [L_prime_temp, ~] = find_L_D_Problem_2(temp_N(i), spline_data, ...
                                               shouldPrint);

        % store the rel. error for each
        rel_error_approx_vec(i) = abs(L_prime_temp - L_prime);
       
        % Re-calculate each N with variable step size, to preserve more
        % accuracy at lower N
        dN(i) = ceil( L * ( (temp_N(i) / (max_N))^2 - ...
                            (temp_N(i) / (max_N))^3 ) * max_N/k );
        temp_N(i+1) = temp_N(i) + dN(i);
        
        % if temp_N becomes the size of the exact solution, then stop the 
        if temp_N(i+1) > max_N
            
            break
        end
        
        
    end
    
    % trim the vector with the Ns used to find L'
    temp_N = temp_N(1:end-1);
    
    % Now use a line of best fit to start the grid search
    err_fit_fcn = fit(temp_N', rel_error_approx_vec', 'smoothingspline');
    N_vec = 1:N;
    err_fit_vec = feval(err_fit_fcn, N_vec);
    
    fprintf('Done computing fit curve.\n')
    disp(err_fit_fcn)
    fprintf('\n')
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Now find the Ns that match the error criteria defined at the top to
    %%% start the grid search
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % define the percentage of the given rel. err range to search
    search_range = 0.1; 
    
    % search for values within (search_range * 100)% of the 5% rel. error
    FUDGE_five = rel_err(1) * search_range; 
    five_idxs = find(abs(err_fit_vec - rel_err(1)) < FUDGE_five, ...
                     1, 'first');
    search_N(1) = round(median(five_idxs));
    
    % search for values within (search_range * 100)% of the 1% rel. error
    FUDGE_one = rel_err(2) * search_range; 
    one_idxs = find(abs(err_fit_vec - rel_err(2)) < FUDGE_one, ...
                     1, 'first');
    search_N(2) = round(median(one_idxs));
    
    % search for values within (search_range * 100)% of the 0.1% rel. error
    FUDGE_tenth = rel_err(3) * search_range; 
    tenth_idxs = find(abs(err_fit_vec - rel_err(3)) < FUDGE_tenth, ...
                     1, 'first');
    search_N(3) = round(median(tenth_idxs));
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Start a linear search for each N that satisfies the given rel.
    %%% error conditions, given the starting search indices.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    dispstat('', 'init'); % One time only initialization
    start_str = sprintf(['Starting search for 5%%, 1%%, and 0.1%% ', ...
                'rel. errors at N = %d, %d, & %d, respectively...'], ...
                search_N(1), search_N(2), search_N(3));
    dispstat( start_str, 'keepthis' );
                
                
    % initialize the solution vector
    [N_sol] = deal(nan(1,3));
    
    for j = 1:3
        
        curr_search_N = search_N(j);
        
        %%% calculate the N-domain to search over
        
        % Search +/- 5% of the search N value, minimum domain being: 
        % N = +/- 10
        N_offset = round(curr_search_N * 0.05) + 10;
        
        startN = curr_search_N - N_offset;
        endN = curr_search_N + N_offset;
        
        % error checking bounds
        if startN < 2
            startN = 2;
        end
        
        if endN > N
            endN = N;
        end
        
        %%% create variables used in the domain search
        
        % Initialize the N vector 
        curr_N_vec = startN:1:endN;
        
        % define the largest possible error to be the "exact" L'
        curr_target_error = rel_err(j);
        curr_rel_error = L_prime;
        
        % search this domain for the first value of N that gives the
        % desired rel. error
        
        i = 1;
        while curr_rel_error > curr_target_error
            
            currN = curr_N_vec(i);
            
            % Find L' with the new N (i)
            [L_prime_temp, ~] = find_L_D_Problem_2(currN, ...
                                                   spline_data, ...
                                                   shouldPrint);
                                               
            % store the rel. error for each
            curr_rel_error = abs(L_prime_temp - L_prime);
            
            
            % loop was mistargeted, so expand the search domain
            % dynamically
            if currN == endN
                curr_N_vec = [curr_N_vec, endN:endN + 1000];
                endN = curr_N_vec(end);
            end
            
            % save the rel. error for plotting
            actual_rel_err{j}(i) = curr_rel_error;
            actual_N_vec{j}(i) = currN;
            
            i = i + 1;
            
        end
        
        % store the N value used for the previous computation before going
        % past the required accuracy
        N_sol(j) = curr_N_vec(i - 2) + 1;
        
        dispstat(sprintf('Progress %0.0f%%', j/3 * 100));
        
    end
    
    
    %% Print Results
    
    cprintf('UnterminatedStrings', ...
            '\n=====================================================\n');
    cprintf('hyper',...
            '"Exact" Lift and Drag Results with %0.0e Panels:\n', N);
    cprintf('key', 'L'' = %0.4g [N/m]\n', L_prime)
    cprintf('key', 'D'' = %0.4g [N/m]\n\n', D_prime)
    
    
    cprintf('UnterminatedStrings', ...
            '=====================================================\n')
    
    cprintf('hyper', ...
            'Rel. Err. of 5%%:\n')
    cprintf('key', ...
            ['Estimated N = %d, Actual N = %d\n', ...
             'Initial N search targeting %% error: %0.1f%%\n\n'], ...
             search_N(1), N_sol(1), ...  
             (abs(N_sol(1) - search_N(1)) / search_N(1)) * 100)

    cprintf('hyper', ...
            'Rel. Err. of 1%%:\n')
    cprintf('key', ...
            ['Estimated N = %d, Actual N = %d\n', ...
             'Initial N search targeting %% error: %0.1f%%\n\n'], ...
             search_N(2), N_sol(2), ...  
             (abs(N_sol(2) - search_N(2)) / search_N(2)) * 100)
         
    cprintf('hyper', ...
            'Rel. Err. of 0.1%%:\n')
    cprintf('key', ...
            ['Estimated N = %d, Actual N = %d\n', ...
             'Initial N search targeting %% error: %0.1f%%\n\n'], ...
             search_N(3), N_sol(3), ...  
             (abs(N_sol(3) - search_N(3)) / search_N(3)) * 100)
         
    
    %% Plot Results
    
    disp('Plotting Results...')
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Plot Setup
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(0, 'defaulttextinterpreter', 'latex');
    saveLocation = '';
    LINEWIDTH = 2.5;
    MARKERSIZE = 6;
    FONTSIZE = 21;
    colors = linspecer(6);
    LINE_SCALE_DOWN = 0.8;
    MARKER_SCALE_UP = 3;
    
    % text params
    TEXT_SCALE_DOWN = 0.8;
    Y_POS_SCALE = 1.15;
    TEXT_X_POS = 600;

    shouldSaveFigures = true;
    
    titleString = sprintf('rel_err_vs_N');

    % setup plot saving
    saveTitle = cat(2, saveLocation, sprintf('%s.pdf', titleString));

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Plot Results
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % create vectors to show where 5, 1, and 0.1 percent error is
    rel_err_vec{1} = rel_err(1) .* ones(1,N);
    rel_err_vec{2} = rel_err(2) .* ones(1,N);
    rel_err_vec{3} = rel_err(3) .* ones(1,N);
    
    hFig = figure('name', titleString);
    scrz = get(groot, 'ScreenSize');
    set(hFig, 'Position', scrz)


    % best fit line search pts and fit line
    p2 = plot(N_vec, abs(err_fit_vec), '-', ...
              'markersize', MARKERSIZE, ...
              'linewidth', LINEWIDTH, ...
              'color', colors(2, :), ...
              'MarkerFaceColor', [0.8, 0.8, 0.8]);
    hold on
    p1 = plot(temp_N, rel_error_approx_vec, ...
              'o', 'markersize', MARKERSIZE, ...
              'linewidth', LINEWIDTH, ...
              'color', colors(1, :), ...
              'MarkerFaceColor', [0.9, 0.9, 0.9]);
    
    % Rel. Err. lines
    plot(N_vec, rel_err_vec{1}, 'k:',...
         'linewidth', LINEWIDTH * LINE_SCALE_DOWN);
    text(TEXT_X_POS, rel_err(1)*Y_POS_SCALE, ...
        ['Rel. Err of 5\%', sprintf(' = %0.2g $[N/m]$', rel_err(1))], ...
        'fontsize', FONTSIZE*TEXT_SCALE_DOWN)
    
    plot(N_vec, rel_err_vec{2}, 'k:', ...
         'linewidth', LINEWIDTH * LINE_SCALE_DOWN);
    text(TEXT_X_POS, rel_err(2)*Y_POS_SCALE, ...
        ['Rel. Err of 1\%', sprintf(' = %0.2g $[N/m]$', rel_err(2))], ...
        'fontsize', FONTSIZE*TEXT_SCALE_DOWN)
    
    plot(N_vec, rel_err_vec{3}, 'k:', ...
         'linewidth', LINEWIDTH * LINE_SCALE_DOWN);
    text(TEXT_X_POS - 450, rel_err(3)*Y_POS_SCALE, ...
        ['Rel. Err of 0.1\%', sprintf(' = %0.2g $[N/m]$', rel_err(3))], ...
        'fontsize', FONTSIZE*TEXT_SCALE_DOWN)

    % Actual N values
    
    for i = 1:3
        p6 = plot(actual_N_vec{i}, actual_rel_err{i}, 'cs', ...
                  'markersize', MARKERSIZE * MARKER_SCALE_UP);
    end
    
    p3 = plot(N_sol(1), rel_err(1), ...
              'p', 'markersize', MARKERSIZE * MARKER_SCALE_UP, ...
              'color', colors(3, :), ...
              'MarkerFaceColor', colors(3, :));

    p4 = plot(N_sol(2), rel_err(2), ...
              'p', 'markersize', MARKERSIZE * MARKER_SCALE_UP, ...
              'color', colors(4, :), ...
              'MarkerFaceColor', colors(4, :));
          
    p5 = plot(N_sol(3), rel_err(3), ...
              'p', 'markersize', MARKERSIZE * MARKER_SCALE_UP, ...
              'color', colors(5, :), ...
              'MarkerFaceColor', colors(5, :));    
    
   
    % plot formatting
    set(gca, 'YScale', 'log')
    xlabel('N')
    ylabel('Rel. Error $[N/m]$')
    title(['Variance of Rel. Error in $L''$ Calculation', ...
           ' with \# of Panels (N) Used'])
    legend([p1, p2, p3, p4, p5, p6], ...
           {'Initial Search Grid Points',...
            'Spline Fit', ...
            ['Rel. Err of 5\%', sprintf(' at  N = %d', N_sol(1))], ...
            ['Rel. Err of 1\%', sprintf(' at  N = %d', N_sol(2))], ...
            ['Rel. Err of 0.1\%', sprintf(' at  N = %d', N_sol(3))], ...
            'Values of N Actually Checked'}, ...
           'interpreter', 'latex', ...
           'location', 'best')

    set(gca, 'defaulttextinterpreter', 'latex')
    set(gca, 'TickLabelInterpreter', 'latex')

    ylim([1e-2, 1e2])
    xlim([0, 1000])

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
    
    
    % show figures again
    set(0,'DefaultFigureVisible','on')
    figure(1)
    figure(2)
    
    toc
    fprintf('Finished Problem 2 Computation.\n')
    cprintf('UnterminatedStrings', ...
            '=====================================================\n')

end