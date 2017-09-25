t_in = 23.5;
t_out = t_in + 2*pi;

r = 3;
x_in = 22.4;
y_in = 10.3;
z_in = 100;

% make parametrization
syms t 
xt = r * sin(t - t_in) + x_in;
yt = @(t) y_in;
zt = r * cos(t - t_in) + z_in + r;

fplot3(xt, yt, zt, [t_in, t_out])