%%% Purpose:    
%%%             This function takes the timestamp and mean TC values for
%%%         calorimeter arrays, the index for when the sample is first
%%%         added to the calorimeter, and the index for when the sample and
%%%         the calorimeter reach thermal equilibrium. 
%%%
%%%             This is done by using unweighted least-squares to find best 
%%%         fit line for the equilibrium line and then plugging in the time 
%%%         at which the sample was added to find a new theoretical maximum
%%%         temp. achieved - T_H. Then, by assuming that T_o as found
%%%         before is actually T_L, I calculated the average of T_H and T_L
%%%         as described in the lab document.
%%%
%%%             Next, I find the time at which this new average temperature
%%%         occurs by fitting a best fit line to the data between T_L and
%%%         T_H, and solving for the time at which it satisfies the eqn:
%%%                 T_avg = mt + b (m and b are regression coeffs.)
%%%
%%%             I then take this time and plug it back into the regression
%%%         equation for the equilibrium data, to find the temperature of 
%%%         the system at the same time as when T_avg occurs, thus finding
%%%         the value for T_2 needed for calculation of the specific heat
%%%         of the sample.
%%%
%%%             To find the uncertainty in the measurement of T_2, one needs 
%%%         to coefficients of the regression to compute the error in
%%%         extrapolating beyond the range of known data. This is done by
%%%         creating the weighting matrix using the formulation shown in
%%%         class and using eqn. 8-15 from the book as the uncertainty in
%%%         each data point used in the regression.
%%%
%%%
%%% Inputs: 
%%%         index_hot_sample_added  - index in data arrays for when the
%%%                                   sample is added to the calorimeter
%%%
%%%         index_equilibirum_temp - index in data arrays for when the
%%%                                   sample and the calorimeter first are
%%%                                   in thermal equilibrium
%%%
%%%         timeStamps - array of time stamps for each measurement taken
%%%
%%%         mean_samples_TC - array of average TC measurement of
%%%                           calorimeter
%%%
%%%
%%%
%%% Outputs:  T_2 - equilibrium temperature of the calorimeter and sample
%%%           sigma_T_2 - uncertainty in the measurement of T_2
%%%           search_midpoint_T - avg of T_H and T_L
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
%%%             - can use the extrapolation error formula as the actual
%%%             uncertainty of T_2, as this encapsulates all of the
%%%             needed sources of error in its measurement
%%%
%%% Author ID:  0dc91b091fd8
%%% Date Created:   10/15/2016
%%% Date Modified:  10/21/2016
 
 
 
%%
function [T_2, sigma_T_2, T_2_time, search_midpoint_T] = Project_1_calc_T_2(index_hot_sample_added, index_equilibirum_temp, timeStamps, mean_samples_TC)
 
    
    %%% Calculate T_2 and its uncertainty using linear regression on
    %%% several regions of the data. Extrapolates the T_2 from the best fit
    %%% line of the equilibrium temperature profile of the calorimeter.
    
    %% use unweighted least-squares to find best fit line for the equilibrium line
    
    % create A from time values for each sample and the slope coefficient 
    % m in T = mt + b
    numTimeStamps = length(timeStamps(index_equilibirum_temp:end));
    bCoefficients = ones(numTimeStamps, 1);
    mCoefficients = timeStamps(index_equilibirum_temp:end);
    
    A = cat(2, mCoefficients, bCoefficients); % make A from m and b coeffs.
    
    % find d matrix from A x = d matrix equation from the T values in the
    % range from t = 0 to the time when the sample was added
    d = mean_samples_TC(index_equilibirum_temp:end);
    
    % find least squares linear fit line
    P_leastSquares = inv(A' * A) * A' * d; %#ok<MINV>
    m = P_leastSquares(1);
    b = P_leastSquares(2);
 
    linear_fit = @(t) m*t + b; % linear fit anonymous function
    
    % find T_H
    time_hot_sample_added = timeStamps(index_hot_sample_added);
    T_L = mean_samples_TC(index_hot_sample_added);
    T_H = linear_fit(time_hot_sample_added);
    
    
    %% find least squares fit line between high and low T lines
    
    % create A from time values for each sample and the slope coefficient 
    % m in T = mt + b
    index_middle_region_end = 925;
    numTimeStamps_2 = length(timeStamps(index_hot_sample_added:index_middle_region_end));
    bCoefficients_2 = ones(numTimeStamps_2, 1);
    mCoefficients_2 = timeStamps(index_hot_sample_added:index_middle_region_end);
    
    A_2 = cat(2, mCoefficients_2, bCoefficients_2); % make A from m and b coeffs.
    
    % find d matrix from A x = d matrix equation from the T values in the
    % range from t = 0 to the time when the sample was added
    d_2 = mean_samples_TC(index_hot_sample_added:index_middle_region_end);
    
    % find least squares linear fit line
    P_leastSquares_2 = inv(A_2' * A_2) * A_2' * d_2; %#ok<MINV>
    m_2 = P_leastSquares_2(1);
    b_2 = P_leastSquares_2(2);
 
    linear_fit_2 = @(t) m_2*t + b_2; % linear fit anonymous function
    
    %% Finding T2 using linear model and extrapolating by finding t s.t. T(t) = T_H + T_L / 2
   
    % developing midpoint value
    search_midpoint_T = (T_H + T_L) / 2;
    
    syms t
    T_2_time = double(solve(m_2*t + b_2 == search_midpoint_T, t));
    
    % plugging this value back into the linear fit for the high curve to
    % find T2 by extrapolating using t = t_avg_T_middle_line
    T_2 = linear_fit(T_2_time);
    
    %% Finding uncertainty in T_2 using extrapolation error
    
    %%% find uncertainty by first building Q to satisfy the following
    %%% formula:
    %%%           sigma_T2_extra = sqrt( [t_extra, 1] * Q * [t_extra; 1] )
    %%%
    %%%  such that Q = inv(A' * W * A)
    %%%
    %%%  where W is in this case:
    %%%         
    %%%         sigma_T2 = sqrt( ((1 /(N - 2)) * SUM(1, N, (T_i - b - m*t_i)^2 )
    %%%         W = sigma_T * I (identity matrix)
    %%%
    %%%  Q (2x2 for linear regression):
    %%%         
    %%%         Q =   |1 / sigma_m^2    1 / sigma_mb^2|
    %%%               |1 / sigma_mb^2    1 / sigma_b^2|
    
    % finding sigma_T2
    sum_discrepency = 0; % start with no uncertainty
 
    % summing discrepancies
    for i = 1:numTimeStamps
        t_i = A(i, 1);
        sum_discrepency = sum_discrepency + ( d(i) - linear_fit(t_i) )^2 ;
    end
 
    sigma_T = sqrt( ( 1 / (numTimeStamps - 2) ) * sum_discrepency );
 
    %%% Finding Error using matrix formulation
    I = eye(numTimeStamps); % create Identity matrix for W
    W = (1 / (sigma_T)^2) * I; % create weighting matrix
 
    % Finding Error using matrix formulation
    Q = inv(A' * W * A); % uncertainty matrix
 
    % finding uncertainty in T_2 at t = t_avg_T_middle_line 
    % (uncertainty in extrapolation)
    
    sigma_T_2 = sqrt( [T_2_time, 1] * Q * [T_2_time; 1] );
 
    
    %% plot formatting
    LINEWIDTH = 2.5;
    FIT_STYLE = ':';
    xExtent = 360;
    
    
    hold on
    plot(timeStamps(index_equilibirum_temp - xExtent:end), linear_fit(timeStamps(index_equilibirum_temp - xExtent:end)),  FIT_STYLE, 'LineWidth', LINEWIDTH)
    plot(mCoefficients_2, linear_fit_2(mCoefficients_2), FIT_STYLE, 'LineWidth', LINEWIDTH)
   
    hold off
 
end
