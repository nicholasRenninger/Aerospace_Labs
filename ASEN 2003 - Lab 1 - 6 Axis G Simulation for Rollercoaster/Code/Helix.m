function [arc_length, R_t_out, T_end,...
          N_t, t_end, T_t] = Helix(helix_max_radius, ...
                                   helix_num_loops, ...
                                   helix_height,...
                                   t_start, pos_in, path_plot, LINEWIDTH)
   
                               
    % [arc_length, R_t_out, T_end,...
    %  N_t, t_end, T_t] = Helix(helix_max_radius, ...
    %                                    helix_num_loops, ...
    %                                    helix_height,...
    %                                    t_start, pos_in,...
    %                                    path_plot, LINEWIDTH)
    %
    % Author: Nicholas Renninger 
    % Date Modified: 2/2/17
    %
    %
    % Describes the loop track segment, after the parabolic hill.
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Inputs:    t_start - starting value of the domain of the track
    %                      segment, given as a non-dimension value of t.
    %
    % helix_max_radius r - the radius of the loop in meters.
    %
    %    helix_num_loops - the number of complete revolutions of the track.
    %         
    %      helix_height  - the proposed change in height of the track 
    %                      segment in meters.
    %
    %            pos_in  - starting position of the track given as
    %                      cartesian vector (x, y, z), in meters.
    %         
    %       path_plot - figure handle containing the plot of the track path
    %
    %       LINEWIDTH - width of the line used to plot the track segment
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Outputs: R_t_out - conatins parameterization of the path of the track
    %                    segment. Is a cell array of the functions (of the
    %                    non-dimensional parametric variable t) that
    %                    describes the path in each cartesian direction.
    %                    Returns position vector in meters.
    %
    %            T_end - Is a vector that describes the unit Tangental
    %                    vector of the TNB frame of the coaster in each
    %                    cartesian direction at the last point of the
    %                    track segment. I.e. the ending unit
    %                    tangental vector of the track segment.
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
    MAX_T_INTERVAL = 2*pi + t_start;
    t_end = MAX_T_INTERVAL;
    t_interval = MAX_T_INTERVAL - MIN_T_INTERVAL;
    t_avg = (MAX_T_INTERVAL + MIN_T_INTERVAL) / 2;
    
    g = 9.81; % m / s^2
    H_INIT = 125; % m
    
    % Defining start location of Helix 
    x_start = pos_in(1);
    y_start = pos_in(2);
    z_start = pos_in(3);
    
    
    %% make parametrization of Helix %%
    syms t s t_new
    xt = helix_max_radius * sin(helix_num_loops * (t - t_start)) + x_start;
    yt = helix_max_radius * cos(helix_num_loops * (t - t_start)) + (y_start - ...
                                                         helix_max_radius);
    zt = -helix_height * (t - t_start) / t_interval + z_start;
    
    % make function from symbolic eqn
    parametric_fcn = matlabFunction(xt, yt, zt);
    
    % make fcn for return
    xt_f = matlabFunction(xt);
    yt_f = matlabFunction(yt);
    zt_f = matlabFunction(zt);
    R_t_out = {xt_f, yt_f, zt_f};
    
    
    %% Defining TNB Vectors %%
    r_vec = [xt, yt, zt];
    
    % T vector
    vt = diff(r_vec, t);
    T = vt ./ norm(vt);
    
    T_x = matlabFunction(T(1));
    T_y = matlabFunction(T(2));
    T_z = matlabFunction(T(3));
    
    T_t = {T_x, T_y, T_z};
    
    % N vector
    T_prime = diff(T, t);
    N = T_prime ./ norm(T_prime);
    
    N_x = matlabFunction(N(1));
    N_y = matlabFunction(N(2));
    N_z = matlabFunction(N(3));
    
    N_t = {N_x, N_y, N_z};
    
    % B vector
    B = cross(vpa(N), vpa(T)) ./ norm(cross(vpa(N), vpa(T)));
 
    % defining function for TNB frame as functions of t
    T_t_fcn = matlabFunction(T);
    N_t_fcn = matlabFunction(N);
    B_t_fcn = matlabFunction(B);
    
    % defining T_end, the T vec at the last point of the helix
    T_end = T_t_fcn(MAX_T_INTERVAL);
    
    %% Arc Length of Track %%
    norm_of_deriv = sqrt(diff(xt)^2 + diff(yt)^2 + diff(zt)^2);
    %speed = sqrt(2 * g * (H_INIT - zt));
    arc_length = double( int(norm_of_deriv, t,...
                               MIN_T_INTERVAL, MAX_T_INTERVAL) );
              
    %% Plotting %%
    
    figure(path_plot)
    scrz = get(groot,'ScreenSize');
    set(path_plot, 'Position', scrz)
    
    % plot helix
    fplot3(xt, yt, zt, [MIN_T_INTERVAL, MAX_T_INTERVAL], 'LineWidth', ...
           LINEWIDTH)
    
    hold on
    
    % plot start location of helix
    [x, y, z] = parametric_fcn(MIN_T_INTERVAL);
    scatter3(x, y, z, 'filled')
    
%     %%% Draw TNB arrows %%%
%     [x, y, z] = parametric_fcn(t_avg);
%     start = [x, y, z];
%     
%     % T
%     stop_T = T_t_fcn(t_avg) * 2 + start;
%     arrow(start, stop_T, 'EdgeColor','g','FaceColor','g');
%     
%     % N
%     stop_N = N_t_fcn(t_avg) * 2 + start;
%     arrow(start, stop_N, 'EdgeColor','r','FaceColor','r');
% 
%     % B 
%     stop_B =  B_t_fcn(t_avg) * 2 + start;
%     arrow(start, stop_B, 'EdgeColor','b','FaceColor','b');
    
    %%% set the aspect ratio to see the TNB vectors correctly %%%
    set(gca,'DataAspectRatioMode','manual')
    set(gca,'PlotBoxAspectRatioMode','manual')
    set(gca,'DataAspectRatio',[1 1 1])
    set(gca,'PlotBoxAspectRatio',[1 1 1])
    
end