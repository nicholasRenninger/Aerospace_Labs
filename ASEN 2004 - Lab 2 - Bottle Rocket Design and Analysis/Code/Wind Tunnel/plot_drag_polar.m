function plot_drag_polar(clean, dirty, seven87, ...
                         FONTSIZE, LINEWIDTH, colorVecs, MARKERSIZE)
    
    %%% plot_drag_polar(clean, dirty, seven87, ...
    %%%                 FONTSIZE, LINEWIDTH, colorVecs, MARKERSIZE)
    %%%
    %%% Function plots C_L vs. C_D (drag polar), with 2 * sigma error bars
    %%%
    %%% Inputs:
    %%%
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
    %%%                 787 model
    %%%
    %%%        - FONTSIZE: sets the fontsize of the text in the figure
    %%%
    %%%        - LINEWIDTH: sets the thickness of the lines on the plot
    %%%
    %%%        - colorVecs: contains RGB triplets that set the line colors
    %%%
    %%%        - MARKERSIZE: sets the size of the plot value markers
    %%%
    %%% Author: Nicholas Renninger
    %%% Date Created: 2/18/17
    %%% Last Modified: 3/8/17

    %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %%
   
    %% C_L, C_D constants
    x_min = min(min([clean.C_D.data, dirty.C_D.data, seven87.C_D.data])) * 0.8;
    x_max = max(max([clean.C_D.data, dirty.C_D.data, seven87.C_D.data])) * 1.05;
    
    sigma_multiplier = 2;
    
    % Calculate uncertainty in each variable 
    cleanErrCD = sigma_multiplier .* clean.C_D.error;
    dirtyErrCD = sigma_multiplier .* dirty.C_D.error;
    seven87ErrCD = sigma_multiplier .* seven87.C_D.error;
    
    y_min = min(min([clean.C_L.data, dirty.C_L.data, seven87.C_L.data])) * 1.1;
    y_max = max(max([clean.C_L.data, dirty.C_L.data, seven87.C_L.data])) * 1.02;
    
    sigma_multiplier = 2;
    
    % Calculate uncertainty in each variable 
    cleanErrCL = sigma_multiplier .* clean.C_L.error;
    dirtyErrCL = sigma_multiplier .* dirty.C_L.error;
    seven87ErrCL = sigma_multiplier .* seven87.C_L.error;
    
    
    
    %% plot
    figure_title = sprintf('Drag Polar');
    saveLocation = '../Figures/';
    saveTitle = cat(2, saveLocation, sprintf('%s.pdf', figure_title));
    xlabel_string = sprintf('$C_D$');
    ylabel_string = sprintf('$C_L$');
    legend_string = {'Clean Configuration - F-16 ', ...
                     'Dirty Configuration - F-16', ...
                     'Boeing 787 Model'};

    hFig = figure('name', sprintf('Drag Polar'));
    scrz = get(groot,'ScreenSize');
    set(hFig, 'Position', scrz)

    errorbar(clean.C_D.data, clean.C_L.data, cleanErrCL, ...
             cleanErrCL, cleanErrCD, cleanErrCD, ':^', ...
             'Color', colorVecs(1, :), 'LineWidth', LINEWIDTH, ...
             'markersize', MARKERSIZE);
    hold on
    errorbar(dirty.C_D.data, dirty.C_L.data, dirtyErrCL, ...
             dirtyErrCL, dirtyErrCD, dirtyErrCD, ':d', ...
             'Color', colorVecs(2, :), 'LineWidth', LINEWIDTH, ...
             'markersize', MARKERSIZE);
         
    errorbar(seven87.C_D.data, seven87.C_L.data, seven87ErrCL, ...
             seven87ErrCL, seven87ErrCD, seven87ErrCD, ':s', ...
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
    [fid, errmsg] = fopen(saveTitle, 'w+');
    if fid < 1 % check if file is already open.
       error('Error Opening File in fopen: \n%s', errmsg); 
    end
    fclose(fid);
    print(gcf, '-dpdf', saveTitle);


end