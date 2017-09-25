%% Housekeeping
clc
clear


%% User Vars

xLabelName = 'x $[m]$';
yLabelName = 'y $[m]$';
zLabelName = '$-C_p$';
titleString = '3D $C_p$ Distribution in the Channel';
colorMapName = 'jet';
save_title_String = '3_d_C_p';
saveString = sprintf('../Figures/%s', save_title_String);

xLimits = [-10, 10];
yLimits = [-3, 3];
zLimits = [-inf, inf];

shouldSaveFigures = true;
increaseQuality = true;

%% Plot Setup

set(0, 'defaulttextinterpreter', 'latex');
saveLocation = '';
LINEWIDTH = 7.5;
MARKERSIZE = 6;
FONTSIZE = 28;
LINE_SCALE_DOWN = 0.8;
MARKER_SCALE_UP = 3;


%% Make Plot
   
fig_handle = gcf;
axes_handle = gca;

scrz = get(groot, 'ScreenSize');
set(fig_handle, 'Position', scrz)

% plot formatting
colormap(colorMapName);

xlabel(xLabelName, 'interpreter', 'latex')
ylabel(yLabelName, 'interpreter', 'latex')
zlabel(zLabelName, 'interpreter', 'latex')
title(titleString, 'interpreter', 'latex')

set(gca, 'defaulttextinterpreter', 'latex')
set(gca, 'TickLabelInterpreter', 'latex')

ylim(yLimits)
xlim(xLimits)
zlim(zLimits)

axes_handle.DataAspectRatioMode = 'manual';
axes_handle.DataAspectRatio = [1 1 axes_handle.DataAspectRatio(3)];

h = gca;
leg = h.Legend;
titleStruct = h.Title;
set(titleStruct, 'FontWeight', 'bold')
set(gca, 'FontSize', FONTSIZE)

if ~isempty( findobj( fig_handle.Children, 'Tag', 'Colorbar' ) )
    
    delete( findobj( fig_handle.Children, 'Tag', 'Colorbar' ) )
    
end

axes_handle.CameraPosition = [-54.4911 -86.1971 176.8887];
axes_handle.CameraViewAngle = 10.7152;

%% Save the figure

% setup plot saving
saveTitle = cat(2, saveLocation, sprintf('%s.pdf', saveString));

%export_fig(saveTitle)
saveMeSomeFigs(shouldSaveFigures, saveTitle, increaseQuality)

