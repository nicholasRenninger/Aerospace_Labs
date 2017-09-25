%% load data
clc 
clear
close all

shouldSaveFigures = true;
FONTSIZE = 24;

% setup plot saving
saveTitle = cat(2, '../../', sprintf('%s.pdf', titleString));

load('v2VaderLaunch.mat');

%% process data
x = ones(length(data.x), 1) * max(data.x) - data.x;
y = (1080-data.y);

k_vert = 10/60; %Ft/pixel conversion (8ft pole, 81 pixels for pole height)
k_horiz = 202 / (max(x)  - min(x)); %Ft/pixel conversion (202ft max dist)

% scale to feet
x = x * k_horiz;
y = y * k_vert;

% rotate data so it starts and ends at height = 0ft
p = polyfit([x(3), max(x)], [y(3), min(y(50:end))], 1);
y_linear_interp = polyval(p, x);

y = y - y_linear_interp;

% deleting the pole height data points
y(1:2) = [];
x(1:2) = [];


%% find max height and dist

x_maxY = x(y == max(y));
y_maxX = y(x == max(x));

fprintf('Max Height: %0.3g [ft] \n Max Distance: %0.3g [ft]\n', ...
        max(y), max(x))

    
%% plot data
leg_str = {sprintf('Max Height = %0.3g [ft]', max(y)), ...
           sprintf('Max Distance = %0.3G [ft]', max(x)), ...
           'Rocket Trajectory'};

hFig = figure('name', 'Rocket Trajectory');
scrz = get(groot, 'ScreenSize');
set(hFig, 'Position', scrz)

hold on
plot(x_maxY, max(y), 'ro')
plot(max(x), y_maxX, 'bo')
plot(x, y, '.')

h = gca;
leg = h.Legend;
titleStruct = h.Title;
set(titleStruct, 'FontWeight', 'bold')
set(gca, 'FontSize', FONTSIZE)
set(leg, 'FontSize', round(FONTSIZE * 0.7))
set(gca, 'defaulttextinterpreter', 'latex')
set(gca, 'TickLabelInterpreter', 'latex')

title('Rocket Tracjectory');
leg = legend(leg_str);
set(leg, 'Location', 'best', 'Interpreter', 'latex')
xlabel('Horizontal Distance [ft.]')
ylabel('Vertical Distance[ft.]')
grid on

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