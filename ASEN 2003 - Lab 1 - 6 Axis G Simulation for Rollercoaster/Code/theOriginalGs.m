function [g_and_s_mat, total_time] = theOriginalGs(Domain, num_steps, ...
                                                   R_t, T_t, N_t,...
                                                   isStraight, Roll)

    % [g_and_s_mat, total_time] = theOriginalGs(Domain, num_steps, ...
    %                                                    R_t, T_t, N_t,...
    %                                                    isStraight, Roll)
    %
    % Authors: Nicholas Renninger, made in collaboration with Marshall Herr
    % Date Modified: 2/2/17
    %
    %
    % Function takes information about the path, TNB frame, and the bank
    % angle of a segment of the track and calculates the G's acting along
    % the TNB vectors of the coaster numerically. The G's are calculated
    % w.r.t. s, the arc length of the track segment given in meters.
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Inputs: Domain - Vector of the starting and ending values of the of
    %                  the domain of the track segment parameterized as the
    %                  non-dimensional parameter t.
    %         
    %     num_steps  - number of linearly spaced steps between the
    %                  beginning and end of the domain. The TNB G-forces
    %                  are computed each step.
    %
    %        R_t_out - conatins parameterization of the path of the track
    %                  segment. Is a cell array of the functions (of the
    %                  non-dimensional parametric variable t) that
    %                  describes the path in each cartesian direction.
    %                  Returns position vector in meters.
    %
    %            T_t - Is a cell array of the functions (of the
    %                  non-dimensional parametric variable t) that
    %                  describes the unit Tangental vector of the TNB
    %                  frame of the coaster in each cartesian direction.
    %
    %            N_t - Is a cell array of the functions (of the
    %                  non-dimensional parametric variable t) that
    %                  describes the unit Normal vector of the TNB frame
    %                  of the coaster in each cartesian direction.
    %
    %     isStraight - Boolean flag that switches how the computation of
    %                  the normal acceleration is done, as the TNB frame is
    %                  not well-defined for curves with ill defined
    %                  curvature.
    %
    %           Roll - Banking angle as a function of t.
    %        
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Outputs: g_and_s_mat -  a matrix with arc length [m] in col. 1,
    %                         tangent Gs in col. 2, lateral Gs in col. 3,
    %                         up/down Gs in col. 4, the ideal roll angle
    %                         during the track segment in rad in col. 5,
    %                         the size of the t step used during the
    %                         calculations in col. 6, and the speed [m/2]
    %                         of the coaster at each t value along the
    %                         track in col. 7.
    %
    %            total_time - how long it takes to go through the track
    %                         segment, given in seconds.
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %% Constants
    h_init = 125; % [m]
    g = 9.81; % [m / s^2]

    % Checking for roll input arg, roll is optional
    if nargin < 7
        Roll = @(t) 0;
    end

    %%% Initializations %%%
    syms t
    Speed = @(z) sqrt(2 * g * (h_init - z));
    g_and_s_mat = zeros(length(num_steps + 1), 7);
    dom_init = Domain(1);
    dom_final = Domain(2);
    total_time = 0; % [s]

    % macros for parametric anon. fcn
    x_t = R_t{1};
    y_t = R_t{2};
    z_t = R_t{3};


    %% Numeric Caluclation of Gs %% 

    % define numeric interval and step size
    step_size = (dom_final - dom_init) / (num_steps + 1);
    first_step = dom_init;
    last_step = dom_final + step_size;

    % start calculating G's
    for i = first_step : step_size : last_step

        if  (i ~= last_step) && (i ~= first_step)


            %%% Calc Arc Length of current and previous step using the arc
            %%% length formula
            r_t_prime = sqrt( diff(x_t(t), t)^2 + diff(y_t(t), t)^2 + ...
                              diff(z_t(t), t)^2 );

            arc_length = vpa( int(r_t_prime, first_step, i) );
            prev = vpa( int(r_t_prime, first_step, i - step_size) );


            %%% Defining time differential: dTime = dS/V_avg
            dS = (arc_length - prev); % change in arc length
            avg_Speed = ( 0.5 * ( Speed(z_t(i - step_size)) + ...
                                  Speed(z_t(i)) ) );

            d_time = dS / avg_Speed;


            %%% Theta is defined as the rotation angle of the N_t vector
            %%% about the B_t direction.
            
            cur_N_vec = [N_t{1}(i), N_t{2}(i), N_t{3}(i)];
            pre_N_vec = [N_t{1}(i - step_size), N_t{2}(i - step_size),...
                         N_t{3}(i - step_size)];
            pre_T_vec = [T_t{1}(i - step_size), T_t{2}(i - step_size),...
                         T_t{3}(i - step_size)];
            
            Theta = atan( dot(cur_N_vec, pre_T_vec) / ...
                          dot(cur_N_vec, pre_N_vec) );


            %%% Defining Normal acceleration as: Speed/R^2=
            %%% Theta*Vavg/dTime
            An = dot(cur_N_vec, [0,0,-1]) * g + Theta * avg_Speed / d_time;
            
            if isnan(An) && ~isStraight
                
                An = 0;
                
            elseif isStraight
                
                % find angle between curve and xy plane
                dx = x_t(dom_final) - x_t(dom_init);
                dz = z_t(dom_final) - z_t(dom_init);
                eta = abs(atan(dz / dx));
                
                % find angle between curve and -k
                phi = pi/2 - eta;
                
            end


            %%% Defining the "Ideal" Banked Turn angle (roll) w.r.t. k_hat
            %%% s.t. the normal acceleration is completely in the up
            %%% direction for the rider e.g. the rider feels all of the
            %%% force coming from their seat.

            % N_t{1} = x_component of N, N_t{2} = y_component of N, N_t{3}
            % = z_component of N
            xy_projection_mag = sqrt( (N_t{1}(i))^2 + (N_t{2}(i))^2 );
            Roll_Ideal = atan( xy_projection_mag / N_t{3}(i) );


            %%% Defining G's in tangental, lateral, and vertical directions
            %%% w.r.t. the rider
            G_T = 0;

            % G_L & G_V depends on the roll angle
            G_L = cos(Roll(i)) * (An / g);
            
            if isStraight
                G_V = sin(phi); 
            else
                G_V = sin(Roll(i)) * (An / g);
            end
            
            
            %%% creating output matrix
            row_idx = round((i - first_step) / step_size);
            g_and_s_mat(row_idx, :) = [arc_length, G_T, G_L, G_V,...
                                       Roll_Ideal, d_time, avg_Speed];
            
            total_time = double(total_time + d_time);
           
        end
    end

end