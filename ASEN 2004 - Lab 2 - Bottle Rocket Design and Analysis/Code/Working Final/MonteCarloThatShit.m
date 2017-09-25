function MonteCarloThatShit(modelInUse, shouldSaveFigures, ...
                            NUM_MC_ITERATIONS)

    %% setup
    % Pre-allocate
    [x, y] = deal(zeros(1, NUM_MC_ITERATIONS));
    
    % printing Progress
    dispstat('','init'); % One time only initialization
    dispstat(sprintf('Starting Simulation Cycles...'), ...
             'keepthis');
         
    saveLocation = '../../Figures/';
    saveTitle = cat(2, saveLocation, sprintf('%s.pdf', 'Monte Carlo'));
         
    
    % set which parameters to use in ODE45 based on whether you are doing
    % sensitivity analysis, finding 85m params, or running a verification
    % case
    run_sens_analysis = false;
    runMonteCarlo = true;
    run_verification_case = false;

    % set global bools that control parameter data flow
    setGlobalBools(run_sens_analysis, runMonteCarlo, run_verification_case);
    
    
    %% RUN MC SIMULATIONN 
    for i = 1:NUM_MC_ITERATIONS
        
        % set global random parameters
        setMCGlobals;

        %% define initial conditions and flight variables

        % Initialize variables, return initial conditions vector
        [~, init_conds] = getInput(run_sens_analysis, ...
                                   runMonteCarlo, ...
                                   run_verification_case);

        % Definging the range of time values to solve the system of
        % ODEs
        INIT_TIME = 0; % seconds
        FINAL_TIME = 5; % last time of projectile - seconds
        time_interval = [INIT_TIME, FINAL_TIME];

        % Set stopping conditions for ODE45
        opts = odeset('Events', @odeStopFunc);

        %% Solve System of ODEs and return numeric results 
        [~, rocketVars] = ode45(modelInUse, ...
                                time_interval, init_conds, opts);
                            
        x(i) = rocketVars(end, 1);
        y(i) = rocketVars(end, 2);
        
        dispstat(sprintf('Progress %0.0f%%', i/NUM_MC_ITERATIONS * 100));
    end
        
       
    
    figure; plot(x,y,'k.','markersize',6)
    axis equal; grid on; xlabel('x [m]'); ylabel('y [m]'); hold on;
    
    %% DO some PCA bro
    
    %%% Calculate covariance matrix
    P = cov(x,y);
    mean_x = mean(x);
    mean_y = mean(y);
    % Calculate the define the error ellipses
    n=100; % Number of points around ellipse
    p=0:pi/n:2*pi; % angles around a circle
    [eigvec,eigval] = eig(P); % Compute eigen-stuff
    xy_vect = [cos(p'),sin(p')] * sqrt(eigval) * eigvec'; % Transformation
    x_vect = xy_vect(:,1);
    y_vect = xy_vect(:,2);
    % Plot the error ellipses overlaid on the same figure
    plot(1*x_vect+mean_x, 1*y_vect+mean_y, 'b')
    plot(2*x_vect+mean_x, 2*y_vect+mean_y, 'g')
    plot(3*x_vect+mean_x, 3*y_vect+mean_y, 'r')
    
    
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
    
end