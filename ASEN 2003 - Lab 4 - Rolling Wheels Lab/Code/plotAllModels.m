function plotAllModels(xdata, ydata, shouldSaveFigures)
    
    %% ASEN 2003: Dynamics & Systems - Spring 2017
    % Project: Rolling Wheel Lab (#4)
    % Project Members:  Joseph Grengs
    %                   Kian Tanner
    %                   Nicholas Renniger
    %
    %
    % Function takes all of the model omega data and plots it all together
    % on one plot to allow for easy comparison between the four models.
    %
    % Project Due Date: Thursday, March 16, 2017 @ 4:00p
    % MATLAB Code Created on: 03/02/2017
    % MATLAB Code last updated on: 03/15/2017
    
    
    %% Plot Setup
    hFig = figure('name', 'Model Comparisons');
    scrz = get(groot, 'ScreenSize');
    set(hFig, 'Position', scrz)
    
    xlabel_str = '$\theta$ (rad)';
    ylabel_str = '$\omega$ (rad/s)';
    title_str = 'Comparison of Models';
    legend_str = {'Model 1', 'Model 2', 'Model 3', 'Model 4'};
    
    colorVecs =     {[0.156863 0.156863 0.156863], ... % sgivery dark grey
                     [0.858824 0.439216 0.576471], ... % palevioletred
                     [0.254902 0.411765 0.882353], ... % royal blue
                     [0.854902 0.647059 0.12549]}; % golden rod
                 
    linetypes = {'--', '-', ':', '-.'};
    LINEWIDTH = 2;
    FONTSIZE = 26;
    MARKERSIZE = 5;
   
    
    xmin = 0;
    xmax = 15;
    
    ymin = 0;
    ymax = 9;
    
    hold on
    grid on
     
    %% plot each model
    for i = 1:length(xdata)
        
        % make line thicker for model 3 to differentiate it from model 4
        if i == 3 
            LINEWIDTH = LINEWIDTH + 1;
            p_vec(i) = plot(xdata{i}, ydata{i}, linetypes{i}, ...
                    'linewidth', LINEWIDTH, 'markersize', MARKERSIZE, ...
                    'Color', colorVecs{i});
            LINEWIDTH = LINEWIDTH - 1;
        else
            p_vec(i) = plot(xdata{i}, ydata{i}, linetypes{i}, ...
                    'linewidth', LINEWIDTH, 'markersize', MARKERSIZE, ...
                    'Color', colorVecs{i});
        end
    end
    
    
    xlim([xmin, xmax])
    ylim([ymin, ymax])
    xlabel(xlabel_str)
    ylabel(ylabel_str)
    leg = legend(p_vec, legend_str, ...
                 'location', 'best', 'interpreter', 'latex');
    set(leg, 'FontSize', round(FONTSIZE * 0.8))
    set(gca,'FontSize', FONTSIZE)
    title(title_str, 'fontsize', round(FONTSIZE))
    set(gca, 'defaulttextinterpreter', 'latex')
    set(gca, 'TickLabelInterpreter', 'latex')
    
    %% setup and save figure as .pdf
    
    saveTitle = '../Figures/All Models';
    
    if shouldSaveFigures
        savefig(saveTitle, 'pdf', '-r500');
    end
    
end