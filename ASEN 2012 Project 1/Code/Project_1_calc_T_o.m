%%% Purpose:    
%%%             This function takes the timestamp and mean TC values for
%%%         calorimeter arrays and the index for when the sample is first
%%%         added to the calorimeter and calculates T_o and its
%%%         uncertainty. This is done using a linear least-squares
%%%         regression on the mean TC data from the start time to the time
%%%         at which the sample was added. Then, using this linear
%%%         regression, the time at which the sample was introduced is
%%%         plugged into the regression line to find T_o. 
%%%
%%%             The uncertainty in T_o is calculated using eqn. 8-15 from
%%%         textbook. This is just essentially finding the deviation of 
%%%         each term and summing them in quadrature.
%%%
%%% Inputs: mean_samples_TC - array of average TC measurement of
%%%                           calorimeter
%%%         timeStamps - array of time stamps for each measurement taken
%%%
%%%         index_hot_sample_added  - index in data arrays for when the
%%%                                   sample is added to the calorimeter
%%%
%%%
%%% Outputs: T_o - initial temperature of the calorimeter
%%%          sigma_T_o - uncertainty in the measurement of T_o
%%%
%%% Assumptions: 
%%%             - can use eqn. 8-15 in book to find uncertainty (errors are
%%%             all independent of each other and can be summed in
%%%             quadrature).
%%%
%%%             - data actually fits a linear relationship with time, and
%%%             as such can be fitted with a line of best fit by least
%%%             square linear regression.
%%%
%%% Author ID:  0dc91b091fd8
%%% Date Created:   10/15/2016
%%% Date Modified:  10/21/2016
 
 
%%
function [T_o, sigma_T_o] = Project_1_calc_T_o(index_hot_sample_added, timeStamps, mean_samples_TC)
    
    %%% use unweighted least-squares to find best fit line and the
    %%% uncertainty in the measurement of T_o
    
    % create A from time values for each sample and the slope coefficient 
    % m in T = mt + b
    numTimeStamps = length(timeStamps(1:index_hot_sample_added));
    bCoefficients = ones(numTimeStamps, 1);
    mCoefficients = timeStamps(1:index_hot_sample_added);
    
    A = cat(2, mCoefficients, bCoefficients); % make A from m and b coeffs.
    
    % find d matrix from A x = d matrix equation from the T values in the
    % range from t = 0 to the time when the sample was added
    d = mean_samples_TC(1:index_hot_sample_added);
    
    % find least squares linear fit line
    P_leastSquares = inv(A' * A) * A' * d; %#ok<MINV>
    m = P_leastSquares(1);
    b = P_leastSquares(2);
 
    linear_fit = @(t) m*t + b; % linear fit anonymous function
     
    % using line of best fit to find T_o
    time_hot_sample_added = timeStamps(index_hot_sample_added);
    T_o = linear_fit(time_hot_sample_added);
    
    %%% Computing Uncertainties
    sum_discrepency = 0; % start with no uncertainty
 
    % summing discrepancies
    for i = 1:numTimeStamps
        t_i = A(i, 1);
        sum_discrepency = sum_discrepency + ( d(i) - linear_fit(t_i) )^2 ;
    end
 
    % finding uncertainty in measurement of T_o
    sigma_T_o = sqrt( ( 1 / (numTimeStamps - 2) ) * sum_discrepency );
    
    %% Plotting
    LINEWIDTH = 2.5;
    FIT_STYLE = ':';
    MARKERSIZE = 2;
    FONTSIZE = 22;
    xExtent = 120;
    X_LOW = 0;
    X_HIGH = 1850;
    
    
    hFig = figure(1);
    set(gca,'FontSize', FONTSIZE)
    set(hFig, 'Position', [100 100 1600 900])
    
    xlim([X_LOW, X_HIGH])
    
    
    hold on
    plot(timeStamps, mean_samples_TC, 'o', 'MarkerSize', MARKERSIZE)
    plot(timeStamps(1:index_hot_sample_added + xExtent), linear_fit(timeStamps(1:index_hot_sample_added + xExtent)),...
                    FIT_STYLE, 'LineWidth', LINEWIDTH)
    
end
