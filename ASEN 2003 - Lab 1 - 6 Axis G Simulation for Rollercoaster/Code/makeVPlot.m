function makeVPlot(g_and_s_mat, braking_V, segment_lengths, avg_speed, ...
                   NUM_STEPS, vPlot)

    % makeVPlot(g_and_s_mat, braking_V, segment_lengths, avg_speed, ...
    %           NUM_STEPS, vPlot)
    %
    % Authors: Nicholas Renninger, made in collaboration with Marchall
    %          Herr
    % Last Modified: 1/31/17
    %
    %
    % Function takes matrix containing arc length, speed and plots speed as
    % a function of the length along the track
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Inputs:
    %           vPlot - must be the figure handle to plot the velocity on
    %
    %       NUM_STEPS - number of data points per track section
    %                   segment_lengths - an array containg the arc_length of
    %                   seach segment
    %
    %       braking_V - matrix containing s in the first column and V in the
    %                   second column during the braking section.
    %
    % segment_lengths - vector containing  the length of each track
    %                   segment.
    %       avg_speed - the avg. speed thruoughout the track segment
    %
    %       braking_V - the speed of the coaster as a function of s during
    %                   braking.
    %
    %     g_and_s_mat - a matrix with arc length [m] in col. 1,
    %                   tangent Gs in col. 2, lateral Gs in col. 3,
    %                   up/down Gs in col. 4, the ideal roll angle
    %                   during the track segment in rad in col. 5,
    %                   the size of the t step used during the
    %                   calculations in col. 6, and the speed [m/2]
    %                   of the coaster at each t value along the
    %                   track in col. 7.
    %

    
    %% Set up
    figure_title = sprintf('Speed as a Function of $s$');
    xlabel_string = sprintf('Arc Length, $s$ (m)');
    ylabel_string = sprintf('Speed $\\left(m / s\\right)$');
    legend_string = {sprintf('Speed of Coaster (m/s)'), ...
                     sprintf('Average Speed of Coaster = %0.3g (m/s)', ...
                             avg_speed)};
    LEGEND_LOCATION = 'best';
    
    LINEWIDTH = 2.5;
    FONTSIZE = 28;
    G_RANGE = [0, 50];
    
    %% format data for plotting
    s = g_and_s_mat(1:end - NUM_STEPS, 1);
    V = g_and_s_mat(1:end - NUM_STEPS, end);
    
    s_brake = braking_V(:, 1);
    v_brake = braking_V(:, 2);
    
    s = cat(1, s, s_brake);
    V = cat(1, V, v_brake);
    
    s_min = s(1);
    s_max = s(end);
    
    %% draw plots
    
    %%% curve plotting
    figure(vPlot);
    scrz = get(groot, 'ScreenSize');
    set(vPlot, 'Position', scrz)
    
    % plotting segment-dividing lines
    V_line = linspace(G_RANGE(1), G_RANGE(2), 100);
  
    for i = 1:length(segment_lengths)
       
        segment_line = ones(1, 100) .* ( segment_lengths(i) + ...
                                         sum(segment_lengths(1:i-1)) );
        plot(segment_line, V_line, ':', ...
              'Color', [0 0.8 0], 'LineWidth', LINEWIDTH - 1.2)
        hold on
        
    end
    
    % plot avg speed
    avg_speed_vec = ones(1, length(s)) * avg_speed;
    p1 = plot(s, avg_speed_vec', ':k', 'LineWidth', LINEWIDTH);
    
    % plotting the line
    p2 = plot(s, V, 'r', 'LineWidth', LINEWIDTH);
    
    % more plot formatting
    set(gca, 'FontSize', FONTSIZE)
    set(gca, 'defaulttextinterpreter', 'latex')
    set(gca, 'TickLabelInterpreter', 'latex')
    legend([p2, p1], legend_string, 'location', ...
       LEGEND_LOCATION, 'FontSize', FONTSIZE - 8, 'interpreter', ...
       'latex')
    xlim([s_min, s_max])
    ylim([0, max(V)])
    title(figure_title)
    xlabel(xlabel_string)
    ylabel(ylabel_string)
    
end