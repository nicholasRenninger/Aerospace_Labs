clear all
close all
clc
PLOT_SAMPLES = 1000;

Temperature = zeros(1, PLOT_SAMPLES);
Pressure = zeros(1, PLOT_SAMPLES);
Air_Density = zeros(1, PLOT_SAMPLES);
gravity = zeros(1, PLOT_SAMPLES);

Balloon_Height = linspace(0, 35000, PLOT_SAMPLES);

[ Temperature, ~, Pressure, Air_Density] = atmoscoesa(Balloon_Height);

height = 35000;
index = find( Balloon_Height == height );

hold on
plot( Balloon_Height, Temperature )
figure
plot( Balloon_Height, Pressure )
figure
plot( Balloon_Height, Air_Density )
hold off

Pressure(index)
Temperature(index)
Air_Density(index)





