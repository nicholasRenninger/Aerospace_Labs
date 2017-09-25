function determineFricMoment(shouldSaveFigures)
    

    %% Setup
    
    %spacecraft constants
    I = 165; %lb(m)*in^2, total moment of inertia without despin masses
    R = 4.25; %in, outer radius
    %convert to metric
    I = I*0.000293; %kg*m^2
    R = R*0.0254; %(in)*(m/in)=m

    %other constants
    m = 2*125/1000; %grams*kg/g = kg, 2 despin masses
    w_0 = 107*2*pi/60; %rpm*rad/(s/min) = rad/s, initial angular velocity
    
    
    %%% Plotting
    set(0, 'defaulttextinterpreter', 'latex');
    titleString = 'omega_vs_t_no_despin';
    saveLocation = '../../Figures/';
    saveTitle = cat(2, saveLocation, titleString);
    LINEWIDTH = 2;
    MARKERSIZE = 3;
    FONTSIZE = 20;
    SCALE_FACTOR = 1;
    colorVecs = [0.294118 0 0.509804; % indigo
                 0.180392 0.545098 0.341176; % sea green
                 1 0.270588 0; % orange red
                 0 0.74902 1; % deep sky blue
                 0.858824 0.439216 0.576471; % forestgreen
                 0.133333 0.545098 0.133333; % palevioletred
                 0.803922 0.521569 0.247059; % peru
                 1 0.498039 0.313725]; % coral
             
    markers = {'+','o','*','.','x','s','d','^','v','>','<','p','h'};
   
    hFig = figure('name', titleString);
    scrz = get(groot, 'ScreenSize');
    set(hFig, 'Position', scrz)
    
    %% Calc Moment
    [~, ~, al] = import_data('110_RPM_NoMass_Lubed.txt');
    M = mean(al(500:1300)) * I;
    
    
    
    %% Plot
    
    % get data from when 
    [t, w, ~] = import_data('100_RPM_0_INCH.txt');
    
    xmin = 0;
    xmax = inf;
    
    ymin = min(w)*0.9;
    ymax = max(w)*1.1;
    
    hold on
    grid on
    
%     leg_string = '';
    
    p1 = plot(t, w, ...
              [markers{2}, ':'], ...
             'linewidth', LINEWIDTH, 'markersize', MARKERSIZE, ...
             'Color', colorVecs(1, :));
    
    xlim([xmin, xmax])
    ylim([ymin, ymax])
    xlabel('$t$ (rad)')
    ylabel('$\omega$ (rad/s)')
%     leg = legend(p1, leg_string, ...
%                  'location', 'best', 'interpreter', 'latex');
    set(gca, 'FontSize', FONTSIZE)
    title(sprintf('$\\omega(t)$ vs. $t$ - No Despin Used'), 'fontsize', ...
          round(FONTSIZE * SCALE_FACTOR))
%     set(leg, 'FontSize', round(FONTSIZE * 0.7))
    set(gca, 'defaulttextinterpreter', 'latex')
    set(gca, 'TickLabelInterpreter', 'latex')
    
    %% setup and save figure as .pdf
    if shouldSaveFigures
        savefig(saveTitle, 'pdf', '-r500');
    end
    
    %% print the moment calculated
    fprintf(['The frictional moment on the spacecraft is: ', ...
             '%0.3g N-m or %0.3g ft-lb\n'], M, M * 0.737562149277)
    
end