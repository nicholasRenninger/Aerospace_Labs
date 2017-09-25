%function [result, ini_x, ini_y, h_initial ,slope, direction] = loop(h_initial, slope, direction, ini_x, ini_y, radius)

% slope is angle (deg) clockwise from horizontal
% direction is angle (deg) counter-clockwise from positive x-axis
ini_x = 0;
ini_y = 0;
slope = pi/5;
direction = pi/7;
h_initial = 100;
radius = 10;

pos(1,:) = [ini_x, ini_y, h_initial];

k = h_initial;
m = ini_x;
n = ini_y;

% k = h_initial+radius*sin(slope);
% m = ini_x+radius*cos(slope)*cos(direction);
% n = ini_y+radius*cos(slope)*sin(direction);
% pos(2,:) = [m n k];
%sqrt((ini_x-m)^2+(ini_y-n)^2+(h_initial-k)^2)

h0 = 125; % m
g = 9.81; % m/s^2
v0 = sqrt(2*g*(h0-h_initial));
slope_deg = slope/180*pi;
adj_slope = radius + radius*sin(-pi/2+slope_deg);
adj_slope_x = radius*cos(-pi/2+slope_deg);

t_length = radius*2*pi;
deg_per_l = 360/t_length;

precision = 0;
for i = 1:(360*10^precision+1)
    theta(i) = (i-1)/10^precision/180*pi-pi/2+slope_deg;
    h(i) = radius + h_initial + radius*sin(theta) - adj_slope;
    temp_x = radius*cos(theta(i));
    pos(i+1,:) = [m+temp_x*cos(direction)-adj_slope_x*cos(direction) n+temp_x*sin(direction)-adj_slope_x*sin(direction) h(i)];
    v(i) = sqrt(2*g*(h0-h(i)));
    a_t(i) = -g/sqrt(2*g*(h0-h(i)));
    a_n(i) = v(i)^2/radius-sin(theta);
end

result = zeros(floor(t_length)+1,5);
for j = 0:floor(t_length)
    result(j+1,1) = h(round(round(deg_per_l*j,2)*10^precision+1));
    result(j+1,2) = v(round(round(deg_per_l*j,2)*10^precision+1));
    result(j+1,3) = a_t(round(round(deg_per_l*j,2)*10^precision+1))/g;
    result(j+1,4) = a_n(round(round(deg_per_l*j,2)*10^precision+1))/g;
    result(j+1,5) = deg_per_l*j;
end

result(end+1,:) = result(1,:);
result(end,5) = 360;



% clear title xlabel ylabel
% figure
% plot(0:floor(t_length)+1,result(:,4))
% xlabel('Arclength (m)')
% ylabel('Normal acceleration (m/s^2)')
% title('Normal acceleration vs Arclength')

% new_k = k+radius*sin(slope);
% new_m = m+radius*cos(slope)*cos(direction);
% new_n = n+radius*cos(slope)*sin(direction);
% pos(length(pos)+1,:) = [new_m new_n new_k];

figure
hold on
% scatter3(pos(1:end-1,1),pos(1:end-1,2),pos(1:end-1,3),1,a_n)
plot3(pos(:,1),pos(:,2),pos(:,3))
plot3(m, n, k,'*' )

%end

%%%%%%%%%%%%%%%%
clear h v a_t a_n x y z h theta
r = radius;
syms s
h = h_initial + r - cos((1/r)*s)*r;
theta = acos((r-(h-h_initial))/r) + 2*floor(s/(t_length/2))*(-acos((r-(h-h_initial))/r)+pi) - pi/2 + slope;
v = sqrt(2*g*(h0-h));
a_t = -1/sqrt(2*g*(h0-h));
a_n = 2*(h0-h)/r;
x = ini_x+r*cos(theta)*cos(direction)-r*sin(slope)*cos(direction);
y = ini_y+r*sin(theta)*sin(direction)-r*sin(slope)*sin(direction);
z = h;

figure
hold on
ezplot3(x,y,z,[0 t_length])
plot3(ini_x, ini_y, h_initial, '*')

% m+temp_x*cos(direction)-adj_slope_x*cos(direction)
% n+temp_x*sin(direction)-adj_slope_x*sin(direction)
% h