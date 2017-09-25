%% ASEN 2003: Dynamics & Systems - Spring 2017
% Project: Rolling Wheel Lab (#4)
% Project Members:  Joseph Grengs
%                   Kian Tanner
%                   Nicholas Renniger
%
%
% Function takes all of the constants defined in the main script and
% calculates the optimal M value with a monte carlo simulation, then
% calculates the expected omega values using each model, calculates
% statistics on the residual, then plots theh results.
%
% Project Due Date: Thursday, March 16, 2017 @ 4:00p
% MATLAB Code Created on: 03/02/2017
% MATLAB Code last updated on: 03/15/2017


function load_and_Analyze_Data(constants)

    unBal_Idx = 1;
    bal_Idx = 1;
    NUM_PLOT_PTS = constants(end - 1);
    shouldSaveFigures = constants(end);
    
    % Look for data files in directory
    listing = dir('*.txt');

    for i = 1:length(listing)
        %% Read in Files
        filename = listing(i);
        name = filename.name;

        data = load(name);
        search = find(data(:,2) > 0.5 & data(:,2) < 15);
        time = data(search, 1);
        theta = data(search, 2);
        omega = data(search, 3);

        [~, val] = sort(theta);
        
        % determine if the data is from unbalanced or balanced test trials
        % and save it in the appropriate structure
        if char(name(1:2)) == ('un')
           
            theta_exp.unbalanced{unBal_Idx} = theta(val);
            time_exp.unbalanced{unBal_Idx} = time(val);
            
            % vector containing the omega used for the model calculation
            theta_mod.unbalanced{unBal_Idx} = linspace(min(theta), ...
                                                       max(theta), ...
                                                       NUM_PLOT_PTS);
            time_mod.unbalanced{unBal_Idx} = linspace(min(time), ...
                                                      max(time), ...
                                                      NUM_PLOT_PTS);
            
            omega_exp.unbalanced{unBal_Idx} = omega(val);
            unBal_Idx = unBal_Idx + 1;
            
        else
            
            theta_exp.balanced{bal_Idx} = theta(val);
            time_exp.balanced{bal_Idx} = time(val);
            
            % vector containing the omega used for the model calculation
            theta_mod.balanced{bal_Idx} = linspace(0, ...
                                                   max(theta), ...
                                                   NUM_PLOT_PTS);
            time_mod.balanced{bal_Idx} = linspace(min(time), ...
                                                  max(time), ...
                                                  NUM_PLOT_PTS);
                                                   
            omega_exp.balanced{bal_Idx} = omega(val);
            bal_Idx = bal_Idx + 1;
            
        end
        
        
    end
    
    %% Calculate M using the data from the balanced trial, using Model 2
    
    tic
    modelUsed = 2;
    M_lims = [0, 1.5]; % set limits for monte carlo search for optimal M
    
    % find optimal M for each trial run and avg. to find experimental M
    for i = 1:length(omega_exp.balanced)
        M_vec(i) = monteCarloCalcM(M_lims, omega_exp.balanced{i}, ...
                            theta_exp.balanced{i}, constants, modelUsed);
    end
    toc
    
    % avg the M found for each trial
    M = mean(M_vec);
                             
    fprintf('Optimal Value of M: %0.3g N*m\n', M)
  
    
    % Calculate the Model 1 and 2 Omega and their Residuals
    for i = 1:length(theta_exp.balanced)
        
        modelUsed = 1;
        omega_mod_res_1{i} = calcModelOmega(theta_exp.balanced{i}, M, ...
                                     constants, modelUsed);
        omega_mod_1{i} = calcModelOmega(theta_mod.balanced{i}, M, ...
                                     constants, modelUsed);

        modelUsed = 2;
        omega_mod_res_2{i} = calcModelOmega(theta_exp.balanced{i}, M, ...
                                     constants, modelUsed);
        omega_mod_2{i} = calcModelOmega(theta_mod.balanced{i}, M, ...
                                     constants, modelUsed);
                                 
        % Calculate Residuals for both models
        residual_vec_model_1{i} = ( omega_exp.balanced{i} - ...
                                    omega_mod_res_1{i} )';
        residual_vec_model_2{i} = ( omega_exp.balanced{i} - ...
                                    omega_mod_res_2{i} )';
                                
        
        % Calculate Statistics for Models 1 and 2
        dataType = sprintf('Balanced Wheel Trial %d - Model 1 Residuals', i);
        calcStatistics(residual_vec_model_1{i}, dataType);
        dataType = sprintf('Balanced Wheel Trial %d - Model 2 Residuals', i);
        calcStatistics(residual_vec_model_2{i}, dataType);
        
        % Packaging Data for plotting
        theta_exp_for_plot{i} = theta_exp.balanced{i};
        omega_exp_for_plot{i} = omega_exp.balanced{i};
        theta_mod_for_plot{i} = theta_mod.balanced{i};
        
    end
        
    
    %%% Plot Results for Balanced Wheel analysis, Model 1 and 2
    testString = sprintf('Balanced Wheel - Models 1 and 2');
    modelsTested = {'1', '2'};
    outputData(theta_exp_for_plot, theta_mod_for_plot, ...
               omega_exp_for_plot, ...
               omega_mod_1, omega_mod_2, ...
               residual_vec_model_1, residual_vec_model_2, ...
               testString, modelsTested, shouldSaveFigures);
    fprintf('\n\n\n')
           
    %% Calculate the Model 3 and 4 Omega and their Residuals
    for i = 1:length(theta_exp.unbalanced)
        
        modelUsed = 3;
        omega_mod_res_3{i} = calcModelOmega(theta_exp.unbalanced{i}, M, ...
                                     constants, modelUsed);
        omega_mod_3{i} = calcModelOmega(theta_mod.unbalanced{i}, M, ...
                                     constants, modelUsed);

        modelUsed = 4;
        omega_mod_res_4{i} = calcModelOmega(theta_exp.unbalanced{i}, M, ...
                                     constants, modelUsed);
        omega_mod_4{i} = calcModelOmega(theta_mod.unbalanced{i}, M, ...
                                     constants, modelUsed);
                                 
        % Calculate Residuals for both models
        residual_vec_model_3{i} = ( omega_exp.unbalanced{i} - ...
                                    omega_mod_res_3{i} )';
        residual_vec_model_4{i} = ( omega_exp.unbalanced{i} - ...
                                    omega_mod_res_4{i} )';
                                
        
        % Calculate Statistics for Models 3 and 4
        dataType = sprintf('Unbalanced Wheel Trial %d - Model 3 Residuals', i);
        calcStatistics(residual_vec_model_3{i}, dataType);
        dataType = sprintf('Unbalanced Wheel Trial %d - Model 4 Residuals', i);
        calcStatistics(residual_vec_model_4{i}, dataType);
        
        % Packaging Data for plotting
        theta_exp_for_plot{i} = theta_exp.unbalanced{i};
        omega_exp_for_plot{i} = omega_exp.unbalanced{i};
        theta_mod_for_plot{i} = theta_mod.unbalanced{i};
        
    end
        
    
    %%% Plot Results for Balanced Wheel analysis, Model 3 and 4
    testString = sprintf('Unbalanced Wheel - Models 3 and 4');
    modelsTested = {'3', '4'};
    outputData(theta_exp_for_plot, theta_mod_for_plot, ...
               omega_exp_for_plot, ...
               omega_mod_3, omega_mod_4, ...
               residual_vec_model_3, residual_vec_model_4, ...
               testString, modelsTested, shouldSaveFigures);
           
   
           
    %% Plot all 4 Models Togther
    
    xdata = {theta_mod.balanced{1}, theta_mod.balanced{1}, ...
             theta_mod.unbalanced{1}, theta_mod.unbalanced{1}};
    ydata = {omega_mod_1{1}, omega_mod_2{1}, omega_mod_3{1}, ...
             omega_mod_4{1}};
         
    plotAllModels(xdata, ydata, shouldSaveFigures)
    
    
    %% Plot Angular Acceleration
    
       
    
    % Plot Model
    type_str = 'Model';
    xdata = {theta_exp.balanced{1}, theta_exp.balanced{2}, ...
             theta_exp.unbalanced{1}, theta_exp.unbalanced{2}};
    ydata = {omega_mod_res_1{1}, omega_mod_res_2{2}, omega_mod_res_3{1}, ...
             omega_mod_res_4{2}};
    time_data = {time_exp.balanced{1}, time_exp.balanced{2}, ...
                 time_exp.unbalanced{1}, time_exp.unbalanced{2}};     
    plotAllAngAccel(xdata, ydata, time_data, type_str, shouldSaveFigures)
    
    
    % Plot Experimental
    type_str = 'Experimental';
    xdata =  {theta_exp.balanced{1}, theta_exp.balanced{2}, ...
              theta_exp.unbalanced{1}, theta_exp.unbalanced{2}};
    ydata = {omega_exp.balanced{1}, omega_exp.balanced{2}, ...
             omega_exp.unbalanced{1}, omega_exp.unbalanced{2}};  
    time_data = {time_exp.balanced{1}, time_exp.balanced{2}, ...
                 time_exp.unbalanced{1}, time_exp.unbalanced{2}};     
    plotAllAngAccel(xdata, ydata, time_data, type_str, shouldSaveFigures)
    
    
end