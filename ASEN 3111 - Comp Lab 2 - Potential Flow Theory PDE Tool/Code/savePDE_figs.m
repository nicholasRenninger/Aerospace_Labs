%% Housekeeping
clc
close
clear


%% User Vars
n = 10;
linspecerMap = linspecer(n);
boneMap = bone(n);
greyMap = gray(n);
whiteMap = white(n);
winterMap = winter(n);
hsvMap = hsv(n);
autumnMap = autumn(n);

xLabelName = 'x $[m]$';
yLabelName = 'y $[m]$';
titleString = 'Equipressure Contours in Velocity Field - $C_p$';
colorMapName = 'colorcube';
colorBarLabel = '$C_p$';
arrowColor = winterMap(10, :);
save_title_String = 'Equipressure Contours in Velocity Field_C_p';
saveString = sprintf('../Figures/%s', save_title_String);

xLimits = [-10, 10];
yLimits = [-3, 3];

shouldSaveFigures = true;
increaseQuality = true;

%% Plot Setup

set(0, 'defaulttextinterpreter', 'latex');
saveLocation = '';
LINEWIDTH = 7.5;
MARKERSIZE = 6;
FONTSIZE = 28;
colors = linspecer(6);
LINE_SCALE_DOWN = 0.8;
MARKER_SCALE_UP = 3;

%% Make Plot

% get plot from PDETools window
ax_handle = findall(0,'tag','PDEAxes');
fig_handle = figure('name', titleString);
copyobj(ax_handle,fig_handle);
set(allchild(fig_handle),'HandleVisibility','on');
delete(setdiff(findobj(0, 'type', 'figure'),...
               [ax_handle.Parent, fig_handle]))

% arrow colors
fig_handle.CurrentAxes.Children(1).Color = arrowColor;

scrz = get(groot, 'ScreenSize');
set(fig_handle, 'Position', scrz)

% plot formatting
colormap(colorMapName);
cBar = colorbar('southoutside', 'TickLabelInterpreter', 'latex');
cBar.Label.String = colorBarLabel;
cBar.Label.Interpreter = 'latex';


xlabel(xLabelName, 'interpreter', 'latex')
ylabel(yLabelName, 'interpreter', 'latex')
title(titleString, 'interpreter', 'latex')

set(gca, 'defaulttextinterpreter', 'latex')
set(gca, 'TickLabelInterpreter', 'latex')

ylim(yLimits)
xlim(xLimits)

h = gca;
leg = h.Legend;
titleStruct = h.Title;
set(titleStruct, 'FontWeight', 'bold')
set(gca, 'FontSize', FONTSIZE)


%% Save the figure

% setup plot saving
saveTitle = cat(2, saveLocation, sprintf('%s.pdf', saveString));

%export_fig(saveTitle)
saveMeSomeFigs(shouldSaveFigures, saveTitle, increaseQuality)

