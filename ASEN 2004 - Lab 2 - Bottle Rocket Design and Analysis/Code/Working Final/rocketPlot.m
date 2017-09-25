function [  ] = rocketPlot( data, t, shouldSaveFigures, figName)
    % Authors: Jeremiah Lane, Nicholas Renninger
    % Date created: 11/22/16
    % Date modified: 12/02/16
    % inputs: time and data matrices
    % outputs: gives plots of different trajectories
    % assumptions: data vectors represent continuous data

    % purpose: this function makes plots of rocket trajectory
    
    %% Pull Data Out / setup
    saveLocation = '../../Figures/';
    saveTitle = cat(2, saveLocation, sprintf('%s.pdf', figName));
    set(0, 'defaulttextinterpreter', 'latex');
    
    % conversions
    M_TO_FEET = 3.28084;
    
    % x is horizontal displacement
    x = data(:,1);
    y = data(:,2);
    % y is vertical displacement
    z = data(:,3);
    
    % finding where it hit the ground
    range = x(end);
    crossrange = y(end);
    t_max = t(end);
    
    % find max distance from launch pad itself
    max_dist = norm([range, crossrange]);
    if crossrange == 0
        angle_offset = 0;
    else
        angle_offset = cotd(range / crossrange);
    end
    
    %% Plot
    hFig = figure('name', figName);
    scrz = get(groot, 'ScreenSize');
    set(hFig, 'Position', scrz)
    
    % plot x vs y in blue
    plot3(x,y,z,'b')
    
    hold on
    % plot point of landing
    plot(x(end), y(end), 'or')
    
    % assign legend
    legend({'Rocket Trajectory', ...
           sprintf('Landing at x = %0.3gm \\& y = %0.3gm', range, crossrange)}, ...
           'interpreter', 'latex', 'location', 'best')
    % give title
    title('Rocket Trajectory')
    % give x and y labels
    xlabel('Downrange Distance (m)')
    ylabel('Crossrange Distance (m)')
    zlabel('Vertical Distance (m)')
    xlim([0 max(x) + 10])
    ylim([-60 60])
    zlim([0 30])
    set(gca, 'fontsize', 28)
    set(gca, 'defaulttextinterpreter', 'latex')
    set(gca, 'TickLabelInterpreter', 'latex')
    grid on

    %% print the statistics about rocket trajectory
    fprintf('The rocket reaches a maximum range of: %0.3gft\n', range * M_TO_FEET)
    fprintf('The rocket reaches a maximum distance crossrange of: %0.3gft\n', crossrange * M_TO_FEET)
    fprintf('The rocket reaches a maximum total distance from launchpad of: %0.3gft\n', max_dist * M_TO_FEET)
    fprintf('The rocket is displaced from the aim line by (+ is left from line, - is right from line): %0.3g deg\n', angle_offset)    
    fprintf('The rocket flies for: %0.3gs\n', t_max)

    %% setup and save figure as .pdf
    if shouldSaveFigures
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
    


end

