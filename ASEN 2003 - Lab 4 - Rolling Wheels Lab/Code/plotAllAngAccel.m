function plotAllAngAccel(xdata, ydata, time_data, type_str, shouldSaveFigures)
    
    %% ASEN 2003: Dynamics & Systems - Spring 2017
    % Project: Rolling Wheel Lab (#4)
    % Project Members:  Joseph Grengs
    %                   Kian Tanner
    %                   Nicholas Renniger
    %
    %
    % Function takes all of the model omega data, calculates angular
    % acceleration, and plots it all together on one plot to allow for easy
    % comparison between the four models.
    %
    % Project Due Date: Thursday, March 16, 2017 @ 4:00p
    % MATLAB Code Created on: 03/02/2017
    % MATLAB Code last updated on: 03/15/2017
    
    
    %% Differentiate Omega to find Alpha
    
    for i = 1:length(ydata)
        
       angAccelData{i} = diff(ydata{i}) ./ diff(time_data{i});
       xdata{i} = xdata{i}(1:end - 1);
        
    end
    
    ydata = angAccelData;
    
    %% Plot Setup
    hFig = figure('name', 'Model Comparisons');
    scrz = get(groot, 'ScreenSize');
    set(hFig, 'Position', scrz)
    
    xlabel_str = '$\theta$ (rad)';
    ylabel_str = '$\alpha$ (rad/$s^2$)';
    title_str = sprintf('%s - Angular Acceleration', type_str);
    if strfind(type_str, 'Model')
        legend_str = {'Model 1', 'Model 2', 'Model 3', 'Model 4'};
    else
        legend_str = {'Trial 1 - Balanced', 'Trial 2 - Balanced',...
                      'Trial 3 - Unbalanced', 'Trial 4 - Unbalanced'};
    end
        
    
    colorVecs =     {[0.156863 0.156863 0.156863], ... % sgivery dark grey
                     [0.858824 0.439216 0.576471], ... % palevioletred
                     [0.254902 0.411765 0.882353], ... % royal blue
                     [0.854902 0.647059 0.12549]}; % golden rod
                     
                     
    linetypes = {'--', '-', ':', '-.'};
    LINEWIDTH = 2;
    FONTSIZE = 26;
    MARKERSIZE = 5;
   
    
    xmin = min(xdata{1});
    xmax = max(xdata{1});
    
    ymin = min(ydata{3});
    ymax = max(ydata{3});
    
    hold on
    grid on
     
    %% Plot each model
    
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
    
    saveTitle = sprintf('../Figures/%s - Angular Acceleration', type_str);
    
    if shouldSaveFigures
        savefig(saveTitle, 'pdf', '-r500');
    end
    
end