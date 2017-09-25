%%% Main code to Analyze the Static Test Stand data, made by the
%%% bomb-digiest lab group.
%%%
%%% Authors: Nicholas Renninger
%%% Date Created: 04/17/2017
%%% Last Modified: 04/19/2017


function [avg_ISP, time_vec, thrust_vec] = STS_Load(shouldSaveFigures)

    %% Setup

    saveLocation = '../../Figures/';

    figName1 = 'Thrust Plot';
    saveTitle1 = cat(2, saveLocation, sprintf('%s.pdf', figName1));

    set(0, 'defaulttextinterpreter', 'latex');

    colorVecs =     {[0.156863 0.156863 0.156863], ... % sgivery dark grey
                     [0.858824 0.439216 0.576471], ... % palevioletred
                     [0.254902 0.411765 0.882353], ... % royal blue
                     [0.854902 0.647059 0.12549]}; % golden rod


    FONTSIZE = 28;


    %% Load in Data from Each Test
    disp('Reading in Data...')
    data = loadInData;
    N = length(data); % number of tests performed

    idx_offset = 0;
    hFig = figure('name', figName1);
    scrz = get(groot, 'ScreenSize');
    set(hFig, 'Position', scrz)

    % loop through every test
    for i = 1:N

        % Get Total Time of Thrust
        total_time_thrust_vec(i + idx_offset) = max(data{i}.time) - ...
                                                min(data{i}.time);

        current_time = total_time_thrust_vec(i + idx_offset);

        % Pull Out Data
        ISP_vec(i) = data{i}.ISP;
        GRP_nums(i) = data{i}.group_num;
        water_mass_vec(i) = data{i}.water_mass;
        pressure_vec(i) = data{i}.pressure;
        temp_vec(i) = data{i}.temp;

        % Get Peak Thrust
        peak_thrust_vec(i) = max(smooth(data{i}.thrust));
        thrust_vec = data{i}.thrust;
        time_vec = data{i}.time;

        hold on
        p1 = plot(time_vec, smooth(thrust_vec), 'b', 'linewidth', 1);    

    end

    disp('Finished')



    %% ISP for Each Test
    ISP_vec = ISP_vec';
    avg_ISP = mean(ISP_vec);


    %% Peak Thrust for Each Test
    peak_thrust_vec =  peak_thrust_vec';

    avg_peak_thrust = mean(peak_thrust_vec);


    %% Print these Results after Table

    % print to command window
    fprintf('Average ISP: %0.3gs\n', avg_ISP)

    % print to command window
    fprintf('Average Peak Thrust is: %0.3gN\n', avg_peak_thrust)



    %% Format Plot of F vs. t
    xMax = 0.2; % [s]

    %%% plot avg. peak thrust
    t_vec = linspace(0, xMax, 100);
    peak_thrust_plot_vec = avg_peak_thrust .* ones(100, 1);

    p2 = plot(t_vec, peak_thrust_plot_vec, ':k', 'linewidth', 2);

    % legend
    legend([p1, p2], {'Thrust Data from Trials', ...
            sprintf('Average Peak Thrust = %0.3gN', avg_peak_thrust)}, ...
           'interpreter', 'latex', 'location', 'best')

    % give title
    title('Representative Thrust Data from Static Test Stand Trials')
    % give x and y labels
    xlabel('$t$ (s)')
    ylabel('$T$ (N)')
    ylim([-30 inf])
    xlim([0, xMax])
    set(gca, 'fontsize', FONTSIZE)
    set(gca, 'defaulttextinterpreter', 'latex')
    set(gca, 'TickLabelInterpreter', 'latex')
    grid on

    %%% setup and save figure as .pdf
    if shouldSaveFigures
        curr_fig = gcf;
        set(curr_fig, 'PaperOrientation', 'landscape');
        set(curr_fig, 'PaperUnits', 'normalized');
        set(curr_fig, 'PaperPosition', [0 0 1 1]);
        [fid, errmsg] = fopen(saveTitle1, 'w+');
        if fid < 1 % check if file is already open.
           error('Error Opening File in fopen: \n%s', errmsg); 
        end
        fclose(fid);
        print(gcf, '-dpdf', saveTitle1);
    end


    %%% printing
    avg_time_thrust = mean(total_time_thrust_vec);

    % print to command window
    fprintf('Average Time to Thrust is: %0.3gs\n', avg_time_thrust)
    
end


