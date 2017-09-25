function makeGPlot(g_and_s_mat, segment_lengths, gPlot)

    % makeGPlot(g_and_s_mat, segment_lengths, gPlot)
    %
    % Authors: Nicholas Renninger, made in collaboration with Marchall
    %          Herr
    % Last Modified: 1/31/17
    %
    %
    % Function takes matrix containing arc lengths and the variation of the
    % tangental, vertical, and lateral G's as functions of the length along
    % the track
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Inputs:
    %           gPlot - must be the figure handle to plot the G's on
    %
    % segment_lengths - vector containing  the length of each track
    %                   segment.
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
    figure_title = sprintf(['G-forces in Tangential, Lateral, and ' ...
                            'Vertical Directions as Functions of $s$']);
    legend_string = {'Tangental G-Force', ...
                     'Lateral G-Force', ...
                     'Vertical (up / down) G-force', ...
                     'Tangetal G-Force Limits', ...
                     'Lateral G-Force Limits', ...
                     'Vertical G-Force Limits'};
    xlabel_string = sprintf('Arc Length, $s$ (m)');
    ylabel_string = sprintf('G-force $\\left(N / mg\\right)$');
    
    LINEWIDTH = 2.5;
    FONTSIZE = 28;
    LEGEND_LOCATION = 'best';
    G_RANGE = [-5, 10];
    
    %% format data for plotting
    s = g_and_s_mat(:, 1)';
    g_T = g_and_s_mat(:, 2)';
    g_L = g_and_s_mat(:, 3)';
    g_V = g_and_s_mat(:, 4)';
    
    s_min = s(1);
    s_max = s(end);
    
    %%% Max and Min G in each direction %%%
    
    % Tangental
    max_T = max(g_T);
    max_T_s = s(find(g_T==max_T,1,'last'));
    
    min_T = min(g_T);
    min_T_s = s(find(g_T==min_T,1,'first'));
    
    % Lateral
    max_L = max(g_L);
    max_L_s = s(find(g_L==max_L,1,'last'));
    
    min_L = min(g_L);
    min_L_s = s(find(g_L==min_L,1,'first'));
    
    % Vertical
    max_V = max(g_V);
    max_V_s = s(find(g_V==max_V,1,'last'));
    
    min_V = min(g_V);
    min_V_s = s(find(g_V==min_V,1,'first'));
    
    %%% G-force limits %%% 
    num_pts = length(s);
    
    % Tangental
    g_T_high = ones(1, num_pts) * 5;
    g_T_low = ones(1, num_pts) * -4;
    
    % Lateral
    g_L_high = ones(1, num_pts) * 3;
    g_L_low = ones(1, num_pts) * -3;

    % Vertical 
    g_V_high = ones(1, num_pts) * 6;
    g_V_low = ones(1, num_pts) * -1;

    %% draw plots
    
    %%% labels
    max_T_str = sprintf('Max Forward G''s: %0.2f', max_T);
    min_T_str = sprintf('Max Backwards G''s: %0.2f', abs(min_T));
    max_L_str = sprintf('Max Left Lateral G''s: %0.2f', max_L);
    min_L_str = sprintf('Max Right Lateral G''s: %0.2f', abs(min_L));
    max_V_str = sprintf('Max Upwards G''s: %0.2f', max_V);
    min_V_str = sprintf('Max Downwards G''s: %0.2f', abs(min_V));
    
    %%% curve plotting
    figure(gPlot)
    scrz = get(groot,'ScreenSize');
    set(gPlot, 'Position', scrz)
    
    % plot zero G line
    plot(linspace(s_min, s_max, 100), zeros(1, 100), ':k', 'LineWidth',...
         LINEWIDTH - 1.2)
    hold on

    % plotting segment-dividing lines
    G_line = linspace(G_RANGE(1), G_RANGE(2), 100);
  
    for i = 1:length(segment_lengths)
       
        segment_line = ones(1, 100) .* ( segment_lengths(i) + ...
                                         sum(segment_lengths(1:i-1)) );
        plot(segment_line, G_line, ':', ...
              'Color', [0 0.8 0], 'LineWidth', LINEWIDTH - 1.2);
        hold on
        
    end
   
    
    % plotting G limits
    p4 = plot(s, g_T_high,'--', s, g_T_low, '--', ...
              'Color', [0 0 0], 'LineWidth', LINEWIDTH - 1.7);
    p5 = plot(s, g_L_high, '--', s, g_L_low, '--', ...
              'Color', [0.9 0.1 0.1], 'LineWidth', LINEWIDTH - 1.7);
    p6 = plot(s, g_V_high, '--', s, g_V_low, '--', ...
              'Color', [0.1 0.1 0.9], 'LineWidth', LINEWIDTH - 1.7);
          
    % plotting G-curves
    p1 = plot(s, g_T, 'k', 'LineWidth', LINEWIDTH);
    p2 = plot(s, g_L, 'r', ...
              'Color', [0.9 0.1 0.1], 'LineWidth', LINEWIDTH);
    p3 = plot(s, g_V, 'b', ...
              'Color', [0.1 0.1 0.9], 'LineWidth', LINEWIDTH);
    
          
    % labeling
    text(max_T_s - 500, 0.8, max_T_str, ...
         'HorizontalAlignment', 'center', 'FontSize', FONTSIZE - 10, ...
         'Color', [0 0 0], 'interpreter', 'latex');
    text(min_T_s - 40, min_T*1.3, min_T_str, ...
         'HorizontalAlignment', 'center', 'FontSize', FONTSIZE - 10, ...
         'Color', [0 0 0], 'interpreter', 'latex');
    text(max_L_s*1.1, max_L - 1, max_L_str, ...
         'HorizontalAlignment', 'center', 'FontSize', FONTSIZE - 10, ...
         'Color', [0.9 0.1 0.1], 'interpreter', 'latex');
    text(min_L_s + 80, min_L*1.1, min_L_str, ...
         'HorizontalAlignment', 'center', 'FontSize', FONTSIZE - 10, ...
         'Color', [0.9 0.1 0.1], 'interpreter', 'latex');
    text(max_V_s - 20, max_V*1.1, max_V_str, ...
         'HorizontalAlignment', 'center', 'FontSize', FONTSIZE - 10, ...
         'Color', [0.1 0.1 0.9], 'interpreter', 'latex');
    text(min_V_s*1.1, min_V*1.1, min_V_str, ...
         'HorizontalAlignment', 'center', 'FontSize', FONTSIZE - 10, ...
         'Color', [0.1 0.1 0.9], 'interpreter', 'latex');
    
    % more plot formatting
    set(gca, 'FontSize', FONTSIZE)
    set(gca, 'defaulttextinterpreter', 'latex')
    set(gca, 'TickLabelInterpreter', 'latex')
    xlim([s_min, s_max])
    ylim(G_RANGE)
    title(figure_title)
    xlabel(xlabel_string)
    ylabel(ylabel_string)
    legend([p1, p2, p3, p4(1), p5(1), p6(1)], legend_string, 'location', ...
           LEGEND_LOCATION, 'FontSize', FONTSIZE-8, 'interpreter', ...
           'latex', 'Box','off')
       
       
end