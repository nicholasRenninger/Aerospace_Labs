function plot_CL_CD_AoA(clean, dirty, seven87, ...
                        FONTSIZE, LINEWIDTH, colorVecs, MARKERSIZE)
    
    %%% plot_CL_CD_AoA(clean, dirty, seven87, ...
    %%%                FONTSIZE, LINEWIDTH, colorVecs, MARKERSIZE)
    %%%
    %%% Function plots C_L vs. AOA and C_D vs. AoA, with 2 * sigma 
    %%% error bars.
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
    %%%
    %%% Author: Nicholas Renninger
    %%% Date Created: 2/18/17
    %%% Last Modified: 3/6/17

    %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% 
    
    %% C_L constants
    x_min = floor(min(clean.AoA.data));
    x_max = ceil(max(clean.AoA.data));
    x_vec = linspace(x_min, x_max, 100);
        
    y_min_CL_clean = min(clean.C_L.data);
    y_min_CL_dirty = min(dirty.C_L.data);
    y_min_CL_787 = min(seven87.C_L.data);
    
    min_clean_vec = y_min_CL_clean * ones(1, 100);
    min_dirty_vec = y_min_CL_dirty * ones(1, 100);
    min_787_vec = y_min_CL_787 * ones(1, 100);
    
    y_max_CL_clean = max(clean.C_L.data);
    y_max_CL_dirty = max(dirty.C_L.data);
    y_max_CL_787 = max(seven87.C_L.data);
    
    max_clean_vec = y_max_CL_clean * ones(1, 100);
    max_dirty_vec = y_max_CL_dirty * ones(1, 100);
    max_787_vec = y_max_CL_787 * ones(1, 100);
    
    y_min = min([y_min_CL_clean, y_min_CL_dirty, y_min_CL_787]) * 1.1;
    y_max = max([y_max_CL_clean, y_max_CL_dirty, y_max_CL_787]) * 1.02;
    
    
    sigma_multiplier = 2;
    
    % Calculate uncertainty in each variable 
    cleanErrCL = sigma_multiplier .* clean.C_L.error;
    dirtyErrCL = sigma_multiplier .* dirty.C_L.error;
    seven87ErrCL = sigma_multiplier .* seven87.C_L.error;
    
   
    %% Plot C_L
    figure_title = sprintf('$C_L$ vs. $\\alpha$');
    SaveTitleName = 'C_L_vs_AoA';
    saveLocation = '../Figures/';
    saveTitleFull = cat(2, saveLocation, sprintf('%s.pdf', SaveTitleName));
    xlabel_string = sprintf('Angle of Attack, $\\alpha \\, (^\\circ)$');
    ylabel_string = sprintf('$C_L$');
    legend_string = {'Clean Configuration - F-16 ', ...
                     'Dirty Configuration - F-16', ...
                     'Boeing 787 Model'};

    hFig = figure('name', sprintf('C_L vs. Angle of Attack'));
    scrz = get(groot,'ScreenSize');
    set(hFig, 'Position', scrz)

    hold on
    % plot min lines
    plot(x_vec, min_clean_vec, '--', 'color', colorVecs(1, :), 'linewidth', LINEWIDTH - 1.5)
    plot(x_vec, min_dirty_vec, '--', 'color', colorVecs(2, :), 'linewidth', LINEWIDTH - 1.5)
    plot(x_vec, min_787_vec, '--', 'color', colorVecs(3, :), 'linewidth', LINEWIDTH - 1.5)
         
    % plot max lines
    plot(x_vec, max_clean_vec, '--', 'color', colorVecs(1, :), 'linewidth', LINEWIDTH - 1.5)
    plot(x_vec, max_dirty_vec, '--', 'color', colorVecs(2, :), 'linewidth', LINEWIDTH - 1.5)
    plot(x_vec, max_787_vec, '--', 'color', colorVecs(3, :), 'linewidth', LINEWIDTH - 1.5)
     
    p1 = errorbar(clean.AoA.data, clean.C_L.data, cleanErrCL, ':^', ...
             'Color', colorVecs(1, :), 'LineWidth', LINEWIDTH, ...
             'markersize', MARKERSIZE);
         
    p2 = errorbar(dirty.AoA.data, dirty.C_L.data, dirtyErrCL, ':d', ...
             'Color', colorVecs(2, :), 'LineWidth', LINEWIDTH, ...
             'markersize', MARKERSIZE);
   
    p3 = errorbar(seven87.AoA.data, seven87.C_L.data, seven87ErrCL, ':s', ...
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
    curr_leg = legend([p1 p2 p3], legend_string, 'location', 'best', ...
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

    
    %% C_D constants
    x_min = floor(min(clean.AoA.data));
    x_max = ceil(max(clean.AoA.data));
    x_vec = linspace(x_min, x_max, 100);
        
    y_min_CD_clean = min(clean.C_D.data);
    y_min_CD_dirty = min(dirty.C_D.data);
    y_min_CD_787 = min(seven87.C_D.data);
    
    min_clean_vec = y_min_CD_clean * ones(1, 100);
    min_dirty_vec = y_min_CD_dirty * ones(1, 100);
    min_787_vec = y_min_CD_787 * ones(1, 100);
    
    y_max_CD_clean = max(clean.C_D.data);
    y_max_CD_dirty = max(dirty.C_D.data);
    y_max_CD_787 = max(seven87.C_D.data);
    
    max_clean_vec = y_max_CD_clean * ones(1, 100);
    max_dirty_vec = y_max_CD_dirty * ones(1, 100);
    max_787_vec = y_max_CD_787 * ones(1, 100);
    
    y_min = min([y_min_CD_clean, y_min_CD_dirty, y_min_CD_787]) * 0.8;
    y_max = max([y_max_CD_clean, y_max_CD_dirty, y_max_CD_787]) * 1.05;
    
    sigma_multiplier = 2;
    
    % Calculate uncertainty in each variable 
    cleanErrCD = sigma_multiplier .* clean.C_D.error;
    dirtyErrCD = sigma_multiplier .* dirty.C_D.error;
    seven87ErrCD = sigma_multiplier .* seven87.C_D.error;
    
   
    %% Plot C_D
    figure_title = sprintf('$C_D$ vs. $\\alpha$');
    SaveTitleName = 'C_D_vs_AoA';
    saveLocation = '../Figures/';
    saveTitleFull = cat(2, saveLocation, sprintf('%s.pdf', SaveTitleName));
    xlabel_string = sprintf('Angle of Attack, $\\alpha \\, (^\\circ)$');
    ylabel_string = sprintf('$C_D$');
    legend_string = {'Clean Configuration - F-16 ', ...
                     'Dirty Configuration - F-16', ...
                     'Boeing 787 Model'};

    hFig = figure('name', sprintf('C_D vs. Angle of Attack'));
    scrz = get(groot,'ScreenSize');
    set(hFig, 'Position', scrz)

    hold on
    
    % plot min lines
    plot(x_vec, min_clean_vec, '--', 'color', colorVecs(1, :), 'linewidth', LINEWIDTH - 1.5)
    plot(x_vec, min_dirty_vec, '--', 'color', colorVecs(2, :), 'linewidth', LINEWIDTH - 1.5)
    plot(x_vec, min_787_vec, '--', 'color', colorVecs(3, :), 'linewidth', LINEWIDTH - 1.5)
         
    % plot max lines
    plot(x_vec, max_clean_vec, '--', 'color', colorVecs(1, :), 'linewidth', LINEWIDTH - 1.5)
    plot(x_vec, max_dirty_vec, '--', 'color', colorVecs(2, :), 'linewidth', LINEWIDTH - 1.5)
    plot(x_vec, max_787_vec, '--', 'color', colorVecs(3, :), 'linewidth', LINEWIDTH - 1.5)
    
    p1 = errorbar(clean.AoA.data, clean.C_D.data, cleanErrCD, ':^', ...
             'Color', colorVecs(1, :), 'LineWidth', LINEWIDTH, ...
             'markersize', MARKERSIZE);
         
    p2 = errorbar(dirty.AoA.data, dirty.C_D.data, dirtyErrCD, ':d', ...
             'Color', colorVecs(2, :), 'LineWidth', LINEWIDTH, ...
             'markersize', MARKERSIZE);
   
    p3 = errorbar(seven87.AoA.data, seven87.C_D.data, seven87ErrCD, ':s', ...
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
    curr_leg = legend([p1 p2 p3], legend_string, 'location', 'best', ...
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