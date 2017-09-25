function plot_CM_AoA(clean, dirty, seven87, ...
                     FONTSIZE, LINEWIDTH, colorVecs, MARKERSIZE)
    
    %%% plot_CM_AoA(AoA, C_M, data_set_string, ...
    %%%                 FONTSIZE, LINEWIDTH, colorVecs, ...
    %%%                 y_limits, MARKERSIZE)
    %%%
    %%% Function plots C_M vs. AoA, with 2 * sigma error bars. Requires
    %%% ../Figures/ folder to exist to save the plots in.
    %%%
    %%% Inputs:
    %%%        - clean: struct containing the value of C_L and C_D for
    %%%                 every AoA (also contained in this struct) for the
    %%%                 clean F-16 model.
    %%%              
    %%%
    %%%        - dirty: struct containing the value of C_L and C_D for
    %%%                 every AoA (also contained in this struct) for the
    %%%                 dirty F-16 model.
    %%%
    %%%        - seven87: struct containing the value of C_L and C_D for
    %%%                 every AoA (also contained in this struct) for the
    %%%                 787 model.
    %%%
    %%%        - FONTSIZE: sets the fontsize of the text in the figure
    %%%
    %%%        - LINEWIDTH: sets the thickness of the lines on the plot
    %%%
    %%%        - colorVecs: contains RGB triplets that set the line colors
    %%%
    %%%        - MARKERSIZE: sets the size of the plot value markers
    %%%
    %%%
    %%% Author: Nicholas Renninger
    %%% Date Created: 2/18/17
    %%% Last Modified: 3/1/17

    %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %%
   
    %% Constants
    x_min = floor(min(clean.AoA.data));
    x_max = ceil(max(clean.AoA.data));
    
    y_min = min(min([clean.C_M.data, dirty.C_M.data, seven87.C_M.data])) * 1.11;
    y_max = max(max([clean.C_M.data, dirty.C_M.data, seven87.C_M.data])) * 1.2;
    
    sigma_multiplier = 2;
    
    % Calculate uncertainty in each variable 
    cleanErrCM = sigma_multiplier .* clean.C_M.error;
    dirtyErrCM = sigma_multiplier .* dirty.C_M.error;
    seven87ErrCM = sigma_multiplier .* seven87.C_M.error;
    
   
    %% Plot
    figure_title = 'Longitudinal Stability';
    SaveTitleName = 'Longitudinal Stability';
    saveLocation = '../Figures/';
    saveTitleFull = cat(2, saveLocation, sprintf('%s.pdf', SaveTitleName));
    xlabel_string = sprintf('Angle of Attack, $\\alpha \\, (^\\circ)$');
    ylabel_string = sprintf('$C_M$');
    legend_string = {'Clean Configuration - F-16 ', ...
                     'Dirty Configuration - F-16', ...
                     'Boeing 787 Model'};

    hFig = figure('name', sprintf('C_M vs. Angle of Attack'));
    scrz = get(groot,'ScreenSize');
    set(hFig, 'Position', scrz)

    errorbar(clean.AoA.data, clean.C_M.data, cleanErrCM, ':^', ...
             'Color', colorVecs(1, :), 'LineWidth', LINEWIDTH, ...
             'markersize', MARKERSIZE);
    hold on
    errorbar(dirty.AoA.data, dirty.C_M.data, dirtyErrCM, ':d', ...
             'Color', colorVecs(2, :), 'LineWidth', LINEWIDTH, ...
             'markersize', MARKERSIZE);
         
    errorbar(seven87.AoA.data, seven87.C_M.data, seven87ErrCM, ':s', ...
             'Color', colorVecs(3, :), 'LineWidth', LINEWIDTH, ...
             'markersize', MARKERSIZE);
    

    grid on
    set(gca,'FontSize', FONTSIZE)
    set(gca, 'defaulttextinterpreter', 'latex')
    set(gca, 'TickLabelInterpreter', 'latex')
    xlim([x_min, x_max])
    ylim([y_min, y_max])
    title(figure_title)
    xlabel(xlabel_string)
    ylabel(ylabel_string)
    curr_leg = legend(legend_string, 'location', 'best', ...
                                     'interpreter', 'latex');
    set(curr_leg, 'fontsize', round(FONTSIZE * 0.7));
    
    % setup and save figure as .pdf
    curr_fig = gcf;
    set(curr_fig, 'PaperOrientation', 'landscape');
    set(curr_fig, 'PaperUnits', 'normalized');
    set(curr_fig, 'PaperPosition', [0 0 1 1]);
    [fid, errmsg] = fopen(saveTitleFull, 'w+');
    if fid < 1 % check if file is already open.
       error('Error Opening File in fopen: \n%s', errmsg); 
    end
    fclose(fid);
    print(gcf, '-dpdf', saveTitleFull);



end