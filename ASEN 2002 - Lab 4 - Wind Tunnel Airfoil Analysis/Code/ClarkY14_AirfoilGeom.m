% Set the Coordinates and plot the geometry of the Clark Y14 Airfoil
% profile with the pressure port locations


%% Set the Clark Y14 Profile
% The Airfoil coordinates in % Chord
x = [100, 95, 90, 80, 70, 60, 50, 40, 30, 20, 15, 10, 7.5, 5, 2.5, 1.25, 0 1.25, 2.5, 5, 7.5 10, 15, 20, 30, 40, 50, 60, 70, 80, 90, 95, 100];
y = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0.04, 0.18, 0.5, 0.75, 1.11, 1.76, 2.31, 4.19, 6.52, 7.78, 9.45, 10.59, 11.48, 12.79, 13.6, 14, 13.64, 12.59, 10.95, 8.8, 6.25, 3.35, 1.78, 0.14];

c = 3.5; %Chord in Inches

% Scale the Profile for the chord length given
x_scaled = c*x/100;
y_scaled = c*y/100;

%% Set the Pressure Port Locations
% The Pressure Ports coordinates in % Chord
xpp = [0, 5, 10, 20, 30, 40, 50, 60, 70, 80, 80, 70, 60, 50, 40, 30, 20, 10, 5];
ypp = [4.19, 9.45, 11.48, 13.6, 14, 13.64, 12.58, 10.95, 8.8, 6.25, 0, 0, 0, 0, 0, 0, 0.04, 0.5, 1.11];

% Outline the pressure ports that are being skipped
xpp_skip = [70, 70, 50];
ypp_skip = [8.8, 0, 0];

% Scale the port locations for the chord length given
xpp_scaled = c*xpp/100;
ypp_scaled = c*ypp/100;
xpp_skipscaled = c*xpp_skip/100;
ypp_skipscaled = c*ypp_skip/100;

%% Plot the Airfoil Geometry

figure('Name','Clark Y-14 Airfoil Geometry','Position',[100, 100, 1600, 900])
plot(x_scaled, y_scaled, '-k')
hold all
plot(xpp_scaled, ypp_scaled, 'o','MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize',10);
plot(xpp_skipscaled,ypp_skipscaled,'x','MarkerEdgeColor','k','MarkerSize',20);
plot([3.5], [0], 'o','MarkerEdgeColor','k','MarkerFaceColor','b','MarkerSize',10);
axis equal
xlim([0 3.5]);
ylim([-0.5 1]);
grid on
xlabel('x [in]');
ylabel('y [in]');
title('Clark Y-14 Airfoil')
set(gca,'FontSize', 30)

