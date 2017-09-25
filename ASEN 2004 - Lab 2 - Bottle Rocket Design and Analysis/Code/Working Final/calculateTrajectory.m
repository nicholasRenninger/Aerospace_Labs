function calculateTrajectory(modelInUse, shouldSaveFigures, figName)

    %% define initial conditions and flight variables
    
    % set which parameters to use in ODE45 based on whether you are doing
    % sensitivity analysis, finding 85m params, or running a verification
    % case
    run_sens_analysis = true;
    find_85m_range = false;
    run_verification_case = false;

    % set global bools that control parameter data flow
    setGlobalBools(run_sens_analysis, find_85m_range, run_verification_case);

    % Initialize variables, return initial conditions vector
    [~, init_conds] = getInput(run_sens_analysis, ...
                               find_85m_range, ...
                               run_verification_case);

    % Definging the range of time values to solve the system of
    % ODEs
    INIT_TIME = 0; % seconds
    FINAL_TIME = 10; % last time of projectile - seconds
    time_interval = [INIT_TIME, FINAL_TIME];

    % Set stopping conditions for ODE45
    opts = odeset('Events', @odeStopFunc);

    %% Solve System of ODEs and return numeric results 
    [t, rocketVars] = ode45(modelInUse, ...
                            time_interval, init_conds, opts);

    rocketPlot( rocketVars, t, shouldSaveFigures, figName )
   


end