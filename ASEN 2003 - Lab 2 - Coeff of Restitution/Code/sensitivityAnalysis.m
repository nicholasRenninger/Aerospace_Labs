function sensitivityAnalysis
  
    %%% sensitivityAnalysis
    %%%
    %%%     Will create plots showing the effect on the uncertainty of e by
    %%%     the variation of the uncertainty of each dependent variable 
    %%%             
    %%% Inputs:
    %%%        none
    %%%
    %%% Outputs:
    %%%         none
    %%%
    %%% Author: Jeffrey Mariner Gonzalez, Nicholas Renninger
    %%% Date Created: 2/12/17
    %%% Last Modified: 2/15/17
    
    %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %%
    
    % define gravitational acceleration, at S.L.
    g = 386.4; % [in / s^2]
    
    LINEWIDTH = 3;
    FONTSIZE = 26;
    
    % magnitude of uncertainties for each dependent variable
    sigt = 0.01;
    sigh = 0.5;
    sigt2 = 0.01;
    sigh2 = 1;

    % defining fcns. for each method
    syms h_curr h_prev t_curr t_prev ts ho
    e1 = @(h_curr, h_prev) sqrt(h_curr / h_prev);
    e2 = @(t_curr, t_prev) (t_curr / t_prev);
    e3 = @(ts,ho) ((ts-sqrt(2*ho/g))/(ts+sqrt(2*ho/g)));
    k = 0:.1:4;

    % calculate how the uncertainty in e changes  with the uncertainty in
    % each dependent variable
    for i = 1:length(k)
        
       hcurre1(i) = ErrorProp(e1, [h_curr h_prev], ...
                                           [40 35], ...
                                           [sigh*k(i), sigh]); 
       hpreve1(i) = ErrorProp(e1, [h_curr h_prev], ...
                                           [40 35], ...
                                           [sigh, sigh*k(i)]);
       tcurre2(i) = ErrorProp(e2, [t_curr t_prev], ...
                                           [.5 .3], ...
                                           [sigt*k(i), sigt]);
       tpreve2(i) = ErrorProp(e2, [t_curr t_prev], ...
                                           [.5 .3], ...
                                           [sigt, sigt*k(i)]);
       tse3(i) = ErrorProp(e3, [ts ho], ...
                                           [10 40], ...
                                           [sigt2*k(i), sigh2]);
       hoe3(i) = ErrorProp(e3, [ts ho], ...
                                           [10 40], ...
                                           [sigt2, sigh2*k(i)]);
    end
    
    
    %% method 1
    
    figure_title = sprintf(['Sensitivity Analysis of Method 1', ...
                            ' - Uncertainty in Measured Height']);
    legend_string = {'$\delta h_n$', '$\delta h_{n-1}$'};
    xlabel_string = sprintf('$\\delta_{height}$ [in.]');
    ylabel_string = sprintf('$\\delta_{e}$');
    LEGEND_LOCATION = 'best';

    sens_anal_1_plot = figure('name', 'Sensitivity Analysis - Method 1');
    scrz = get(groot,'ScreenSize');
    set(sens_anal_1_plot, 'Position', scrz)
    
    %h current    
    plot(sigh*k, hcurre1, 'LineWidth', LINEWIDTH);
    
    hold on;
    
    % h prev
    plot(sigh*k, hpreve1, 'LineWidth', LINEWIDTH);

    
    grid on
    set(gca,'FontSize', FONTSIZE)
    set(gca, 'defaulttextinterpreter', 'latex')
    set(gca, 'TickLabelInterpreter', 'latex')
    title(figure_title)
    xlabel(xlabel_string)
    ylabel(ylabel_string)
    legend(legend_string, 'location', LEGEND_LOCATION, ...
           'interpreter', 'latex')

    %%% end figure one %%%


    %% method 2
    
    figure_title = sprintf(['Sensitivity Analysis of Method 2', ...
                            ' - Uncertainty in Measured Time']);
    legend_string = {'$\delta t_n$', '$\delta t_{n-1}$'};
    xlabel_string = sprintf('$\\delta_{time}$ [in.]');
    ylabel_string = sprintf('$\\delta_{e}$');
    LEGEND_LOCATION = 'best';

    sens_anal_2_plot = figure('name', 'Sensitivity Analysis - Method 2');
    scrz = get(groot,'ScreenSize');
    set(sens_anal_2_plot, 'Position', scrz)
    
    
    plot(sigt*k, tcurre2,'LineWidth', LINEWIDTH);
 
    hold on;
    
    plot(sigt*k, tpreve2, 'LineWidth', LINEWIDTH);

    grid on
    set(gca,'FontSize', FONTSIZE)
    set(gca, 'defaulttextinterpreter', 'latex')
    set(gca, 'TickLabelInterpreter', 'latex')
    title(figure_title)
    xlabel(xlabel_string)
    ylabel(ylabel_string)
    legend(legend_string, 'location', LEGEND_LOCATION, ...
           'interpreter', 'latex')
   
    %%% end figure two %%%

    %% method 3 pt 1
    
    figure_title = sprintf(['Sensitivity Analysis of Method 3', ...
                            ' - Uncertainty in Time to Stop Measurement']);
    xlabel_string = sprintf('$\\delta_{time}$ [in.]');
    ylabel_string = sprintf('$\\delta_{e}$');

    sens_anal_3_plot = figure('name', 'Sensitivity Analysis - Method 3');
    scrz = get(groot,'ScreenSize');
    set(sens_anal_3_plot, 'Position', scrz)
    
    plot(sigt2*k, tse3, 'LineWidth', LINEWIDTH);
    
    grid on
    set(gca,'FontSize', FONTSIZE)
    set(gca, 'defaulttextinterpreter', 'latex')
    set(gca, 'TickLabelInterpreter', 'latex')
    title(figure_title)
    xlabel(xlabel_string)
    ylabel(ylabel_string)
       
    %end figure 3 

    %% method 3 pt 2
    
    figure_title = sprintf(['Sensitivity Analysis of Method 3', ...
                          ' - Uncertainty in Initial Height Measurement']);

    xlabel_string = sprintf('$\\delta_{height}$ [in.]');
    ylabel_string = sprintf('$\\delta_{e}$');


    sens_anal_4_plot = figure('name', 'Sensitivity Analysis - Method 3');
    scrz = get(groot,'ScreenSize');
    set(sens_anal_4_plot, 'Position', scrz)
    
    plot(sigh2*k, hoe3, 'LineWidth', LINEWIDTH);
    
    grid on
    set(gca,'FontSize', FONTSIZE)
    set(gca, 'defaulttextinterpreter', 'latex')
    set(gca, 'TickLabelInterpreter', 'latex')
    title(figure_title)
    xlabel(xlabel_string)
    ylabel(ylabel_string)


end

