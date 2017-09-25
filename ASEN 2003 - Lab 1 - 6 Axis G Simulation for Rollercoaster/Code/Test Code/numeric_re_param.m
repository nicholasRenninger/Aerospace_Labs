clear variables
close all
clc

%% t parameterizes the space curve
u = 0.01; t0 = 0; t_final = 2*pi + u;
t = t0:u:t_final;
a = 4;
r = 2;
h_init = 125; 
s_init = 0; 
g = 9.81; 
helix_ht = 10;

% This is the cartesian version of curve
% x = r * sin(a * t); 
% y = r * cos(a * t);
% z = -helix_ht * t / t_final + h_init;

x = 0 .* t; 
y = ones(1, length(t)) * 5;
z = -t + h_init;

%% find arc length of curve
dx_t = derivative(x);
dy_t = derivative(y);
dz_t = derivative(z);
speed_t = sqrt(2 * g * (h_init - z));
s = cumtrapz( sqrt(dx_t.^2 + dy_t.^2 + dz_t.^2 ) ) + s_init;

%% Numerically finding t(s)
X = s.';
V = [ t.', x.', y.', z.'];

% Making linearly spaced arc length vector
L = s(end);
s0 = s(1);
num_pts = length(s);
Xq = linspace(s0, L, num_pts); % equally spaced arc length steps

Vq = interp1(X, V, Xq, 'spline'); 

ts = Vq(:, 1); % time param at each of the 
xs = Vq(:, 2);
ys = Vq(:, 3);
zs = Vq(:, 4);

%% TNB Frame

r1_vec(:, 1) = x;
r1_vec(:, 2) = y;
r1_vec(:, 3) = z;

% T vector
vt = derivative(r1_vec) ;
T = vt ./ norm(vt);

% N vector
T_prime = derivative(T);
N = T_prime ./ norm(T_prime);

% B vector
B = cross(N, T) ./ norm(cross(N, T));


%%% Subbing in t = f(s) to get T, N, B components of acceleration as
%%% functions of s.
at = derivative(vt);

% find component of acceleration in the direction of TNB as fcns of t
[A_T_t, A_N_t, A_B_t] = deal(zeros(num_pts, 1));
for i = 1:num_pts
    
    A_T_t(i, :) = dot(at(i, :), T(i, :));
    A_N_t(i, :) = dot(at(i, :), N(i, :));
    A_B_t(i, :) = dot(at(i, :), B(i, :));

end

%%% Find TNB Acceleration as a fcn of arc length (s)
X = s.';
V_A = [ t.', A_T_t, A_N_t, A_B_t];


Vq = interp1(X, V_A, Xq, 'spline'); 

ts = Vq(:, 1); % time param at each of the 
xs = Vq(:, 2);
ys = Vq(:, 3);
zs = Vq(:, 4);


%% Verify and Plot

% verify that curve parameterized by constant arc length steps is same as
% the xs, ys, and zs vectors
x_ts = r * sin(a * ts); 
y_ts = r * cos(a * ts);
z_ts = -helix_ht * ts / t_final + h_init;


% Plotting Track Path
path_plot = figure('Name', 'Track Path');
hold on

plot3(x, y, z, 'r')
figure(path_plot)
%plot3(xs, ys, zs, 'sq')
%figure(path_plot)
plot3(x_ts, y_ts, z_ts, 'o')
figure(path_plot)
scatter3(x(1), y(1), z(1), 50, 'filled')
figure(path_plot)


%%% Draw TNB arrows %%%
t_test = floor(num_pts / 2);
start = r1_vec(t_test, :);
scale = 10;

% T
stop_T = T(t_test, :) * scale + start;
arrow(start, stop_T, 'EdgeColor', 'g', 'FaceColor', 'g');

% N
figure(path_plot)
stop_N = N(t_test, :) * scale + start;
arrow(start, stop_N, 'EdgeColor', 'r', 'FaceColor', 'r');

% B 
figure(path_plot)
stop_B =  B(t_test, :) * scale^1.4 + start;
arrow(start, stop_B, 'EdgeColor', 'b', 'FaceColor', 'b');

%%% set the aspect ratio to see the TNB vectors correctly %%%
set(gca,'DataAspectRatioMode','manual')
set(gca,'PlotBoxAspectRatioMode','manual')
set(gca,'DataAspectRatio',[1 1 1])
set(gca,'PlotBoxAspectRatio',[1 1 1])


%%% Plot g-forces
g_plot = figure('Name', 'G-Force Plot');
%plot()