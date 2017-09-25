function plot_L_over_D_AoA(clean, dirty, seven87, ...
                        FONTSIZE, LINEWIDTH, colorVecs, MARKERSIZE)
    
    %%% plot_CL_CD_AoA(clean, dirty, seven87, ...
    %%%                FONTSIZE, LINEWIDTH, colorVecs, MARKERSIZE)
    %%%
    %%% Function plots (L/D) vs. AoA, with 2 * sigma 
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
    
    %% Uncertainty Propagation
    syms C_L_sym C_D_sym
    L_o_D_fcn = @(C_L_sym, C_D_sym) C_L_sym ./ C_D_sym;
    
    L_o_D_clean.data = L_o_D_fcn(clean.C_L.data, clean.C_D.data);
    L_o_D_dirty.data = L_o_D_fcn(dirty.C_L.data, dirty.C_D.data);
    L_o_D_787.data = L_o_D_fcn(seven87.C_L.data, seven87.C_D.data);
    
    % find error in LoD using general error propagation
    for i = 1:length(clean.C_L.data)
        
        
        L_o_D_clean.error(i) = ErrorProp(L_o_D_fcn, [C_L_sym, C_D_sym], ...
                               [clean.C_L.data(i), clean.C_D.data(i)], ...
                               [clean.C_L.error(i), clean.C_D.error(i)]);
                           
                               
    end
    
    for i = 1:length(dirty.C_L.data)
        
        
        L_o_D_dirty.error(i) = ErrorProp(L_o_D_fcn, [C_L_sym, C_D_sym], ...
                               [dirty.C_L.data(i), dirty.C_D.data(i)], ...
                               [dirty.C_L.error(i), dirty.C_D.error(i)]);
                           
                               
    end
    
    for i = 1:length(seven87.C_L.data)
        
        
        L_o_D_787.error(i) = ErrorProp(L_o_D_fcn, [C_L_sym, C_D_sym], ...
                            [seven87.C_L.data(i), seven87.C_D.data(i)], ...
                            [seven87.C_L.error(i), seven87.C_D.error(i)]);
                           
                               
    end
    
    sigma_multiplier = 2;
    
    % Calculate uncertainty in each variable 
    cleanErrLoD = sigma_multiplier .* L_o_D_clean.error;
    dirtyErrLoD = sigma_multiplier .* L_o_D_dirty.error;
    seven87ErrLoD = sigma_multiplier .* L_o_D_787.error;
    
    
    %% C_L constants
    x_min = floor(min(clean.AoA.data));
    x_max = ceil(max(clean.AoA.data));
    x_vec = linspace(x_min, x_max, 100);
    
    y_min_clean = min(L_o_D_clean.data);
    y_min_dirty = min(L_o_D_dirty.data);
    y_min_787 = min(L_o_D_787.data);
    
    min_clean_vec = y_min_clean * ones(1, 100);
    min_dirty_vec = y_min_dirty * ones(1, 100);
    min_787_vec = y_min_787 * ones(1, 100);
    
    y_max_clean = max(L_o_D_clean.data);
    y_max_dirty = max(L_o_D_dirty.data);
    y_max_787 = max(L_o_D_787.data);
    
    max_clean_vec = y_max_clean * ones(1, 100);
    max_dirty_vec = y_max_dirty * ones(1, 100);
    max_787_vec = y_max_787 * ones(1, 100);
    
    y_min = min([y_min_clean, y_min_dirty, y_min_787]) * 1.1;
    y_max = max([y_max_clean, y_max_dirty, y_max_787]) * 1.101;
    
   
    %% Plot Lift over Drag
    figure_title = sprintf('$(L/D)$ vs. $\\alpha$');
    SaveTitleName = 'L_over_D_vs_AoA';
    saveLocation = '../Figures/';
    saveTitleFull = cat(2, saveLocation, sprintf('%s.pdf', SaveTitleName));
    xlabel_string = sprintf('Angle of Attack, $\\alpha \\, (^\\circ)$');
    ylabel_string = sprintf('$(L/D)$');
    legend_string = {'Clean Configuration - F-16 ', ...
                     'Dirty Configuration - F-16', ...
                     'Boeing 787 Model'};

    hFig = figure('name', sprintf('L_over_D vs. Angle of Attack'));
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
     
    p1 = errorbar(clean.AoA.data, L_o_D_clean.data, cleanErrLoD, ':^', ...
             'Color', colorVecs(1, :), 'LineWidth', LINEWIDTH, ...
             'markersize', MARKERSIZE);
         
    p2 = errorbar(dirty.AoA.data, L_o_D_dirty.data, dirtyErrLoD, ':d', ...
             'Color', colorVecs(2, :), 'LineWidth', LINEWIDTH, ...
             'markersize', MARKERSIZE);
   
    p3 = errorbar(seven87.AoA.data, L_o_D_787.data, seven87ErrLoD, ':s', ...
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