function truss3d_main_simulation(inputfile, use_dynamic_FOS)
   
    % function truss3d_main_simulation(inputfile, use_dynamic_FOS)
    %
    % Stochastic analysis of 3-D statically determinate truss by
    % Monte Carlo Simulation. Only positions and strength of joints
    % treated as random variables
    %
    % Assumption: variation of joint strength and positions described
    %             via Gaussian distributions
    %
    %             joint strength : mean = 4.8N
    %                              std-dev of joint strength = 0.4N
    %             joint position :
    %                              coefficient of varation = 0.01
    %                              (defined wrt to maximum dimension of truss)
    %
    %             number of samples is set to 1e3
    %
    % Input:  inputfile  - name of input file
    %         use_dynamic_FOS - True: run cycle of monte carlo simulations
    %                                 to determine FOS based on covergence
    %                                 of probabilities of failure.
    %                           
    %                           False: only run monte carlo simulation once
    %                                  with FOS = 1 for analyzing external
    %                                  loading.
    %
    % Author: Kurt Maute for ASEN 2001, Oct 13 2012
    %
    % Updated to 3d on 10/10/16 by
    % Alexis Sotomayor & Nicholas Renninger
    
    clc

    % parameters
    MEAN_JOINT_STRENGTH              = 4.8;     % mean of joint strength
    JOINT_STRENGTH_VARIATION         = 0.4;     % standard deviation of distribution of joint strength
    JOINT_POSITION_COEF_VARIATION    = 0.01;    % coefficient of variation of joint position
    PROBABILITY_FAILURE              = 1e-6;    % accepted starting probability of truss failure
    NUM_SAMPLES                      = 1e4;     % number of samples in monte carlo simulation
    NUM_PROBABILITY_SAMPLES          = 1e3;     % number of times to run whole simulation to find optimal probability / FOS
    current_probability_of_failure   = 0.5;     % defines starting probability to begin solution algorithm
    
    
    
    if use_dynamic_FOS
        
        % compute how much to increase PROBABILITY_FAILURE by each time
        % simulation is run
        probability_step_size = (current_probability_of_failure - PROBABILITY_FAILURE) / NUM_PROBABILITY_SAMPLES;
        
        % intializations
        probability_theoretical_vec = zeros(NUM_PROBABILITY_SAMPLES, 1);
        probability_MC_vec = zeros(NUM_PROBABILITY_SAMPLES, 1);
        FOS_vec = zeros(NUM_PROBABILITY_SAMPLES, 1);
        
        for j = 1:NUM_PROBABILITY_SAMPLES

            if current_probability_of_failure > PROBABILITY_FAILURE % keep computing probabilities until you

                % run monte carlo simulation on the current FOS condition
                [current_probability_of_failure, FOS, maxForces, maxReact] = truss3d_monteCarlo(inputfile, NUM_SAMPLES,...
                                                                               MEAN_JOINT_STRENGTH, JOINT_STRENGTH_VARIATION,...
                                                                               JOINT_POSITION_COEF_VARIATION, PROBABILITY_FAILURE, ...
                                                                               use_dynamic_FOS);

                fprintf('Current Simulation Cycle: %d/%d\n', j, NUM_PROBABILITY_SAMPLES);
                fprintf('The theoretical probability of failure for this trusss is: %f\n', PROBABILITY_FAILURE);
                fprintf('The current probability of failure for this trusss is: %f\n', current_probability_of_failure);
                fprintf('The safety factor for this trusss is: %f\n\n', FOS);


                % Adjust PROBABILITY_FAILURE up each time whole simulation is
                % run, based on number of times to run whole simulation
                PROBABILITY_FAILURE = PROBABILITY_FAILURE + probability_step_size;
                probability_theoretical_vec(j) = PROBABILITY_FAILURE;
                probability_MC_vec(j) = current_probability_of_failure;
                FOS_vec(j) = FOS;

            else 

                % break loop the first time the calculated probability matches
                % the theoretical one. The two probabilities will then be as
                % close as possible to each other for the number of samples run
                break
            end

        end
        
            figure(1);

            fig1 = semilogx(probability_theoretical_vec, FOS_vec, probability_MC_vec, FOS_vec, 'LineWidth', 3);
            hold on
            plot(current_probability_of_failure, FOS, 'o', 'MarkerSize', 9);
            set(gca,'FontSize', 26)
            set(figure(2), 'Position', [100 100 1600 900])
            xlim([min(probability_theoretical_vec)*1.1, max(probability_MC_vec) * 1.1])
            ylim([1 + 0.1*max(FOS_vec), max(FOS_vec)])
            xlabel('Probability of Failure') 
            ylabel('FOS')
            titleString = sprintf('FOS vs. Probability of Failure');
            title(titleString)
            legendString = {'Initial Probability Guess', 'Probability Calculated in Monte Carlo Simulation'};
            legend(fig1, legendString, 'location', 'north')
            hold off
        
    else
        
        % run monte carlo simulation on the current FOS condition
        [current_probability_of_failure, FOS, maxForces, maxReact] = truss3d_monteCarlo(inputfile, NUM_SAMPLES,...
                                                                       MEAN_JOINT_STRENGTH, JOINT_STRENGTH_VARIATION,...
                                                                       JOINT_POSITION_COEF_VARIATION, PROBABILITY_FAILURE, ...
                                                                       use_dynamic_FOS);
        
    end
    
    figure(2);
 
    subplot(1,2,1);
    hist(maxForces, 30);
    set(gca,'FontSize', 26)
    title('Histogram of maximum bar forces');
    xlabel('Magnitude of bar forces');
    ylabel('Frequency');

    subplot(1,2,2);
   
    hist(maxReact, 30);
    set(gca,'FontSize', 26)
    title('Histogram of maximum support reactions');
    xlabel('Magnitude of reaction forces');
    ylabel('Frequency');
    
    fprintf('\nFailure probability : %0.5f percent \nFOS: %f\n', current_probability_of_failure * 100, FOS);

end