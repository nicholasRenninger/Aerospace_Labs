function [R_t_out, N_t, T_t, ...
          T_out, arc_length] = transition3(t_start, pos_in, ...
                                           path_plot, t_end, LINEWIDTH)
    
                                       
    % [R_t_out, N_t, T_t, ...
    %           T_out, arc_length] = transition3(t_start, pos_in, ...
    %                                            path_plot, t_end,
    %                                            LINEWIDTH)
    % 
    %
    % Author: Nicholas Renninger 
    % Date Modified: 2/2/17
    %
    %
    % Describes the 3rd transition curve of the track segment leading into
    % the braking section.
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Inputs: t_start - starting value of the domain of the track segment,
    %                   given as a non-dimension value of t.
    %         
    %         pos_in  - starting position of the track given as cartesian
    %                   vector (x, y, z), in meters.
    %         
    %       path_plot - figure handle containing the plot of the track path
    %
    %           t_end - ending value of the domain of the track segment,
    %                   given as a non-dimension value of t.
    %
    %       LINEWIDTH - width of the line used to plot the track segment
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Outputs: R_t_out - conatins parameterization of the path of the track
    %                    segment. Is a cell array of the functions (of the
    %                    non-dimensional parametric variable t) that
    %                    describes the path in each cartesian direction.
    %                    Returns position vector in meters.
    %
    %              N_t - Is a cell array of the functions (of the
    %                    non-dimensional parametric variable t) that
    %                    describes the unit Normal vector of the TNB frame
    %                    of the coaster in each cartesian direction.
    %
    %              T_t - Is a cell array of the functions (of the
    %                    non-dimensional parametric variable t) that
    %                    describes the unit Tangental vector of the TNB
    %                    frame of the coaster in each cartesian direction.
    %
    %            T_out - Is a vector that describes the unit Tangental
    %                    vector of the TNB frame of the coaster in each
    %                    cartesian direction at the last point in the
    %                    domain. I.e. the ending unit tangental vector of
    %                    the track segment.
    %
    %       arc_length - The arc length of the track segment over the
    %                    specified domain given by t_start and t_end. Given
    %                    in meters.
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% Initial Setup %%
    MIN_T_INTERVAL = t_start;
    MAX_T_INTERVAL = t_end;
    
    r = 55; % [m]
    
    % Defining start location of Helix 
    x_start = pos_in(1);
    y_start = pos_in(2);
    z_start = pos_in(3);
    
    
    %% make parametrization of transition %%
    syms t s t_new
    xt = -r * sin(t) + (x_start + r*sin(MIN_T_INTERVAL));
    yt = y_start;
    zt = r * cos(t) + (z_start - r*cos(MIN_T_INTERVAL));

    
    % make function from symbolic eqn
    parametric_fcn = matlabFunction(xt, yt, zt);
    
    % make fcn for return
    xt_f = matlabFunction(xt, 'Vars', t);
    yt_f = matlabFunction(yt, 'Vars', t);
    zt_f = matlabFunction(zt, 'Vars', t);
    R_t_out = {xt_f, yt_f, zt_f};
    
    
    %% Defining TNB Vectors %%
    r_vec = [xt, yt, zt];
    
    % T vector
    vt = diff(r_vec, t);
    T = vt ./ norm(vt);
    
    T_x = matlabFunction(T(1), 'Vars', t);
    T_y = matlabFunction(T(2), 'Vars', t);
    T_z = matlabFunction(T(3), 'Vars', t);
    
    T_t = {T_x, T_y, T_z};
    
    % N vector
    T_prime = diff(T, t);
    N = T_prime ./ norm(T_prime);
    
    N_x = matlabFunction(N(1), 'Vars', t);
    N_y = matlabFunction(N(2), 'Vars', t);
    N_z = matlabFunction(N(3), 'Vars', t);
    
    N_t = {N_x, N_y, N_z};
    
 
    % defining function for TNB frame as functions of t
    T_t_fcn = matlabFunction(T);
    
    % defining T_end, the T vec at the last point of the helix
    T_out = T_t_fcn(MAX_T_INTERVAL);
    
    %% Arc Length of Track %%
    norm_of_deriv = sqrt(diff(xt)^2 + diff(zt)^2);
    arc_length = double( int(norm_of_deriv, t,...
                               MIN_T_INTERVAL, MAX_T_INTERVAL) );
              
    %% Plotting %%
    figure(path_plot)
    
    % plot segment
    yt = @(t) y_start;
    fplot3(xt, yt, zt, [MIN_T_INTERVAL, MAX_T_INTERVAL], 'LineWidth', ...
           LINEWIDTH)
    
    hold on
    
    % plot start location of segment
    [x, y, z] = parametric_fcn(MIN_T_INTERVAL);
    scatter3(x, y, z, 'filled')
    
    
    
end